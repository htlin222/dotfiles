# Flags (Compressed)

## Thinking

| Flag         | Tokens | Auto-Trigger            | Enables    |
| ------------ | ------ | ----------------------- | ---------- |
| --think      | 4K     | imports>5, refs>10      | --seq      |
| --think-hard | 10K    | refactor, bottlenecks>3 | --seq --c7 |
| --ultrathink | 32K    | legacy, critical vuln   | --all-mcp  |

## Efficiency

| Flag          | Effect                             |
| ------------- | ---------------------------------- |
| --uc          | 30-50% reduction, auto@context>75% |
| --answer-only | Direct response, no workflow       |
| --validate    | Pre-op validation, auto@risk>0.7   |
| --safe-mode   | Max validation, auto@context>85%   |

## MCP

| Flag      | Server     | Auto-Trigger                         |
| --------- | ---------- | ------------------------------------ |
| --c7      | Context7   | library imports, framework questions |
| --seq     | Sequential | debugging, --think flags             |
| --magic   | Magic      | UI components, design                |
| --play    | Playwright | testing, E2E                         |
| --all-mcp | All        | complexity>0.8                       |
| --no-mcp  | None       | 40-60% faster                        |

## Delegation

| Flag                              | Effect                                    |
| --------------------------------- | ----------------------------------------- |
| --delegate [files\|folders\|auto] | Sub-agent parallel, auto@dirs>7\|files>50 |
| --concurrency [n]                 | Max agents (default:7, 1-15)              |
| --prefer-skills                   | Skills>Tasks (60-80% savings)             |

## Wave

| Flag                           | Effect                                        |
| ------------------------------ | --------------------------------------------- |
| --wave-mode [auto\|force\|off] | Auto@complexity>0.8+files>20+ops>2            |
| --wave-strategy                | progressive\|systematic\|adaptive\|enterprise |

## Scope

- --scope: file\|module\|project\|system
- --focus: performance\|security\|quality\|architecture\|accessibility\|testing

## Loop

| Flag             | Effect                            |
| ---------------- | --------------------------------- |
| --loop           | Iterative mode (default:3 cycles) |
| --iterations [n] | Cycle count (1-10)                |
| --interactive    | User confirm between cycles       |

## Personas

architect\|frontend\|backend\|analyzer\|security\|mentor\|refactorer\|performance\|qa\|devops\|scribe=lang

## Precedence

safety > explicit > thinking(ultra>hard>think) > --no-mcp > scope(system>project>module>file)
