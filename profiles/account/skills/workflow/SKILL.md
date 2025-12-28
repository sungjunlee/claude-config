---
name: workflow
description: |
  Session management and strategic planning skill.
  Use when: managing session handoffs, resuming work, creating plans.
  Triggers: "handoff", "resume", "plan", "핸드오프", "플랜"
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, WebSearch, WebFetch, Task
model: sonnet
---

# Workflow Skill

세션 관리 및 전략적 플래닝을 위한 스킬입니다. Context 연속성 유지 및 복잡한 작업 계획 수립을 지원합니다.

## Overview

공식 플러그인에 없는 기능을 제공합니다:
- **Session Continuity**: Context handoff로 세션 간 상태 유지
- **Strategic Planning**: 복잡한 작업의 전략적 계획 수립

## Capabilities

### 1. Session Management
- Context handoff 시스템으로 세션 간 상태 유지
- `/clear` 전 자동 저장 권장
- Scratch notes를 통한 경량 working memory

### 2. Strategic Planning
- 복잡도 기반 계획 수립 (Simple/Medium/Complex)
- 웹 리서치 및 Context7을 통한 최신 best practices 조사
- 자동화된 Git 워크플로우 설정

## Workflow Detection

| 트리거 | Workflow | 설명 |
|--------|----------|------|
| "handoff", "핸드오프" | `workflows/handoff.md` | 세션 상태 저장 |
| "resume", "재개" | `workflows/resume.md` | 이전 작업 복원 |
| "plan", "플랜", "계획" | `workflows/plan.md` | 전략적 계획 수립 |

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

- `/flow:handoff` → `workflows/handoff.md`
- `/flow:resume` → `workflows/resume.md`
- `/flow:plan` → `workflows/plan.md`

## Best Practices

### Session Management
- 80% context에서 핸드오프 생성
- `.scratch.md`에 실시간 생각 기록
- 복잡한 작업 전 plan 먼저 수립

### Planning
- 요구사항을 명확히 제공
- 리서치 결과 검토
- 자동화 워크플로우 확인

## Success Metrics

- 세션 연속성 유지
- 계획 품질 및 실행력
- Context 효율적 활용
