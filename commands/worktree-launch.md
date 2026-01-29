---
description: Launch Claude sessions in existing worktrees via tmux or iTerm
---

# Worktree Launch

Launch Claude sessions in existing worktrees: $ARGUMENTS

## Purpose

Automatically open terminal sessions (tmux windows or iTerm tabs) for each worktree, with `claude` running in each one for parallel development.

## Usage

```bash
# Launch with tmux (recommended - works everywhere)
/worktree-launch tmux

# Launch with iTerm (macOS only)
/worktree-launch iterm

# List existing worktrees
/worktree-launch list
```

## Commands

### tmux

Creates a detached tmux session with one window per worktree:
- Session name: `{project}-wt`
- Each window named after worktree (e.g., `auth`, `payment`)
- `claude` auto-started in each window
- Attach from another terminal: `tmux attach -t {project}-wt`

**Why detached?** Preserves your current Claude Code session. Attach from a different terminal.

### iterm (macOS)

Opens iTerm tabs for each worktree:
- Creates new tab per worktree
- Each tab `cd`s to worktree and runs `claude`
- Uses current iTerm window

### list

Shows existing worktrees and their branches.

## Prerequisites

- Worktrees must exist (use `/worktree-init` first)
- For tmux: `tmux` installed (`brew install tmux`)
- For iTerm: iTerm2 app installed, macOS only

## Workflow

```
/worktree-init "tasks..."    # Create worktrees
         ↓
/worktree-launch tmux        # Launch terminals
         ↓
tmux attach -t {project}-wt  # Attach to session
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

## Output Example

```
🚀 Launching Claude sessions...

tmux session: myproject-wt

  Window 0: auth     → claude started
  Window 1: payment  → claude started
  Window 2: search   → claude started

✅ Session created (detached)

To attach: tmux attach -t myproject-wt
```

## Related Commands

- `/worktree-init` - Initialize worktrees (run first)
- `/worktree-status` - Monitor worktree progress

## Execution

Run the worktree manager script:
```bash
~/.claude/scripts/worktree-manager.sh launch {tmux|iterm|list}
```
