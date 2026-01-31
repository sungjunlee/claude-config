# Claude Config

Claude Code 및 AI 코딩 에이전트를 위한 개인 설정입니다.

## 설치

### Quick Start (Plugin + Account Settings)

Skills와 hooks는 플러그인으로, permissions와 global preferences는 install.sh로 설치합니다.

**1. Account-level 설정 설치:**

```bash
curl -fsSL https://raw.githubusercontent.com/sungjunlee/claude-config/main/install.sh | bash
```

**2. Plugin 설치 (Claude Code 내에서):**

```
/plugin marketplace add sungjunlee/claude-config
/plugin install my@sungjunlee-claude-config
```

**3. Auto-update 활성화 (권장):**

```
/plugin → Marketplace settings → Enable auto-update
```

### 컴포넌트별 설치 위치

| 컴포넌트 | 설치 위치 | 설치 방법 | 자동 업데이트 |
|----------|-----------|-----------|---------------|
| Skills (session, worktree, dev-setup) | Plugin | `/plugin install` | ✅ Yes |
| Hooks (PostToolUse, etc.) | Plugin | `/plugin install` | ✅ Yes |
| Permissions | ~/.claude/settings.json | install.sh | ❌ Manual |
| Global preferences | ~/.claude/CLAUDE.md | install.sh | ❌ Manual |
| LLM models reference | ~/.claude/llm-models-latest.md | install.sh | ❌ Manual |

### 이전 버전에서 마이그레이션

`~/.claude/scripts/` 또는 `~/.claude/hooks/`가 있는 경우:

```bash
./install.sh  # 자동으로 레거시 파일 정리
```

## 저장소 구조

```
.
├── .claude-plugin/          # Plugin metadata
│   ├── plugin.json          # Plugin manifest (v2.1.0)
│   └── marketplace.json     # Marketplace entry
│
├── skills/                  # Plugin: Skills (자동 업데이트)
│   ├── session/             # 세션 연속성 도구
│   ├── worktree/            # 병렬 개발 도구
│   └── dev-setup/           # 개발 환경 설정
│
├── hooks/                   # Plugin: Hooks (자동 업데이트)
│   └── hooks.json           # Hook configurations
│
├── scripts/                 # Plugin: Scripts (hooks에서 사용)
│   ├── inject_datetime.sh
│   ├── audit_logger.py
│   └── hooks/
│       └── post_edit.py
│
├── account/                 # install.sh: Account configs (수동 업데이트)
│   └── claude-code/
│       ├── settings.json    # Permissions
│       ├── CLAUDE.md        # Global preferences
│       └── llm-models-latest.md
│
└── install.sh               # Account-level 설치 스크립트
```

## Skills - 개인 도구 모음

### Session Management

| 명령어 | 용도 |
|--------|------|
| `/session handoff` | 세션 상태 저장 (`/clear` 전) |
| `/session resume` | 이전 세션 컨텍스트 복원 |

### Worktree

| 명령어 | 용도 |
|--------|------|
| `/worktree init` | 병렬 워크트리 초기화 (계획 + 분배 + 설정) |
| `/worktree launch` | tmux/iTerm에서 Claude 세션 실행 |
| `/worktree status` | 전체 워크트리 상태 확인 |

### Dev Setup

| 명령어 | 용도 |
|--------|------|
| `/dev-setup` | 개발 환경 보안 설정 (gitleaks, hooks) |
| `/dev-setup gitleaks` | Gitleaks pre-commit 훅 설치 |
| `/dev-setup gitignore` | .gitignore 패턴 강화 |

## Hooks

플러그인에 포함된 hooks:

| Event | Matcher | 기능 |
|-------|---------|------|
| UserPromptSubmit | * | 현재 시간 주입 |
| PreToolUse | Bash | Bash 명령 감사 로깅 |
| PermissionRequest | * | 권한 요청 알림 |
| PostToolUse | Edit\|Write\|MultiEdit | 자동 포맷팅 |

## 업데이트

### Plugin 업데이트 (Skills & Hooks)

Auto-update가 활성화되어 있으면 자동으로 업데이트됩니다.

수동 업데이트:
```
/plugin update my@sungjunlee-claude-config
```

### Account 설정 업데이트 (Permissions)

```bash
./install.sh --force
```

## 공식 플러그인 (권장)

```bash
/plugin install pr-review-toolkit      # PR 리뷰 (6개 전문 에이전트)
/plugin install commit-commands        # Git 워크플로우 자동화
/plugin install feature-dev            # 가이드 기능 개발
/plugin install document-skills@anthropic-agent-skills  # 문서 생성/편집
/plugin install security-guidance      # 보안 패턴 모니터링
```

## 지원 도구

| 도구 | 설정 위치 | 설명 |
|------|-----------|------|
| Claude Code | `~/.claude/` | Anthropic CLI |
| Codex | `~/.codex/` | OpenAI CLI |
| Antigravity | `~/.gemini/antigravity/` | Google Gemini CLI |

## 참고

- [MIGRATION.md](MIGRATION.md) - 마이그레이션 가이드
- [Claude Code Plugins Reference](https://code.claude.com/docs/en/plugins-reference)
- [skills.sh](https://skills.sh) - 커뮤니티 skills 디렉토리

## License

MIT
