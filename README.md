# Claude Config

Claude Code를 위한 Skills 기반 설정입니다.

## 설치

```bash
curl -fsSL https://raw.githubusercontent.com/sungjunlee/claude-config/main/install.sh | bash
```

## 구조

```
~/.claude/
├── skills/                    # Skills (자동 로드)
│   ├── workflow/              # /flow:handoff, resume, plan, fix-errors
│   ├── worktree/              # /worktree:distribute, plan, status, sync
│   ├── testing/               # /dev:test (Python, JS, Rust context)
│   ├── linting/               # /dev:lint (ruff, ESLint, Clippy context)
│   └── frameworks/fastapi/    # FastAPI patterns
│
├── commands/                  # Commands (수동 호출)
│   ├── dev/                   # /commit, /refactor, /optimize, /explain, /epct, /cr
│   ├── gh/                    # /pr
│   └── ai/                    # /gemini, /codex, /route, /try-free, /consensus, /pipeline
│
├── agents/                    # time-aware (datetime 자동 주입)
├── scripts/                   # 지원 스크립트
├── CLAUDE.md                  # 글로벌 설정
└── llm-models-latest.md       # LLM 모델 참조
```

## Skills

| Skill | 명령어 | 용도 |
|-------|--------|------|
| `workflow` | `/flow:handoff`, `/flow:resume`, `/flow:plan`, `/flow:fix-errors` | 세션 관리 |
| `worktree` | `/worktree:distribute`, `/worktree:plan`, `/worktree:status`, `/worktree:sync` | 병렬 개발 |
| `testing` | `/dev:test` | 언어별 테스트 |
| `linting` | `/dev:lint` | 언어별 린팅 |
| `fastapi` | (자동 context) | FastAPI 패턴 |

## Commands

| 명령어 | 용도 |
|--------|------|
| `/dev:commit` | 스마트 커밋 |
| `/dev:refactor` | 리팩토링 |
| `/dev:optimize` | 성능 최적화 |
| `/dev:explain` | 코드 설명 |
| `/dev:epct` | Explore-Plan-Code-Test 워크플로 |
| `/dev:cr` | CodeRabbit 통합 |
| `/gh:pr` | PR 생성 |

## AI 멀티모델 명령어

| 명령어 | 모델 | 용도 |
|--------|------|------|
| `/ai:gemini` | Google Gemini | 대용량 파일 분석 (무료) |
| `/ai:codex` | OpenAI Codex | 알고리즘, 디버깅 |
| `/ai:route` | 자동 선택 | 작업별 최적 모델 |
| `/ai:try-free` | 무료→유료 | 비용 최적화 |

## 공식 플러그인 연동

| 플러그인 | 용도 |
|----------|------|
| `pr-review-toolkit` | 코드 리뷰 |
| `document-skills` | 문서 생성 |
| `silent-failure-hunter` | 에러 탐지 |

## 업데이트

```bash
# 재설치로 업데이트
curl -fsSL https://raw.githubusercontent.com/sungjunlee/claude-config/main/install.sh | bash
```

## License

MIT
