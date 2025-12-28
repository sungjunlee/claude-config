# Planning Guide

전략적 계획 수립을 위한 가이드라인입니다.

## Complexity Assessment

### Simple Tasks (1-3)
**특징**:
- 단일 파일 변경
- 명확한 요구사항
- 즉시 실행 가능

**접근**:
- 직접 실행
- 간단한 체크리스트
- 최소한의 리서치

**예시**:
- 오타 수정
- 간단한 버그 픽스
- 설정 값 변경

### Medium Tasks (4-7)
**특징**:
- 다중 파일 변경
- 표준 기능 구현
- 명확한 패턴 존재

**접근**:
- 구조화된 단계
- 체크포인트 설정
- 기본 리서치

**예시**:
- 새 API 엔드포인트
- 컴포넌트 추가
- 기존 기능 확장

### Complex Tasks (8-10)
**특징**:
- 아키텍처 변경
- 다중 시스템 영향
- 리서치 필요

**접근**:
- 포괄적 계획
- 리스크 평가
- 광범위한 리서치
- 다중 리뷰 포인트

**예시**:
- 인증 시스템 마이그레이션
- 데이터베이스 스키마 변경
- 마이크로서비스 분리

## Research Phase

### Web Search
최신 best practices 조사:
- "[technology] best practices 2025"
- "[pattern] implementation guide"
- "[problem] solution comparison"

### Context7
라이브러리 정보 확인:
- 최신 버전
- 권장 설정
- 마이그레이션 가이드

### Internal Analysis
기존 코드베이스 패턴:
- 유사 구현 찾기
- 코딩 컨벤션 확인
- 의존성 분석

## Git Workflow

### Branch Naming
```
feature/[feature-name]    # 새 기능
fix/[bug-description]     # 버그 수정
refactor/[area]           # 리팩토링
chore/[task]              # 설정, 유지보수
```

### Commit Strategy
```
1. chore: setup project structure
2. feat: implement core functionality
3. test: add unit tests
4. docs: update documentation
```

### PR Strategy
1. Draft PR 생성
2. 자체 리뷰 (code-reviewer)
3. CI 통과 확인
4. Ready for review 전환
5. Merge

## Phase Planning

### Parallel vs Sequential

**Parallel** (동시 실행 가능):
- 독립적인 파일 수정
- 서로 의존성 없음
- 리소스 충돌 없음

**Sequential** (순차 실행 필요):
- 이전 단계 결과 필요
- 같은 파일 수정
- 데이터 의존성

### Phase Template
```markdown
### Phase 1: [Name] (Parallel)
- [ ] Step 1.1: [Action]
- [ ] Step 1.2: [Action] [parallel]
- [ ] Step 1.3: [Action] [parallel]
Checkpoint: [검증 방법]
Estimated: [시간]

### Phase 2: [Name] (Sequential)
- [ ] Step 2.1: [Action] [depends: 1.1]
- [ ] Step 2.2: [Action]
Checkpoint: [검증 방법]
Estimated: [시간]
```

## Risk Assessment

### Risk Matrix
| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| DB Migration 실패 | High | Medium | 백업 먼저, dry-run |
| API Breaking Change | High | Low | 버전 관리, deprecation |
| 성능 저하 | Medium | Medium | 벤치마크 테스트 |
| 테스트 실패 | Medium | High | 점진적 변경 |

### Common Mitigations
- **Feature flag**: 점진적 롤아웃
- **Rollback plan**: 빠른 복구 준비
- **Backup**: 변경 전 백업
- **Dry-run**: 실제 적용 전 시뮬레이션

## Automation Triggers

### Recommended Triggers
```yaml
on_phase_complete:
  phase_1: "git add -A && git commit"
  phase_2: "invoke test-runner"

on_test_failure: "invoke debugger"
on_pr_ready: "invoke code-reviewer"
on_context_80: "invoke handoff"
```

## Quality Gates

### Before Commit
- [ ] 빌드 성공
- [ ] 테스트 통과
- [ ] 린트 통과

### Before PR
- [ ] 코드 리뷰 완료
- [ ] 문서 업데이트
- [ ] 변경사항 요약

### Before Merge
- [ ] CI 통과
- [ ] 리뷰어 승인
- [ ] 충돌 해결

## Thinking Mode Selection

### Normal Mode
- 파일 5개 미만
- 간단한 변경
- 명확한 요구사항

### Think Mode
- 파일 5-15개
- 중간 복잡도
- 일부 불확실성

### Ultra Think Mode
- 파일 15개 이상
- 아키텍처 변경
- 복잡한 의존성
- 중요한 결정

## Documentation Requirements

### Always Update
- README (설치/사용법 변경 시)
- CHANGELOG (버전 릴리즈)
- API docs (인터페이스 변경)

### Consider Updating
- Architecture docs
- Migration guides
- Configuration docs

## Best Practices

1. **작게 시작**: 큰 작업을 작은 단계로
2. **자주 검증**: 각 단계 후 테스트
3. **문서화**: 결정사항 기록
4. **롤백 계획**: 항상 복구 방법 준비
5. **점진적 변경**: 한 번에 너무 많이 변경 금지
