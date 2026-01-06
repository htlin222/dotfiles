---
name: skill-gen
description: Generate new Claude Code skills from user requirements. Use when user asks to create a new skill, slash command, or wants to automate a workflow. Guides through skill creation with proper structure and best practices.
---

# Skill Generator

Help users create new Claude Code skills with proper structure and best practices.

## Workflow

1. **Gather Requirements**
   - Ask user: What should this skill do?
   - Ask user: When should it trigger? (keywords, scenarios)
   - Ask user: Does it need scripts or just instructions?

2. **Generate Skill Structure**
   - Create directory: `~/.claude/skills/{skill-name}/`
   - Create SKILL.md with proper frontmatter
   - Create scripts/ if needed
   - Create references/ for detailed docs

3. **Validate**
   - Ensure name follows rules: lowercase, numbers, hyphens only
   - Ensure description clearly states what + when
   - Keep SKILL.md under 500 lines

## Skill Structure Template

```
{skill-name}/
├── SKILL.md           # Required: Main instructions
├── scripts/           # Optional: Executable code
│   └── main.py
└── references/        # Optional: Detailed docs
    └── examples.md
```

## SKILL.md Template

```markdown
---
name: {skill-name}
description: {What it does}. Use when {trigger conditions}.
---

# {Skill Title}

{Brief overview}

## When to Use

- {Scenario 1}
- {Scenario 2}

## Instructions

{Step-by-step guidance for Claude}

## Examples

**Input:** {example request}
**Output:** {expected behavior}
```

## Naming Rules

- Length: 1-64 characters
- Allowed: lowercase letters, numbers, hyphens (`-`)
- Not allowed: start/end with `-`, consecutive `--`
- Must match folder name

## Best Practices

1. **Description**: Clearly state WHAT it does and WHEN to use it
2. **Progressive Disclosure**: Keep SKILL.md light, put details in references/
3. **Examples**: Always include input/output examples
4. **Scripts**: Reference them explicitly in SKILL.md

## Quick Start

To create a new skill, tell me:

1. What should it do?
2. A short name (e.g., `commit-helper`, `test-runner`)
3. When should Claude use it?

I will generate the complete skill structure for you.
