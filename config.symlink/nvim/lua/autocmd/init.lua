local vim = vim
-----------------------------------------------------------
-- Autocommand functions
-----------------------------------------------------------

local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

-----------------------------------------------------------

require "autocmd.ftkeymap"
require "autocmd.fttemplate"
require "autocmd.format"
require "autocmd.garden"

-- highlight on yank
autocmd("TextYankPost", {
  group = augroup("YankHighlight", { clear = true }),
  callback = function()
    vim.highlight.on_yank { higroup = "IncSearch", timeout = "1000" }
  end,
})

-- removes trailing whitespace from any file before saving (加入文件大小檢查)
autocmd("BufWritePre", {
  pattern = "",
  callback = function()
    if not vim.bo.modifiable then
      return
    end
    local file_size = vim.fn.getfsize(vim.fn.expand "%")
    if file_size < 1024 * 1024 * 10 then -- 只處理小於 10MB 的文件
      vim.cmd ":%s/\\s\\+$//e"
    end
  end,
})

-- PanguAll 格式化中文文本 (加入文件大小檢查)
autocmd("BufWritePre", {
  pattern = { "*.txt", "*.md" },
  callback = function()
    if vim.fn.exists(":PanguAll") ~= 2 then
      return
    end
    local file_size = vim.fn.getfsize(vim.fn.expand "%")
    if file_size < 1024 * 1024 * 5 then -- 只處理小於 5MB 的文件
      vim.cmd "PanguAll"
    end
  end,
})

autocmd({ "BufRead", "BufNewFile" }, {
  callback = function()
    if vim.bo.filetype == "" then
      vim.bo.filetype = "bash"
    end
  end,
})

-- sets the filetype to zsh for any new or existing buffer with a .gp file extension
autocmd({ "BufRead", "BufNewFile" }, { pattern = "*.gp", command = "set filetype=zsh" })
autocmd({ "BufRead", "BufNewFile" }, { pattern = "*.gs", command = "set filetype=javascript" })
autocmd({ "BufRead", "BufNewFile" }, { pattern = "*.conf", command = "set filetype=bash" })

-- for goovy
autocmd({ "BufRead", "BufNewFile" }, { pattern = "*.nf", command = "set filetype=groovy" })

-- R format

-- converts Graphviz .gv files to SVG format when they are saved, and notifies the user about the success or failure of the conversion.
autocmd("BufWritePost", {
  group = augroup("GraphvizAutocommands", { clear = true }),
  pattern = "*.gv",
  callback = function()
    if vim.fn.executable("dot") ~= 1 then
      return
    end
    local filename = vim.fn.expand "%"
    local output = vim.fn.expand "%:r" .. ".svg"
    local cmd = "dot -Tsvg " .. vim.fn.shellescape(filename) .. " -o " .. vim.fn.shellescape(output)
    -- Start the conversion job
    vim.fn.jobstart(cmd, {
      on_exit = function(_, exit_code)
        if exit_code == 0 then
          vim.api.nvim_out_write "🟢SVG converted\n"
        else
          vim.api.nvim_err_writeln "🔴SVG Failed"
        end
      end,
    })
  end,
})

-- automatically updates any line in a Vim or Neovim buffer containing a date pattern like date: "YYYY-MM-DD" to the current date upon saving the file.

-- disables automatic line breaking based on comments (c), the 'textwidth' option (r), and list formatting (o)
autocmd("BufEnter", { pattern = "", command = "set fo-=c fo-=r fo-=o" })

-- save on exit (已禁用以提升性能 - 可通過設置 vim.g.auto_save_on_leave = true 啟用)
if vim.g.auto_save_on_leave then
  autocmd("BufLeave", {
    group = augroup("SaveOnExit", { clear = true }),
    callback = function()
      local filename = vim.fn.expand "%:t"
      local readonly = vim.bo.readonly
      if filename ~= "plugins.lua" and not readonly then
        vim.cmd "silent! write"
        -- vim.cmd(
        -- 	"execute 'silent !ffplay -v 0 -nodisp -autoexit ' . shellescape(expand('$HOME/.config/nvim/lua/custom/media/save.wav')) . ' &'"
        -- )
      end
    end,
  })
end

-- Disable line length marker; set the 'colorcolumn' option to 0 for specific file types (text, markdown, html, xhtml, javascript, typescript).
augroup("setLineLength", { clear = true })
autocmd("Filetype", {
  group = "setLineLength",
  pattern = { "text", "html", "xhtml", "javascript", "typescript" },
  command = "setlocal cc=0",
})

-- set indentation to 2 spaces
augroup("setIndent", { clear = true })
autocmd("Filetype", {
  group = "setIndent",
  pattern = { "xml", "html", "xhtml", "css", "scss", "javascript", "typescript", "yaml", "lua" },
  command = "setlocal shiftwidth=2 tabstop=2",
})

-- 只在文字類型檔案啟用拼寫檢查
augroup("setSpell", { clear = true })
autocmd("Filetype", {
  group = "setSpell",
  pattern = { "text", "markdown", "quarto", "gitcommit", "tex", "plaintex" },
  command = "setlocal spell",
})

-- set lines (優化：只在沒有設置時才更新，避免重複設置)
local colorcolumn_set = false
autocmd("InsertEnter", {
  group = augroup("column", { clear = true }),
  pattern = "*",
  callback = function()
    if not colorcolumn_set then
      vim.opt.colorcolumn = "80,120"
      colorcolumn_set = true
    end
  end,
})

---------------------
-- Terminal settings:
---------------------

-- open a Terminal on the right tab
autocmd("CmdlineEnter", {
  command = "command! Term :botright vsplit term://$SHELL",
})

-- Enter insert mode when switching to terminal
autocmd("TermOpen", {
  command = "setlocal listchars= nonumber norelativenumber nocursorline",
})

autocmd("TermOpen", {
  pattern = "",
  command = "startinsert",
})

-- au BufWinEnter * set shm+=I
autocmd("BufWinEnter", {
  pattern = "*",
  command = "set shm+=I",
})

-- Close terminal buffer on process exit
autocmd("BufLeave", {
  pattern = "term://*",
  command = "stopinsert",
})

vim.o.confirm = true
autocmd("BufEnter", {
  group = augroup("NvimTreeClose", { clear = true }),
  callback = function()
    local layout = vim.api.nvim_call_function("winlayout", {})
    if
      layout[1] == "leaf"
      and vim.api.nvim_get_option_value("filetype", { buf = vim.api.nvim_win_get_buf(layout[2]) }) == "NvimTree"
      and layout[3] == nil
    then
      vim.cmd "quit"
    end
  end,
})

autocmd("QuitPre", {
  callback = function()
    local tree_wins = {}
    local floating_wins = {}
    local wins = vim.api.nvim_list_wins()
    for _, w in ipairs(wins) do
      local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
      if bufname:match "NvimTree_" ~= nil then
        table.insert(tree_wins, w)
      end
      if vim.api.nvim_win_get_config(w).relative ~= "" then
        table.insert(floating_wins, w)
      end
    end
    if 1 == #wins - #floating_wins - #tree_wins then
      -- Should quit, so we close all invalid windows.
      for _, w in ipairs(tree_wins) do
        vim.api.nvim_win_close(w, true)
      end
    end
  end,
})

-- 優化：只在 nvim-tree 已載入時才檢查，避免強制載入
autocmd("BufEnter", {
  nested = true,
  callback = function()
    -- 檢查 nvim-tree 是否已在記憶體中載入（不會觸發載入）
    if not package.loaded["nvim-tree.utils"] then
      return
    end
    local utils = require("nvim-tree.utils")
    if #vim.api.nvim_list_wins() == 1 and utils.is_nvim_tree_buf() then
      vim.cmd "quit"
    end
  end,
})

-- LSP Floating Window Resize Fix
local lsp_resize_group = augroup("LspFloatingResize", { clear = true })
autocmd("VimResized", {
  group = lsp_resize_group,
  callback = function()
    -- Force refresh LSP floating window dimensions on terminal resize
    if vim.o.columns <= 0 or vim.o.lines <= 0 then
      vim.schedule(function()
        vim.cmd("redraw!")
      end)
    end
  end,
})
