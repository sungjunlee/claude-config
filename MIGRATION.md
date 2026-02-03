# Migration Guide

## Plugin Architecture (v2.1.0) - Current

2026년 1월, 플러그인 아키텍처로 전환되었습니다.

### 주요 변경점

1. **Skills/Hooks → Plugin**: 자동 업데이트 가능한 플러그인으로 배포
2. **install.sh 간소화**: Account 설정(permissions, CLAUDE.md)만 설치
3. **레거시 정리**: `~/.claude/skills/`, `~/.claude/hooks/`, `~/.claude/scripts/` 제거

### 저장소 구조

```text
.
├── .claude-plugin/plugin.json  # Plugin metadata
├── skills/                     # Plugin (auto-update)
├── hooks/hooks.json            # Plugin (auto-update)
├── scripts/                    # Plugin (auto-update)
├── account/
│   ├── claude-code/            # → ~/.claude/ (install.sh로 설치)
│   ├── codex/                  # → ~/.codex/
│   └── antigravity/            # → ~/.gemini/antigravity/
└── install.sh
```

### 설치 후 ~/.claude/ 구조

```text
~/.claude/
├── CLAUDE.md            # 글로벌 설정 (install.sh)
├── settings.json        # Permissions (install.sh)
└── llm-models-latest.md # LLM 모델 참조 (install.sh)

# Skills, hooks, scripts는 플러그인에서 제공 (별도 위치)
```

### 설치 방법

```bash
# 1. Account 설정 설치
./install.sh

# 2. Plugin 설치 (Claude Code 내에서)
/plugin marketplace add sungjunlee/claude-config
/plugin install my@sungjunlee-claude-config
```

### 레거시 정리

`install.sh`가 자동으로 레거시 디렉토리를 정리합니다. 자동 정리가 실패한 경우에만 수동 삭제가 필요합니다:

```bash
# 자동 정리 실패 시에만 실행
rm -rf ~/.claude/scripts ~/.claude/hooks ~/.claude/skills
```

---

## 저장소 구조 변경 (v4.2) - Historical

> ⚠️ **참고**: 이 섹션은 v2.1.0 이전 기록입니다. 현재 구조는 위의 Plugin Architecture를 참조하세요.

2026년 1월, 저장소 구조가 개편되었습니다.

### 주요 변경점

1. **account/ 디렉토리 도입**: 계정 레벨 설정이 `account/` 하위로 이동
2. **멀티 도구 지원**: Claude Code, Codex, Antigravity 동시 지원
3. **커뮤니티 Skills**: `npx skills add`로 외부 skills 설치 가능

---

## Unified My Skill Architecture (v4.1)

2026년 1월, 모든 커스텀 기능을 단일 `my` skill로 통합했습니다.

### 명령어 변경

| 이전 | 현재 (v3.0.0) |
|------|------|
| `/flow:handoff` | `/session-handoff` |
| `/flow:resume` | `/session-resume` |
| `/worktree:plan` | `/worktree-init` |
| `/worktree:distribute` | `/worktree-init --continue` |
| `/worktree:status` | `/worktree-status` |
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

### Commands 명령어 요약 (v3.0.0)

공식 플러그인에 없는 기능:

| 명령어 | 용도 |
|--------|------|
| `/session-handoff`, `/session-resume` | 세션 연속성 |
| `/worktree-init`, `/worktree-launch` | 병렬 개발 |
| `/worktree-status` | 워크트리 관리 |
| `/dev-setup [gitleaks\|gitignore\|hooks]` | 개발 환경 설정 |
