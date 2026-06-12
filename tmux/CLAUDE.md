# tmux

- `tmux.conf.symlink` → `~/.tmux.conf`; `tmux.symlink/` → `~/.tmux`
  (TPM plugins live there but are **gitignored** — only config is tracked).
- Prefix is unconventional: `set -g prefix None`, then a root-table `C-a`
  binding that first switches input method to ABC (`im-select`) and then
  enters the prefix client table. Don't "fix" this back to a normal prefix.
- Plugins via TPM: vim-tmux-navigator, tmux-menus, tmux-fzf, tmux-yank,
  extrakto, tmux-open, tmux-jump, tmux-autoreload, tmux-fuzzback,
  tmux-thumbs, tmux-dotbar (status bar, themed by `bin/toggle-theme`),
  tmux-resurrect + tmux-continuum.
- Install new plugins inside tmux with `prefix + I`.
