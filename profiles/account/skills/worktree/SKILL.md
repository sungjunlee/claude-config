---
name: worktree
description: |
  Git worktree management for parallel task execution.
  Use when: distributing tasks across worktrees, checking worktree status,
  synchronizing environments, or planning parallel work.
  Triggers: "worktree", "parallel work", "multiple features", "병렬 작업",
  "동시에 작업", "워크트리"
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Worktree Management Skill

병렬 작업 실행을 위한 Git worktree 관리 스킬입니다. 독립적인 작업 단위를 여러 worktree에 분산하여 동시 진행할 수 있습니다.

## Overview

Git worktrees를 활용해 여러 기능을 동시에 개발할 수 있게 해줍니다. 각 worktree는 독립된 작업 공간으로, 서로 다른 브랜치에서 충돌 없이 병렬 작업이 가능합니다.

## Capabilities

### 1. Task Analysis & Distribution
- 사용자 요구사항 분석 및 병렬화 가능 작업 식별
- 구조화된 PLAN.md 파일 생성
- 브랜치 명명 규칙에 따른 이름 생성
- 작업 간 의존성 식별 및 문서화

### 2. Worktree Management
- 적절한 브랜치 설정으로 worktree 생성
- 환경 설정 파일 자동 복사 (.env, package.json 등)
- 공유 리소스용 symlink 생성 (node_modules, venv)
- Worktree 상태 모니터링
- 정리 및 병합 프로세스 가이드

### 3. Task Documentation
- `.worktrees/tasks/`에 상세 작업 지침 생성
- 각 작업별 명확한 수락 기준 포함
- 공통 컨텍스트 및 공유 요구사항 문서화
- 구체적인 Claude Code 호출 지침 제공

## Routing Logic

| 요청 패턴 | Workflow |
|----------|----------|
| "worktree 계획", "병렬 작업 분석", "plan parallel" | `workflows/plan.md` |
| "worktree 분배", "작업 시작", "distribute tasks" | `workflows/distribute.md` |
| "worktree 상태", "진행 확인", "check status" | `workflows/status.md` |
| "worktree 동기화", "환경 맞추기", "sync environment" | `workflows/sync.md` |

## Workflow Sequence

```text
/worktree:plan → PLAN.md 생성 → /worktree:distribute → 병렬 실행 → /worktree:status
```

## PLAN.md Format

````markdown
# Task Plan
Created: [YYYY-MM-DD]

## Task List
```bash
# Format: task-name: task description (estimated time)
auth: Implement OAuth2.0 authentication system (2h)
payment: Integrate Stripe payment processing (3h)
search: Add Elasticsearch full-text search (2h)
```

## Common Context
- TypeScript with strict mode
- Jest for testing (min 80% coverage)
- Follow REST API conventions

## Task Dependencies
- All tasks can run independently
- Merge order: auth → payment → search (recommended)
````

## Best Practices

### Task Selection
- 서로 다른 파일 집합을 수정하는 작업 선택
- 데이터베이스 스키마 충돌 피하기
- 포트 및 리소스 제약 고려
- 독립적인 테스트 가능 여부 확인

### Documentation Standards
- 모든 작업에 전용 지침 파일 생성
- 구체적인 수락 기준 포함
- 특별 요구사항 문서화
- 문제 해결 가이드 제공

### Merge Strategy
- 분배 시 병합 순서 계획
- 잠재적 충돌 문서화
- 롤백 절차 포함
- 통합 지점 테스트

## Integration

### With plan-agent
- 복잡한 작업 분석 시 plan-agent 활용
- 연구 결과를 모범 사례에 적용
- 위험 평가를 계획에 통합

### With Other Tools
- `scripts/worktree-manager.sh` 실행용
- `/worktree:status`로 모니터링 연동
- `/worktree:sync`로 업데이트 조정

## Example Commands

```bash
# Initialize worktree system
/worktree:plan "implement auth, payment, and search features"

# Distribute tasks
/worktree:distribute

# Check status
/worktree:status

# Synchronize changes
/worktree:sync

# Work in specific worktree
cd .worktrees/auth && claude
```

## Error Handling

Common issues and solutions:
- **Branch conflicts**: 기존 브랜치 확인, 필요시 정리
- **Symlink failures**: 소스 디렉토리 존재 확인
- **Permission issues**: 스크립트 실행 권한 확인
- **Space constraints**: 분배 전 디스크 공간 확인

## Success Metrics

- 모든 작업이 파일 충돌 없이 적절히 격리됨
- 각 worktree에 환경이 올바르게 구성됨
- 각 병렬 작업에 대한 명확한 문서
- 효율적인 리소스 공유 (symlinks 작동)
- 완료 후 원활한 병합 프로세스
