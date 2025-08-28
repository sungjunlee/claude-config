# Command: /worktree-status

모든 worktree의 현재 상태 확인

## Usage

```bash
/worktree-status
```

## Description

`.worktrees/` 디렉토리 내의 모든 worktree 상태를 한눈에 확인합니다.

## Output Information

각 worktree별로 표시:
- 브랜치명
- 변경된 파일 수
- 최근 커밋 메시지
- 작업 진행 상황

## Example Output

```
Worktree Status
────────────────────

auth
  Branch: feature/auth
  Changes: 5 files
  Last commit: Add OAuth2.0 login

payment
  Branch: feature/payment
  Changes: 0 files
  Last commit: Initial Stripe setup

search
  Branch: feature/search
  Changes: 3 files
  Last commit: No commits yet
```

## Implementation

```bash
scripts/worktree-manager.sh status
```

## Related Commands

- `/worktree-distribute` - 작업 분배
- `/worktree-sync` - 공유 정보 동기화