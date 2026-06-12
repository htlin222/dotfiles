# start/ — installers

Four entry points, all built on the shared TUI library in `lib/`:

- `bootstrap` — full machine setup: Homebrew → oh-my-zsh (`--unattended`) →
  symlinks → macOS deps (sources `bin/dot`).
- `link_dotfiles` — symlinks only: every `*.symlink` (maxdepth 2) under the
  repo becomes `~/.<basename>`. Idempotent; safe to re-run.
- `install` — `brew bundle` (streamed) + every topic `install.sh` (spinnered;
  failures don't abort the rest).
- `setup_linux.sh` — Pop!_OS/apt setup: packages, oh-my-zsh + plugins, TPM,
  explicit link list, chsh. Unattended: `backup_all=true`, never prompts.

## lib/

- `ui.sh` — source first. Capability-detected TUI: banner boxes, step
  counters (`ui_steps_total` + `ui_step`), status lines (`ui_ok/info/warn/err`),
  `ui_fail` (aborts), `ui_run LABEL CMD…` (spinner; captures output, shows
  last 15 lines on failure, returns the command's rc), `ui_done` (elapsed).
  Degrades for non-tty / `NO_COLOR` / `TERM=dumb` / non-UTF-8 locales.
- `links.sh` — source after ui.sh; needs `$DOTFILES_ROOT` set. `link_file
  src dst` with conflict policy globals (`overwrite_all`/`backup_all`/
  `skip_all` — set before calling to skip prompts), `install_dotfiles`
  (the find loop), `links_summary` (counters). Has an `-ef` self-link guard
  so linking the repo onto itself can't move it away.

## Constraints

- **Bash 3.2** — runs on fresh macOS before Homebrew installs bash 5.
  No associative arrays, no `${var,,}`, no `readarray`.
- Pad TUI strings by character count, not `printf %-*s` (bytes) — multibyte
  glyphs break box alignment otherwise.
- Don't spinner commands that prompt (sudo apt, brew bundle) — stream them.
- Verify with `bash -n`, `shellcheck --severity=warning`, and a sandbox run:
  fake `$HOME` + fake repo, execute with `/bin/bash` (3.2).
