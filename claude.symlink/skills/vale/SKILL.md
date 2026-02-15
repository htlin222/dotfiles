---
name: vale
description: Runs Vale prose linter on markdown/text files and auto-fixes issues. Use when the user asks to lint, proofread, or improve writing quality of markdown or text files.
---

# Vale Lint & Fix

Run Vale on files, then fix issues directly based on the lint output.

## Workflow

1. **Run Vale** with JSON output on the target file(s):

```bash
vale --output=JSON <file-or-glob>
```

2. **Parse the JSON output.** Each issue has:
   - `Line`, `Span` (column range) — location
   - `Check` — rule name (e.g. `Microsoft.Passive`, `write-good.Weasel`)
   - `Message` — human-readable explanation
   - `Severity` — `error`, `warning`, or `suggestion`
   - `Action.Name` — suggested fix type (`replace`, `remove`, `edit`)
   - `Action.Params` — replacement candidates

3. **Read the file** and fix each issue:
   - For `replace` actions with clear suggestions: apply the best-fit replacement
   - For stylistic issues (passive voice, wordiness, weasel words): rewrite the sentence
   - For issues requiring judgment: use context to determine the best fix
   - Skip rules that conflict with the document's domain (e.g. medical terminology flagged as jargon)

4. **Re-run Vale** after fixes to verify issues are resolved. Repeat if needed.

## Scope Rules

- If no file is specified, ask the user which file(s) to lint
- For globs (e.g. `docs/*.md`), process each file sequentially
- Only fix `error` and `warning` by default; include `suggestion` if user asks for thorough review

## What NOT to Fix

- Domain-specific terminology flagged incorrectly (medical, legal, technical terms)
- Intentional stylistic choices (e.g. first person in a blog post)
- Code blocks and frontmatter — Vale should already skip these, but double-check
