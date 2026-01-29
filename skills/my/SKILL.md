---
name: my
description: |
  Personal development toolkit for session continuity and parallel development.
  Use when: user mentions "handoff", "resume session", "worktree", "parallel development",
  "multiple features", "split tasks", or needs to transfer context between sessions.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
model: claude-sonnet-4-5-20250929
---

# My Skill

Personal development tools providing features not available in official plugins.

## Commands

### Session Management (`session-*`)
Maintain context continuity across Claude sessions.
- `/my:session-handoff` - Create handoff document before ending session
- `/my:session-resume` - Resume work from previous handoff
- See: `context/session.md`

### Parallel Development (`worktree-*`)
Run multiple Claude sessions in isolated git worktrees.
- `/worktree-init` - Plan + distribute + setup (all-in-one)
- `/worktree-launch` - Start Claude sessions in tmux/iTerm
- `/worktree-status` - Monitor progress across all worktrees
- See: `context/worktree.md`

## Context Files

| File | Purpose |
|------|---------|
| `context/session.md` | Session management guide |
| `context/worktree.md` | Parallel worktree operations |
| `context/handoff-template.md` | Handoff document template |
