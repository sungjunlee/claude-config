# Command: /worktree-sync

worktree 간 공유 정보 동기화

## Usage

```bash
/worktree-sync
```

## Description

worktree 간에 공유해야 할 정보를 동기화합니다.
환경 변수 변경사항, 공통 설정, 컨텍스트 정보 등을 전파합니다.

## Actions

1. **환경 파일 동기화**
   - 메인 브랜치의 .env 변경사항을 모든 worktree에 전파
   - package.json 의존성 변경 감지 및 알림

2. **공유 컨텍스트 업데이트**
   - `.worktrees/CONTEXT.md` 파일 업데이트
   - 각 worktree의 진행 상황을 STATUS.md에 기록

3. **설정 파일 동기화**
   - tsconfig.json, .eslintrc 등 설정 파일 변경 전파

## Example

```bash
# 메인에서 .env 수정 후
/worktree-sync

# 출력:
✓ Synced .env to auth worktree
✓ Synced .env to payment worktree
✓ Updated CONTEXT.md
⚠ package.json changed - run npm install in worktrees
```

## Implementation

환경 파일 변경 감지 및 선택적 동기화:
- 변경된 파일만 복사
- 충돌 가능성 있는 파일은 사용자에게 확인
- node_modules는 심링크 유지

## Notes

- 작업 중인 파일은 덮어쓰지 않음
- 중요 변경사항은 사용자 확인 필요