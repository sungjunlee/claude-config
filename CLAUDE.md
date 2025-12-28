# CLAUDE.md

Claude Code Skills 기반 설정 저장소입니다.

## 저장소 구조

```
profiles/account/           # Account 설정 (~/.claude/로 설치)
├── skills/                 # Skills
│   ├── workflow/           # handoff, resume, plan, fix-errors
│   ├── worktree/           # distribute, plan, status, sync
│   ├── testing/            # test (Python, JS, Rust context)
│   ├── linting/            # lint (ruff, ESLint, Clippy context)
│   └── frameworks/fastapi/ # FastAPI patterns
├── commands/               # Commands
│   ├── dev/                # commit, refactor, optimize, explain, epct, cr
│   ├── gh/                 # pr
│   └── ai/                 # multi-model integration
├── agents/                 # time-aware
├── scripts/                # 지원 스크립트
├── CLAUDE.md               # 글로벌 설정
└── llm-models-latest.md    # LLM 모델 참조
```

## 설치

```bash
./install.sh --force
```

## 개발

### 새 Skill 추가
1. `profiles/account/skills/[name]/` 생성
2. `SKILL.md` 작성 (skill 정의)
3. `workflows/*.md` 추가 (실행 워크플로)
4. `context/*.md` 추가 (도메인 지식)

### 새 Command 추가
1. `profiles/account/commands/[namespace]/[name].md` 생성
2. Frontmatter에 description 추가
3. `$ARGUMENTS`로 파라미터 전달

### 테스트
```bash
./install.sh --force
# ~/.claude/ 확인
```

## 파일 위치

| 파일 | 용도 |
|------|------|
| `profiles/account/settings.json` | Claude Code 설정 |
| `profiles/account/CLAUDE.md` | 글로벌 선호 설정 |
| `profiles/account/llm-models-latest.md` | LLM 모델 참조 |

## 참고

- [MIGRATION.md](MIGRATION.md) - 마이그레이션 가이드
- [docs/SKILLS_MIGRATION_PROPOSAL.md](docs/SKILLS_MIGRATION_PROPOSAL.md) - 설계 문서
