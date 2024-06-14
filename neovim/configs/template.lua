return {
  "glepnir/template.nvim",
  -- lazy = false,
  -- event = "VeryLazy",
  cmd = { "Template", "TemProject" },
  config = function()
    local stack_dir = tostring(vim.fn.expand("%:p:h")) .. "/template"
    local temp_dir_path = tostring(stack_dir)
    print(temp_dir_path)
    require("template").setup({
      -- temp_dir = temp_dir_path,
      temp_dir = "~/Documents/Medical/template/",
      author = "Hsieh-Ting Lin 🦎", -- your name
      email = "1izard@duck.com", -- email address       -- config in there
    })
  end,
}

-- lazy load you can use cmd or ft. if you are using cmd to lazyload when you edit the template file
-- you may see some diagnostics in template file. use ft to lazy load the diagnostic not display
-- when you edit the template file.
-- {{_date_}} insert current date
--
-- {{_cursor_}} set cursor here
--
-- {{_file_name_}} current file name
--
-- {{_author_}} author info
--
-- {{_email_}} email adrress
--
-- {{_variable_}} variable name
--
-- {{_upper_file_}} all-caps file name
--
-- {{_lua:vim.fn.expand(%:.:r)_}} set by lua script
-- Define your template
-- You need to configure the setting variable temp_dir.
-- An example configuration: temp.temp_dir = '~/.config/nvim/template.
-- Create the directory at the location specified then proceed to add template files.
--require("telescope").load_extension('find_template')
