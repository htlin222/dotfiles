# ORCHESTRATOR.md - SuperClaude Routing System

## Resource Thresholds

- **Green** (0-60%): Full operations
- **Yellow** (60-75%): Suggest --uc mode
- **Orange** (75-85%): Defer non-critical ops
- **Red** (85-95%): Force efficiency modes
- **Critical** (95%+): Essential ops only

## Complexity Levels

| Level    | Indicators             | Token Budget |
| -------- | ---------------------- | ------------ |
| Simple   | Single file, <3 steps  | 5K           |
| Moderate | Multi-file, 3-10 steps | 15K          |
| Complex  | System-wide, >10 steps | 30K+         |

## Domain Keywords

- **frontend**: UI, component, React, Vue, CSS, responsive
- **backend**: API, database, server, endpoint, auth
- **security**: vulnerability, encryption, audit, compliance
- **docs**: document, README, wiki, guide, changelog

## Tool Selection

| Need             | Tool           |
| ---------------- | -------------- |
| Search patterns  | Grep           |
| File discovery   | Glob           |
| Complex analysis | Sequential MCP |
| Library docs     | Context7 MCP   |
| UI components    | Magic MCP      |
| E2E testing      | Playwright MCP |

## Token Efficiency Hierarchy

1. **Direct Tools** (minimal): Grep, Read, Glob, Edit
2. **Skills** (low): /commit, /map, /prime, /checkpoint
3. **Task Agents** (high): Only for parallel processing

## Auto-Activation Triggers

| Condition       | Action             |
| --------------- | ------------------ |
| Dirs >7         | --delegate folders |
| Files >50       | --delegate files   |
| Complexity >0.8 | --wave-mode        |
| Context >75%    | --uc               |

## Persona Activation

| Domain             | Persona     | Confidence |
| ------------------ | ----------- | ---------- |
| Performance issues | performance | 85%        |
| Security concerns  | security    | 90%        |
| UI/UX tasks        | frontend    | 80%        |
| Complex debugging  | analyzer    | 75%        |
| Documentation      | scribe      | 70%        |

## Flag Precedence

1. Safety flags > optimization
2. Explicit > auto-activation
3. --ultrathink > --think-hard > --think
4. --no-mcp overrides all MCP flags
5. system > project > module > file scope

## Quality Gates (8-step)

1. Syntax validation
2. Type checking
3. Lint/quality
4. Security scan
5. Test coverage (≥80% unit)
6. Performance check
7. Documentation
8. Integration test

## Emergency Recovery

- MCP Timeout → fallback server
- Token Limit → activate --uc
- Tool Failure → alternative tool
