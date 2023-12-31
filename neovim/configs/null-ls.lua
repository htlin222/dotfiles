local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local null_ls = require("null-ls")
local utils = require("null-ls.utils")

local opts = {
	sources = {
		-- 👉 雖然很好玩，但很煩，一直跳一些無意義的通知
		-- null_ls.builtins.diagnostics.vale,
		-- null_ls.builtins.code_actions.shellcheck,
		-- null_ls.builtins.diagnostics.cmake_lint,
		-- null_ls.builtins.diagnostics.proselint,
		-- null_ls.builtins.diagnostics.pydocstyle, --
		-- null_ls.builtins.diagnostics.vale.with({ filetypes = { "text" } }),
		-- null_ls.builtins.diagnostics.vale.with({ filetypes = { "text", "markdown" } }),
		-- null_ls.builtins.diagnostics.ruff,     -- pydocstyle
		-- null_ls.builtins.diagnostics.semgrep, -- too slow
		-- null_ls.builtins.diagnostics.shellcheck, -- shell script formatting
		-- null_ls.builtins.diagnostics.vint,
		-- null_ls.builtins.formatting.autopep8,
		-- null_ls.builtins.formatting.autoflake,
		-- null_ls.builtins.formatting.beautysh,
		-- null_ls.builtins.formatting.clang_format.with({ filetypes = { "dot" } }),
		-- null_ls.builtins.formatting.black,
		-- null_ls.builtins.formatting.fixjson,
		-- null_ls.builtins.formatting.reorder_python_imports,
		-- null_ls.builtins.formatting.shfmt,
		-- -- null_ls.builtins.formatting.yapf,
		-- null_ls.builtins.formatting.yamlfmt,
		-- null_ls.builtins.formatting.tidy,
		-- null_ls.builtins.formatting.stylua,
		-- null_ls.builtins.formatting.markdownlint,
		-- --  Don't use "prettierd" -- will delete your contnet
		-- null_ls.builtins.formatting.prettier,
		-- null_ls.builtins.diagnostics.mypy.with({
		--   -- this line fix the problem about the ERROR showed up when the Buffer not saved yet
		--   runtime_condition = function(params)
		--     return utils.path.exists(params.bufname)
		--   end,
		--   extra_args = function()
		--     local virtual = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_DEFAULT_ENV") or "/usr"
		--     return { "--python-executable", virtual .. "/bin/python3" }
		--   end,
		-- }),
	},
	on_attach = function(client, bufnr)
		if client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({
				group = augroup,
				buffer = bufnr,
			})
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.format({ bufnr = bufnr })
				end,
			})
		end
	end,
}
return opts
