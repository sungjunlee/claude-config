---
name: worktree
description: |
  Parallel development using git worktrees for multi-task development.
  Use when: "parallel development", "multiple features", "worktree", "split tasks",
  "simultaneous work", "run multiple Claude sessions", "tmux", "distribute tasks".
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
model: claude-sonnet-4-5-20250929
argument-hint: "[init|launch|status] [tmux|iterm]"
---

# Git Worktree Management

Run multiple Claude sessions in isolated git worktrees for parallel development.

## Quick Reference

| Command | Description |
|---------|-------------|
| `/worktree init "task1, task2"` | Create worktrees + setup |
| `/worktree launch tmux` | Start Claude sessions in tmux |
| `/worktree launch iterm` | Start Claude sessions in iTerm |
| `/worktree status` | Monitor all worktree progress |

## Dynamic Context

- Current branch: !`git branch --show-current 2>/dev/null || echo "not a git repo"`
- Existing worktrees: !`[ -d .worktrees ] && ls -d .worktrees/*/ 2>/dev/null | wc -l | tr -d ' ' || echo 0`
- Git status: !`git status --short 2>/dev/null | head -3`

## Workflows

Based on `$ARGUMENTS`:

### Init Mode
When argument starts with "init":
- See [workflows/init.md](workflows/init.md)
- Creates PLAN.md, distributes tasks, runs setup

### Launch Mode
When argument starts with "launch":
- See [workflows/launch.md](workflows/launch.md)
- Starts Claude sessions in tmux or iTerm

### Status Mode
When argument starts with "status":
- See [workflows/status.md](workflows/status.md)
- Shows progress across all worktrees

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

## Critical Rules

- **Task Independence**: Each task MUST modify different files
- **No File Conflicts**: Overlapping modifications cause merge conflicts
- **Resource Management**: Use different ports per worktree

## Supporting Files

| File | Purpose |
|------|---------|
| [workflows/init.md](workflows/init.md) | Initialize worktrees |
| [workflows/launch.md](workflows/launch.md) | Launch Claude sessions |
| [workflows/status.md](workflows/status.md) | Monitor progress |
| [context/guide.md](context/guide.md) | Reference guide |

