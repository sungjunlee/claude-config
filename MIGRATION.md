# Migration Guide

## Skills Architecture (v3.0)

2025년 12월, commands/agents 구조에서 **Skills 기반 아키텍처**로 전환했습니다.

### 구조 변경

```
~/.claude/
├── skills/           # Skills (자동 로드)
│   ├── workflow/     # handoff, resume, plan, fix-errors
│   ├── worktree/     # distribute, plan, status, sync
│   ├── testing/      # test (언어별 context)
│   ├── linting/      # lint (언어별 context)
│   └── frameworks/   # fastapi patterns
├── commands/         # Commands (수동 호출)
│   ├── dev/          # commit, refactor, optimize, explain, epct, cr
│   ├── gh/           # pr
│   └── ai/           # multi-model integration
├── agents/           # time-aware만 유지
└── scripts/
```

### 제거된 명령어 (공식 플러그인 사용)

| 기존 | 대체 |
|------|------|
| `/dev:review` | `pr-review-toolkit` plugin |
| `/dev:debug` | `silent-failure-hunter` plugin |
| `/gh:docs` | `document-skills` plugin |

### Skills로 이동된 명령어

| 기존 | 신규 |
|------|------|
| `/flow:*` | `/flow:*` (skill 기반) |
| `/worktree:*` | `/worktree:*` (skill 기반) |
| `/dev:test` | `/dev:test` (언어 context 포함) |

### 제거된 Agents

| Agent | 대체 |
|-------|------|
| `code-reviewer.md` | `pr-review-toolkit` plugin |
| `test-runner.md` | `skills/testing/` |
| `debugger.md` | `silent-failure-hunter` plugin |
| `plan-agent.md` | `skills/workflow/` |
| `reflection-agent.md` | `skills/workflow/` |
| `worktree-coordinator.md` | `skills/worktree/` |

`time-aware.md`만 유지 (datetime 자동 주입).

### 마이그레이션

```bash
# 재설치
curl -fsSL https://raw.githubusercontent.com/sungjunlee/claude-config/main/install.sh | bash

# 구 파일 정리 (선택)
rm -rf ~/.claude/commands/flow/
rm -rf ~/.claude/commands/worktree/
rm -f ~/.claude/commands/dev/{review,debug,test}.md
rm -f ~/.claude/agents/{code-reviewer,test-runner,debugger,plan-agent,reflection-agent,worktree-coordinator}.md
```

### Skills 구조

```
skill-name/
├── SKILL.md           # Skill 정의
├── workflows/         # 실행 가능한 워크플로
└── context/           # 도메인 지식
```

호출: `/skill-name:workflow`
