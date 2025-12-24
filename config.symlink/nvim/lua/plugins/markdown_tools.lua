return {
  "tadmccorkle/markdown.nvim",
  ft = { "markdown", "quarto" },
  opts = {
    -- 啟用內建的按鍵映射
    mappings = {
      inline_surround_toggle = "gs", -- 切換行內格式 (如 **bold**)
      inline_surround_toggle_line = "gss", -- 切換整行格式
      inline_surround_delete = "ds", -- 刪除行內格式
      inline_surround_change = "cs", -- 更改行內格式
      link_add = "gl", -- 添加連結
      link_follow = "gx", -- 跟隨連結
      go_curr_heading = "]c", -- 跳到當前標題
      go_parent_heading = "]p", -- 跳到父標題
      go_next_heading = "]]", -- 下一個標題 (與 mkdnflow 相同)
      go_prev_heading = "[[", -- 上一個標題 (與 mkdnflow 相同)
    },
    inline_surround = {
      emphasis = {
        key = "i",
        txt = "*",
      },
      strong = {
        key = "b",
        txt = "**",
      },
      strikethrough = {
        key = "s",
        txt = "~~",
      },
      code = {
        key = "c",
        txt = "`",
      },
    },
    on_attach = function(bufnr)
      local map = vim.keymap.set
      local opts = { buffer = bufnr, silent = true }
      -- 增加/減少標題層級
      map({ "n", "i" }, "<M-=>", "<Cmd>MDListItemBelow<CR>", opts)
      map({ "n", "i" }, "<M-->", "<Cmd>MDListItemAbove<CR>", opts)
    end,
  },
}
