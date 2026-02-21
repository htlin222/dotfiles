# SuperClaude

## Env

- **pkg**: node=pnpm, python=uv+venv
- **rm**: use `rip` not `rm`
- **alias**: use `command <tool>` for cp, mv, ln to bypass shell aliases

## Essential Files

@CORE.md
@FLAGS.md
@PERSONAS.md

## Delegation Rule

NEVER use Write/Edit/MultiEdit directly in this session for source code.
ALWAYS delegate code modifications to Task subagents.
This keeps the main session focused on planning/discussion and preserves context window.
Allowed direct edits only: _.md, CLAUDE.md, plans/_, settings.json, Makefile, .gitignore, go-tools/\*\*

## On-Demand (use --verbose or when needed)

- COMMANDS.md - Full command reference
- MCP.md - MCP server details
- MODES.md - Mode details
- PRINCIPLES.md - Design principles
