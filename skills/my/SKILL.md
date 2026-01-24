---
name: my
description: |
  Personal development toolkit - AI integration, session management, parallel development.
  Use when: multi-model AI, session handoff, git worktree operations.
  Triggers: "gemini", "codex", "handoff", "resume", "worktree"
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
model: sonnet
---

# My Skill

개인 개발 도구 모음입니다. 공식 플러그인에 없는 기능을 제공합니다.

## Commands

### AI Integration (`ai-*`)

외부 AI 모델을 활용한 특화 작업:

| Command | Purpose | Cost |
|---------|---------|------|
| `/my:ai-gemini` | Large file analysis (2M context) | Free |
| `/my:ai-codex` | Algorithm optimization, debugging | Paid |
| `/my:ai-consensus` | Multi-AI opinions for decisions | Mixed |
| `/my:ai-pipeline` | Multi-stage project analysis | Mixed |

**Prerequisites:**
```bash
npm install -g @google/gemini-cli && gemini login
npm install -g @openai/codex@latest && codex auth login
```

### Session Management

세션 간 컨텍스트 연속성 유지:

| Command | Purpose |
|---------|---------|
| `/my:handoff` | Save session state before `/clear` |
| `/my:resume` | Restore previous session context |

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
# AI: Large codebase analysis (free)
/my:ai-gemini "analyze entire auth system"

# AI: Critical architecture decision
/my:ai-consensus "PostgreSQL vs MongoDB?"

# Session: Save before clearing
/my:handoff
/clear
/my:resume

# Worktree: Parallel feature development
/my:wt-plan
/my:wt-distribute
/my:wt-launch tmux
/my:wt-status
```
