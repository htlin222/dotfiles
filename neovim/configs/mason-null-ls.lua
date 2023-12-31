return { -- NB: the purpose of this table is to load mason and null-ls before the mason-null-ls config
  "jay-babu/mason-null-ls.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason.nvim",
    "jose-elias-alvarez/null-ls.nvim", -- TODO: will try to migrate the null-ls config to here
  },
  config = function()
    require("mason-null-ls").setup({
      ensure_installed = {
        "stylua",
        "jq",
        "tidy",
        "reorder-python-imports",
        "shellcheck",
        "cmake_link",
        "ruff",
        "pydocstyle",
        "proselint",
        "mypy",
        "clang_format",
        "autopep8",
        "beautysh",
        "beautysh",
        "proselint",
        "black",
        "fixjson",
        "prettier",
        "yamlfmt",
        "markdownlint",
        "reorder_python_imports",
        "rome",
        "semgrep",
        "shfmt",
        "yapf",
      },
      automatic_installation = true,
    })
    require("custom.configs.null-ls") -- require your null-ls config here (example below)
  end,
}
-- [jay-babu/mason-null-ls.nvim](https://github.com/jay-babu/mason-null-ls.nvim)
