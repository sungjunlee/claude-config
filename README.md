# Claude Config

Claude Code를 위한 최소한의 커스텀 설정입니다. 공식 플러그인과 중복되지 않는 기능만 유지합니다.

## 설치

```bash
curl -fsSL https://raw.githubusercontent.com/sungjunlee/claude-config/main/install.sh | bash
```

## 구조

```
~/.claude/
├── skills/
│   ├── workflow/         # 세션 관리 (공식 대안 없음)
│   └── worktree/         # 병렬 개발 (공식 대안 없음)
│
├── commands/
│   └── ai/               # 멀티모델 통합 (공식 대안 없음)
│
├── agents/               # time-aware
├── CLAUDE.md             # 글로벌 설정
└── llm-models-latest.md  # LLM 모델 참조
```

## 커스텀 Skills (공식 대안 없음)

| Skill | 명령어 | 용도 |
|-------|--------|------|
| `workflow` | `/flow:handoff`, `/flow:resume`, `/flow:plan` | 세션 연속성 |
| `worktree` | `/worktree:plan`, `/worktree:distribute`, `/worktree:status`, `/worktree:sync` | Git worktree 병렬 작업 |

## 멀티모델 명령어

| 명령어 | 모델 | 용도 |
|--------|------|------|
| `/ai:gemini` | Google Gemini | 대용량 파일 분석 (무료) |
| `/ai:codex` | OpenAI Codex | 알고리즘, 디버깅 |
| `/ai:route` | 자동 선택 | 작업별 최적 모델 |
| `/ai:try-free` | 무료→유료 | 비용 최적화 |

## 공식 플러그인 사용 권장

아래 기능들은 공식 플러그인 사용을 권장합니다:

| 작업 | 공식 플러그인 | 설치 |
|------|--------------|------|
| 코드 리뷰 | `pr-review-toolkit` | `/plugin install pr-review-toolkit` |
| PR 리뷰 | `code-review` | `/plugin install code-review` |
| 커밋 | `commit-commands` | `/plugin install commit-commands` |
| 기능 개발 | `feature-dev` | `/plugin install feature-dev` |
| 문서 생성 | `document-skills` | `/plugin install document-skills@anthropic-agent-skills` |
| 보안 검사 | `security-guidance` | `/plugin install security-guidance` |

## 업데이트

```bash
curl -fsSL https://raw.githubusercontent.com/sungjunlee/claude-config/main/install.sh | bash
```

## License

MIT
