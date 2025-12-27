---
description: Check status of all parallel git worktrees
deprecated: true
deprecated-by: skills/worktree/workflows/status.md
---

> **DEPRECATED** (v2.0 removal planned): Migrated to `skills/worktree/workflows/status.md`

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
═══════════════════════════════
     Worktree Status
═══════════════════════════════

✅ auth
   Branch: feature/auth
   Changes: 0 file(s)
   Commits: 5
   Last: Implement JWT validation
   Task: ../tasks/auth.md

📝 payment
   Branch: feature/payment
   Changes: 3 file(s)
   Commits: 2
   Last: Add Stripe webhook handler
   Task: ../tasks/payment.md

🔄 search
   Branch: feature/search
   Changes: 7 file(s)
   Commits: 0
   Last: No commits yet
   Task: ../tasks/search.md

───────────────────────────────
Git Worktree Summary:
3 active worktrees
```

## Status Indicators

- ✅ **Complete**: No changes, has commits (ready to merge)
- 📝 **In Progress**: Has uncommitted changes
- 🔄 **Starting**: No commits yet
- ⚠️ **Conflict**: Merge conflicts detected

## Integration Points

- After `/worktree-distribute` to verify setup
- Before merging to check completion
- During work to monitor progress
- With `/worktree-sync` to identify sync needs

## Advanced Options

Future enhancements could include:
- Filter by status (complete/in-progress)
- Show test results per worktree
- Display merge conflict warnings
- Track time spent per task

Execute status check now using `scripts/worktree-manager.sh status`.