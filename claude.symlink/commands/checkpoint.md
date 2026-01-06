---
allowed-tools: Bash, Read, Write, Glob
description: Git checkpoint management - create, list, and restore checkpoints
---

# /checkpoint - Git Checkpoint System

Manage git checkpoints (stashes) for safe code exploration and recovery.

## Usage

```
/checkpoint create [name]     # Create a named checkpoint
/checkpoint list              # List all Claude checkpoints
/checkpoint restore [name]    # Restore a specific checkpoint
/checkpoint pop               # Restore most recent checkpoint
/checkpoint clear             # Remove all Claude checkpoints
```

## Instructions

When this command is invoked:

### /checkpoint create [name]

1. Check if in a git repository
2. Check if there are uncommitted changes
3. Create a git stash with the name: `claude-checkpoint_YYYYMMDD_HHMMSS: [name]`
4. Confirm the checkpoint was created

### /checkpoint list

1. Run `git stash list`
2. Filter stashes that start with `claude-checkpoint`
3. Display in a formatted table:
   - Index (stash@{N})
   - Timestamp
   - Description
   - Number of files changed

### /checkpoint restore [name]

1. Find the stash matching the given name or index
2. Apply the stash with `git stash apply stash@{N}`
3. Do NOT drop the stash (keep it for safety)
4. Report what was restored

### /checkpoint pop

1. Find the most recent `claude-checkpoint` stash
2. Apply and drop it with `git stash pop stash@{N}`
3. Report what was restored

### /checkpoint clear

1. List all `claude-checkpoint` stashes
2. Ask for confirmation before proceeding
3. Drop each matching stash
4. Report how many were removed

## Examples

```bash
# Create checkpoint before risky changes
/checkpoint create "before refactoring auth module"

# List checkpoints
/checkpoint list

# Restore if something went wrong
/checkpoint restore "before refactoring auth module"

# Quick restore of most recent
/checkpoint pop

# Clean up old checkpoints
/checkpoint clear
```

## Notes

- Checkpoints use git stash under the hood
- Include untracked files in checkpoints
- Checkpoints persist across sessions
- Use descriptive names for easy identification
