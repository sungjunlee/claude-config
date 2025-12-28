---
name: workflow
description: |
  Session management skill for context continuity.
  Use when: managing session handoffs, resuming work.
  Triggers: "handoff", "resume", "핸드오프", "재개"
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
model: sonnet
---

# Workflow Skill

세션 관리를 위한 스킬입니다. Context 연속성 유지를 지원합니다.

## Overview

공식 플러그인에 없는 기능을 제공합니다:
- **Session Continuity**: Context handoff로 세션 간 상태 유지

> **Note**: 기능 개발 계획은 `feature-dev` 플러그인 사용을 권장합니다.
> `/plugin install feature-dev`

## Capabilities

### Session Management
- Context handoff 시스템으로 세션 간 상태 유지
- `/clear` 전 자동 저장 권장
- Scratch notes를 통한 경량 working memory

## Workflow Detection

| 트리거 | Workflow | 설명 |
|--------|----------|------|
| "handoff", "핸드오프" | `workflows/handoff.md` | 세션 상태 저장 |
| "resume", "재개" | `workflows/resume.md` | 이전 작업 복원 |

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

## Command Mapping

- `/flow:handoff` → `workflows/handoff.md`
- `/flow:resume` → `workflows/resume.md`

## Best Practices

- 80% context에서 핸드오프 생성
- `.scratch.md`에 실시간 생각 기록
- 기능 개발 계획은 `feature-dev` 플러그인 사용

## Success Metrics

- 세션 연속성 유지
- Context 효율적 활용
