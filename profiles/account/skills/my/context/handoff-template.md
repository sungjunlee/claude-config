# Handoff Template

세션 핸드오프 문서 생성을 위한 템플릿입니다.

## Quick Handoff Template

```markdown
# Project Handoff - [YYYY-MM-DD HH:MM]

## Session Summary
[1-2 문장으로 이번 세션의 주요 성과]

## Completed
- [완료된 작업 1]
- [완료된 작업 2]

## Current State
**Active Work**: [현재 진행 중인 작업]

**Modified Files**:
- `path/to/file1` - [변경 내용]
- `path/to/file2` - [변경 내용]

## Next Steps
1. [다음 우선순위 작업]
2. [그 다음 작업]

## Notes
- [주의사항이나 gotchas]

---
Complexity: [1-10]
Flow: [deep_work|exploring|debugging|refactoring|implementing]
Confidence: [1-10]/10
```

## Detailed Handoff Template

```markdown
# Project Handoff - [YYYY-MM-DD HH:MM]

## Session Summary
[이번 세션의 목표와 성과 상세 설명]

## Completed Tasks

### [Task 1 Name]
- Description: [상세 설명]
- Files changed: [파일 목록]
- Key decisions: [결정사항]

### [Task 2 Name]
- Description: [상세 설명]
- Files changed: [파일 목록]

## Current State

### Active Work
[현재 진행 중인 작업의 상태]
- Started: [시작한 것]
- Remaining: [남은 것]

### Modified Files
| File | Change Type | Description |
|------|-------------|-------------|
| `path/file1` | Modified | [설명] |
| `path/file2` | Created | [설명] |

### Key Decisions
1. [결정 1]: [이유]
2. [결정 2]: [이유]

### Working Notes
[docs/handoff/.scratch.md 내용 포함]

## Next Steps

### Complexity: [Simple|Medium|Complex] (Score: [1-10])

**Immediate (다음 세션 시작 시)**:
1. [구체적 작업]

**Short-term**:
1. [이후 작업]

### Recommended Approach
[복잡한 경우: "plan-agent를 통한 전략적 계획 필요"]
[단순한 경우: "직접 계속 진행 가능"]

## Important Notes

### Warnings
- [주의해야 할 사항]

### Known Issues
- [알려진 문제점]

### Temporary Workarounds
- [임시 해결책]

## Technical Context

### Commands
- Build: `[command]`
- Test: `[command]`
- Lint: `[command]`
- Dev server: `[command]`

### Dependencies Added
- [새로 추가된 패키지]

### Environment Changes
- [설정 변경사항]

## Session Metadata
- Start: [세션 시작 시간]
- End: [현재 시간]
- Model: [사용 모델]
- Complexity Level: [1-10]
- Flow State: [상태]
- Confidence Level: [1-10]/10
- Agents Used: [사용된 에이전트]
- Pending Reviews: [대기 중인 리뷰]
```

## Team Handoff Template

```markdown
# Project Handoff - [Project Name]
Date: [YYYY-MM-DD]

## Background
[프로젝트 배경 및 요구사항 설명]

## Setup Instructions

### Prerequisites
- [필요한 도구/환경]

### Installation
```bash
[설치 명령어]
```

### Configuration
[설정 필요사항]

## Current Implementation Status

### Completed Features
- [x] [기능 1]
- [x] [기능 2]

### In Progress
- [ ] [진행 중인 기능]

### Not Started
- [ ] [시작 안 한 기능]

## Architecture Overview
[간단한 아키텍처 설명]

## Key Files
| File | Purpose |
|------|---------|
| `path/file` | [역할] |

## Dependencies & Blockers

### External Dependencies
- [외부 의존성]

### Blockers
- [차단 요소]

## Next Steps for New Developer
1. [첫 번째로 할 일]
2. [두 번째로 할 일]

## Contact
[추가 질문 시 연락처]
```

## Metadata File Template (.current)

```yaml
current: HANDOFF-[YYYYMMDD-HHMM].md
created: [ISO timestamp]
model: [model name]
session_duration: [minutes]
files_modified: [count]
mode: [quick|detailed|team]
complexity_level: [1-10]
flow_state: [deep_work|exploring|debugging|refactoring|implementing]
confidence_level: [1-10]
agents_used: [list]
pending_reviews: [list]
```

## Scratch Notes Template (.scratch.md)

```markdown
# Scratch Notes

## Current Focus
[한 줄로 현재 집중하는 것]

## Blockers
- [막힌 것들]

## Quick Notes
- [아이디어, 리마인더]
- [확인할 링크나 참조]
- [테스트할 가설]

## Try Next
- [시도할 접근법]

## Hypotheses
- [디버깅 가설]

---
Last updated: [timestamp]
```
