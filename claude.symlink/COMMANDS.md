# Commands (Compressed)

## Wave-Enabled (Tier 1)

| Cmd        | Purpose                    | Personas                      | MCP                         |
| ---------- | -------------------------- | ----------------------------- | --------------------------- |
| /analyze   | Multi-dimensional analysis | Analyzer, Architect, Security | Sequential, Context7        |
| /build     | Project builder            | Frontend, Backend, Architect  | Magic, Context7, Sequential |
| /implement | Feature implementation     | Frontend, Backend, Security   | Magic, Context7, Sequential |
| /improve   | Evidence-based enhancement | Refactorer, Performance, QA   | Sequential, Context7        |

## Wave-Enabled (Tier 2)

| Cmd     | Purpose              | Personas            | MCP                         |
| ------- | -------------------- | ------------------- | --------------------------- |
| /design | Design orchestration | Architect, Frontend | Magic, Sequential, Context7 |
| /task   | Project management   | Architect, Analyzer | Sequential                  |

## Standard Commands

| Cmd           | Purpose               | Personas            | MCP                    |
| ------------- | --------------------- | ------------------- | ---------------------- |
| /troubleshoot | Problem investigation | Analyzer, QA        | Sequential, Playwright |
| /explain      | Educational           | Mentor, Scribe      | Context7, Sequential   |
| /cleanup      | Tech debt reduction   | Refactorer          | Sequential             |
| /document     | Documentation         | Scribe, Mentor      | Context7, Sequential   |
| /estimate     | Evidence estimation   | Analyzer, Architect | Sequential, Context7   |
| /test         | Testing workflows     | QA                  | Playwright, Sequential |
| /git          | Git workflow          | DevOps, Scribe, QA  | Sequential             |

## Meta Commands

| Cmd    | Purpose                 |
| ------ | ----------------------- |
| /index | Command catalog         |
| /load  | Project context loading |
| /spawn | Task orchestration      |
| --loop | Iterative refinement    |

## Arguments

- `[target]`: Primary argument
- `@<path>`: File/folder reference
- `!<command>`: Shell command
- `--<flags>`: Modifier flags

## Wave Trigger

Auto-activates: complexity ≥0.7 + files >20 + operation_types >2
