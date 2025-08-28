# Worktree Parallel Task System Usage Guide

## 🎯 개요

A system that uses Git worktree to run multiple tasks in parallel.
Each task runs in an independent branch and directory, allowing multiple Claude Code instances to run simultaneously.

## 📦 설치

```bash
# Claude Config가 설치되어 있어야 함
cd claude-config
./install.sh

# 스크립트 실행 권한 확인
chmod +x scripts/worktree-manager.sh
```

## 🚀 빠른 시작

### 1. Generate Task Plan (Automatic)
```bash
# Automatic generation using plan-agent in Claude
/worktree-plan "Implement authentication, payment, and search features"
```

Or manually:

```bash
# Create template then edit
./scripts/worktree-manager.sh init
vim .worktrees/PLAN.md
```

### 2. Distribute Tasks
```bash
./scripts/worktree-manager.sh distribute
# Or within Claude
/worktree-distribute
```

### 3. Work in Each Worktree
```bash
# Terminal 1
cd .worktrees/auth
claude

# Terminal 2 (new tab/window)
cd .worktrees/payment
claude

# Terminal 3 (new tab/window)
cd .worktrees/search
claude
```

## 📋 주요 명령어

### Claude Commands

- `/worktree-plan [task description]` - Automatically generate PLAN.md with plan-agent
- `/worktree-distribute` - Distribute tasks based on PLAN.md
- `/worktree-status` - Check all worktree status
- `/worktree-sync` - Synchronize environment files

### Shell Script

```bash
# Create initial template
./scripts/worktree-manager.sh init

# Execute task distribution
./scripts/worktree-manager.sh distribute

# Check status
./scripts/worktree-manager.sh status

# Synchronize environment files
./scripts/worktree-manager.sh sync
```

## 🗂️ Directory Structure

```
myproject/
├── .worktrees/              # Worktree 루트
│   ├── PLAN.md              # Task plan
│   ├── tasks/               # Task instructions
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

## 🔄 Workflow

### 1. Planning
- `/worktree-plan` 명령으로 plan-agent가 자동 생성
- 또는 PLAN.md를 직접 작성
- Each task is designed to be independently executable

### 2. Automatic Distribution
- Create git worktree for each task
- 브랜치명: `feature/[task-name]`
- Automatically copy environment files (.env, package.json 등)
- node_modules는 심링크로 연결 (디스크 절약)

### 3. Parallel Work
- 각 worktree에서 독립적으로 Claude Code 실행
- Task instructions are at `.worktrees/tasks/[task].md` 참조
- 서로 간섭 없이 동시 진행

### 4. Completion and Merge
```bash
# After task completion, merge to main branch
git checkout main
git merge feature/auth
git merge feature/payment

# Worktree 정리
git worktree remove .worktrees/auth
```

## ✨ 특징

### Automatic Environment Copying
다음 파일들이 자동으로 복사됩니다:
- `.env`, `.env.local`, `.env.development`
- `package.json`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
- `tsconfig.json`, `.eslintrc`, `.prettierrc`
- `docker-compose.yml`
- Python: `requirements.txt`, `pyproject.toml`
- Ruby: `Gemfile`, `Gemfile.lock`

### Dependency Management
- `node_modules`는 심링크로 연결 (디스크 공간 절약)
- Python `venv`도 심링크로 공유 가능

### Isolated Work Environment
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

### Synchronize environment files
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