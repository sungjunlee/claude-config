# Claude Config

Claude Code 및 AI 코딩 에이전트를 위한 계정 레벨 설정입니다.

## 설치

### 전체 설치 (권장)

skills, commands, hooks, scripts, CLAUDE.md 등 모든 설정을 설치합니다.

```bash
curl -fsSL https://raw.githubusercontent.com/sungjunlee/claude-config/main/install.sh | bash
```

옵션:
```bash
./install.sh --all              # 모든 도구 (Claude, Codex, Antigravity)
./install.sh --tools claude,codex  # 특정 도구만
./install.sh --force            # 기존 설정 백업 후 덮어쓰기
```

### Skills만 설치

skills만 따로 설치하고 싶다면 [npx skills](https://skills.sh)를 사용할 수 있습니다.

```bash
npx skills add sungjunlee/claude-config
npx skills add sungjunlee/claude-config --skill session  # 특정 skill만
npx skills add sungjunlee/claude-config --list      # 목록 보기
```

### 공식 플러그인 (권장)

```bash
/plugin install pr-review-toolkit      # PR 리뷰 (6개 전문 에이전트)
/plugin install commit-commands        # Git 워크플로우 자동화
/plugin install feature-dev            # 가이드 기능 개발
/plugin install document-skills@anthropic-agent-skills  # 문서 생성/편집
/plugin install security-guidance      # 보안 패턴 모니터링
```

## 저장소 구조

```
.
├── account/                 # 계정 레벨 설정 (홈 디렉토리로 설치됨)
│   ├── claude-code/         # → ~/.claude/
│   │   ├── scripts/         # 지원 스크립트
│   │   ├── hooks/           # 이벤트 훅
│   │   ├── CLAUDE.md        # 글로벌 설정
│   │   └── llm-models-latest.md
│   ├── codex/               # → ~/.codex/
│   └── antigravity/         # → ~/.gemini/antigravity/
│
├── skills/                  # 커스텀 skills → ~/.claude/skills/
│   ├── session/             # 세션 연속성 도구
│   ├── worktree/            # 병렬 개발 도구
│   └── dev-setup/           # 개발 환경 설정
│
└── install.sh               # 설치 스크립트
```

설치 후 `~/.claude/` 구조:

```
~/.claude/
├── skills/
│   ├── session/        # 세션 연속성 도구
│   ├── worktree/       # 병렬 개발 도구
│   └── dev-setup/      # 개발 환경 설정
├── scripts/            # 지원 스크립트
├── hooks/              # 이벤트 훅 (선택)
├── CLAUDE.md           # 글로벌 설정
└── llm-models-latest.md # LLM 모델 참조
```

## Skills - 개인 도구 모음

공식 플러그인에 없는 개인 확장 기능입니다.

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

## 업데이트

```bash
# 재설치로 업데이트
curl -fsSL https://raw.githubusercontent.com/sungjunlee/claude-config/main/install.sh | bash

# 강제 업데이트 (기존 설정 백업 후 덮어쓰기)
./install.sh --force
```

## 지원 도구

| 도구 | 설정 위치 | 설명 |
|------|-----------|------|
| Claude Code | `~/.claude/` | Anthropic CLI |
| Codex | `~/.codex/` | OpenAI CLI |
| Antigravity | `~/.gemini/antigravity/` | Google Gemini CLI |

## 참고

- [MIGRATION.md](MIGRATION.md) - 마이그레이션 가이드
- [skills.sh](https://skills.sh) - 커뮤니티 skills 디렉토리

## License

MIT
