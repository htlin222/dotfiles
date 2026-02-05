if vim.loader then
  vim.loader.enable()
end

local uv = vim.uv or vim.loop
vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

local function safe_dofile(path)
  local ok, err = pcall(dofile, path)
  if not ok then
    vim.schedule(function()
      vim.notify(("Failed to load %s: %s"):format(path, err), vim.log.levels.WARN)
    end)
  end
end

local function load_base46()
  local defaults = vim.g.base46_cache .. "defaults"
  local statusline = vim.g.base46_cache .. "statusline"

  if uv.fs_stat(defaults) and uv.fs_stat(statusline) then
    safe_dofile(defaults)
    safe_dofile(statusline)
    return
  end

  local ok, base46 = pcall(require, "base46")
  if ok and base46 and base46.load_all_highlights then
    pcall(base46.load_all_highlights)
  end

  if uv.fs_stat(defaults) then
    safe_dofile(defaults)
  end
  if uv.fs_stat(statusline) then
    safe_dofile(statusline)
  end
end

-- load theme
load_base46()

require "options"
require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)
