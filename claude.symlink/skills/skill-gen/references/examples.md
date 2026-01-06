# Skill examples

## Example 1: Commit message helper

```markdown
---
name: commit-helper
description: Generate conventional commit messages. Use when user asks to commit changes or write commit message.
---

# Commit helper

Generate commit messages following Conventional Commits spec.

## Format

<type>(<scope>): <subject>

## Types

- feat: New feature
- fix: Bug fix
- docs: Documentation
- style: Formatting
- refactor: Code restructure
- test: Add tests
- chore: Maintenance
```

## Example 2: Test runner with script

```markdown
---
name: test-runner
description: Run and analyze test results. Use when user asks to run tests or check test coverage.
---

# Test runner

Run project tests and analyze results.

## Execution

Run the test script:

python3 ~/.claude/skills/test-runner/scripts/run_tests.py

## Supported frameworks

- Jest (JavaScript)
- pytest (Python)
- cargo test (Rust)
```

## Example 3: Code reviewer

```markdown
---
name: code-review
description: Review code for quality, security, and best practices. Use when user asks to review code or check for issues.
---

# Code reviewer

Systematic code review checklist.

## Review areas

1. Security vulnerabilities
2. Performance issues
3. Code style consistency
4. Error handling
5. Test coverage
```
