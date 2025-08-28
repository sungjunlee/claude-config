# Command: /worktree-status

Check current status of all worktrees

## Usage

```bash
/worktree-status
```

## Description

View the status of all worktrees in the `.worktrees/` directory at a glance.

## Output Information

Display for each worktree:
- Branch name
- Number of changed files
- Latest commit message
- Task progress

## Example Output

```
Worktree Status
────────────────────

auth
  Branch: feature/auth
  Changes: 5 files
  Last commit: Add OAuth2.0 login

payment
  Branch: feature/payment
  Changes: 0 files
  Last commit: Initial Stripe setup

search
  Branch: feature/search
  Changes: 3 files
  Last commit: No commits yet
```

## Implementation

```bash
scripts/worktree-manager.sh status
```

## Related Commands

- `/worktree-distribute` - Distribute tasks
- `/worktree-sync` - Sync shared information