-- Wiki 風格 Markdown 檔案自動模板
-- 當在含有 .iswiki 標記檔的目錄中建立新的 .md 檔案時，自動插入 frontmatter 和標題

local vim = vim

vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.md",
  callback = function()
    -- 檢查當前目錄是否有 .iswiki 檔案，且尚未插入過模板
    if vim.fn.filereadable ".iswiki" == 1 and not vim.b.inserted then
      vim.b.inserted = true -- 標記已插入，避免重複執行

      -- 從檔名取得標題（不含副檔名）
      local filename = vim.fn.expand "%:t:r"
      -- 將底線轉換為空格，作為顯示用標題
      local title = filename:gsub("_", " ")
      -- 取得今天的日期
      local date = os.date "%Y-%m-%d"
      -- 取得前一個檔案的連結（用於建立反向連結）
      local previous = vim.g.previous or ""

      -- 建立 YAML frontmatter 和內容模板
      local lines = {
        "---",
        "title: '" .. title .. "'",
        'date: "' .. date .. '"',
        "---",
        "",
        "> [!info]",
        ">",
        "> 🌱 來自: [[" .. previous .. "]]", -- Obsidian 風格的 wiki 連結
        "",
        "# " .. filename,
      }

      -- 在緩衝區開頭插入模板
      vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)
    end
  end,
})
