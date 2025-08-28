# Command: /worktree-distribute

PLAN.md를 읽어서 작업들을 worktree로 분배

## Usage

```bash
/worktree-distribute
```

## Description

`.worktrees/PLAN.md` 파일을 파싱해서 각 작업을 독립된 git worktree로 분배합니다.
환경 파일(.env, package.json 등)을 자동으로 복사해서 즉시 작업 가능한 상태로 만듭니다.

## Actions

1. `.worktrees/PLAN.md` 파싱
2. 각 작업별 worktree 생성 (브랜치명: `feature/task-name`)
3. 환경 파일 자동 복사 (.env, package.json, lock 파일 등)
4. `tasks/` 폴더에 작업별 지시서 생성
5. 각 worktree에서 Claude 실행 방법 안내

## Prerequisites

- Git repository
- `.worktrees/PLAN.md` 파일 존재

## PLAN.md Format

```markdown
# 작업 계획

## 작업 목록
​```bash
# 형식: task-name: 작업 설명
auth: 사용자 인증 시스템 구현
payment: 결제 모듈 구현
search: 검색 기능 구현
​```

## 공통 컨텍스트
- TypeScript 사용
- 테스트 코드 포함
```

## Output

각 작업별로:
- `.worktrees/[task-name]/` 디렉토리 생성
- `.worktrees/tasks/[task-name].md` 작업 지시서 생성
- 필요한 환경 파일 복사

## Example

```bash
# 1. PLAN.md 작성
vim .worktrees/PLAN.md

# 2. 분배 실행
/worktree-distribute

# 3. 각 worktree에서 작업
cd .worktrees/auth && claude
```

## Implementation

```bash
scripts/worktree-manager.sh distribute
```