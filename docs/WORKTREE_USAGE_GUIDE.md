# Worktree 병렬 작업 시스템 사용 가이드

## 🎯 개요

Git worktree를 활용해서 여러 작업을 병렬로 진행하는 시스템입니다.
각 작업은 독립된 브랜치와 디렉토리에서 진행되며, 여러 Claude Code 인스턴스를 동시에 실행할 수 있습니다.

## 📦 설치

```bash
# Claude Config가 설치되어 있어야 함
cd claude-config
./install.sh

# 스크립트 실행 권한 확인
chmod +x scripts/worktree-manager.sh
```

## 🚀 빠른 시작

### 1. 작업 계획 생성 (자동)
```bash
# Claude에서 plan-agent를 활용한 자동 생성
/worktree-plan "인증, 결제, 검색 기능 구현"
```

또는 수동으로:

```bash
# 템플릿 생성 후 편집
./scripts/worktree-manager.sh init
vim .worktrees/PLAN.md
```

### 2. 작업 분배
```bash
./scripts/worktree-manager.sh distribute
# 또는 Claude 내에서
/worktree-distribute
```

### 3. 각 worktree에서 작업
```bash
# Terminal 1
cd .worktrees/auth
claude

# Terminal 2 (새 탭/창)
cd .worktrees/payment
claude

# Terminal 3 (새 탭/창)
cd .worktrees/search
claude
```

## 📋 주요 명령어

### Claude Commands

- `/worktree-plan [작업 설명]` - plan-agent로 PLAN.md 자동 생성
- `/worktree-distribute` - PLAN.md 기반 작업 분배
- `/worktree-status` - 모든 worktree 상태 확인
- `/worktree-sync` - 환경 파일 동기화

### Shell Script

```bash
# 초기 템플릿 생성
./scripts/worktree-manager.sh init

# 작업 분배 실행
./scripts/worktree-manager.sh distribute

# 상태 확인
./scripts/worktree-manager.sh status

# 환경 파일 동기화
./scripts/worktree-manager.sh sync
```

## 🗂️ 디렉토리 구조

```
myproject/
├── .worktrees/              # Worktree 루트
│   ├── PLAN.md              # 작업 계획
│   ├── tasks/               # 작업별 지시서
│   │   ├── auth.md
│   │   ├── payment.md
│   │   └── search.md
│   ├── auth/                # Worktree 1
│   ├── payment/             # Worktree 2
│   └── search/              # Worktree 3
├── .env                     # 자동 복사됨
├── package.json             # 자동 복사됨
└── src/                     # 메인 코드
```

## 🔄 작업 흐름

### 1. 계획 수립
- `/worktree-plan` 명령으로 plan-agent가 자동 생성
- 또는 PLAN.md를 직접 작성
- 각 작업은 독립적으로 실행 가능하도록 설계

### 2. 자동 분배
- 각 작업별로 git worktree 생성
- 브랜치명: `feature/[task-name]`
- 환경 파일 자동 복사 (.env, package.json 등)
- node_modules는 심링크로 연결 (디스크 절약)

### 3. 병렬 작업
- 각 worktree에서 독립적으로 Claude Code 실행
- 작업 지시서는 `.worktrees/tasks/[task].md` 참조
- 서로 간섭 없이 동시 진행

### 4. 완료 및 병합
```bash
# 작업 완료 후 메인 브랜치로 병합
git checkout main
git merge feature/auth
git merge feature/payment

# Worktree 정리
git worktree remove .worktrees/auth
```

## ✨ 특징

### 자동 환경 복사
다음 파일들이 자동으로 복사됩니다:
- `.env`, `.env.local`, `.env.development`
- `package.json`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
- `tsconfig.json`, `.eslintrc`, `.prettierrc`
- `docker-compose.yml`
- Python: `requirements.txt`, `pyproject.toml`
- Ruby: `Gemfile`, `Gemfile.lock`

### 의존성 관리
- `node_modules`는 심링크로 연결 (디스크 공간 절약)
- Python `venv`도 심링크로 공유 가능

### 격리된 작업 환경
- 각 worktree는 독립된 git 브랜치
- 파일 변경이 서로 영향 없음
- 독립적인 커밋 히스토리

## 💡 활용 시나리오

### 시나리오 1: 기능 병렬 개발
```bash
# PLAN.md
auth: 인증 시스템
admin: 관리자 패널
api: REST API

# 3개 기능을 3명의 Claude가 동시 개발
```

### 시나리오 2: 버그 수정
```bash
# PLAN.md
fix-login: 로그인 버그 수정
fix-payment: 결제 오류 수정
fix-search: 검색 성능 개선

# 각 버그를 독립적으로 수정
```

### 시나리오 3: 리팩토링
```bash
# PLAN.md
refactor-auth: 인증 모듈 리팩토링
refactor-db: DB 레이어 개선
refactor-ui: UI 컴포넌트 정리

# 대규모 리팩토링을 영역별로 진행
```

## 🛠️ 문제 해결

### Worktree가 생성되지 않을 때
```bash
# 기존 브랜치 확인
git branch -a

# 필요시 브랜치 삭제
git branch -D feature/task-name

# 다시 시도
./scripts/worktree-manager.sh distribute
```

### 환경 파일 동기화
```bash
# .env가 변경되었을 때
./scripts/worktree-manager.sh sync

# 또는 Claude에서
/worktree-sync
```

### Worktree 정리
```bash
# 개별 worktree 제거
git worktree remove .worktrees/auth

# 전체 정리
git worktree prune
rm -rf .worktrees
```

## 📝 Best Practices

1. **작업 독립성 유지**
   - 각 작업이 다른 작업에 의존하지 않도록 설계
   - 공통 코드는 메인 브랜치에서 먼저 구현

2. **적절한 작업 크기**
   - 너무 큰 작업은 분할
   - 너무 작은 작업은 묶어서 처리

3. **정기적인 동기화**
   - 환경 파일 변경 시 sync 실행
   - 메인 브랜치 변경사항 주기적으로 병합

4. **명확한 작업 설명**
   - PLAN.md에 구체적인 작업 내용 기술
   - 완료 기준 명시

## 🔗 관련 문서

- [Git Worktree 공식 문서](https://git-scm.com/docs/git-worktree)
- [Claude Code Commands](../commands/workflow/)
- [Worktree Coordinator Agent](../agents/worktree-coordinator.md)