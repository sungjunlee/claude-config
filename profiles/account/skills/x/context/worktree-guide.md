# Git Worktree Guide

## Overview

Git worktree는 하나의 레포지토리에서 여러 작업 디렉토리를 동시에 관리할 수 있는 기능입니다. 각 worktree는 독립적인 브랜치를 체크아웃하여 병렬 작업이 가능합니다.

## Basic Commands

### Create Worktree

```bash
# 새 브랜치와 함께 worktree 생성
git worktree add ../.worktrees/feature-name -b feature/feature-name

# 기존 브랜치로 worktree 생성
git worktree add ../.worktrees/feature-name feature/existing-branch
```

### List Worktrees

```bash
git worktree list
```

### Remove Worktree

```bash
# worktree 제거 (디렉토리는 유지)
git worktree remove .worktrees/feature-name

# 강제 제거
git worktree remove --force .worktrees/feature-name

# 디렉토리 직접 삭제 후 정리
rm -rf .worktrees/feature-name
git worktree prune
```

## Directory Structure

```text
project-root/
├── .worktrees/
│   ├── PLAN.md              # 작업 계획
│   ├── tasks/               # 작업별 지침
│   │   ├── auth.md
│   │   ├── payment.md
│   │   └── search.md
│   ├── auth/                # Auth worktree
│   ├── payment/             # Payment worktree
│   └── search/              # Search worktree
└── src/                     # Main working directory
```

## Environment Setup

### Files to Copy

각 worktree 생성 시 복사해야 할 파일들:

```text
.env
.env.local
.env.development
package.json
package-lock.json (or yarn.lock, pnpm-lock.yaml)
tsconfig.json
.eslintrc.*
.prettierrc.*
pyproject.toml
requirements.txt
Cargo.toml
```

### Symlinks for Efficiency

대용량 디렉토리는 symlink로 공유:

```bash
# Node.js
ln -s ../../node_modules .worktrees/feature-name/node_modules

# Python
ln -s ../../.venv .worktrees/feature-name/.venv

# Rust
ln -s ../../target .worktrees/feature-name/target
```

## Parallel Development Workflow

### 1. Planning Phase

```bash
# PLAN.md 생성
/worktree:plan "implement auth, payment, search features"
```

### 2. Distribution Phase

```bash
# Worktrees 생성 및 환경 설정
/worktree:distribute
```

### 3. Parallel Work

```bash
# 터미널 1
cd .worktrees/auth && claude

# 터미널 2
cd .worktrees/payment && claude

# 터미널 3
cd .worktrees/search && claude
```

### 4. Monitoring

```bash
# 진행 상황 확인
/worktree:status
```

### 5. Synchronization

```bash
# 환경 파일 동기화
/worktree:sync
```

### 6. Merge

```bash
# 각 브랜치 병합 (권장 순서 따르기)
git checkout main
git merge feature/auth
git merge feature/payment
git merge feature/search
```

## Best Practices

### Task Independence

- 각 작업이 서로 다른 파일을 수정하도록 분리
- 공유 파일 수정이 필요한 경우 의존성 명시
- 데이터베이스 마이그레이션은 별도 처리

### Resource Management

- 포트 충돌 방지 (각 worktree에 다른 포트 할당)
- 데이터베이스 연결 수 제한 고려
- 디스크 공간 모니터링

### Conflict Prevention

- 병합 순서 미리 계획
- 공통 유틸리티 변경은 먼저 병합
- 자주 `/worktree:status` 확인

## Troubleshooting

### Branch Already Exists

```bash
# 기존 브랜치 삭제
git branch -D feature/name

# 또는 다른 이름 사용
git worktree add .worktrees/name -b feature/name-v2
```

### Worktree Locked

```bash
# 잠금 해제
git worktree unlock .worktrees/name
```

### Orphaned Worktrees

```bash
# 고아 worktree 정리
git worktree prune
```

### Permission Denied

```bash
# 스크립트 실행 권한
chmod +x scripts/worktree-manager.sh
```

## Integration with CI/CD

### GitHub Actions Example

```yaml
jobs:
  parallel-build:
    strategy:
      matrix:
        feature: [auth, payment, search]
    steps:
      - uses: actions/checkout@v4
      - run: |
          git worktree add .worktrees/${{ matrix.feature }} feature/${{ matrix.feature }}
          cd .worktrees/${{ matrix.feature }}
          npm install && npm test
```

## References

- [Git Worktree Documentation](https://git-scm.com/docs/git-worktree)
