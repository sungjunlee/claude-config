# Git Worktree Guide

Git worktree를 활용한 병렬 개발 가이드입니다.

## 핵심 명령어

| Command | Purpose |
|---------|---------|
| `/worktree-init` | 계획 + 분배 + 환경 세팅 |
| `/worktree-launch` | 세션 실행 (tmux/iterm) |
| `/worktree-status` | 전체 상태 확인 |

## 워크플로우

### 1. 초기화 (Init)
```bash
/worktree-init "auth, payment, search 기능 구현"
```
한 번에:
- PLAN.md 생성
- Worktrees 생성
- 환경 파일 복사
- 패키지 매니저 실행 (npm/pnpm/uv)
- 작업별 CLAUDE.md 생성

### 2. 실행 (Launch)
```bash
/worktree-launch tmux    # tmux 세션
/worktree-launch iterm   # iTerm 탭 (macOS)
```

### 3. 모니터링 (Status)
```bash
/worktree-status
```

### 4. 병합 & 정리 (Merge & Cleanup)
```bash
# 병합
git checkout main
git merge feature/auth

# 정리
git worktree remove .worktrees/auth
git branch -d feature/auth
```

## 디렉토리 구조

```
project/
├── .worktrees/
│   ├── PLAN.md              # 전체 계획
│   ├── tasks/               # 작업별 지침
│   │   ├── auth.md
│   │   └── payment.md
│   ├── auth/                # Auth worktree
│   │   ├── CLAUDE.md       # 작업 컨텍스트
│   │   └── ...
│   └── payment/             # Payment worktree
└── src/                     # Main directory
```

## 기본 Git Worktree 명령어

```bash
# 생성
git worktree add .worktrees/feature-name -b feature/feature-name

# 목록
git worktree list

# 제거
git worktree remove .worktrees/feature-name

# 정리 (고아 참조)
git worktree prune
```

## 작업 분리 원칙

### 독립성 확보
- 각 작업이 서로 다른 파일 수정
- 공유 파일 수정은 최소화
- 파일 겹침 시 merge 충돌 발생

### 리소스 관리
- 포트 충돌 방지 (각 worktree에 다른 포트)
- DB 연결 수 제한 고려
- 토큰 소비 주의 (병렬 실행 시 빠름)

## 문제 해결

### 브랜치 충돌
```bash
git branch -D feature/name
# 또는
git worktree add .worktrees/name -b feature/name-v2
```

### Worktree 잠금
```bash
git worktree unlock .worktrees/name
```

### 정리
```bash
git worktree prune
```

## 참조

- [Git Worktree Documentation](https://git-scm.com/docs/git-worktree)
