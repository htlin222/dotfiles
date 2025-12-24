# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Zsh Configuration Architecture

This is a zsh dotfiles configuration system with a modular architecture centered around performance optimization and lazy loading. The configuration uses Oh-My-Zsh as the base framework with custom plugin management.

### Core Structure

- **Main config**: `zshrc.symlink` - Entry point with performance-optimized plugin loading
- **Modules**: `modules/` - Modular configuration files loaded on demand
- **Functions**: `functions.zsh` - Custom function definitions
- **Symlinks**: Files ending in `.symlink` are designed to be symlinked to `~/.zsh*`

### Plugin Loading Strategy

The configuration implements a sophisticated 3-tier plugin loading system:

1. **EAGER_PLUGINS**: Core plugins loaded immediately (git, zsh-lazyload, fast-syntax-highlighting)
2. **PROMPT_PLUGINS**: Loaded on first prompt display (zsh-autosuggestions)
3. **KEYPRESS_PLUGINS**: Loaded on first keypress (zsh-vi-mode, fzf-tab, zsh-autopair)
4. **DEFERRED_PLUGINS**: Loaded in background after shell start (colored-man-pages, copyfile, etc.)

### Module System

Configuration is split into focused modules in `modules/`:

**Core Modules:**

- `alias.zsh`: Command aliases and shortcuts
- `fzf.zsh`: FZF fuzzy finder configuration
- `note_related.zsh`: Note-taking and documentation functions

**Function Modules (split for maintainability):**

- `fn_navigation.zsh`: Navigation & file managers (ya, fcd, mkcd, up, gitop)
- `fn_git.zsh`: Git workflows (zgit, ygit, dp, dotrelease, gist)
- `fn_fzf.zsh`: FZF-related functions (fzf-pre, rgnv, vg, neovim_fzf)
- `fn_utils.zsh`: Utilities (notify, timezsh, topdf, ex, swap)
- `fn_dev.zsh`: Development tools (chrome-debug, brew-switch, netlify_pub)
- `fn_notes.zsh`: Note-taking (hh, study, dia, drafts, anki)
- `fn_media.zsh`: Media processing (yt-mp3, joinmp4, convert_mp4_to_gif)
- `fn_macos.zsh`: macOS-only functions (unlock, unblock, ignore*dropbox*\*)

## Common Development Commands

### Zsh Configuration Management

- `zshconfig` - Edit main zsh configuration
- `reload` - Reload shell configuration
- `timezsh` - Benchmark shell startup time

### Navigation and File Management

- `ya` - Yazi file manager with directory changing
- `fcd` - Fuzzy find and change directory
- `mkcd <dir>` - Create and change to directory
- `cdf` - Fuzzy find directory and cd

### Development Tools

- `vf` - Fuzzy find and edit files with nvim
- `gitop` - Navigate to git repository root
- `dp` - Commit and push dotfiles with AI-generated commit message
- `zgit` - Add, commit with AI, and push in one command

### Note Taking and Documentation

- `hh` - Search and edit markdown files in Dropbox
- `study` - Navigate medical documentation
- `dia` - Create/edit daily diary entries
- `rgnv` - Ripgrep search with nvim opening

### Utilities

- `unlock` - Remove macOS app quarantine
- `remind <text> <date>` - Add system reminders
- `topdf <file>` - Convert documents to PDF
- `ya` - Yazi file manager integration

## Performance Optimizations

The configuration includes several performance features:

### Cached Path Checking

- Uses `_cached_path_check()` to cache expensive directory existence checks
- Caches results in `$ZSH_CACHE_DIR/.path_cache`

### Async Loading

- Completions loaded asynchronously with `_load_completions_async()`
- Deferred initialization for heavy tools like forgit
- Background loading of plugin systems

### Compilation

- Automatic compilation of completion dumps to `.zwc` files
- Lazy compilation triggered only when needed

## Environment Variables

Key environment variables set in `zprofile.symlink`:

- `DOTFILES`: Path to dotfiles directory
- `EDITOR`/`VISUAL`: Set to nvim
- `PIPX_DEFAULT_PYTHON`: Fixed Python version for pipx
- Various PATH additions for tools and scripts

## Function Ecosystem

The configuration includes 100+ custom functions covering:

- Git workflow automation (`zgit`, `ygit`, `gitacp`)
- File management (`ya`, `fcd`, `mkcd`)
- Note-taking (`hh`, `study`, `dia`)
- Media processing (`yt-mp3`, `convert_mp4_to_gif`)
- Development shortcuts (`vf`, `gitop`)
- System utilities (`unlock`, `remind`)

## Shell Integration

- **Tmux**: Auto-starts tmux in WezTerm
- **FZF**: Configured with custom colors and fd integration
- **Powerlevel10k**: Theme with instant prompt for fast startup
- **Atuin**: History search integration (deferred loading)
- **Python venv**: Auto-activation of `.venv` if present

## Testing and Maintenance

- Use `timezsh` to benchmark shell startup performance
- Debug with `ZSH_DEBUGRC=1` environment variable to enable zprof
- Plugin loading errors are handled gracefully with warning messages
- Failed plugins don't break the shell startup process
