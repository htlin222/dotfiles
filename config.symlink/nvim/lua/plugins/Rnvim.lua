return {
  "R-nvim/R.nvim",
  lazy = true, -- 只在R文件類型時加載，提升啟動性能
  ft = { "r", "rmd", "quarto" }, -- 只在R相關文件類型時加載
  config = function()
    -- 使用 autocommand 設置 buffer-local 鍵位映射
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "r", "rmd", "quarto" },
      callback = function()
        vim.keymap.set("n", "<CR>", "<Plug>RDSendLine", { buffer = true, desc = "R: Send line" })
        vim.keymap.set("v", "<CR>", "<Plug>RSendSelection", { buffer = true, desc = "R: Send selection" })
      end,
    })
    -- Create a table with the options to be passed to setup()
    local opts = {
      R_args = { "--quiet", "--no-save" },
      min_editor_width = 72,
      rconsole_width = 78,
      -- Fix syntax error with special prompt characters
      R_prompt_str = "> ",
      R_continue_str = "+ ",
      disable_cmds = {
        "RClearConsole",
        "RCustomStart",
        "RSPlot",
        "RSaveClose",
      },
    }
    -- Check if the environment variable "R_AUTO_START" exists.
    -- If using fish shell, you could put in your config.fish:
    -- alias r "R_AUTO_START=true nvim"
    if vim.env.R_AUTO_START == "true" then
      opts.auto_start = 1
      opts.objbr_auto_start = true
    end
    require("r").setup(opts)
  end,
}
