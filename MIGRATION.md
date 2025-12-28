# Migration Guide

## Unified X Skill Architecture (v4.0)

2025년 12월, 모든 커스텀 기능을 단일 `x` skill로 통합했습니다.

### 현재 구조

```
~/.claude/
├── skills/
│   └── x/                # 통합 확장 도구
│       ├── commands/     # AI, 세션, 워크트리 명령어
│       └── context/      # 참조 문서
├── agents/               # time-aware만 유지
└── scripts/
```

### 명령어 변경

| 이전 | 현재 |
|------|------|
| `/flow:handoff` | `/x:handoff` |
| `/flow:resume` | `/x:resume` |
| `/worktree:plan` | `/x:wt-plan` |
| `/worktree:distribute` | `/x:wt-distribute` |
| `/worktree:status` | `/x:wt-status` |
| `/worktree:sync` | `/x:wt-sync` |
| `/ai:gemini` | `/x:ai-gemini` |
| `/ai:codex` | `/x:ai-codex` |
| `/ai:consensus` | `/x:ai-consensus` |
| `/ai:pipeline` | `/x:ai-pipeline` |

### 공식 플러그인으로 대체

| 제거된 항목 | 공식 대안 |
|------------|----------|
| `skills/testing/` | `pr-review-toolkit:pr-test-analyzer` + 내장 test-runner |
| `skills/linting/` | Claude 내장 (직접 린터 실행) |
| `skills/frameworks/fastapi/` | Claude 기본 지식 + Context7 |
| `/dev:commit` | `commit-commands` plugin |
| `/dev:cr` | `pr-review-toolkit` plugin |
| `/dev:refactor`, `/dev:optimize`, `/dev:explain` | Claude 내장 |
| `/dev:epct` | `feature-dev` plugin |
| `/gh:pr` | `feature-dev` plugin + `gh` 직접 사용 |
| `/flow:plan` | `feature-dev` plugin |
| `/ai:route`, `/ai:try-free` | 제거 (MCP bridge 직접 사용) |

### 권장 플러그인 설치

```bash
/plugin install pr-review-toolkit
/plugin install commit-commands
/plugin install feature-dev
/plugin install document-skills@anthropic-agent-skills
/plugin install security-guidance
```

### 마이그레이션

```bash
# 재설치
curl -fsSL https://raw.githubusercontent.com/sungjunlee/claude-config/main/install.sh | bash

# 구 파일 정리 (선택)
rm -rf ~/.claude/skills/{workflow,worktree,ai,testing,linting,frameworks}
rm -rf ~/.claude/commands/
```

### X Skill 명령어 요약

공식 플러그인에 없는 기능:

| 카테고리 | 명령어 | 용도 |
|----------|--------|------|
| AI | `/x:ai-gemini`, `/x:ai-codex` | 외부 AI 모델 활용 |
| AI | `/x:ai-consensus`, `/x:ai-pipeline` | 멀티모델 분석 |
| Session | `/x:handoff`, `/x:resume` | 세션 연속성 |
| Worktree | `/x:wt-plan`, `/x:wt-distribute` | 병렬 개발 |
| Worktree | `/x:wt-status`, `/x:wt-sync` | 워크트리 관리 |
