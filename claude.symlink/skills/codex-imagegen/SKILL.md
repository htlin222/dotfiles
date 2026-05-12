---
name: codex-imagegen
description: Generate an image and write it to a local file by delegating to the Codex CLI agent, which calls OpenAI's images API (gpt-image-1) and saves the result. Use when the user asks for an image to be created/drawn/generated AND saved to a path (e.g. "幫我生一張戴墨鏡的柴犬，存成 tmp/shiba.png", "draw me X and save to images/y.png", "用 codex 生圖"). Requires `codex login` AND `$OPENAI_API_KEY` set in the environment.
---

# codex-imagegen

## Overview

This skill drives the Codex CLI agent (`codex exec`) and asks it to produce a PNG at a path the caller chooses. On this machine the agent does **not** invoke a built-in `image_generation` tool — instead it shells out to `https://api.openai.com/v1/images/generations` with model `gpt-image-1`, base64-decodes the response, and writes the PNG. The wrapper handles the friction: companion-env interception, sandbox/network confinement, path resolution, output verification.

## When to use

Trigger when the user's request has both:
1. An image-generation intent — "生圖 / 畫一張 / generate / draw / create an image of …", and
2. A target file path — "存成 X.png", "save to X.png", or an output directory.

If only (1) is present, ask for the path before proceeding.

## How to use

Run the bundled script. It takes the output path as the first argument and the description as the rest:

```bash
bash {SKILL_DIR}/scripts/imagegen.sh <output-path> <description...>
```

`{SKILL_DIR}` is this skill's folder. From inside Claude Code use the absolute path
`/Users/htlin/.claude/skills/codex-imagegen/scripts/imagegen.sh` (or the dotfiles
source `/Users/htlin/.dotfiles/claude.symlink/skills/codex-imagegen/scripts/imagegen.sh`).

The script:
- Errors out if `codex` is missing or `codex login status` does not say "Logged in".
- Resolves a relative output path against the current working directory and `mkdir -p` the parent.
- Calls `codex exec -C "$(pwd)" -s workspace-write --skip-git-repo-check` with a Chinese prompt that instructs codex to use the image generation tool and save to the absolute output path.
- Fails (exit 1) if no file was written, otherwise prints `wrote <path> (<bytes> bytes)`.

## Smoke test

The canonical smoke test from the article:

```bash
bash /Users/htlin/.claude/skills/codex-imagegen/scripts/imagegen.sh tmp/shiba.png 戴墨鏡的柴犬
```

Expected: a PNG (~1–3 MB, ~1024px square or larger) at `tmp/shiba.png` and a final line `wrote /…/tmp/shiba.png (<bytes> bytes)`.

## Notes

Things the wrapper does that aren't obvious from the article:

- **Strips `CODEX_COMPANION_SESSION_ID` and `CLAUDE_PLUGIN_DATA`.** When this skill runs from inside Claude Code, those env vars are inherited from the Codex Companion plugin. Left alone, the companion intercepts `codex exec` and pipes the existing companion-session prompt into it (you'll see `user / reply with ok` in the codex log). Unsetting both forces a fresh exec.
- **Uses `--dangerously-bypass-approvals-and-sandbox`.** The article uses `-s workspace-write`, but on this machine the codex agent does not have a built-in image_generation tool and instead `curl`s `https://api.openai.com/v1/images/generations` itself. `workspace-write` blocks that egress, so the agent gives up after exploration. Full bypass lets it through.
- **Requires `$OPENAI_API_KEY`.** Despite the article's "ChatGPT login is enough" claim, the agent on this machine reads `$OPENAI_API_KEY` directly. The wrapper warns (does not abort) when missing, in case the user is running in a session where ChatGPT auth does work.
- **Verifies the file landed.** Codex sometimes claims success without writing — the wrapper exits non-zero unless the target file exists and is non-empty.
- First image-gen run can take 30–60 s; later runs are faster.
