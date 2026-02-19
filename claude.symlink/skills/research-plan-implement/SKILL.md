---
name: research-plan-implement
description: Enforces a three-phase RPI workflow (Research, Plan, Implement) for code changes. Use when tackling non-trivial features, refactors, or bug fixes in medium-to-large codebases to prevent context waste and ensure correctness over speed.
---

# Research-Plan-Implement (RPI)

A disciplined three-phase workflow that trades speed for clarity, predictability, and correctness. Each phase has a validation gate that must pass before proceeding.

**Core principle**: Never let AI write code without first researching the codebase and producing a validated plan. A 1-page plan gives 10x leverage over reviewing 1,000 lines of AI code.

## When to Use

- Non-trivial features, refactors, or bug fixes
- Unfamiliar or large codebases
- Tasks where incorrect code is costlier than slow code
- When previous direct-implementation attempts have failed

## When NOT to Use

- Single-line fixes, typos, or trivial changes
- Tasks where you already have full context and a clear path
- Exploratory prototyping (use RPI when hardening the prototype)

## Workflow

Copy this checklist and track progress:

```
- [ ] Phase 1: Research (FAR validated)
- [ ] Phase 2: Plan (FACTS validated)
- [ ] Phase 3: Implement (verified)
```

---

## Phase 1: Research

**Goal**: Explore the codebase, find the right files. Make ZERO modifications.

Use sub-agents (Task tool with `Explore` type) to read broadly without polluting the main context. Sub-agents return only compressed facts.

### Research Outputs

For each finding, record:
- **File path** and **line number(s)**
- **What** exists there (function signature, data structure, pattern)
- **Why** it matters to the current task

### FAR Validation Gate

Every finding must pass all three:

| Check | Question | Fail Example |
|-------|----------|-------------|
| **F**actual | Is this from actual code, not assumption? | "There's probably a config file somewhere" |
| **A**ctionable | Does it include specific file path + line number? | "The auth module handles this" |
| **R**elevant | Is it directly related to the task? | Documenting unrelated utility functions |

**Template for research summary**:

```markdown
## Research Findings for: {task description}

### Finding 1: {short title}
- **File**: `src/auth/middleware.ts:42-67`
- **What**: `validateToken()` checks JWT expiry and role claims
- **Why**: We need to extend this to support API key auth

### Finding 2: {short title}
- **File**: `src/types/auth.ts:15-23`
- **What**: `AuthContext` interface defines `user`, `token`, `roles`
- **Why**: Must add `apiKey` field here

### FAR Check
- [x] All findings reference actual code with paths and line numbers
- [x] No assumptions or guesses included
- [x] Every finding directly relates to the task
```

**Do NOT proceed to Phase 2 until FAR passes.**

---

## Phase 2: Plan

**Goal**: Produce a step-by-step plan where each step has code-level specificity.

A plan without code snippets is just a "feeling" -- it has no execution power.

### Plan Structure

For each step:

```markdown
### Step N: {action verb} + {what}

**File**: `path/to/file.ts:line-range`
**Change**: {precise description of what to add/modify/remove}
**Code sketch**:
  ```typescript
  // Before (current):
  function validateToken(token: string): AuthContext { ... }

  // After (planned):
  function validateAuth(credential: string | ApiKey): AuthContext { ... }
  ```
**Verify**: {how to confirm this step succeeded}
**Scope**: Changes ONLY `validateToken` signature and body. Does NOT touch callers yet.
```

### FACTS Validation Gate

Every step must pass all five:

| Check | Question | Fail Example |
|-------|----------|-------------|
| **F**easible | Can this be done in the current environment? | "Migrate to a new framework" mid-task |
| **A**tomic | Does it do exactly one thing? | "Update auth and refactor tests" |
| **C**lear | Are file names, line numbers, and code snippets present? | "Update the relevant files" |
| **T**estable | Is there a concrete verification step? | "Make sure it works" |
| **S**coped | Is it clear what changes and what doesn't? | No mention of boundaries |

**FACTS checklist**:

```markdown
### FACTS Validation
- [ ] F: Every step is achievable in current environment
- [ ] A: Each step has exactly one objective
- [ ] C: Every step has file path, line numbers, and code sketch
- [ ] T: Every step has a specific verification command or check
- [ ] S: Every step states what it changes AND what it leaves untouched
```

**Do NOT proceed to Phase 3 until FACTS passes.**

### Present Plan to User

After FACTS validation, present the plan for human review. The plan is the primary review artifact -- it's far more efficient to review a plan than to review generated code.

---

## Phase 3: Implement

**Goal**: Execute the validated plan with minimal context pressure.

### Execution Rules

1. **Follow the plan step by step** -- do not improvise or "improve" beyond scope
2. **One step at a time** -- complete and verify each step before the next
3. **Use sub-agents for independent steps** -- keep main context lean
4. **Verify after each step** -- run the verification defined in the plan

### After Each Step

```markdown
Step N: {title}
- Status: DONE / BLOCKED / MODIFIED
- Verification: {result of the verification step}
- Deviation: {none, or explain why plan was adjusted}
```

### If a Step Fails

1. **Do NOT retry blindly** -- diagnose why it failed
2. **Update the plan** with new information
3. **Re-validate FACTS** on the updated step
4. If 3+ steps fail consecutively, **STOP** -- see Escalation below

---

## Intent Compression

When the conversation becomes long or starts going off track (roughly 20+ turns):

1. **Stop all implementation work**
2. **Summarize** key research findings and plan state into a compressed format:

```markdown
## Compressed Context for: {task}

### Validated Facts
- {fact 1 with file path and line number}
- {fact 2 with file path and line number}

### Plan Status
- Steps completed: {list}
- Current step: {N} - {status}
- Remaining: {list}

### Blockers
- {any unresolved issues}
```

3. **Start a new conversation** with this compressed context

Better input produces better output. A fresh context with compressed facts outperforms a bloated context with noise.

---

## Sub-Agent Strategy

Sub-agents are sharding tools, not personas. Use them to:

| Task | Agent Type | Returns |
|------|-----------|---------|
| Broad codebase reading | `Explore` | Compressed file/function map |
| Targeted search | `Explore` | Specific paths and line numbers |
| Independent implementation steps | `Bash` or `general-purpose` | Step completion status |
| Test execution | `Bash` | Pass/fail with output |

**Rules**:
- Sub-agents do the heavy reading; main agent does the reasoning
- Sub-agents return compressed facts, not raw file contents
- Never let main context absorb entire files when a sub-agent can extract the relevant lines

---

## Escalation

When RPI plans repeatedly fail (3+ consecutive step failures), this signals that the task complexity exceeds what AI can handle with current context.

**Action**: Stop. Return to the whiteboard. The human must re-think the approach and break the problem down differently before re-engaging AI.

Do not brute-force through repeated failures -- that wastes context and produces bad code.
