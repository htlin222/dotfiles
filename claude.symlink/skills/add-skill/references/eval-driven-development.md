# Evaluation-Driven Skill Development

Build skills that solve real problems by testing before documenting.

## Contents

- [Core Process](#core-process)
- [Writing Evaluations](#writing-evaluations)
- [Two-Claude Iterative Development](#two-claude-iterative-development)
- [Observation Patterns](#observation-patterns)
- [Team Feedback Loop](#team-feedback-loop)

## Core Process

Build evaluations BEFORE writing extensive documentation:

1. **Identify gaps** — Run Claude on representative tasks *without* a skill. Document specific failures or missing context.
2. **Create evaluations** — Build 3+ scenarios that test these gaps.
3. **Establish baseline** — Measure Claude's performance without the skill.
4. **Write minimal instructions** — Only enough to address the gaps and pass evaluations.
5. **Iterate** — Execute evaluations, compare against baseline, refine.

This ensures you solve actual problems rather than anticipate requirements that never materialize.

## Writing Evaluations

Structure each evaluation as a test scenario:

```json
{
  "skills": ["your-skill-name"],
  "query": "A realistic user request that exercises the skill",
  "files": ["test-files/sample-input.pdf"],
  "expected_behavior": [
    "Successfully performs the core operation",
    "Handles edge case X correctly",
    "Produces output in the expected format"
  ]
}
```

Aim for at least 3 evaluations covering:
- **Happy path** — Standard use case
- **Edge case** — Unusual input or boundary condition
- **Error case** — Missing files, bad input, etc.

## Two-Claude Iterative Development

Use two Claude instances in a feedback loop:

### Creating a new skill

1. **Complete a task without a skill** — Work through a problem with Claude A using normal prompting. Notice what information you repeatedly provide.
2. **Identify the reusable pattern** — What context would be useful for similar future tasks?
3. **Ask Claude A to create the skill** — "Create a skill that captures this pattern we just used."
4. **Review for conciseness** — Remove explanations Claude already knows. Ask: "Remove the explanation about what X means — Claude already knows that."
5. **Improve information architecture** — Ask Claude A to organize content. E.g., "Move the table schema into a separate reference file."
6. **Test with Claude B** — Use the skill with a fresh Claude instance on related tasks. Observe whether it finds the right info, applies rules correctly, handles the task.
7. **Iterate** — If Claude B struggles, return to Claude A with specifics: "When Claude used this skill, it forgot to filter by date. Should we add a section about date filtering?"

### Iterating on existing skills

Alternate between:
- **Claude A** (the expert who refines the skill)
- **Claude B** (the agent using the skill on real work)
- **Observing Claude B** and bringing insights back to Claude A

1. Use the skill in real workflows (not test scenarios)
2. Observe behavior — note struggles, successes, unexpected choices
3. Return to Claude A: "Claude B forgot to filter test accounts. The rule is mentioned but maybe not prominent enough?"
4. Review Claude A's suggestions — reorganize, use stronger language ("MUST filter" vs "always filter"), restructure
5. Apply changes, test again with Claude B
6. Repeat as you encounter new scenarios

## Observation Patterns

Watch how Claude actually navigates and uses the skill:

| What to Watch | What It Means | Action |
|---------------|---------------|--------|
| Reads files in unexpected order | Structure isn't intuitive | Reorganize navigation in SKILL.md |
| Misses references to important files | Links aren't prominent enough | Make references more explicit |
| Re-reads the same file repeatedly | Content should be in SKILL.md directly | Promote to main file |
| Never accesses a bundled file | File is unnecessary or poorly signaled | Remove or improve signaling |
| Skips validation steps | Steps aren't emphasized enough | Use stronger language, add checklist |
| Generates code instead of running scripts | Execution intent unclear | Clarify: "Run `script.py`" vs "See `script.py`" |

## Team Feedback Loop

When sharing skills with others:

1. **Share and observe** — Let teammates use the skill
2. **Ask targeted questions**:
   - Does the skill activate when expected?
   - Are instructions clear?
   - What's missing?
3. **Incorporate feedback** — Address blind spots in your own usage patterns
4. **Test across models** — What works for Opus may need more detail for Haiku
