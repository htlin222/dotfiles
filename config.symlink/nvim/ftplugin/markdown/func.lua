local vim = vim
vim.api.nvim_create_user_command("AddToAnki", function(opts)
  local deck = opts.args
  require("func.anki").add_to_anki(deck)
end, { nargs = "?" })

-- convert_to_note

vim.api.nvim_create_user_command("AddCard", function(args)
  require("func.anki").convert_to_note()
end, { nargs = "?" })

-- remove_under_score_and_capitalize

vim.api.nvim_create_user_command("RemoveSpaceAndCap", function(args)
  require("func").remove_under_score_and_capitalize()
end, { nargs = "?" })
