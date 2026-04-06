---
name: add-skill
description: Create new Claude Code skills with proper structure. Use when adding a skill or slash command.
---

# Add Skill

Create properly structured Claude Code skills from user requirements.

## Quick Mode

For rapid creation, user can provide all info at once:

```
/add-skill name=my-skill purpose="Does X" trigger="when user asks for Y"
```

Parse and generate without interactive prompts.

## Workflow

### Step 1: Fetch Latest Documentation

Always fetch official docs first to ensure compliance with current spec:

```
WebFetch: https://code.claude.com/docs/en/skills
Prompt: Extract skill file format, required fields, naming rules, and best practices
```

If WebFetch fails, fallback:

```
WebSearch: "Claude Code skills SKILL.md format site:code.claude.com"
```

### Step 2: Gather Requirements

Ask user (or parse from quick mode):

1. **Scope**: Global skill or repo-local skill?
   - **Global** → `~/.claude/skills/{skill-name}/` (available in all projects)
   - **Repo-local** → `.claude/skills/{skill-name}/` (only this repo, committed with code)
2. **Name**: lowercase, hyphens only (prefer gerund: `processing-pdfs`, `testing-code`)
3. **Purpose**: What does it do? (1-2 sentences)
4. **Trigger**: When should Claude use it? (keywords, scenarios)
5. **Complexity**: Instructions-only, or needs scripts/references?
6. **Freedom level**: Rigid (exact steps) vs flexible (general guidance)?

### Step 3: Create Skill Structure

```
{base-path}/skills/{skill-name}/
├── SKILL.md           # Required: Main instructions (<500 lines)
├── scripts/           # Optional: Executable code
│   └── main.py
└── references/        # Optional: Detailed docs (one level deep)
    └── examples.md
```

### Step 4: Generate SKILL.md

```markdown
---
name: {skill-name}
description: {What it does in third person}. Use when {trigger conditions}.
---

# {Skill Title}

{Brief overview - assume Claude is smart, only add context it doesn't already have}

## Quick Start

{Minimal working example or first step}

## Instructions

{Step-by-step guidance with appropriate freedom level}

## Advanced Features

**Feature A**: See [references/feature-a.md](references/feature-a.md)
```

### Step 5: Check Line Count & Apply Progressive Disclosure

After drafting SKILL.md, count its lines. If approaching or exceeding **500 lines**:

1. Inform the user: "The SKILL.md is {N} lines — exceeding the recommended 500-line limit."
2. Identify splittable sections: detailed references, long examples, advanced features
3. Move to reference files: `references/{topic}.md` — one level deep only
4. Replace in SKILL.md with a short summary + link
5. Add table of contents to any reference file over 100 lines

### Step 6: Validate

Run through the [validation checklist](#validation-checklist) before finalizing.

### Step 7: Verify

```bash
ls -la ~/.claude/skills/{skill-name}/
cat ~/.claude/skills/{skill-name}/SKILL.md
```

Test with: `claude --debug` to check for loading errors.

## Naming Rules

- **Length**: 1-64 characters
- **Format**: lowercase letters, numbers, hyphens only
- **Prefer gerund form**: `processing-pdfs`, `testing-code`, `writing-documentation`
- **Acceptable alternatives**: `pdf-processing`, `process-pdfs`
- **Not allowed**: start/end with `-`, consecutive `--`, reserved words (`anthropic`, `claude`), XML tags
- **Avoid**: vague names (`helper`, `utils`, `tools`), overly generic (`documents`, `data`)
- **Must match**: folder name

## Description Rules

- **Maximum**: 1024 characters, non-empty, no XML tags
- **Always third person**: "Processes Excel files" not "I can help you"
- **Include both**: what it does AND when to use it
- **Be specific**: Claude uses descriptions to choose from 100+ skills

**Good**:
```yaml
description: Extracts text and tables from PDF files, fills forms, merges documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```

**Bad**: "Helps with documents", "Processes data", "Does stuff with files"

## Core Principles

### Conciseness

Challenge each piece of information:
- "Does Claude really need this explanation?"
- "Can I assume Claude knows this?"
- "Does this paragraph justify its token cost?"

### Degrees of Freedom

| Freedom | Use When | Example |
|---------|----------|---------|
| **High** (text instructions) | Multiple valid approaches | Code review guidelines |
| **Medium** (pseudocode/params) | Preferred pattern exists | Report generation template |
| **Low** (exact scripts) | Fragile operations, consistency critical | Database migrations |

### Consistent Terminology

Pick one term and use it throughout. Don't mix "API endpoint" / "URL" / "API route".

## Patterns

### Workflow with Checklist

For complex multi-step operations, provide a copyable checklist.

### Feedback Loop

Run validator → fix errors → repeat until passing.

### Conditional Workflow

Guide through decision points: **Creating new?** → "Creation workflow" / **Editing existing?** → "Editing workflow"

## Scripts Best Practices

- Handle errors explicitly — don't punt to Claude
- No voodoo constants — justify and document all values
- List dependencies with install instructions
- Make execution intent clear: "Run `script.py`" (execute) vs "See `script.py`" (reference)
- Use forward slashes in all file paths
- MCP tool references — use fully qualified names: `ServerName:tool_name`

## Anti-Patterns

- Explaining things Claude already knows
- Offering too many tool/library options — provide a default with escape hatch
- Time-sensitive information — use `<details>` tag for old patterns
- Deeply nested references (file → file → file)
- Assuming packages are installed without install instructions

## Validation Checklist

### Core Quality
- [ ] Name: lowercase, numbers, hyphens only, 1-64 chars, no reserved words
- [ ] Description: third person, specific, includes what + when, under 1024 chars
- [ ] SKILL.md body under 500 lines
- [ ] Additional details in separate reference files (one level deep)
- [ ] No time-sensitive information
- [ ] Consistent terminology throughout
- [ ] Concrete examples (not abstract)
- [ ] Progressive disclosure used appropriately

### Scripts (if applicable)
- [ ] Scripts handle errors explicitly
- [ ] No voodoo constants (all values justified)
- [ ] Required packages listed with install instructions
- [ ] Forward slashes in all paths

### Testing
- [ ] Tested with real usage scenarios
- [ ] Works across target models (Haiku needs more guidance, Opus needs less)

## Further Reading

- **Eval-driven development**: See [references/eval-driven-development.md](references/eval-driven-development.md)
- **Examples**: See [references/examples.md](references/examples.md)
- **Official docs**: https://code.claude.com/docs/en/skills
