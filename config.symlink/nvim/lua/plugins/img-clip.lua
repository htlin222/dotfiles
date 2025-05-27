return {
  "HakonHarnes/img-clip.nvim",
  event = "VeryLazy",
  opts = {
    -- add options here
    -- or leave it empty to use the default settings
    default = {
      use_absolute_path = false, ---@type boolean
      dir_path = function()
        return vim.fn.expand "%:t:r"
      end,
      relative_to_current_file = true, ---@type boolean | fun(): boolean
      prompt_for_file_name = false, ---@type boolean
      file_name = "%y%m%d-%H%M%S", ---@type string
    },
    filetypes = {
      markdown = {
        url_encode_path = true, ---@type boolean | fun(): boolean
        template = "![h:450px$CURSOR](./$FILE_PATH)", ---@type string | fun(context: table): string
        download_images = true, ---@type boolean | fun(): boolean
      },
    },
  },
  keys = {
    -- suggested keymap
    { "<leader>pp", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
  },
}
