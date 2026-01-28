# Session Management Guide

세션 간 컨텍스트 연속성 유지를 위한 상세 가이드입니다.

## 핵심 명령어

| Command | Purpose |
|---------|---------|
| `/my:session-handoff` | 세션 상태 저장 (clear 전) |
| `/my:session-resume` | 이전 세션 컨텍스트 복원 |

## Handoff 모드

### Quick (기본)
```bash
/my:session-handoff
```
- 1-2분 내 생성
- 핵심 정보만 포함
- 일반적인 작업 전환에 적합

### Detailed
```bash
/my:session-handoff --detailed
```
- 상세 컨텍스트 포함
- 기술적 결정사항 기록
- 복잡한 작업/디버깅에 적합

### Team
```bash
/my:session-handoff --team
```
- 팀원 인수인계용
- 설치/설정 지침 포함
- 프로젝트 배경 설명

## 워크플로우

### 권장 타이밍
1. **80% 컨텍스트 도달 시** - 자동 알림
2. **작업 전환 전** - 다른 프로젝트로 이동
3. **하루 끝** - 내일 이어서 작업
4. **복잡한 디버깅 중** - 진행 상황 보존

### 저장 위치
```
docs/handoff/
├── .current           # 현재 핸드오프 메타데이터
├── .scratch.md        # 임시 노트
└── HANDOFF-*.md       # 핸드오프 문서 (최대 5개)
```

### 복원 프로세스
1. `/my:session-resume` 실행
2. 최신 핸드오프 로드
3. 복잡도에 따라:
   - 단순: 직접 계속
   - 복잡: plan-agent 자동 호출

## Best Practices

### Handoff 작성 시
- 현재 작업의 "왜"를 명확히
- 다음 단계를 구체적으로
- 막힌 부분/이슈 명시

### Resume 시
- 먼저 handoff 내용 검토
- git status 확인
- 변경된 파일 리뷰

## 템플릿
상세 템플릿은 `context/handoff-template.md` 참조.
