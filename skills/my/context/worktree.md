# Worktree Operations Guide

Git worktree를 활용한 병렬 개발 상세 가이드입니다.

## 핵심 명령어

| Command | Purpose |
|---------|---------|
| `/my:wt-plan` | 병렬 작업 계획 생성 |
| `/my:wt-distribute` | 작업을 worktree로 분배 |
| `/my:wt-launch` | 세션 실행 (tmux/iterm) |
| `/my:wt-status` | 전체 상태 확인 |
| `/my:wt-sync` | 환경 파일 동기화 |

## 워크플로우

### 1. 계획 (Plan)
```bash
/my:wt-plan "auth, payment, search 기능 구현"
```
생성물: `.worktrees/PLAN.md`

### 2. 분배 (Distribute)
```bash
/my:wt-distribute
```
- Worktrees 생성
- 브랜치 설정
- 환경 파일 복사
- 작업 지침 배치

### 3. 실행 (Launch)
```bash
/my:wt-launch tmux    # tmux 세션
/my:wt-launch iterm   # iTerm 탭 (macOS)
```

### 4. 모니터링 (Status)
```bash
/my:wt-status
```
- 각 worktree 진행률
- 변경된 파일 수
- 마지막 커밋

### 5. 동기화 (Sync)
```bash
/my:wt-sync
```
- .env 파일 동기화
- 설정 파일 업데이트

### 6. 병합 (Merge)
```bash
# PLAN.md의 권장 순서 따라
git checkout main
git merge feature/auth
git merge feature/payment
git merge feature/search
```

## 디렉토리 구조

```
project/
├── .worktrees/
│   ├── PLAN.md           # 전체 계획
│   ├── tasks/            # 작업별 지침
│   │   ├── auth.md
│   │   └── payment.md
│   ├── auth/             # Auth worktree
│   └── payment/          # Payment worktree
└── src/                  # Main directory
```

## 작업 분리 원칙

### 독립성 확보
- 서로 다른 파일 수정
- 공유 파일은 최소화
- 의존성 명시

### 리소스 관리
- 포트 충돌 방지
- DB 연결 제한 고려
- 디스크 공간 모니터링

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
상세 가이드: `context/worktree-guide.md`
