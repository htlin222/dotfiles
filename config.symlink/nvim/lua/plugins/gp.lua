return {
  "robitx/gp.nvim",

  event = "VeryLazy",
  config = function()
    local conf = {
      -- For customization, refer to Install > Configuration in the Documentation/Readme
    }
    require("gp").setup(conf)

    -- Setup shortcuts here (see Usage > Shortcuts in the Documentation/Readme)
  end,
}
