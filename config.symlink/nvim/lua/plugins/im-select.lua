return {
  "keaising/im-select.nvim",
  event = "InsertEnter",
  config = function()
    local is_mac = vim.fn.has("mac") == 1
    require("im_select").setup({
      default_im_select = is_mac and "com.apple.keylayout.ABC" or "1",
      default_command = is_mac and "im-select" or "fcitx5-remote",
      -- fcitx5-remote 用 -t 切換，用 -c 關閉
      set_default_events = { "VimEnter", "InsertLeave", "FocusGained" },
      set_previous_events = { "InsertEnter" },
      keep_quiet_on_no_binary = true,
      async_switch_im = true,
    })
  end,
}
