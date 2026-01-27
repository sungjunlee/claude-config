---
name: my
description: |
  Personal development toolkit - AI integration, session management, parallel development.
  Use when: multi-model AI, session handoff, git worktree operations.
  Triggers: "handoff", "resume", "worktree"
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
model: claude-sonnet-4-5
---

# My Skill

개인 개발 도구 모음입니다. 공식 플러그인에 없는 기능을 제공합니다.

## Commands

### Session Management

세션 간 컨텍스트 연속성 유지:

| Command | Purpose |
|---------|---------|
| `/my:session-handoff` | Save session state before `/clear` |
| `/my:session-resume` | Restore previous session context |

**Best Practice:** 80% context 사용 시 handoff 생성

### Worktree (`wt-*`)

Git worktree를 활용한 병렬 개발:

| Command | Purpose |
|---------|---------|
| `/my:wt-plan` | Generate parallel task plan |
| `/my:wt-distribute` | Distribute tasks to worktrees |
| `/my:wt-launch` | Launch claude sessions in worktrees |
| `/my:wt-status` | Check all worktree status |
| `/my:wt-sync` | Sync environment across worktrees |

## Context Files

| File | Purpose |
|------|---------|
| `context/handoff-template.md` | Handoff document template |
| `context/worktree-guide.md` | Worktree operation guide |

## Usage Examples

```bash
# Session: Save before clearing
/my:session-handoff
/clear
/my:session-resume

# Worktree: Parallel feature development
/my:wt-plan
/my:wt-distribute
/my:wt-launch tmux
/my:wt-status
```
