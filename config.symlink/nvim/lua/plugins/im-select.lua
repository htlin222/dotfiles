-- Input-method auto-switching.
--
-- WHY THIS IS HAND-ROLLED INSTEAD OF using im-select.nvim's autocmds:
-- im-select.nvim reads the current IM with a *synchronous* vim.fn.system() on
-- every InsertEnter/InsertLeave (im_select.lua:130, get_current_select). The
-- `async_switch_im` option only makes the IM *write* async — the *read* always
-- blocks. On macOS the `im-select` binary costs 0.1-1.6s per call, so entering
-- insert mode (o/i/a) and leaving it froze the editor for up to ~2s.
--
-- This reimplements the same three behaviors with vim.system (async, never
-- blocks the UI): on InsertLeave remember the IM and go back to ABC; on
-- InsertEnter restore the IM you last typed with; keep ABC in normal mode.
return {
  "keaising/im-select.nvim",
  event = "VeryLazy",
  config = function()
    -- Non-mac (fcitx5): keep the upstream plugin; its spawn path is cheaper
    -- there and fcitx5-remote is fast.
    if vim.fn.has("mac") ~= 1 then
      require("im_select").setup({
        default_im_select = "1",
        default_command = "fcitx5-remote",
        set_default_events = { "VimEnter", "InsertLeave", "FocusGained" },
        set_previous_events = { "InsertEnter" },
        keep_quiet_on_no_binary = true,
        async_switch_im = true,
      })
      return
    end

    local BIN = "im-select"
    if vim.fn.executable(BIN) ~= 1 then
      return -- keep_quiet_on_no_binary: silently no-op
    end

    local ABC = "com.apple.keylayout.ABC"
    local prev = ABC -- IM last used inside insert mode

    -- fire-and-forget async switch; never blocks
    local function switch(method)
      vim.system({ BIN, method })
    end

    local group = vim.api.nvim_create_augroup("im-select-async", { clear = true })

    -- Leaving insert: async-read the current IM, remember it, then go to ABC so
    -- normal-mode motions (h/j/k/l, etc.) work.
    vim.api.nvim_create_autocmd("InsertLeave", {
      group = group,
      callback = function()
        vim.system({ BIN }, { text = true }, function(o)
          local cur = vim.trim(o.stdout or "")
          if cur ~= "" then
            prev = cur
            if cur ~= ABC then
              switch(ABC)
            end
          end
        end)
      end,
    })

    -- Entering insert: restore the IM you last typed with.
    vim.api.nvim_create_autocmd("InsertEnter", {
      group = group,
      callback = function()
        if prev ~= ABC then
          switch(prev)
        end
      end,
    })

    -- Ensure ABC in normal mode on startup / regaining focus.
    vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained" }, {
      group = group,
      callback = function()
        switch(ABC)
      end,
    })

    switch(ABC)
  end,
}
