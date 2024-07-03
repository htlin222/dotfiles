local vim = vim
vim.api.nvim_create_user_command("AddToAnki", function(opts)
  local deck = opts.args
  require("func.anki").add_to_anki(deck)
end, { nargs = "?" })
