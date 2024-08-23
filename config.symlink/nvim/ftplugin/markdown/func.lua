local vim = vim
vim.api.nvim_create_user_command("AddToAnki", function(opts)
  local deck = opts.args
  require("func.anki").add_to_anki(deck)
end, { nargs = "?" })

-- convert_to_note

vim.api.nvim_create_user_command("AddCard", function(args)
  require("func.anki").convert_to_note()
end, { nargs = "?" })
