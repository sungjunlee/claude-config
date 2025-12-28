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
│   └── my/               # 개인 도구 모음 (공식 대안 없음)
│       ├── commands/     # AI, 세션, 워크트리 명령어
│       └── context/      # 참조 문서
│
├── agents/               # time-aware
├── CLAUDE.md             # 글로벌 설정
└── llm-models-latest.md  # LLM 모델 참조
```

## My Skill - 개인 도구 모음

단일 skill로 통합된 개인 확장 기능입니다.

### AI Integration (`ai-*`)

| 명령어 | 용도 |
|--------|------|
| `/my:ai-gemini` | 대용량 파일 분석 (무료, 2M 컨텍스트) |
| `/my:ai-codex` | 알고리즘 최적화, 디버깅 |
| `/my:ai-consensus` | 중요 결정 시 여러 AI 관점 |
| `/my:ai-pipeline` | 복잡한 프로젝트 멀티스테이지 분석 |

### Session Management

| 명령어 | 용도 |
|--------|------|
| `/my:handoff` | 세션 상태 저장 (`/clear` 전) |
| `/my:resume` | 이전 세션 컨텍스트 복원 |

### Worktree (`wt-*`)

| 명령어 | 용도 |
|--------|------|
| `/my:wt-plan` | 병렬 작업 계획 생성 |
| `/my:wt-distribute` | 워크트리에 작업 분배 |
| `/my:wt-status` | 전체 워크트리 상태 확인 |
| `/my:wt-sync` | 환경 파일 동기화 |

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
