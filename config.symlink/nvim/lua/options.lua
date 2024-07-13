require "nvchad.options"
local vim = vim
local opt = vim.opt
local wo = vim.wo

-- start option
opt.cursorlineopt = "both"
opt.autoindent = true
opt.autochdir = true
opt.lbr = true
opt.expandtab = true
opt.shiftround = false
opt.shiftwidth = 2
opt.tabstop = 2

opt.spell = true
opt.spelllang = { "en_us" }
opt.smartindent = true
opt.softtabstop = 2
opt.swapfile = false
opt.scrolloff = 10
opt.sidescrolloff = 8
opt.tabstop = 2
opt.colorcolumn = "80," .. table.concat(vim.fn.range(120, 999), ",")
wo.relativenumber = true
vim.cmd [[highlight ColorColumn ctermbg=235 guibg=#2c2d27]]
vim.g.did_load_netrw = 1
vim.markdown_folding = 1

require "autocmd"
