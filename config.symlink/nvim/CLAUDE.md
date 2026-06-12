# nvim — NvChad v2.5 + lazy.nvim

Live Neovim config, linked as `~/.config/nvim`. (The root-level `neovim/`
dir in this repo is the **legacy** pre-2.5 config — don't edit that one.)

- `init.lua` bootstraps lazy.nvim, then NvChad, then `lua/`.
- Plugin specs live under `lua/plugins/` (~150 specs) — add a plugin by
  adding a spec file/entry there; lazy.nvim picks it up. `lazy-lock.json`
  pins versions and is committed.
- `lua/configs/` — LSP servers and conform.nvim formatters.
- `lua/autocmd/`, `lua/lua_snippets/` — autocommands and snippets.
- Leader key: `Space`. Comments are often in Traditional Chinese — keep
  that style when editing nearby code.
- Notable plugins: codecompanion, telescope, treesitter, conform, neogit,
  quarto, telekasten, obsidian.

After changing plugin specs, verify with `nvim --headless "+Lazy! sync" +qa`
or open nvim and run `:Lazy`.
