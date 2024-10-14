return {
  "TobinPalmer/Tip.nvim",
  enabled = false,
  event = "VimEnter",
  init = function()
    -- Default config
    --- @type Tip.config
    require("tip").setup {
      seconds = 10,
      title = "Tip!",
      url = "https://vimiscool.tech/neotip",
    }
  end,
}
