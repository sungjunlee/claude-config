---
description: Check status of all parallel git worktrees
---

# Worktree Status

Display comprehensive status of all worktrees for: $ARGUMENTS

## Purpose
Monitor progress across all parallel development worktrees, providing visibility into each task's state and readiness for merge.

## Process

1. **Scan Worktrees**:
   - Locate all worktrees in `.worktrees/` directory
   - Verify git status for each
   - Check branch information

2. **Gather Metrics**:
   - Count modified files
   - Review commit history
   - Check for uncommitted changes
   - Identify merge readiness

3. **Display Status**:
   - Show branch names and states
   - List file modification counts
   - Display latest commit messages
   - Indicate completion status

## Output Format

```text
================================
 Worktree Status
================================

[OK] auth
  Branch:  feature/auth
  Changes: 0 file(s)
  Commits: 5
  Last:    Implement JWT validation
  Task:    .worktrees/tasks/auth.md

[WIP] payment
  Branch:  feature/payment
  Changes: 3 file(s)
  Commits: 2
  Last:    Add Stripe webhook handler
  Task:    .worktrees/tasks/payment.md

[NEW] search
  Branch:  feature/search
  Changes: 0 file(s)
  Commits: 0
  Last:    No commits yet
  Task:    .worktrees/tasks/search.md

--------------------------------
Git Worktree Summary:
3 active worktree(s)
```

## Status Indicators

- **[OK]**: No changes, has commits (ready to merge)
- **[WIP]**: Has uncommitted changes (work in progress)
- **[NEW]**: No commits yet (just started)
- **[CONFLICT]**: Merge conflicts detected

## Integration Points

- After `/my:wt-distribute` to verify setup
- Before merging to check completion
- During work to monitor progress
- With `/my:wt-sync` to identify sync needs

Execute status check now by running the `worktree-status.sh` script from the account profile's scripts directory.

