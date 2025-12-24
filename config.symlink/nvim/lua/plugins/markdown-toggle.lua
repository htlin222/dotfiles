return {
  "roodolv/markdown-toggle.nvim",
  ft = { "markdown", "quarto" },
  config = function()
    require("markdown-toggle").setup {
      use_default_keymaps = false,
      -- Checkbox 循環設定
      cycle_box_table = { "[ ]", "[x]", "[~]", "[!]", "[>]" },
    }
    -- 自訂快捷鍵
    local toggle = require("markdown-toggle")
    local map = vim.keymap.set
    local opts = { buffer = true, silent = true }

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "markdown", "quarto" },
      callback = function()
        -- Checkbox 操作
        map("n", "<leader>cb", toggle.checkbox, { buffer = true, desc = "Toggle checkbox" })
        map("n", "<leader>cB", toggle.checkbox_cycle, { buffer = true, desc = "Cycle checkbox" })
        -- 列表操作
        map("n", "<leader>cl", toggle.list, { buffer = true, desc = "Toggle list" })
        map("n", "<leader>cL", toggle.list_cycle, { buffer = true, desc = "Cycle list style" })
        -- 標題操作
        map("n", "<leader>ch", toggle.heading, { buffer = true, desc = "Toggle heading" })
        -- 引用操作
        map("n", "<leader>cq", toggle.quote, { buffer = true, desc = "Toggle quote" })
        -- 有序列表
        map("n", "<leader>co", toggle.olist, { buffer = true, desc = "Toggle ordered list" })
      end,
    })
  end,
}
