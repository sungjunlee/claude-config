---
name: workflow
description: |
  Session management and strategic planning skill.
  Use when: managing session handoffs, resuming work, creating plans, fixing errors.
  Triggers: "handoff", "resume", "plan", "fix errors", "핸드오프", "플랜"
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, WebSearch, WebFetch, Task
model: sonnet
---

# Workflow Skill

세션 관리 및 전략적 플래닝을 위한 스킬입니다. Context 연속성 유지, 복잡한 작업 계획 수립, 그리고 자기 성찰 분석을 지원합니다.

## Overview

이 스킬은 두 가지 핵심 에이전트 기능을 통합합니다:
- **Plan Agent**: 복잡한 작업의 전략적 계획 수립, 리서치, 실행 전략 생성
- **Reflection Agent**: Claude 자체 성능 분석 및 워크플로우 최적화

## Capabilities

### 1. Session Management
- Context handoff 시스템으로 세션 간 상태 유지
- `/clear` 전 자동 저장 권장
- Scratch notes를 통한 경량 working memory

### 2. Strategic Planning
- 복잡도 기반 계획 수립 (Simple/Medium/Complex)
- 웹 리서치 및 Context7을 통한 최신 best practices 조사
- 자동화된 Git 워크플로우 설정

### 3. Self-Reflection
- Context 사용량 모니터링
- 응답 품질 및 효율성 분석
- 워크플로우 최적화 권장

### 4. Error Resolution
- 빌드/테스트/린트 에러 자동 식별
- 우선순위 기반 수정
- 검증 사이클 실행

## Workflow Detection

| 트리거 | Workflow | 설명 |
|--------|----------|------|
| "handoff", "핸드오프" | `workflows/handoff.md` | 세션 상태 저장 |
| "resume", "재개" | `workflows/resume.md` | 이전 작업 복원 |
| "plan", "플랜", "계획" | `workflows/plan.md` | 전략적 계획 수립 |
| "fix errors", "에러 수정" | `workflows/fix-errors.md` | 에러 자동 수정 |
| "reflection", "성찰" | → reflection-agent 호출 | 자기 분석 수행 |

## Routing Logic

```text
요청 분석 → 복잡도 평가 → workflow 선택 → 실행 → 결과 리포트
```

### Complexity-Based Routing

| 복잡도 | 설명 | 접근 방식 |
|--------|------|-----------|
| Simple (1-3) | 단일 파일, 간단한 수정 | 직접 실행 |
| Medium (4-7) | 다중 파일, 표준 기능 | 구조화된 접근 |
| Complex (8-10) | 아키텍처 변경, 마이그레이션 | plan-agent 호출 |

## Plan Agent Integration

복잡한 작업에 대해 자동으로 호출됩니다:

### Research Phase
- 웹 검색으로 현재 best practices 조사
- Context7로 라이브러리 최신 버전 확인
- 보안 best practices 조사

### Planning Output
```markdown
# Execution Plan: [Task]

## Complexity Assessment
- Level: [Simple/Medium/Complex]
- Files Affected: [count]
- Risk Factors: [list]

## Git Workflow
Branch: `[type]/[name]`

## Implementation Phases
### Phase 1: [Name]
- [ ] Step 1
- [ ] Step 2

## Automated Triggers
on_phase_complete: [actions]
on_pr_ready: [actions]
```

## Reflection Integration

세션 성능 분석 시 호출:

### Analysis Areas
- Context 사용량 및 burn rate
- Task 완료율 및 품질
- Tool 사용 패턴 최적화

### Auto-trigger Conditions
- 50+ interactions 후
- Context 80% 도달 시
- 복잡한 multi-step 작업 후

## Handoff System

### File Locations
```
docs/handoff/
├── HANDOFF-[YYYYMMDD-HHMM].md  # 세션별 핸드오프
├── .current                     # 최신 핸드오프 포인터
├── .scratch.md                  # 실시간 working notes
└── archive/                     # 오래된 핸드오프
```

### Handoff Modes
- **Quick** (default): 핵심 정보만
- **Detailed** (`--detailed`): 전체 세션 기록
- **Team** (`--team`): 외부 협업용 포맷

### Archive Policy
- 최근 5개 핸드오프 유지
- 오래된 것은 archive/로 이동

## Context Files

| 파일 | 용도 |
|------|------|
| `context/handoff-template.md` | 핸드오프 문서 템플릿 |
| `context/planning-guide.md` | 계획 수립 가이드라인 |

## Command Mapping

기존 `/flow:*` 명령어와 호환:
- `/flow:handoff` → `workflows/handoff.md`
- `/flow:resume` → `workflows/resume.md`
- `/flow:plan` → `workflows/plan.md`
- `/flow:fix-errors` → `workflows/fix-errors.md`
- `/flow:reflection` → reflection-agent 직접 호출
- `/flow:scaffold` → 별도 명령어 유지 (프로젝트 스캐폴딩)
- `/flow:qa` → 별도 명령어 유지 (PR 품질 게이트)

## Best Practices

### Session Management
- 80% context에서 핸드오프 생성
- `.scratch.md`에 실시간 생각 기록
- 복잡한 작업 전 plan 먼저 수립

### Planning
- 요구사항을 명확히 제공
- 리서치 결과 검토
- 자동화 워크플로우 확인

### Reflection
- 자연스러운 breakpoint에서 수행
- 강점과 개선점 객관적 평가
- 실행 가능한 인사이트에 집중

## Error Handling

- **Missing handoff**: `/flow:plan`으로 새로 시작
- **Outdated handoff**: plan-agent로 재평가
- **Complex errors**: debugger agent 호출

## Success Metrics

- 세션 연속성 유지
- 계획 품질 및 실행력
- 에러 해결 완료율
- Context 효율적 활용
