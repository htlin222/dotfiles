--  [markdown markmap]
--  https://github.com/Zeioth/markmap.nvim
return {
  "Zeioth/markmap.nvim",
  build = "yarn global add markmap-cli",
  event = "VeryLazy",
  cmd = { "MarkmapOpen", "MarkmapSave", "MarkmapWatch", "MarkmapWatchStop" },
  opts = {
    html_output = "/tmp/markmap.html", -- (default) Setting a empty string "" here means: [Current buffer path].html
    hide_toolbar = false,            -- (default)
    grace_period = 3600000,          -- (default) Stops markmap watch after 60 minutes. Set it to 0 to disable the grace_period.
  },
  config = function(_, opts)
    require("markmap").setup(opts)
  end,
}
