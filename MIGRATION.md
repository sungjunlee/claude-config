# Migration Guide

## 저장소 구조 변경 (v4.2)

2026년 1월, 저장소 구조가 개편되었습니다.

### 주요 변경점

1. **account/ 디렉토리 도입**: 계정 레벨 설정이 `account/` 하위로 이동
2. **멀티 도구 지원**: Claude Code, Codex, Antigravity 동시 지원
3. **커뮤니티 Skills**: `npx skills add`로 외부 skills 설치 가능

### 저장소 구조

```text
.
├── account/
│   ├── claude-code/     # → ~/.claude/ (scripts, hooks, CLAUDE.md 등)
│   ├── codex/           # → ~/.codex/
│   └── antigravity/     # → ~/.gemini/antigravity/
├── commands/            # → ~/.claude/commands/
├── skills/              # → ~/.claude/skills/
└── install.sh
```

### 설치 후 ~/.claude/ 구조

```text
~/.claude/
├── commands/            # /my:* 커맨드
├── skills/
│   ├── session/         # 세션 연속성 도구
│   ├── worktree/        # 병렬 개발 도구
│   └── dev-setup/       # 개발 환경 설정
├── scripts/             # 지원 스크립트
├── hooks/               # 이벤트 훅
├── CLAUDE.md            # 글로벌 설정
└── llm-models-latest.md
```

---

## Unified My Skill Architecture (v4.1)

2026년 1월, 모든 커스텀 기능을 단일 `my` skill로 통합했습니다.

### 명령어 변경

| 이전 | 현재 |
|------|------|
| `/flow:handoff` | `/session handoff` |
| `/flow:resume` | `/session resume` |
| `/worktree:plan` | `/worktree init` |
| `/worktree:distribute` | `/worktree init --continue` |
| `/worktree:status` | `/worktree status` |
| `/worktree:sync` | 제거됨 (init 시 자동 복사) |
| `/ai:gemini` | 제거됨 |
| `/ai:codex` | 제거됨 |
| `/ai:consensus` | 제거됨 |
| `/ai:pipeline` | 제거됨 |

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
rm -rf ~/.claude/skills/my/commands
```

### Skills 명령어 요약

공식 플러그인에 없는 기능:

| Skill | 명령어 | 용도 |
|-------|--------|------|
| session | `/session handoff`, `/session resume` | 세션 연속성 |
| worktree | `/worktree init`, `/worktree launch` | 병렬 개발 |
| worktree | `/worktree status` | 워크트리 관리 |
| dev-setup | `/dev-setup [gitleaks\|gitignore\|hooks]` | 개발 환경 설정 |
