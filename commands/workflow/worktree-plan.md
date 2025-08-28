# Command: /worktree-plan

Plan-agent를 활용해서 병렬 작업용 PLAN.md 자동 생성

## Usage

```bash
/worktree-plan [작업 설명]
```

## Description

plan-agent를 호출해서 작업을 분석하고, 병렬로 실행 가능한 독립적인 작업들로 분할한 후,
`.worktrees/PLAN.md` 파일을 자동 생성합니다.

## Examples

```bash
# 예시 1: 전자상거래 사이트 핵심 기능
/worktree-plan "전자상거래 사이트에 인증, 결제, 검색 기능 추가"

# 예시 2: 대규모 리팩토링
/worktree-plan "React 16에서 18로 마이그레이션, 동시에 TypeScript 도입"

# 예시 3: 버그 수정
/worktree-plan "로그인, 결제, 검색에서 발견된 버그들 수정"
```

## Process

1. **Plan-agent 호출**
   - 작업 복잡도 평가
   - 병렬 실행 가능한 단위로 분할
   - 각 작업의 독립성 확인

2. **PLAN.md 생성**
   - 표준 형식으로 작업 목록 생성
   - 공통 컨텍스트 정의
   - 작업 간 의존성 명시

3. **자동 분배 준비**
   - `/worktree-distribute` 실행 준비
   - 각 작업별 브랜치명 결정
   - 예상 작업 시간 산정

## Generated PLAN.md Format

```markdown
# 작업 계획
생성일: 2025-01-28
생성자: plan-agent

## 작업 목록
​```bash
# 병렬 실행 가능한 독립 작업들
auth: OAuth2.0 로그인 시스템 구현 (예상: 2시간)
payment: Stripe 결제 연동 (예상: 3시간)  
search: Elasticsearch 검색 기능 (예상: 2시간)
​```

## 공통 컨텍스트
- TypeScript 사용
- 테스트 코드 필수
- REST API 규격 준수

## 작업 의존성
- 모든 작업 독립적 실행 가능
- 병합 순서: 제한 없음

## 참고사항
- Plan-agent 연구 결과 기반
- 현재 베스트 프랙티스 적용
```

## Integration with Plan-agent

이 명령은 plan-agent의 다음 기능을 활용합니다:

1. **복잡도 평가**: 전체 작업의 복잡도 분석
2. **작업 분할**: 병렬 실행 가능한 단위로 분해
3. **리서치**: 필요시 웹 검색 및 Context7 조회
4. **리스크 평가**: 각 작업의 위험 요소 식별

## Workflow

```mermaid
/worktree-plan → plan-agent → PLAN.md 생성 → /worktree-distribute → 병렬 작업
```

## Benefits

- **자동화**: 수동으로 PLAN.md 작성 불필요
- **최적화**: plan-agent가 최적의 작업 분할 수행
- **일관성**: 표준화된 형식으로 생성
- **연구 기반**: 최신 베스트 프랙티스 적용

## Related Commands

- `/plan` - 일반적인 작업 계획 (병렬 실행 아님)
- `/worktree-distribute` - PLAN.md 기반 작업 분배
- `/worktree-status` - 병렬 작업 진행 상황 확인

## Implementation

```bash
# 1. plan-agent 호출로 작업 분석
# 2. 병렬 실행 가능한 작업들로 분할
# 3. .worktrees/PLAN.md 생성
# 4. 사용자에게 다음 단계 안내
```