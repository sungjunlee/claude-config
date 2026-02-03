---
description: Launch Claude sessions in existing worktrees using tmux or iTerm
argument-hint: "[tmux|iterm|list]"
allowed-tools: ["Bash", "Read"]
---

# Worktree Launch

Launch Claude sessions in existing worktrees: $ARGUMENTS

## Role

You are a terminal session orchestrator. Your job is to launch multiple Claude Code sessions in parallel, one for each worktree.

## Arguments

Parse `$ARGUMENTS` for:
- `tmux` - Create tmux session with windows (works everywhere)
- `iterm` - Open iTerm tabs (macOS only)
- `list` - Show existing worktrees without launching (default)

If no argument provided, defaults to `list`.

## Prerequisites Check

Before launching, verify:
1. `.worktrees/` directory exists
2. At least one worktree is present
3. For tmux: `tmux` command is available
4. For iTerm: Running on macOS with iTerm2 installed

## Usage

```bash
/worktree-launch tmux    # Recommended (works everywhere)
/worktree-launch iterm   # macOS only
/worktree-launch list    # List existing worktrees
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
Launching Claude sessions...

tmux session: myproject-wt

  Window 0: auth     → claude started
  Window 1: payment  → claude started
  Window 2: search   → claude started

Session created (detached)

To attach: tmux attach -t myproject-wt
```

## Related Commands

- `/worktree-init` - Initialize worktrees (run first)
- `/worktree-status` - Monitor worktree progress

## Execution

Run the worktree manager script:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/worktree-manager.sh launch {tmux|iterm|list}
```
