# CLAUDE.md

Claude Code Skills 기반 설정 저장소입니다.

## 저장소 구조

```
.claude-plugin/          # Plugin metadata
skills/                  # Plugin: Skills (자동 업데이트)
hooks/                   # Plugin: Hooks (자동 업데이트)
scripts/                 # Plugin: Scripts (hooks에서 사용)
account/
├── claude-code/          # Account 설정 (~/.claude/로 설치)
│   ├── settings.json      # Permissions
│   ├── CLAUDE.md          # 글로벌 설정
│   └── llm-models-latest.md # LLM 모델 참조
└── codex/                 # Codex 템플릿 (~/.codex)
```

## 설치

```bash
./install.sh --force
```

## 개발

### 새 Skill 추가
1. `skills/[name]/` 생성
2. `SKILL.md` 작성 (skill 정의)
3. `workflows/*.md` 추가 (실행 워크플로)
4. `context/*.md` 추가 (도메인 지식)

### 테스트
```bash
./install.sh --force
# ~/.claude/ 확인
```

## 파일 위치

| 파일 | 용도 |
|------|------|
| `account/claude-code/settings.json` | Claude Code 설정 |
| `account/claude-code/CLAUDE.md` | 글로벌 선호 설정 |
| `account/claude-code/llm-models-latest.md` | LLM 모델 참조 |

## 참고

- [MIGRATION.md](MIGRATION.md) - 마이그레이션 가이드
- [docs/SKILLS_MIGRATION_PROPOSAL.md](docs/SKILLS_MIGRATION_PROPOSAL.md) - 설계 문서
