local vim = vim
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.md",
  callback = function()
    if vim.fn.filereadable ".iswiki" == 1 and not vim.b.inserted then
      vim.b.inserted = true
      local filename = vim.fn.expand "%:t:r"
      local title = filename:gsub("_", " ")
      local date = os.date "%Y-%m-%d"
      local previous = vim.g.previous or ""

      local lines = {
        "---",
        "title: '" .. title .. "'",
        'date: "' .. date .. '"',
        "---",
        "",
        "> [!info]",
        ">",
        "> 🌱 來自: [[" .. previous .. "]]",
        "",
        "# " .. filename,
      }

      vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)
    end
  end,
})
