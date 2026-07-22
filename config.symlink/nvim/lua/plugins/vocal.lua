-- vocal.nvim — 語音錄音 → 轉錄插入游標處
-- 原插件寫死走 OpenAI（api.openai.com + 金鑰須 sk- 開頭），這裡改掛 Groq
-- 的 whisper-large-v3。Groq 的 /audio/transcriptions 端點與 OpenAI 完全相容，
-- 差別只在 base URL 與金鑰前綴（gsk_），所以攔截 `vocal.api.transcribe`
-- 改用 curl 直打 Groq，即可保留插件其餘錄音/UI/緩衝區邏輯。
--
-- 依賴：sox（錄音，已裝）、curl（轉錄，系統內建）、plenary.nvim
-- 金鑰：GROQ_API（放在 ~/.dotfiles/.env，會被 zshrc 注入互動 shell）

-- Groq 語音端點設定（要換模型/端點只改這裡）
local GROQ_ENDPOINT = "https://api.groq.com/openai/v1/audio/transcriptions"
local GROQ_MODEL = "whisper-large-v3"

-- 轉錄後的「消除冗言」後處理：Whisper 只會逐字轉錄，prompt 也無法去掉口語贅字
-- （嗯、那個、就是…），所以再打一次 Groq chat 讓 LLM 清理。要關掉把 CLEANUP_ENABLED 設 false。
local GROQ_CHAT_ENDPOINT = "https://api.groq.com/openai/v1/chat/completions"
local CLEANUP_ENABLED = true
local CLEANUP_MODEL = "llama-3.1-8b-instant" -- 快又便宜，清贅字綽綽有餘
local CLEANUP_SYSTEM = "你是逐字稿編輯。移除口語贅字與語助詞（嗯、啊、呃、那個、就是、然後那個、"
  .. "重複詞、口吃），保留原意與所有實質內容，不要新增或臆測資訊。保持原文語言；"
  .. "若內容為中文，輸出通順的台灣繁體中文。只輸出清理後的文字，不要加任何說明、標題或引號。"

-- 讀取 Groq 金鑰：優先環境變數，GUI 啟動的 nvim 沒繼承 shell 時再讀 .env
local function read_groq_key()
  local key = os.getenv("GROQ_API")
  if key and key ~= "" then
    return key
  end
  local f = io.open(vim.fn.expand("~/.dotfiles/.env"), "r")
  if not f then
    return nil
  end
  local found
  for line in f:lines() do
    local v = line:match("^%s*GROQ_API%s*=%s*(.+)$")
    if v then
      found = v:gsub("^[\"']", ""):gsub("[\"']%s*$", ""):gsub("%s+$", "")
      break
    end
  end
  f:close()
  return found
end

-- 消除冗言後處理：把逐字稿丟給 Groq chat 清掉贅字，完成後呼叫 on_done(清理後文字)。
-- 任何失敗都退回原始逐字稿，確保絕不因清理而弄丟轉錄結果。
local function cleanup_text(api_key, text, on_done)
  local ok_body, body = pcall(vim.json.encode, {
    model = CLEANUP_MODEL,
    temperature = 0,
    messages = {
      { role = "system", content = CLEANUP_SYSTEM },
      { role = "user", content = text },
    },
  })
  if not ok_body then
    return on_done(text)
  end
  require("plenary.job")
    :new({
      command = "curl",
      args = {
        "-s",
        "--max-time",
        "60",
        "-X",
        "POST",
        GROQ_CHAT_ENDPOINT,
        "-H",
        "Authorization: Bearer " .. api_key,
        "-H",
        "Content-Type: application/json",
        "-d",
        body,
      },
      on_exit = vim.schedule_wrap(function(j, code)
        local ok = pcall(function()
          if code ~= 0 then
            return on_done(text)
          end
          local raw = table.concat(j:result() or {}, "\n")
          local dok, decoded = pcall(vim.json.decode, raw)
          local content = dok
            and type(decoded) == "table"
            and decoded.choices
            and decoded.choices[1]
            and decoded.choices[1].message
            and decoded.choices[1].message.content
          if type(content) == "string" and content:gsub("%s", "") ~= "" then
            return on_done(content)
          end
          require("vocal.api").debug_log("[groq] cleanup 回應非預期，退回原始逐字稿：" .. raw:sub(1, 200))
          return on_done(text)
        end)
        if not ok then
          on_done(text)
        end
      end),
    })
    :start()
end

-- curl 版轉錄：直打 Groq，跳過原插件的 sk- 前綴驗證與 OpenAI python uploader。
-- 介面與 vocal.api.transcribe 一致：(filename, api_key, on_success, on_error)
local function groq_transcribe(filename, api_key, on_success, on_error)
  local api = require("vocal.api")
  local opts = api.options or {}
  local response_format = opts.response_format or "json"

  if not api_key or api_key == "" then
    return on_error("找不到 GROQ_API 金鑰（請確認 ~/.dotfiles/.env 有設）")
  end
  if not filename or vim.fn.filereadable(filename) ~= 1 then
    return on_error("音檔不存在或無法讀取：" .. tostring(filename))
  end

  local Job = require("plenary.job")

  -- 實際上傳到 Groq（upload_path = 要送的檔；cleanup_path = 送完要刪的暫存檔）
  local function upload(upload_path, cleanup_path)
    local args = {
      "-s",
      "--max-time",
      tostring(opts.timeout or 300),
      "-X",
      "POST",
      GROQ_ENDPOINT,
      "-H",
      "Authorization: Bearer " .. api_key,
      "-F",
      "file=@" .. upload_path,
      "-F",
      "model=" .. (opts.model or GROQ_MODEL),
      "-F",
      "response_format=" .. response_format,
      "-F",
      "temperature=" .. tostring(opts.temperature or 0),
    }
    if opts.language and opts.language ~= "" then
      table.insert(args, "-F")
      table.insert(args, "language=" .. opts.language)
    end
    -- prompt：偏置轉錄風格（這裡用來把中文導向繁體），vocal 原生沒有此欄位
    if opts.prompt and opts.prompt ~= "" then
      table.insert(args, "-F")
      table.insert(args, "prompt=" .. opts.prompt)
    end

    Job:new({
      command = "curl",
      args = args,
      on_exit = vim.schedule_wrap(function(j, code)
        if cleanup_path then
          pcall(os.remove, cleanup_path)
        end
        -- 全程 pcall 保護：任何意外都轉成 on_error，不讓它變成裸 Lua 錯誤
        local guarded_ok, guarded_err = pcall(function()
          local body = table.concat(j:result() or {}, "\n")
          local stderr = table.concat(j:stderr_result() or {}, "\n")
          api.debug_log(
            string.format(
              "[groq] curl exit code=%s, body_len=%d, body_head=%s, stderr=%s",
              tostring(code),
              #body,
              body:sub(1, 200),
              stderr:sub(1, 200)
            )
          )
          if code ~= 0 then
            return on_error(string.format("curl 失敗（code %d）：%s", code, stderr))
          end
          -- response_format = "text" 直接回純文字
          if response_format == "text" then
            if body ~= "" then
              return on_success(body)
            end
            return on_error("Groq 回傳空內容")
          end
          if body == "" then
            return on_error("Groq 回傳空內容（HTTP 可能非 200，開 debug 看 log）")
          end
          local ok, decoded = pcall(vim.json.decode, body)
          if ok and type(decoded) == "table" then
            if decoded.error then
              local msg = type(decoded.error) == "table"
                  and (decoded.error.message or vim.inspect(decoded.error))
                or tostring(decoded.error)
              return on_error("Groq API 錯誤：" .. msg)
            elseif decoded.text ~= nil then
              local text = decoded.text
              -- 有內容才做「消除冗言」；空白/純靜音不必多打一次 API
              if
                CLEANUP_ENABLED
                and type(text) == "string"
                and text:gsub("%s", "") ~= ""
              then
                return cleanup_text(api_key, text, on_success)
              end
              return on_success(text)
            end
          end
          return on_error("Groq 回應格式非預期：" .. body:sub(1, 300))
        end)
        if not guarded_ok then
          on_error("Groq 轉錄回呼發生例外：" .. tostring(guarded_err))
        end
      end),
    }):start()
  end

  -- 錄音被硬停時 sox 來不及回寫 WAV header（宣告超大 data size / 資料半殘），
  -- Groq 解碼會直接回 "unexpected EOF"。上傳前先用 sox 重編碼成乾淨 16k mono：
  -- sox 容忍 premature EOF，會讀出可用音訊並寫出正規 WAV，順便縮小上傳體積。
  -- sox 本就是錄音的必備依賴，不新增依賴。
  local clean_path = filename .. ".groq16k.wav"
  Job:new({
    command = "sox",
    args = { filename, "-c", "1", "-r", "16000", clean_path },
    on_exit = vim.schedule_wrap(function(_, scode)
      if vim.fn.filereadable(clean_path) == 1 and (vim.fn.getfsize(clean_path) or 0) > 44 then
        api.debug_log(
          string.format(
            "[groq] sox 重編碼 ok (code=%s) -> %d bytes",
            tostring(scode),
            vim.fn.getfsize(clean_path)
          )
        )
        upload(clean_path, clean_path)
      else
        api.debug_log(
          string.format("[groq] sox 重編碼無可用輸出 (code=%s)，改上傳原檔", tostring(scode))
        )
        upload(filename, nil)
      end
    end),
  }):start()
end

return {
  "kyzabuilds/vocal.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = "Vocal",
  keys = {
    -- 避開 venv 的 <leader>v 前綴（vs/vc）；rv = record voice
    { "<leader>rv", "<cmd>Vocal<cr>", desc = "Vocal：錄音並用 Groq 轉錄" },
  },
  config = function()
    -- 攔截點：把雲端轉錄改成打 Groq（在 setup 前後皆可，執行期才會被呼叫）
    require("vocal.api").transcribe = groq_transcribe

    require("vocal").setup({
      -- 金鑰直接解析好傳入；nil 時原插件會去讀 OPENAI_API_KEY（非我們要的）
      api_key = read_groq_key(),
      recording_dir = vim.fn.expand("~/recordings"),
      delete_recordings = true,
      -- 用上面 keys 的懶載入綁定（<leader>rv），關掉插件內建的 <leader>v 以免衝突
      keymap = false,
      api = {
        model = GROQ_MODEL,
        -- Whisper 的 language 只吃 ISO-639-1 的 "zh"，不分繁簡；預設會轉「簡體」。
        language = "zh",
        -- 靠繁體 prompt 把輸出風格導向繁體中文（實測可把簡體翻成繁體）。
        -- prompt 是 vocal 原生沒有、由我們的 override 額外送給 Groq 的欄位。
        prompt = "以下是繁體中文的內容。",
        response_format = "json",
        temperature = 0,
        timeout = 300,
      },
    })
  end,
}
