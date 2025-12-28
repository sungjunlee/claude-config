# Migration Guide

## Minimal Skills Architecture (v3.1)

2025년 12월, 공식 플러그인과 중복되는 기능을 제거하고 최소한의 커스텀 설정만 유지합니다.

### 현재 구조

```
~/.claude/
├── skills/
│   ├── workflow/     # handoff, resume, plan (공식 대안 없음)
│   └── worktree/     # distribute, plan, status, sync (공식 대안 없음)
├── commands/
│   └── ai/           # multi-model integration (공식 대안 없음)
├── agents/           # time-aware만 유지
└── scripts/
```

### 공식 플러그인으로 대체

| 제거된 항목 | 공식 대안 |
|------------|----------|
| `skills/testing/` | `pr-review-toolkit:pr-test-analyzer` + 내장 test-runner |
| `skills/linting/` | Claude 내장 (직접 린터 실행) |
| `skills/frameworks/fastapi/` | Claude 기본 지식 + Context7 |
| `workflow/fix-errors` | Claude 내장 기능 |
| `/dev:commit` | `commit-commands` plugin |
| `/dev:cr` | `pr-review-toolkit` plugin |
| `/dev:refactor`, `/dev:optimize`, `/dev:explain` | Claude 내장 |
| `/dev:epct` | `feature-dev` plugin |
| `/gh:pr` | `feature-dev` plugin + `gh` 직접 사용 |

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
rm -rf ~/.claude/skills/{testing,linting,frameworks}
rm -rf ~/.claude/commands/{dev,gh}
```

### 유지되는 커스텀 기능

공식 플러그인에 없는 기능만 유지:

| 기능 | 용도 |
|------|------|
| `/flow:handoff`, `/flow:resume` | 세션 연속성 (context 제한 극복) |
| `/flow:plan` | 전략적 계획 수립 |
| `/worktree:*` | Git worktree 병렬 작업 |
| `/ai:*` | 멀티모델 통합 (Gemini, Codex 등) |
