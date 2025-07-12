# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a sophisticated Neovim configuration built on NvChad v2.5, heavily customized for academic/research workflows with a focus on:
- Markdown/Quarto document authoring
- Data science (Python, R, Julia)
- Multilingual support (English/Chinese)
- Note-taking and knowledge management

## Commands

### Plugin Management (lazy.nvim)
```bash
# Update plugins
:Lazy sync

# Check plugin status
:Lazy

# Profile plugin load times
:Lazy profile
```

### Linting & Formatting
```bash
# Manually trigger linting (or use <leader>ll)
:lua require("lint").try_lint()

# Format current buffer (or happens on save automatically)
:lua require("conform").format()

# Check formatters for current buffer
:ConformInfo
```

### LSP Commands
```bash
# LSP info for current buffer
:LspInfo

# Restart LSP
:LspRestart

# Check Mason-installed tools
:Mason
```

## Architecture

### Core Structure
- **init.lua**: Entry point that bootstraps lazy.nvim and loads NvChad
- **lua/init.lua**: Environment detection (VSCode, WezTerm) and conditional loading
- **lua/options.lua**: Neovim settings and options
- **lua/mappings.lua**: Key bindings organized by functionality
- **lua/plugins/**: Individual plugin specifications with lazy-loading rules
- **lua/configs/**: Plugin configurations (LSP, formatters, linters, etc.)
- **lua/autocmd/**: Autocommands organized by purpose (editing, filetypes, etc.)

### Key Design Patterns

1. **Environment-Aware Configuration**: The config adapts based on whether it's running in:
   - Regular Neovim
   - VSCode Neovim extension
   - WezTerm terminal

2. **Language Server Protocol (LSP)**: Extensive LSP configurations in `lua/configs/lspconfig.lua` with:
   - Debounced text changes (1.5s) for performance
   - Custom handlers for diagnostics and hover
   - Language-specific server configurations

3. **Snippet System**: Two parallel snippet systems:
   - LuaSnip-based snippets in `lua/lua_snippets/`
   - VSCode-compatible snippets in `lua/vscode_snippets/`
   - Academic/medical focused snippets (oncology, statistics)

4. **Autocommand Organization**: Autocommands are categorized in `lua/autocmd/`:
   - `editing.lua`: Text manipulation (whitespace, Chinese spacing)
   - `filetype.lua`: Filetype-specific behaviors
   - `misc.lua`: General utilities (auto-save, last position)
   - `folding.lua`: Code folding with TreeSitter

5. **Data-Driven Features**: JSON data files in `lua/data/` for:
   - Emoji picker
   - Mathematical symbols
   - LaTeX shortcuts
   - Symbol mappings

### Plugin Management Strategy

Uses lazy.nvim with:
- Lazy loading by default (unless `lazy = false`)
- Event-based loading (BufReadPost, InsertEnter, etc.)
- Command-based loading
- Version locking via `lazy-lock.json`

### Formatting & Linting Architecture

**Conform.nvim** handles formatting:
- Format on save (3.5s timeout)
- Language-specific formatters
- Fallback chains (e.g., prettier → prettierd)

**nvim-lint** handles linting:
- Triggers on BufWritePost
- Debounced execution
- Multiple linters per filetype

### Notable Integrations

- **Academic Tools**: Zotero citations, BibTeX, Quarto
- **Note-Taking**: Markdown enhancements, wiki links, Anki integration
- **Terminal**: Toggleterm with custom terminals (ipython, julia)
- **AI/Completion**: Codeium integration for AI completions
- **Version Control**: Gitsigns, diffview, git-conflict

## Development Tips

1. When modifying plugins, add specs to `lua/plugins/` directory
2. LSP server configurations go in `lua/configs/lspconfig.lua`
3. Formatter/linter configs are in `lua/configs/conform.lua` and `lua/configs/nvim-lint.lua`
4. Use `:Lazy reload {plugin}` to reload specific plugins during development
5. Check `lua/mappings.lua` before adding new keybindings to avoid conflicts
6. The configuration uses Traditional Chinese comments - maintain this convention
7. Test changes in both regular Neovim and VSCode to ensure compatibility