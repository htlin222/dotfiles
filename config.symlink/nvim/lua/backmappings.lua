local vim = vim
local M = {} -- 先產生一個空的table
M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } }, -- 把; 指定為:
    -- ["x"] = { "x", "to black hole", opts = { nowait = true } }, -- 把; 指定為:
    ["c"] = { '"_c', "to black hole", opts = { nowait = true } }, -- 把; 指定為:
    ["+"] = { "<C-a>", "decrase number", opts = { nowait = true } }, -- 把; 指定為:
    ["x"] = { '"_x', "do not yank x when x", opts = { nowait = true } }, -- 把; 指定為:
    ["_"] = { "<C-x>", "increase number", opts = { nowait = true } }, -- 把; 指定為:
    ["dd"] = {
      function()
        if vim.fn.getline "." == "" then
          return '"_dd'
        end
        return "dd"
      end,
      "don't save empty line to register if is empty line",
      opts = { expr = true },
    }, -- 把; 指定為:
    -- ["<leader><CR>"] = { "i<CR><ESC>", "break line" },
    ["<leader><CR>"] = {
      ":silent lua AppendCurrentLine()<CR>",
      "Code Complete",
      opts = { nowait = true, silent = true },
    },
    ["<leader>o"] = { "<cmd>lua Open_with_default_app()<CR>", "Open by default app" },
    -- ["<leader>mp"] = { ":MarkdownPreview<CR>", "MarkdownPreview", opts = { nowait = true, silent = true } },
    ["yij"] = { "yi[", "same as i[", opts = { nowait = true } },
    ["yik"] = { "yi{", "same as i{", opts = { nowait = true } },
    ["yih"] = { "yi<", "same as i<", opts = { nowait = true } },
    ["yim"] = { "yi'", "same as i'", opts = { nowait = true } },
    ["yi,"] = { 'yi"', 'same as i"', opts = { nowait = true } },
    ["yaj"] = { "ya[", "same as a[", opts = { nowait = true } },
    ["yak"] = { "ya{", "same as a{", opts = { nowait = true } },
    ["yah"] = { "ya<", "same as a<", opts = { nowait = true } },
    ["yam"] = { "ya'", "same as a'", opts = { nowait = true } },
    ["ya,"] = { 'ya"', 'same as a"', opts = { nowait = true } },
    ["<C-p>"] = {
      function()
        os.execute "cliptoimgur"
        vim.cmd "put"
      end,
      "uploade image to imgur",
      opts = { nowait = true, silent = true },
    },
    ["<leader>cc"] = { "<cmd>ChatGPT<CR>", "ChatGPT", opts = { nowait = true } },
    ["<leader>co"] = {
      "<cmd>lua Copy_outline_to_clipboard()<CR>",
      "Copy_outline_to_clipboard",
      opts = { nowait = true },
    },
    ["<leader>jl"] = {
      ":setlocal spell spelllang=en_us<CR>",
      "Spell Check",
      opts = { nowait = true, silent = true },
    },
    ["<leader>i"] = {
      function()
        vim.cmd "startinsert"
        os.execute "im-select com.boshiamy.inputmethod.BoshiamyIMK"
        -- brew tap daipeihust/tap
        -- brew install im-select
        print "切換為嘸蝦米輸入法！"
      end,
      "when go into the insert mode, switch to boshiamy.inputmethod",
      opts = { nowait = true, silent = true },
    },
    ["<C-c>"] = { "<ESC>", "Map Ctrl + C to True Esc" },
    ["<C-s>"] = { ":SymbolsOutline<CR>", "Outline", opts = { nowait = true, silent = true } },
    ["<leader>qa"] = { ":qa<CR>", "quit", opts = { nowait = true, silent = true } },
    ["<leader>ll"] = { "za", "Foldings", opts = { nowait = true, silent = true } },
    ["<Esc>"] = { ":", "enter command mode", opts = { nowait = true } },
    ["<Down>"] = { ":tabnext<CR>", "Next tab", opts = { nowait = true, silent = true } },
    ["<Up>"] = { ":tabprevious<CR>", "Previous Tab", opts = { nowait = true, silent = true } },
    ["<leader><tab>"] = { ":tab sb %<CR>", "current file to a new tab", opts = { nowait = true, silent = true } },
    -- ["<leader><leader>"] = { "ciw", "Change and edit", opts = { nowait = true, silent = true } },
    ["<leader>mk"] = {
      ":mksession! ./.vim_auto_session.vim<CR>:echo '已保存目前的工進度 💼 '<CR>",
      "save session to .vim_auto_session",
      opts = { nowait = true, silent = true },
    },
    ["<leader>q"] = { ":q<CR>", "quit", opts = { nowait = true, silent = true } },
    ["<leader>ta"] = { ":tabnew<CR>", "New Tab", opts = { nowait = true, silent = true } },
    ["<leader>tb"] = { ":Telescope bibtex<CR>", "add citation", opts = { nowait = true } },
    ["<leader>te"] = { ":Telescope symbols<CR>", "emoji", opts = { nowait = true } },
    ["<leader>tt"] = { ":Template ", "Insert template", opts = { nowait = true } },
    ["<leader>w"] = { ":w ++p ++bad=drop<CR>", "save", opts = { nowait = true, silent = true } },
    ["?"] = { ":noh<CR>", "enter command mode", opts = { nowait = true, silent = true } },
    ["H"] = { "^", "begining of line", opts = { nowait = true } },
    ["L"] = { "$", "go to end of line", opts = { nowait = true } },
    ["<C-o>"] = { -- open url under cursor
      function()
        local pattern = "^(zotero|skim)"
        local currentWord = vim.fn.expand "<cWORD>"
        if string.match(currentWord, pattern) then
          vim.cmd("!open " .. currentWord)
        end
      end,
      "check and open",
      opts = { noremap = true, silent = true },
    },
    ["<Right>"] = {
      function()
        require("nvchad.tabufline").tabuflineNext()
      end,
      "Goto next buffer",
    },
    ["<Left>"] = {
      function()
        require("nvchad.tabufline").tabuflinePrev()
      end,
      "Goto prev buffer",
    },
    ["<CR>"] = {
      function()
        if vim.api.nvim_buf_get_option(0, "buftype") == "nofile" then
          vim.api.nvim_set_keymap("n", "<CR>", "<CR>", { noremap = true, silent = true })
        else
          vim.api.nvim_set_keymap("n", "<CR>", "za", { noremap = true, silent = true })
        end
      end,
    },
  },
  i = {
    ["<C-c>"] = { "<ESC>", "Map Ctrl + C to True Esc" },
    ["<C-\\>"] = { "<ESC>", "Map Ctrl + C to True Esc" },
  },
  v = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
    ["<leader>ga"] = { ":'<,'>!aicomp<cr>", "Aider Append", opts = { nowait = true } },
    ["p"] = { '"_dP', "paste but don't overwrite the clipboard", opts = { nowait = true } },
    ["H"] = { "^", "begining of line", opts = { nowait = true } },
    ["ij"] = { "i[", "same as i[", opts = { nowait = true } },
    ["ik"] = { "i{", "same as i{", opts = { nowait = true } },
    ["ih"] = { "i<", "same as i<", opts = { nowait = true } },
    ["im"] = { "i'", "same as i'", opts = { nowait = true } },
    ["i,"] = { 'i"', 'same as i"', opts = { nowait = true } },
    ["aj"] = { "a[", "same as a[", opts = { nowait = true } },
    ["ak"] = { "a{", "same as a{", opts = { nowait = true } },
    ["ah"] = { "a<", "same as a<", opts = { nowait = true } },
    ["am"] = { "a'", "same as a'", opts = { nowait = true } },
    ["<"] = { "<gv", "indent right", opts = { nowait = true } },
    [">"] = { ">gv", "indent left", opts = { nowait = true } },
    ["a,"] = { 'a"', 'same as a"', opts = { nowait = true } },
    ["L"] = { "$h", "go to end of line", opts = { nowait = true } },
    ["J"] = { ":m '>+1<CR>gv=gv", "move the selection down", opts = { nowait = true } },
    ["K"] = { ":m '<-2<CR>gv=gv", "move the selection up", opts = { nowait = true } },
    -- autocmd BufWritePre ~/Documents/Medical/*.md execute "s/\.\s\([A-Z]\)/.\r- \1/g"
  },
}
M.lspsaga = {
  plugin = true,
  n = {
    ["<leader>ft"] = { "<cmd>Lspsaga term_toggle<CR>", "float term", opts = { nowait = true } },
    ["<leader>T"] = { "<cmd>Lspsaga term_toggle<CR>", "float term", opts = { nowait = true } },
    ["<leader>ca"] = { ":Lspsaga code_action<cr>", "Code Action", opts = { nowait = true } },
    -- ["<leader>cn"] = { "<cmd>Lspsaga code_action<CR>", "code_action", opts = { nowait = true } },
    ["<leader>dx"] = {
      "<cmd>Lspsaga diagnostic_jump_next<CR>",
      "Lspsaga diagnostic_jump_next",
      opts = { nowait = true },
    },
    ["<leader>lo"] = { "<cmd>Lspsaga outline<CR>", "Lspsaga outline", opts = { nowait = true } },
    ["<leader>se"] = { "<cmd>Lspsaga rename<CR>", "rename", opts = { nowait = true } },
  },
  v = {
    ["<leader>se"] = { "<cmd>Lspsaga rename<CR>", "rename", opts = { nowait = true } },
  },
}

M.mkdn = {
  plugin = true,
  n = {
    ["<leader>ww"] = {
      function()
        local file_name = vim.fn.expand "%:t:r"
        local formatted_file_name = file_name .. ".md"
        print(formatted_file_name)
        print "輸出成A4檔⌛"
        local cmd = string.format('to_a4.sh "%s" > /dev/null 2>&1 &', formatted_file_name)
        -- local cmd = string.format('to_a4.sh "%s"', formatted_file_name)
        os.execute(cmd)
        print "完成😊"
      end,
      "save to a4 in tmp",
      opts = { silent = false },
    },
    ["<leader>yy"] = { -- 👉 [[wiwki link]]
      function()
        local file_name = vim.fn.expand "%:t:r"
        local formatted_file_name = "[[" .. file_name .. "]]"
        vim.fn.setreg("+", formatted_file_name, "y")
        print(formatted_file_name)
      end,
      "Yank Filename as wikilink",
      opts = { silent = false },
    },
    ["<leader>pp"] = { -- 👉 [[paste as wiwki link]]
      function()
        -- 獲取當前暫存器（"）的內容
        local content = vim.fn.getreg '"'
        -- 在內容前後新增雙方括號
        local content = content:gsub("%c", "")
        local bracketedContent = "[[" .. content .. "]]"
        -- 使用 `vim.api.nvim_put()` 函數粘貼處理過的內容
        -- 第一個參數是一個包含要粘貼行的表（在這裡，我們的內容被視為一行）
        -- 第二個參數是模式，"c" 表示字元模式
        -- 第三個參數是是否要在粘貼後模擬按下 Enter 鍵，false 表示不模擬
        -- 第四個參數是是否要使用暫存器的內容，true 表示使用
        vim.api.nvim_put({ bracketedContent }, "c", false, true)
      end,
      "PasteWithBracketed",
      opts = { silent = false },
    },
    ["<leader>wf"] = { -- of this file
      function()
        local win = vim.api.nvim_get_current_win()
        local buf = vim.api.nvim_get_current_buf()
        local line = vim.api.nvim_win_get_cursor(win)[1]
        local line_length = string.len(vim.api.nvim_buf_get_lines(buf, line - 1, line, false)[1])

        -- 移動到行尾
        vim.api.nvim_win_set_cursor(win, { line, line_length })
        local file_name = vim.fn.expand "%:t:r"
        local formatted_file_name = "-of-" .. file_name
        vim.fn.setreg("+", file_name, "y")
        vim.api.nvim_put({ formatted_file_name }, "c", true, true)
        print(formatted_file_name)
      end,
      "create text: of this file",
      opts = { silent = false },
    },
    ["<leader>yp"] = { --split the line
      ":call InsertFilenameFromQueue()<CR>",
      "Insert Filename FromQueue",
      opts = { nowait = true, silent = true },
    },
    ["<leader>1"] = {
      function()
        local current_line = vim.api.nvim_get_current_line()
        local new_line = "# " .. current_line
        vim.api.nvim_set_current_line(new_line)
      end,
      "add level 2",
      opts = { silent = false },
    },
    ["<leader>a"] = {
      function()
        local current_line = vim.api.nvim_get_current_line()
        local new_line = "## " .. current_line
        vim.api.nvim_set_current_line(new_line)
      end,
      "add level 2",
      opts = { silent = false },
    },
    ["<leader>3"] = {
      function()
        local current_line = vim.api.nvim_get_current_line()
        local new_line = "### " .. current_line
        vim.api.nvim_set_current_line(new_line)
      end,
      "add level 1",
      opts = { silent = false },
    },
    ["<leader>mh"] = { -- of this file
      function()
        -- 獲取當前行和光標位置
        local line = vim.fn.getline "."
        local col = vim.fn.col "."

        -- 尋找被雙重方括號包圍的文字
        local before_cursor = line:sub(1, col - 1)
        local after_cursor = line:sub(col)
        local start_pos = before_cursor:find "%[%[.-%]$"
        local end_pos = after_cursor:find "^%].-%]%]"

        if start_pos and end_pos then
          local word = line:sub(start_pos, col + end_pos - 2)
          word = word:sub(3, -3) -- 移除方括號

          -- 搜尋當前目錄（./）下是否有匹配的檔案
          local handle = io.popen('find ./ -name "' .. word .. '.md"')
          local result = handle:read "*a"
          handle:close()

          if result ~= "" then
            -- 找到了匹配的檔案，讀取第13行到第23行
            local file_path = result:gsub("\n", "")
            local lines = {}
            local i = 1
            for line in io.lines(file_path) do
              if i >= 13 and i <= 23 then
                table.insert(lines, line)
              end
              i = i + 1
            end

            -- 使用 buf hover 彈出窗口顯示這些行
            local content = table.concat(lines, "\n")
            vim.lsp.util.open_floating_preview({ content }, "markdown")
          else
            -- 沒有找到匹配的檔案
            vim.api.nvim_out_write "No preview allowed\n"
          end
        else
          -- 文字不是由雙重方括號包圍的
          vim.api.nvim_out_write "No preview allowed\n"
        end
      end,
      "create text: of this file",
      opts = { silent = false },
    },
    ["<leader>mo"] = { -- of this file
      function()
        local win = vim.api.nvim_get_current_win()
        local buf = vim.api.nvim_get_current_buf()
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local file_name = vim.fn.expand "%:t:r"
        local formatted_file_name = "-of-" .. file_name

        for i, line in ipairs(lines) do
          if line:match "^## " then
            local current_line = vim.api.nvim_buf_get_lines(buf, i - 1, i, false)[1]
            local trimmed_line = current_line:gsub("%s+$", "") -- 移除行尾的空白
            local line_length = string.len(trimmed_line)

            -- 檢查該行的末尾是否已經包含格式化後的文件名
            if trimmed_line:sub(-#formatted_file_name) ~= formatted_file_name then
              -- 移動到行尾並設置修剪後的行
              vim.api.nvim_buf_set_lines(buf, i - 1, i, false, { trimmed_line })
              vim.api.nvim_win_set_cursor(win, { i, line_length })

              -- 將文件名添加到該行的末尾
              vim.fn.setreg("+", file_name, "y")
              vim.api.nvim_put({ formatted_file_name }, "c", true, true)
              vim.cmd "echohl Identifier"
              vim.cmd "echomsg '🐉所有的二級標題後面都有檔名了'"
              vim.cmd "echohl None"
            end
          end
        end
      end,
      "create text: of this file",
      opts = { silent = false },
    },
    ["<CR>"] = {
      function()
        if vim.bo.filetype == "markdown" then
          local currentLine = vim.fn.getline "."
          local url = string.match(currentLine, "%(([^%)]+)%)")
          if url and (url:find "^zotero" or url:find "^skim" or url:find "^raycast") then
            vim.cmd("!open " .. vim.fn.fnameescape(url))
          else
            vim.cmd "MkdnEnter"
          end
        else
          vim.fn.search "___" -- 使用 vim.fn.search 尋找下一個匹配項
          vim.cmd "echomsg '下一個空白'"
        end
      end,
      "Follow Link",
    },
    ["<leader><leader>"] = {
      function()
        if vim.bo.filetype == "markdown" then
          vim.fn.search "___"
          vim.cmd "echomsg '下一個空白'"
        end
      end,
      "Follow Link",
    },

    ["<leader>ii"] = {
      "ca<",
      "edit the <>",
    },
    ["<leader>mz"] = { --split the line
      function()
        vim.cmd "write"
        local file_name = vim.fn.expand "%:p"
        local snippets_path = "~/.dotfiles/neovim/vscode_snippets/garden.json"
        local cmd = string.format("python ~/pyscripts/add_snippets.py '%s' '%s'", file_name, snippets_path)
        vim.fn.system(cmd)
        vim.cmd "echohl Identifier"
        vim.cmd "echomsg '加入片語'"
        vim.cmd "echohl None"
      end,
      "Add snippets filename",
      opts = { nowait = true, silent = false },
    },
    ["<leader>s."] = { --split the line
      ":silent! call SubstitutionForCurrentLine()<CR>",
      "split line",
      opts = { nowait = true, silent = true },
    },
    ["<leader>mn"] = { --split the line
      ":call WithAnkiTagThenSentToSimplenote()<CR>",
      "Sent To Simplenote with anki tag",
      opts = { nowait = true, silent = true },
    },
    ["<leader>re"] = { --split the line
      ":Recent<CR>",
      "renew Medial/recent.md",
      opts = { nowait = true, silent = true },
    },
    ["<leader>s,"] = { --split the line
      ":silent! call SubstitutionForCurrentLineComma()<CR>",
      "split line by comma",
      opts = { nowait = true, silent = true },
    },
    ["<leader>sc"] = { --split the line
      ":silent! call SubstitutionForCurrentChineseComma()<CR>",
      "split line by chinese comma",
      opts = { nowait = true, silent = true },
    },
    ["<leader>rr"] = { --split the line
      ":silent! call AddPrefix()<CR>",
      "Add Prefix",
      opts = { nowait = true, silent = true },
    },
    ["<leader>;"] = { --split the line
      ":silent! call SubstitutionForCurrentLineSemiColon()<CR>",
      "split line by semicolon",
      opts = { nowait = true, silent = true },
    },
    ["<leader>mr"] = { --split the line
      ":call Recruit()<CR>",
      "Recruit wikilink if start with [[",
      opts = { nowait = true, silent = true },
    },
    ["<leader>s2"] = { --split the line
      ":call SplitByH2()<CR>",
      "Split by H2 with wikilink",
      opts = { nowait = true, silent = true },
    },
    ["<leader>mt"] = { --split the line
      ":TableModeToggle<CR>",
      "TableModeToggle",
      opts = { nowait = true, silent = true },
    },
  },
  i = {
    ["@"] = { "<cmd>Telescope bibtex<CR>", "add citation", opts = { nowait = true } },
  },
  v = {
    ["<C-g>"] = {
      ":call  SearchGoogle()<CR>",
      "SearchGoogle",
      opts = { nowait = true, silent = true },
    },
  },
}
M.hover = {
  plugin = true,
  n = {
    ["gk"] = {
      function()
        require("hover").hover()
      end,
      "Hover",
      opts = { nowait = true },
    },
    ["gK"] = {
      function()
        require("hover").hover_select()
      end,
      "Hover Select",
      opts = { nowait = true },
    },
  },
}
M.telekasten = {
  plugin = true,
  n = {
    ["<leader>fr"] = {
      function()
        require("telekasten").find_friends()
      end,
      "Find Friends",
    },
    ["<leader>z"] = { "<cmd>Telekasten panel<CR>" },
    ["<leader>zf"] = { "<cmd>Telekasten find_notes<CR>" },
    ["<leader>zg"] = { "<cmd>Telekasten search_notes<CR>" },
    ["<leader>zd"] = { "<cmd>Telekasten goto_today<CR>" },
    ["<leader>zn"] = { "<cmd>Telekasten new_note<CR>" },
    ["<leader>zc"] = { "<cmd>Telekasten show_calendar<CR>" },
    ["<leader>zb"] = { "<cmd>Telekasten show_backlinks<CR>" },
    ["<leader>ti"] = { "<cmd>Telekasten insert_img_link<CR>" },
  },
  -- i = {
  -- 	["\\["] = { "<cmd>Telekasten insert_link<CR>", "Find Friends" },
  -- },
}
M.dap = {
  plugin = true,
  n = {
    ["<leader>db"] = { "<cmd> DapToggleBreakpoint <CR>" },
  },
}
M.dap_python = {
  plugin = true,
  n = {
    ["<leader>dpr"] = {
      function()
        require("dap-python").test_method()
      end,
    },
  },
}
M.harpoon = {
  plugin = true, -- Important
  n = {
    -- ["<leader>kk"] = { ":Telescope harpoon marks<CR>", "Show List" },
    ["<leader>kk"] = { '<cmd>lua require("harpoon.ui").toggle_quick_menu()<CR>', "Show List" },
    ["<leader>jj"] = {
      function()
        require("harpoon.mark").add_file()
        vim.cmd "echohl Identifier"
        vim.cmd "echomsg '自閉円頓裹👐'"
        vim.cmd "echohl None"
      end,
      "harpoon.mark: add_file",
    },
    ["<leader>jk"] = {
      function()
        require("harpoon.ui").nav_next()
        vim.cmd "echohl Identifier"
        vim.cmd "echomsg '⇉ 術式順転『蒼』⇉'"
        vim.cmd "echohl None"
      end,
      "harpoon.mark: next",
    },
    ["<leader>kj"] = {
      function()
        require("harpoon.ui").nav_prev()
        vim.cmd "echohl Identifier"
        vim.cmd "echomsg '⇇ 術式反転『赫』⇇'"
        vim.cmd "echohl None"
      end,
      "harpoon.nav.prev",
    },
  },
}

M.iron = {
  plugin = true,
  n = {
    ["<leader>po"] = { ':echo "hellow"', "testpy", opts = { nowait = true } },
  },
}

M.nvimR = {
  plugin = true,
  n = {
    ["<leader><leader>"] = { "<Plug>RDSendLine", "RDSendLine", opts = { nowait = true, silent = true } },
    ["<leader>rf"] = { "<Plug>RSendFile", "RSendFile", opts = { nowait = true, silent = true } },
    ["<leader>rc"] = {
      ':silent! RSend system("clear")<CR>',
      "ClearConsole",
      opts = { nowait = true, silent = true },
    },
    ["<leader>rh"] = { "<Plug>Rhelp", "R help", opts = { nowait = true } },
    ["<leader>r<CR>"] = { "<Plug>RStart", "R start", opts = { nowait = true, silent = true } },
    ["<leader>rq"] = { "<Plug>RSaveClose", "R save and close", opts = { nowait = true, silent = true } },
    ["<leader>rd"] = { "<Plug>RViewDFv", "R save and close", opts = { nowait = true, silent = true } },
    ["<leader>rs"] = { "<Plug>RSummary", "R Summary", opts = { nowait = true, silent = true } },
    ["<leader>ro"] = { "<Plug>RUpdateObjBrowser", "R update object windows", opts = { nowait = true } },
  },
  v = {
    ["<leader><leader>"] = { "<Plug>RDSendSelection", "RDSendSelection", opts = { nowait = true } },
  },
}
-- M.whatever = {
--   plugin = true, -- Important
--   n = {
--      ["<C-n>"] = {"<cmd> Telescope <CR>", "Telescope"}
--   }
-- }
--
-- require("core.utils").load_mappings("someplugin")
return M
