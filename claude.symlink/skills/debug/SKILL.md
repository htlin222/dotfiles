---
name: debug
description: Debug errors, test failures, and unexpected behavior. Use when encountering issues, error messages, or when something doesn't work as expected.
---

# Debug

Systematic debugging for errors, test failures, and unexpected behavior.

## When to Use

- Error messages or stack traces appear
- Tests are failing
- Code behaves unexpectedly
- User says "it's broken" or "not working"
- Need to find root cause of an issue

## Debugging Process

1. **Capture** - Get error message, stack trace, and reproduction steps
2. **Isolate** - Narrow down the failure location
3. **Hypothesize** - Form theories about the cause
4. **Test** - Validate hypotheses with evidence
5. **Fix** - Implement minimal fix
6. **Verify** - Confirm solution works

## Investigation Steps

```bash
# Check recent changes that might have caused the issue
git log --oneline -10
git diff HEAD~3

# Find error patterns in logs
grep -r "error\|Error\|ERROR" logs/ 2>/dev/null | tail -20

# Check test output
npm test 2>&1 | tail -50  # or pytest, cargo test, etc.
```

## Output Format

```markdown
## Debug Report

**Issue:** [Brief description]
**Root Cause:** [What's actually wrong]

### Evidence

- [Finding 1]
- [Finding 2]

### Fix

[Code or configuration change]

### Verification

[How to confirm the fix works]

### Prevention

[How to prevent this in the future]
```

## Examples

**Input:** "TypeError: Cannot read property 'map' of undefined"
**Action:** Trace the undefined value, find where data should be initialized, fix the source

**Input:** "Tests are failing"
**Action:** Run tests, capture failures, analyze each failure, fix underlying issues
