---
name: x
description: |
  Extended development toolkit - AI integration, session management, parallel development.
  Use when: multi-model AI, session handoff, git worktree operations.
  Triggers: "gemini", "codex", "handoff", "resume", "worktree"
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
model: sonnet
---

# X Skill

확장 개발 도구 모음입니다. 공식 플러그인에 없는 기능을 제공합니다.

## Commands

### AI Integration (`ai-*`)

외부 AI 모델을 활용한 특화 작업:

| Command | Purpose | Cost |
|---------|---------|------|
| `/x:ai-gemini` | Large file analysis (2M context) | Free |
| `/x:ai-codex` | Algorithm optimization, debugging | Paid |
| `/x:ai-consensus` | Multi-AI opinions for decisions | Mixed |
| `/x:ai-pipeline` | Multi-stage project analysis | Mixed |

**Prerequisites:**
```bash
npm install -g @google/gemini-cli && gemini login
npm install -g @openai/codex@latest && codex auth login
```

### Session Management

세션 간 컨텍스트 연속성 유지:

| Command | Purpose |
|---------|---------|
| `/x:handoff` | Save session state before `/clear` |
| `/x:resume` | Restore previous session context |

**Best Practice:** 80% context 사용 시 handoff 생성

### Worktree (`wt-*`)

Git worktree를 활용한 병렬 개발:

| Command | Purpose |
|---------|---------|
| `/x:wt-plan` | Generate parallel task plan |
| `/x:wt-distribute` | Distribute tasks to worktrees |
| `/x:wt-status` | Check all worktree status |
| `/x:wt-sync` | Sync environment across worktrees |

## Context Files

| File | Purpose |
|------|---------|
| `context/handoff-template.md` | Handoff document template |
| `context/worktree-guide.md` | Worktree operation guide |

## Usage Examples

```bash
# AI: Large codebase analysis (free)
/x:ai-gemini "analyze entire auth system"

# AI: Critical architecture decision
/x:ai-consensus "PostgreSQL vs MongoDB?"

# Session: Save before clearing
/x:handoff
/clear
/x:resume

# Worktree: Parallel feature development
/x:wt-plan
/x:wt-distribute
/x:wt-status
```
