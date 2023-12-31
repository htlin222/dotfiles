return { --vim-startuptime
  "dstein64/vim-startuptime",
  -- lazy-load on a command
  -- event = "VeryLazy",
  cmd = "StartupTime",
  -- init is called during startup. Configuration for vim plugins typically should be set in an init function
  init = function()
    vim.g.startuptime_tries = 10
  end,
}
