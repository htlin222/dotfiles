return {
  "mfussenegger/nvim-dap-python",
  -- event = "VeryLazy",
  ft = "python",
  dependencies = {
    "mfussenegger/nvim-dap",
    "rcarriga/nvim-dap-ui",
  },
  config = function(_, opts)
    local debug_py_python_path = vim.fn.expand("~/.local/share/nvim/mason/packages/debugpy/venv/bin/python")
    require("dap-python").setup(debug_py_python_path, { console = "externalTerminal" })
    require("core.utils").load_mappings("dap_python")
  end,
}
