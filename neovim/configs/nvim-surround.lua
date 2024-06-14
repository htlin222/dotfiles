return {        --nvim-surround
  "kylechui/nvim-surround",
  version = "*", -- Use for stability; omit to use `main` branch for the latest features
  -- event = "VeryLazy",
  -- lazy = false,
  -- event = "VeryLazy",
  config = function()
    require("nvim-surround").setup({
      -- Configuration here, or leave empty to use defaults
      move_cursor = false,
      surrounds = { -- Setting of surround here
        ["j"] = {
          add = function()
            return { { "[" }, { "]" } }
          end,
        },
        ["k"] = {
          add = function()
            return { { "_" }, { "_" } }
          end,
        },
        ["l"] = {
          add = function()
            return { { "👉 **" }, { "** 👈" } }
          end,
        },
        ["m"] = {
          add = function()
            return { { "⚠️ _" }, { "_⚠️ " } }
          end,
        },
        ["c"] = {
          add = function()
            return { { "{{c1::" }, { "::❓}}" } }
          end,
        },
        ["2"] = {
          add = function()
            return { { "{{c2::" }, { "::❓}}" } }
          end,
        },
        ["3"] = {
          add = function()
            return { { "{{c3::" }, { "::❓}}" } }
          end,
        },
        ["i"] = {
          add = function()
            return { { "![Figure: ](" }, { ")" } }
          end,
        },
      },
      -- Defines surround keys and behavior
      keymaps = {
        visual = "<leader><leader>", -- 在視覺模式下：按ctrl k可以開始加料
      },
    })
  end,
}
