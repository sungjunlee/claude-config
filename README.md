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

## 권장 공식 플러그인

### pr-review-toolkit
PR 리뷰를 위한 6개 전문 에이전트:
- `code-reviewer` - 코드 품질 (0-100 confidence score)
- `pr-test-analyzer` - 테스트 커버리지 분석 (1-10 severity)
- `silent-failure-hunter` - 에러 핸들링 이슈 탐지
- `type-design-analyzer` - 타입 설계 분석
- `comment-analyzer` - 코드 코멘트 검토
- `code-simplifier` - 복잡도 개선 제안

```bash
/plugin install pr-review-toolkit
```

### code-review
자동 PR 코드 리뷰 (5개 병렬 Sonnet 에이전트):
- CLAUDE.md 준수 검사
- 버그 탐지
- PR 히스토리 분석
- Confidence 기반 필터링 (기본 80/100)

```bash
/plugin install code-review
```

### commit-commands
Git 워크플로우 자동화:
- 스마트 커밋 메시지 생성
- 브랜치 관리
- PR 생성 자동화

```bash
/plugin install commit-commands
```

### feature-dev
가이드 기능 개발 워크플로우:
- `code-explorer` - 코드베이스 분석
- `code-architect` - 아키텍처 설계
- `code-reviewer` - 품질 리뷰

```bash
/plugin install feature-dev
```

### document-skills
문서 생성 및 편집:
- PDF - 추출, 생성, 병합/분할
- DOCX - Word 문서 생성/편집, 변경 추적
- PPTX - 프레젠테이션 생성
- XLSX - 스프레드시트, 수식, 차트

```bash
/plugin install document-skills@anthropic-agent-skills
```

### security-guidance
실시간 보안 패턴 모니터링:
- Command injection 탐지
- XSS 취약점
- Eval 사용
- Pickle deserialization
- os.system 호출 등

```bash
/plugin install security-guidance
```

## 업데이트

```bash
curl -fsSL https://raw.githubusercontent.com/sungjunlee/claude-config/main/install.sh | bash
```

## License

MIT
