-- ln -s $(pwd) ~/.config/nvim/lua/custom
local vim = vim
function _G.playAudio(audioFilePath)
	local audioFilePath_expaned = vim.fn.expand(audioFilePath)
	local escapedPath = vim.fn.shellescape(audioFilePath_expaned)
	local command = string.format("ffplay -v 0 -nodisp -autoexit %s &", escapedPath)
	os.execute(command)
end
-- Play: 🎤
-- playAudio("$HOME/.config/nvim/lua/custom/media/open.mp3")
--
local opt = vim.opt
local wo = vim.wo
-- start option
opt.autoindent = true
opt.autochdir = true
opt.lbr = true
opt.expandtab = true
opt.shiftround = false
opt.shiftwidth = 2

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
vim.cmd([[highlight ColorColumn ctermbg=235 guibg=#2c2d27]])
-- vim.cmd([[highlight @markup.link ctermbg=235 guifg=#aad84c guibg=#2c2d27]])
-- vim.cmd([[highlight Title ctermbg=235 guifg=#aad84c guibg=#2c2d27]])
vim.g.did_load_netrw = 1
vim.markdown_folding = 1
