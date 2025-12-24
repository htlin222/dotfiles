return {
  "MeanderingProgrammer/markdown.nvim",
  name = "render-markdown",
  ft = { "markdown", "quarto", "Avante" }, -- 只在需要時載入
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons", -- 可選：用於代碼區塊圖標
  },
  config = function()
    require("render-markdown").setup {
      file_types = { "markdown", "quarto", "Avante" },
      render_modes = { "n", "c" }, -- 普通模式和命令模式時渲染

      -- 標題樣式
      heading = {
        enabled = true,
        sign = true, -- 在標誌列顯示標題圖標
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
        width = "block", -- 背景延伸到整行
      },

      -- 代碼區塊
      code = {
        enabled = true,
        sign = false,
        style = "full", -- full, normal, language, none
        width = "block",
        left_pad = 2,
        right_pad = 2,
        border = "thin", -- thin, thick, none
        highlight = "RenderMarkdownCode",
      },

      -- 列表項目符號
      bullet = {
        enabled = true,
        icons = { "●", "○", "◆", "◇" },
        right_pad = 1,
        highlight = "RenderMarkdownBullet",
      },

      -- Checkbox 樣式
      checkbox = {
        enabled = true,
        unchecked = { icon = "󰄱 ", highlight = "RenderMarkdownUnchecked" },
        checked = { icon = "󰄵 ", highlight = "RenderMarkdownChecked" },
        custom = {
          todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
          important = { raw = "[!]", rendered = "󰀨 ", highlight = "DiagnosticWarn" },
          doing = { raw = "[~]", rendered = "󰦖 ", highlight = "DiagnosticInfo" },
          canceled = { raw = "[>]", rendered = "󰜺 ", highlight = "Comment" },
        },
      },

      -- 引用區塊
      quote = {
        enabled = true,
        icon = "▎",
        repeat_linebreak = true,
        highlight = "RenderMarkdownQuote",
      },

      -- 表格
      pipe_table = {
        enabled = true,
        style = "full", -- full, normal, none
        cell = "padded", -- padded, raw, overlay
        border = { "┌", "┬", "┐", "├", "┼", "┤", "└", "┴", "┘", "│", "─" },
      },

      -- 連結
      link = {
        enabled = true,
        image = "󰥶 ",
        email = "󰀓 ",
        hyperlink = "󰌹 ",
        custom = {
          web = { pattern = "^http", icon = "󰖟 " },
          youtube = { pattern = "youtube%.com", icon = "󰗃 " },
          github = { pattern = "github%.com", icon = "󰊤 " },
          zotero = { pattern = "^zotero:", icon = "󱉟 " },
        },
      },

      -- 分隔線
      dash = {
        enabled = true,
        icon = "─",
        width = "full",
        highlight = "RenderMarkdownDash",
      },

      -- Callout / Alert 區塊
      callout = {
        note = { raw = "[!NOTE]", rendered = "󰋽 Note", highlight = "RenderMarkdownInfo" },
        tip = { raw = "[!TIP]", rendered = "󰌶 Tip", highlight = "RenderMarkdownSuccess" },
        important = { raw = "[!IMPORTANT]", rendered = "󰅾 Important", highlight = "RenderMarkdownHint" },
        warning = { raw = "[!WARNING]", rendered = "󰀪 Warning", highlight = "RenderMarkdownWarn" },
        caution = { raw = "[!CAUTION]", rendered = "󰳦 Caution", highlight = "RenderMarkdownError" },
      },

      win_options = {
        conceallevel = {
          default = vim.api.nvim_get_option_value("conceallevel", {}),
          rendered = 3,
        },
        concealcursor = {
          default = vim.api.nvim_get_option_value("concealcursor", {}),
          rendered = "",
        },
      },
    }
  end,
}
