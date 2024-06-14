-- ~/.config/nvim/lua/custom/configs/*.lua
local plug_list = {
	--- First to load
	"neodev",
	"lspsaga", -- https://github.com/nvimdev/lspsaga.nvim
	"carbon-now",
	"grugfar",
	"nio",
	"gitmoji",
	"render-markdown",
	"todotxt",
	-- "headlines",
	"quarto",
	"otter",
	-- "lsp_signature",
	"codeium",
	"lsp-timeout",
	"fugitive", -- "tpope/vim-fugitive",
	"neoclip",
	"gp",
	"iron",
	"hawtkeys",
	"automkdir",
	-- "papis",
	"r",
	-- "notator",
	"vim-markdown-toc",
	-- "inline-fold",
	"close-buffers",
	"gitlinker",
	"gitsigns",
	"octo",
	"fidget", -- Extensible UI for Neovim notifications and LSP progress messages.
	-- "spider", -- Use the w, e, b motions like a spider. Move by subwords and skip insignificant punctuation.
	"marks",
	"urlview",
	"better-escape",
	"rainbow-delimiters",
	"pangu",
	"neocomposer",
	"trailblazer",
	"oil", -- A vim-vinegar like file explorer that lets you edit your filesystem like a normal Neovim buffer.
	-- "dressing",
	"conform",
	"lint",
	"mason-lspconfig",
	"firenvim",
	"nvim-lspconfig",
	"mason-nvim-dap", -- TODO: figure out how to use it
	"mason-tool-installer", -- WARN: Cause Error
	-- "nvim-treesitter-textobjects",
	"nvim-tree",
	-- telescope stuff
	-- "telekasten", -- ft.
	"telescope-bibtex",
	"telescope",
	"telescope-symbols",
	"compiler",
	"hbac",
	-- -- --- others
	"cursorline",
	"inc-rename",
	"modicator", -- A small Neovim plugin that changes the color of your cursor's line number based on the current Vim mode.
	"dial",
	"specs",
	"hover",
	"chatgpt",
	"trailblazer",
	"pick",
	"aerial",
	"cheatsheet",
	"harpoon",
	"aidoc",
	"hop", -- may replaced by
	-- -- "flash",
	-- "satellite", -- only support 0.10 now at 0.09
	-- "neoscroll",
	"winshift",
	-- "nvim-ufo",
	"mini",
	"yanky",
	"vim-table-mode",
	-- "barbecue",
	"iswap", -- Interactively select and swap: function arguments, list elements, function parameters, and more. Powered by tree-sitter.
	"fsread",
	"legendary",
	"mkdnflow",
	"regexplainer",
	"neo-tree",
	"neotest",
	-- how to handle hits TODO:
	"noice", -- when suggestion show up, <C-y> to sent the command
	"nvim-dap",
	-- "markmap",
	"nvim-dap-python",
	"nvim-dap-ui",
	"nvim-search-and-replace",
	"nvim-surround",
	"pantran",
	"indent-blankline",
	"pretty-fold",
	"project",
	"scrollbar",
	"early-retirement",
	"due",
	-- "ufo",
	-- "quicknote",
	"search-replace",
	"symbols-outline",
	"trouble",
	"twilight",
	"mode",
	"vim-illuminate",
	"vim-startuptime",
	"todo-comments",
	"vim-tmux-navigator",
	"highlight-undo",
	"zen-mode",
	"gist",
	"cybu",
	"zk",
	"markdown-preview",
	"deadcolumn",
	"LuaSnip",
	"cmp",
	"numbertoggle",
	-- "filetype", -- not yet to figure out how does it works
	"neorg", -- TODO: 感覺很厲害的筆記系統，但我還沒想好要怎麼用
}
-- make the complete list
local plugins = {}
for _, plug in ipairs(plug_list) do
	plugins[#plugins + 1] = require("custom.configs." .. plug)
end
return plugins
