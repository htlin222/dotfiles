# pyscripts — Python utilities

~47 standalone Python 3 scripts, linked to `~/pyscripts` and on PATH via
`zsh/zprofile.symlink`. macOS-centric (osascript automation) with heavy
API integration: OpenAI, AnkiWeb (`add_md_to_anki.py`), Imgur, Bitly.

Conventions:

- `#!/usr/bin/env python3` shebang (a few pin a pyenv venv path on purpose
  — leave those alone), `# -*- coding: utf-8 -*-`, then a
  `# title:` / `# date:` / `# author:` header.
- Input usually comes from the clipboard or stdin rather than argv.
- Credentials come from env vars or `openai_api.yaml` — never hardcode.
- Python env management is `uv` + venv (per global CLAUDE.md), not pip.
