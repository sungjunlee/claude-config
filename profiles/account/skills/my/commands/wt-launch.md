---
description: Launch claude in existing worktrees via tmux or iTerm
---

# Worktree Launch

Launch claude sessions in existing worktrees: $ARGUMENTS

## Purpose
Automatically open terminal sessions (tmux windows or iTerm tabs) for each worktree, with `claude` running in each one for parallel development.

## Usage

```bash
# Launch with tmux (recommended - works everywhere)
scripts/worktree-launcher.sh tmux

# Launch with iTerm (macOS only)
scripts/worktree-launcher.sh iterm

# List existing worktrees
scripts/worktree-launcher.sh list
```

## Commands

### tmux
Creates a detached tmux session with one window per worktree:
- Session name: `{project-name}-wt`
- Each window named after worktree (e.g., `auth`, `payment`)
- `claude` auto-started in each window
- Attach from another terminal: `tmux attach -t {session}`

**Why detached?** Preserves your current Claude Code session. Attach from a different terminal.

### iterm (macOS)
Opens iTerm tabs for each worktree:
- Creates new tab per worktree
- Each tab `cd`s to worktree and runs `claude`
- Uses current iTerm window

### list
Shows existing worktrees and their branches.

## Prerequisites

- Worktrees must exist (use `/wt-distribute` first)
- For tmux: `tmux` installed (`brew install tmux`)
- For iTerm: iTerm2 app installed, macOS only

## Workflow

```
/wt-distribute          # Claude Code creates worktrees
         ↓
/wt-launch tmux         # Script launches terminals
         ↓
tmux attach -t wt       # User attaches to session
```

## Tmux Quick Reference

```bash
# Attach to session
tmux attach -t {project}-wt

# List sessions
tmux ls

# Switch windows (inside tmux)
Ctrl-b n    # Next window
Ctrl-b p    # Previous window
Ctrl-b 0-9  # Go to window number

# Detach (keep session running)
Ctrl-b d

# Kill session
tmux kill-session -t {project}-wt
```

## Execution

Run the launcher script:
```bash
scripts/worktree-launcher.sh {tmux|iterm|list}
```
