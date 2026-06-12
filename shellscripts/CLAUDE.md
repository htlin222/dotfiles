# shellscripts — bash utilities

~70 standalone bash scripts, on PATH via `zsh/zprofile.symlink`
(`$HOME/.dotfiles/shellscripts`). Mostly macOS-targeted; mixed
English/Traditional-Chinese comments and emoji-heavy output are the
house style.

Conventions for new scripts:

- Header block: `# title:` / `# author:` / `# date:` / `# description:`.
- Positional args validated with `$#` checks + a usage message; `exit 1`
  on bad input.
- Run `shellcheck` before committing.

Recurring themes: media conversion (ffmpeg), document conversion
(pandoc → PDF), tmux popups, Downloads cleanup, OpenAI-via-curl helpers.
