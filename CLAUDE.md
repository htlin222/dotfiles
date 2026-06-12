# dotfiles — repo guide

Personal macOS/Linux dotfiles. Topic-per-directory layout; anything named
`*.symlink` gets linked into `$HOME` as `.<name>` by `start/link_dotfiles`
(e.g. `zsh/zshrc.symlink → ~/.zshrc`, whole dirs too: `claude.symlink → ~/.claude`).

## Map

| Path | What it is |
| --- | --- |
| `start/` | Installers: `bootstrap`, `install`, `link_dotfiles`, `setup_linux.sh` + shared TUI in `start/lib/` (see its CLAUDE.md) |
| `zsh/` | Modular zsh config, lazy plugin loading (see its CLAUDE.md) |
| `claude.symlink/` | `~/.claude` — global CLAUDE.md/CORE/FLAGS/PERSONAS/RTK, `settings.json`, 45 skills, hooks. **Mostly gitignored; only whitelisted paths are tracked** (see `.gitignore` lines 58–67) |
| `claude.symlink/go-tools/` | Go source for `claude-hooks` + `claude-statusline` binaries (see its CLAUDE.md) |
| `config.symlink/` | `~/.config` — ~90 app configs (nvim, wezterm, kitty, helix, yazi, …) |
| `config.symlink/nvim/` | Live Neovim config: NvChad v2.5 + lazy.nvim |
| `neovim/` | **Legacy** NvChad-custom config (pre-2.5); kept for reference, not linked |
| `hammerspoon.symlink/` | Hammerspoon: hyper key, vim mode, window management |
| `tmux/` | tmux.conf + TPM plugins (plugins themselves gitignored) |
| `git/` | gitconfig (delta pager, difftastic on demand, GPG signing), global ignores |
| `bin/` | `dot` (sourced by `start/bootstrap` for macOS deps), `toggle-theme` (light/dark for Ghostty/tmux/Claude) |
| `shellscripts/` | ~70 bash utilities, on PATH via zprofile |
| `pyscripts.symlink/` | ~47 Python utilities (`~/pyscripts`, on PATH) |
| `osx/` | `set-defaults.sh` — macOS `defaults write` settings |
| `system/` | Early-loading zsh env/path fragments |
| `docs/` | Quarto book (`_quarto.yml`), deployed via Netlify |
| `Brewfile` | Homebrew bundle (~370 formulae, ~250 casks), consumed by `start/install` |

## Conventions

- **Bash 3.2 compatibility** in `start/` — bootstrap runs on fresh macOS
  before Homebrew exists. No assoc arrays, no `${var,,}`.
- New shell scripts: run `shellcheck` before committing.
- `claude.symlink/CLAUDE.md` is the **global Claude instructions file**
  (SuperClaude config), not repo documentation — don't put repo docs there.
- Secrets live in gitignored `.env` files (`**/.env`); `.env.example`
  documents the keys. Never commit credentials (gitleaks runs via husky
  pre-commit).
- Commit style: conventional commits (`feat:`, `fix:`, `chore:` …).

## Common tasks

- Relink dotfiles: `start/link_dotfiles`
- Rebuild hooks after Go changes: `make -C claude.symlink/go-tools install`
  (builds + copies `claude-hooks`/`claude-statusline` to `~/.local/bin`)
- `dp` (zsh function) — commit + push dotfiles with AI commit message
