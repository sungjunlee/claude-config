---
name: session
description: |
  Session continuity tools for context preservation across Claude sessions.
  Use when: "handoff", "resume", "save context", "continue later", "session summary",
  "before clear", "restore session", "pick up where I left off".
allowed-tools: Read, Write, Edit, Glob, Grep
model: claude-sonnet-4-5-20250929
argument-hint: "[handoff|resume] [--detailed|--team|--list]"
---

# Session Management

Maintain context continuity across Claude Code sessions.

## Quick Reference

| Command | Description |
|---------|-------------|
| `/session handoff` | Save session state before `/clear` |
| `/session resume` | Restore from previous handoff |
| `/session handoff --detailed` | Full context with technical decisions |
| `/session handoff --team` | Team handover with setup instructions |
| `/session resume --list` | List available handoffs |

## Dynamic Context

- Session ID: ${CLAUDE_SESSION_ID}
- Current branch: !`git branch --show-current 2>/dev/null || echo "not a git repo"`
- Uncommitted changes: !`git status --short 2>/dev/null | wc -l | tr -d ' '`

## Workflows

Based on `$ARGUMENTS`:

### Handoff Mode
When argument contains "handoff":
- See [workflows/handoff.md](workflows/handoff.md)

### Resume Mode
When argument contains "resume":
- See [workflows/resume.md](workflows/resume.md)

## Storage

```
docs/handoff/
├── .current           # Current handoff metadata (YAML)
├── .scratch.md        # Working notes
├── HANDOFF-*.md       # Handoff documents (keep last 5)
└── archive/           # Older handoffs
```

## Auto-trigger Conditions

Suggest handoff when:
- Context usage > 80%
- User mentions `/clear`
- Major milestone completed
- Switching between features

## Supporting Files

| File | Purpose |
|------|---------|
| [workflows/handoff.md](workflows/handoff.md) | Handoff creation process |
| [workflows/resume.md](workflows/resume.md) | Resume restoration process |
| [templates/](templates/) | Document templates |
