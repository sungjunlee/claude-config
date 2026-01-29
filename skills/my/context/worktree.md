# Git Worktree Guide

Reference guide for parallel development using git worktrees with Claude Code.

## Quick Reference

| Command | Purpose |
|---------|---------|
| `/worktree-init` | Plan + distribute + environment setup |
| `/worktree-launch` | Start Claude sessions (tmux/iTerm) |
| `/worktree-status` | Monitor all worktree progress |

## Workflow

### 1. Initialize

```bash
/worktree-init "implement auth, payment, search features"
```

This command:
- Creates `.worktrees/PLAN.md` with task breakdown
- Creates isolated worktrees for each task
- Copies environment files (.env, package.json, etc.)
- Runs package manager (pnpm/npm/yarn/uv/pip)
- Generates per-worktree CLAUDE.md

### 2. Launch Sessions

```bash
/worktree-launch tmux    # Recommended (works everywhere)
/worktree-launch iterm   # macOS only
```

### 3. Monitor Progress

```bash
/worktree-status
```

### 4. Merge & Cleanup

```bash
# Merge completed work
git checkout main
git merge feature/auth

# Remove worktree
git worktree remove .worktrees/auth
git branch -d feature/auth
```

## Directory Structure

```
project/
├── .worktrees/
│   ├── PLAN.md              # Overall task plan
│   ├── tasks/               # Task instructions
│   │   ├── auth.md
│   │   └── payment.md
│   ├── auth/                # Worktree: auth feature
│   │   ├── CLAUDE.md       # Task-specific context
│   │   ├── .env            # Copied from main
│   │   └── node_modules/   # Installed dependencies
│   └── payment/             # Worktree: payment feature
└── src/                     # Main working directory
```

## Essential Git Commands

```bash
# Create worktree with new branch
git worktree add .worktrees/feature-name -b feature/feature-name

# List all worktrees
git worktree list

# Remove worktree
git worktree remove .worktrees/feature-name

# Prune orphaned references
git worktree prune
```

## Critical Rules

### Task Independence
- Each task MUST modify different files
- Overlapping file modifications cause merge conflicts
- If tasks must share files, merge them sequentially

### Resource Management
- Use different ports per worktree (e.g., 3000, 3001, 3002)
- Consider database connection limits
- Token consumption increases with parallel sessions

## Troubleshooting

### Branch Already Exists
```bash
git branch -D feature/name
# Or use different name
git worktree add .worktrees/name -b feature/name-v2
```

### Worktree Locked
```bash
git worktree unlock .worktrees/name
```

### Cleanup Orphaned Worktrees
```bash
git worktree prune
```

## References

- [Git Worktree Documentation](https://git-scm.com/docs/git-worktree)
