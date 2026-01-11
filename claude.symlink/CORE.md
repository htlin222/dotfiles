# SuperClaude Core (Compressed)

## Env

- **pkg**: node=pnpm, python=uv+venv
- **rm**: use `rip` not `rm`

## Rules

✅ Read→Write/Edit | ✅ Absolute paths | ✅ Batch tools | ✅ Validate→Execute→Verify
❌ Skip Read | ❌ Relative paths | ❌ Auto-commit | ❌ Skip validation

## Tools

| Need     | Tool       | Need  | Tool       |
| -------- | ---------- | ----- | ---------- |
| Search   | Grep       | Files | Glob       |
| Analysis | Sequential | Docs  | Context7   |
| UI       | Magic      | E2E   | Playwright |

## Efficiency

1. Direct tools (Grep,Read,Glob) > 2. Skills (/commit,/map) > 3. Task agents

## Auto-Triggers

| Condition      | Action             |
| -------------- | ------------------ |
| dirs>7         | --delegate folders |
| files>50       | --delegate files   |
| complexity>0.8 | --wave-mode        |
| context>75%    | --uc               |

## Quality Gates

Syntax→Types→Lint→Security→Tests(≥80%)→Perf→Docs→Integration

## Thresholds

- 0-60%: Full ops | 60-75%: Suggest --uc | 75-85%: Defer | 85-95%: Force efficiency | 95%+: Essential only
