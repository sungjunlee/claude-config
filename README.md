# Claude Config

Claude Code Plugin으로 배포되는 개인 설정입니다.

**v2.1.0** - Plugin Architecture

## 왜 플러그인인가?

| 방식 | Skills/Hooks | Permissions | 업데이트 |
|------|-------------|-------------|----------|
| **Plugin (v2.1+)** | 플러그인 번들 | install.sh | 자동 (`/plugin update`) |
| Legacy (v2.0-) | ~/.claude/ 복사 | install.sh | 수동 (재설치) |

플러그인 아키텍처는 skills와 hooks의 **자동 업데이트**를 지원합니다.

## 설치

### 1. Plugin 설치 (Skills & Hooks)

Claude Code 내에서:

```
/plugin marketplace add sungjunlee/claude-config
/plugin install my@sungjunlee-claude-config
```

Auto-update 활성화 (권장):
```
/plugin → Marketplace settings → Enable auto-update
```

### 2. Account 설정 (Permissions)

Permissions는 플러그인으로 배포할 수 없어 별도 설치가 필요합니다:

```bash
curl -fsSL https://raw.githubusercontent.com/sungjunlee/claude-config/main/install.sh | bash
```

### 설치 결과

| 컴포넌트 | 위치 | 자동 업데이트 |
|----------|------|---------------|
| Skills | Plugin | ✅ |
| Hooks | Plugin | ✅ |
| Scripts | Plugin | ✅ |
| Permissions | ~/.claude/settings.json | ❌ |
| CLAUDE.md | ~/.claude/CLAUDE.md | ❌ |

## Skills

### Session

| 명령어 | 용도 |
|--------|------|
| `/session handoff` | 세션 상태 저장 (`/clear` 전) |
| `/session resume` | 이전 세션 복원 |

### Worktree

| 명령어 | 용도 |
|--------|------|
| `/worktree init` | 병렬 워크트리 초기화 |
| `/worktree launch` | tmux/iTerm에서 Claude 세션 실행 |
| `/worktree status` | 워크트리 상태 확인 |

### Dev Setup

| 명령어 | 용도 |
|--------|------|
| `/dev-setup` | 개발 환경 보안 설정 |
| `/dev-setup gitleaks` | Gitleaks pre-commit 훅 설치 |
| `/dev-setup gitignore` | .gitignore 패턴 강화 |

## Hooks

| Event | Matcher | 기능 |
|-------|---------|------|
| UserPromptSubmit | * | UTC 타임스탬프 주입 |
| PreToolUse | Bash | 명령 감사 로깅 → ~/.claude/command-audit.log |
| PermissionRequest | * | 데스크톱 알림 (macOS/Linux) |
| PostToolUse | Edit\|Write\|MultiEdit | 자동 포맷팅 (Python, TS/JS, Rust, Go) |

## 업데이트

### Plugin (Skills & Hooks)

```
/plugin update my@sungjunlee-claude-config
```

또는 auto-update 활성화 시 자동.

### Account 설정

```bash
./install.sh --force
```

## 저장소 구조

```
.
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest (v2.1.0)
│
├── skills/                  # [Plugin] 자동 업데이트
│   ├── session/
│   ├── worktree/
│   └── dev-setup/
│
├── hooks/
│   └── hooks.json           # [Plugin] Hook 설정
│
├── scripts/                 # [Plugin] Hook 스크립트
│   ├── inject_datetime.sh
│   ├── audit_logger.py
│   ├── notify_permission.sh
│   └── hooks/
│       └── post_edit.py
│
├── account/
│   └── claude-code/         # [install.sh] Account 설정
│       ├── settings.json
│       ├── CLAUDE.md
│       └── llm-models-latest.md
│
└── install.sh
```

## 권장 플러그인

```
/plugin install pr-review-toolkit
/plugin install commit-commands
/plugin install feature-dev
```

## 마이그레이션

v2.0 이하에서 업그레이드:

```bash
./install.sh  # 레거시 디렉토리 자동 정리
```

자세한 내용: [MIGRATION.md](MIGRATION.md)

## 기타 도구 지원

| 도구 | 설정 위치 |
|------|-----------|
| Claude Code | ~/.claude/ |
| Codex | ~/.codex/ |
| Antigravity | ~/.gemini/antigravity/ |

## License

MIT
