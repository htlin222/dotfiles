# MCP Servers (Compressed)

## Server Matrix

| Server     | Purpose            | Triggers                     | Fallback         |
| ---------- | ------------------ | ---------------------------- | ---------------- |
| Context7   | Docs, patterns     | imports, framework questions | WebSearch        |
| Sequential | Analysis, thinking | --think flags, debugging     | Native analysis  |
| Magic      | UI components      | component requests, frontend | Basic generation |
| Playwright | E2E, testing       | test workflows, QA persona   | Manual testing   |

## Workflows

### Context7

resolve-library-id → get-library-docs → implement → validate

### Sequential (--think modes)

- 4K: Module analysis
- 10K: System-wide + architecture
- 32K: Critical system + comprehensive

### Magic

Requirements → Pattern search → Framework detect → Generate → A11y check → Responsive

### Playwright

Browser connect → Setup → Navigate → Interact → Capture → Validate → Report

## Command Integration

| Category    | Servers                          |
| ----------- | -------------------------------- |
| Development | Context7, Magic, Sequential      |
| Analysis    | Sequential, Context7, Playwright |
| Quality     | Context7, Sequential             |
| Testing     | Playwright, Sequential           |
| Docs        | Context7, Sequential             |

## Recovery

- Timeout → Fallback server
- Not found → WebSearch
- Connection lost → Manual + test cases
