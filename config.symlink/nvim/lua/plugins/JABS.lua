local vim = vim
return {
  "matbme/JABS.nvim",
  -- lazy = false,
  keys = {
    { -- example for lazy-loading on keystroke
      "<leader>ls",
      "<cmd>JABSOpen<CR>",
      mode = { "n", "o", "x" },
      desc = "JABSOpen",
    },
  },

  config = function()
    require("jabs").setup {
      relative = "cursor", -- win, editor, cursor. Default win
      border = "none",
      symbols = {
        current = "󰓎",
        split = "󱤗",
        alternate = "󰁔",
        hidden = "󰘓",
        locked = "󰈡", -- default 
        ro = "R", -- default 
        edited = "󱇨", -- default 
        terminal = "", -- default 
        default_file = "󰈙", -- Filetype icon if not present in nvim-web-devicons. Default 
        terminal_symbol = "", -- Filetype icon for a terminal split. Default 
      },
      keymap = {
        close = "x", -- Close buffer. Default D
        h_split = "h", -- Horizontally split buffer. Default s
        v_split = "v", -- Vertically split buffer. Default v
        preview = "l", -- Open buffer preview. Default P
      },
    }

    -- vim.keymap.set("n", "<leader>ls", "<cmd>JABSOpen<CR>", { desc = "JABSOpen", silent = true })
  end,
}
