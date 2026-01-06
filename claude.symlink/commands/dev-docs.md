---
allowed-tools: Bash, Read, Write, Glob, Grep, TodoWrite
description: Create comprehensive strategic plan and dev docs for large tasks
---

# Dev Docs System

Creates a structured documentation system for large tasks to maintain context across sessions.

## Usage

```
/dev-docs [task-name]
```

## Instructions

When this command is invoked:

1. **Create dev docs directory structure**:

   ```
   dev/active/[task-name]/
   ├── plan.md      # Strategic implementation plan
   ├── context.md   # Key files, decisions, dependencies
   └── tasks.md     # Detailed task checklist
   ```

2. **Generate plan.md** with:
   - Task overview and objectives
   - High-level implementation strategy
   - Key architectural decisions
   - Risk assessment and mitigation
   - Success criteria

3. **Generate context.md** with:
   - List of key files to be modified
   - Important code patterns and conventions discovered
   - External dependencies and their versions
   - Design decisions and rationale
   - Links to relevant documentation

4. **Generate tasks.md** with:
   - Detailed, actionable task checklist
   - Estimated complexity for each task
   - Dependencies between tasks
   - Progress tracking checkboxes

5. **Update TodoWrite** with the initial tasks

## Template Structure

### plan.md

```markdown
# [Task Name] - Implementation Plan

## Overview

[Brief description of what we're building]

## Objectives

- [ ] Objective 1
- [ ] Objective 2

## Strategy

[High-level approach]

## Architecture Decisions

- Decision 1: [rationale]

## Risks

| Risk | Mitigation |
| ---- | ---------- |
| ...  | ...        |

## Success Criteria

- [ ] Criteria 1
```

### context.md

```markdown
# [Task Name] - Context

## Key Files

- `path/to/file.ts` - [purpose]

## Code Patterns

- Pattern 1: [description]

## Dependencies

- package@version - [why needed]

## Decisions Log

| Date | Decision | Rationale |
| ---- | -------- | --------- |
| ...  | ...      | ...       |
```

### tasks.md

```markdown
# [Task Name] - Tasks

## Phase 1: Setup

- [ ] Task 1 (S)
- [ ] Task 2 (M)

## Phase 2: Implementation

- [ ] Task 3 (L)

## Phase 3: Testing

- [ ] Task 4 (S)

Legend: (S)mall, (M)edium, (L)arge
```

## Notes

- Run `/update-dev-docs` before session compaction to capture progress
- Keep context.md updated as you discover new information
- Check off tasks in tasks.md as you complete them
