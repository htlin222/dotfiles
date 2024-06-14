local vim = vim
-----------------------------------------------------------
-- Autocommand functions
-----------------------------------------------------------

local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

-----------------------------------------------------------
-- Autocommand functions
-----------------------------------------------------------

local handle = io.popen "uname -a" -- 執行 uname -a 並取得輸出
local result = handle:read "*a"
handle:close()

if string.match(result, "GNU") then -- 如果輸出中包含 "GNU"
  require "autocmd.linux"
else
  require "autocmd.macos" -- 否則加載 macOS 專用模組
end
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

-- removes trailing whitespace from any file before saving
autocmd("BufWritePre", { pattern = "", command = ":%s/\\s\\+$//e" })
autocmd("BufWritePre", { pattern = { "*.txt", "*.md" }, command = "PanguAll" })

-- sets the filetype to zsh for any new or existing buffer with a .gp file extension
autocmd({ "BufRead", "BufNewFile" }, { pattern = "*.gp", command = "set filetype=zsh" })

-- for goovy
autocmd({ "BufRead", "BufNewFile" }, { pattern = "*.nf", command = "set filetype=groovy" })

-- R format

-- converts Graphviz .gv files to SVG format when they are saved, and notifies the user about the success or failure of the conversion.
autocmd("BufWritePost", {
  group = augroup("GraphvizAutocommands", { clear = true }),
  pattern = "*.gv",
  callback = function()
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

-- save on exit
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

-- Disable line length marker; set the 'colorcolumn' option to 0 for specific file types (text, markdown, html, xhtml, javascript, typescript).
augroup("setLineLength", { clear = true })
autocmd("Filetype", {
  group = "setLineLength",
  pattern = { "text", "markdown", "html", "xhtml", "javascript", "typescript" },
  command = "setlocal cc=0",
})

-- set indentation to 2 spaces
augroup("setIndent", { clear = true })
autocmd("Filetype", {
  group = "setIndent",
  pattern = { "xml", "html", "xhtml", "css", "scss", "javascript", "typescript", "yaml", "lua" },
  command = "setlocal shiftwidth=2 tabstop=2",
})

-- set lines
autocmd("InsertEnter", {
  group = augroup("column", { clear = true }),
  pattern = "*",
  callback = function()
    vim.opt.colorcolumn = "80," .. table.concat(vim.fn.range(120, 999), ",")
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
      and vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(layout[2]), "filetype") == "NvimTree"
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

autocmd("BufEnter", {
  nested = true,
  callback = function()
    if #vim.api.nvim_list_wins() == 1 and require("nvim-tree.utils").is_nvim_tree_buf() then
      vim.cmd "quit"
    end
  end,
})
