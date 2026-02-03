---
description: Display comprehensive status of all worktrees - commits, changes, merge readiness
argument-hint: ""
allowed-tools: ["Bash", "Read"]
---

# Worktree Status

Display comprehensive status of all worktrees.

## Role

You are a progress monitor for parallel development. Your job is to:
1. Scan all worktrees in `.worktrees/` directory
2. Gather git status, commits, and changes for each
3. Present a clear summary showing completion status
4. Suggest next actions (merge ready tasks, cleanup merged branches)

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

```
═══════════════════════════════════════
        Worktree Status
═══════════════════════════════════════

✅ auth
   Branch: feature/auth
   Changes: 0 file(s)
   Commits: 5
   Last: Implement JWT validation
   Ready to merge

📝 payment
   Branch: feature/payment
   Changes: 3 file(s)
   Commits: 2
   Last: Add Stripe webhook handler
   In progress

🔄 search
   Branch: feature/search
   Changes: 7 file(s)
   Commits: 0
   Last: (no commits yet)
   Just started

───────────────────────────────────────
Summary: 3 worktrees (1 ready, 2 in progress)
```

## Status Indicators

| Icon | Status | Description |
|------|--------|-------------|
| ✅ | Ready | No uncommitted changes, has commits |
| 📝 | In Progress | Has uncommitted changes |
| 🔄 | Starting | No commits yet |

## Cleanup Hints

When a worktree is ready to be removed:
```
🗑️ auth (PR merged)
   Branch: feature/auth
   Cleanup: git worktree remove .worktrees/auth
            git branch -d feature/auth
```

## Quick Actions

```bash
# After work is complete
git worktree remove .worktrees/[name]
git branch -d feature/[name]
```

## Related Commands

- `/worktree-init` - Initialize new worktrees
- `/worktree-launch` - Launch Claude sessions

## Execution

Run the worktree manager script:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/worktree-manager.sh status
```
