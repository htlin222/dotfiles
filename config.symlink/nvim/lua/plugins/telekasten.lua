local vim = vim
local function determine_home()
  local current_file_path = vim.fn.expand "%:p"
  local inbox_path = vim.fn.expand "~/Dropbox/inbox"
  local medical_path = vim.fn.expand "~/Dropbox/Medical"
  if string.sub(current_file_path, 1, string.len(inbox_path)) == inbox_path then
    return inbox_path
  else
    return medical_path
  end
end
return { --telekasten
  "renerocksai/telekasten.nvim",
  cmd = { "Telekasten" }, -- 只在使用 Telekasten 命令時載入
  keys = {
    { "<leader>z", "<cmd>Telekasten panel<CR>", desc = "Telekasten panel" },
    { "<leader>zf", "<cmd>Telekasten find_notes<CR>", desc = "Find notes" },
    { "<leader>zg", "<cmd>Telekasten search_notes<CR>", desc = "Search notes" },
    { "<leader>zd", "<cmd>Telekasten goto_today<CR>", desc = "Go to today" },
    { "<leader>zn", "<cmd>Telekasten new_note<CR>", desc = "New note" },
    { "<leader>zc", "<cmd>Telekasten show_calendar<CR>", desc = "Show calendar" },
    { "<leader>zb", "<cmd>Telekasten show_backlinks<CR>", desc = "Show backlinks" },
    { "<leader>zI", "<cmd>Telekasten insert_img_link<CR>", desc = "Insert image link" },
  },
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    -- 插入模式快捷鍵（不在 keys 表中）
    vim.keymap.set("i", "\\[", "<cmd>Telekasten insert_link<CR>", { desc = "Insert link" })
    -- 註冊 treesitter parser
    vim.treesitter.language.register("markdown", "telekasten")

    require("telekasten").setup {
      subdirs_in_links = false,
      -- home = vim.fn.expand("~/Dropbox/inbox"), -- Put the name of your notes directory here
      -- home = vim.fn.expand("~/Dropbox/Medical"), -- Put the name of your notes directory here
      home = determine_home(),
      auto_set_filetype = false,
      tag_notation = "yaml-bare",
      template_new_note = vim.fn.expand "~/Dropbox/Medical/template/new_note.md",
      template_new_daily = vim.fn.expand "~/Dropbox/Medical/template/new_daily.md",
      template_new_weekly = vim.fn.expand "~/Dropbox/Medical/template/new_weekly.md",
    }
  end,
}
