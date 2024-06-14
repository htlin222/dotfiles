return {
  "ThePrimeagen/harpoon",
  -- lazy = false,
  event = "VeryLazy",
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    require("harpoon").setup({
      -- opts here
      menu = {
        width = vim.api.nvim_win_get_width(0) - 4,
      },
    })
    require("telescope").load_extension("harpoon")
    require("core.utils").load_mappings("harpoon")
  end,
}
