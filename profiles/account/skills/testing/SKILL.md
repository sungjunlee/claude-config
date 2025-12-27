---
name: testing
description: |
  Universal test runner with language auto-detection and comprehensive testing support.
  Use when: running tests, fixing test failures, improving coverage, or debugging test issues.
  Triggers: "test", "run tests", "pytest", "jest", "cargo test", "테스트", "테스트 실행"
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
model: sonnet
---

# Testing Skill

언어 자동 감지 기반의 범용 테스트 실행 스킬입니다. 프로젝트 타입을 자동으로 인식하고 적절한 테스트 프레임워크와 설정을 적용합니다.

## Overview

프로젝트 파일을 분석하여 언어를 감지하고, 해당 언어에 최적화된 테스트 전략을 적용합니다. 테스트 실패 시 자동 분석 및 수정을 지원합니다.

## Capabilities

### 1. Language Auto-Detection
- 프로젝트 파일 기반 언어 자동 감지
- 언어별 최적 테스트 프레임워크 선택
- 적절한 context 파일 자동 로딩

### 2. Test Execution
- 테스트 발견 및 실행
- 커버리지 리포트 생성
- 병렬 실행 지원

### 3. Failure Analysis & Repair
- 에러 메시지 및 스택 트레이스 분석
- 루트 원인 식별 (테스트 이슈 vs 코드 이슈)
- 테스트 의도 유지하며 수정

### 4. Coverage Enhancement
- 미테스트 코드 경로 식별
- 엣지 케이스 테스트 생성
- 버그 수정용 회귀 테스트 추가

## Language Detection Logic

| 프로젝트 파일 | 언어 | Context | 테스트 프레임워크 |
|--------------|------|---------|-----------------|
| `pyproject.toml`, `setup.py`, `requirements.txt` | Python | `context/python.md` | pytest |
| `package.json`, `*.ts`, `*.tsx` | JavaScript/TypeScript | `context/javascript.md` | jest, vitest, mocha |
| `Cargo.toml` | Rust | `context/rust.md` | cargo test |
| `go.mod` | Go | (builtin) | go test |
| `pom.xml`, `build.gradle` | Java/Kotlin | (builtin) | maven, gradle |
| `Gemfile` | Ruby | (builtin) | rspec, minitest |

## Routing Logic

| 요청 패턴 | Workflow |
|----------|----------|
| "test", "run tests", "테스트 실행" | `workflows/test.md` |
| 언어별 상세 가이드 필요 시 | `context/{language}.md` 로딩 |

## Workflow Sequence

```text
언어 감지 → context 로딩 → 테스트 실행 → 실패 분석 → 자동 수정 → 커버리지 리포트
```

## Output Format

```markdown
## Test Execution Report

### Summary
- Tests Run: X
- Passed: ✅ Y
- Failed: ❌ Z
- Coverage: X%

### Failed Tests (if any)
1. **TestName**
   - Error: [error message]
   - Fix Applied: [description]
   - Status: ✅ Fixed

### Coverage Improvements
- Added X new tests
- Coverage increased from Y% to Z%
- Key areas covered: [list]

### Recommendations
- Priority areas for more tests
- Performance concerns
```

## Best Practices

### Test Execution
- 변경된 파일 관련 테스트 우선 실행
- 빠른 피드백을 위해 `-x` (first failure stop) 활용
- 커버리지 임계값 설정 (`--cov-fail-under=80`)

### Failure Handling
- 테스트 실패 시 원인 분석 먼저
- 코드 이슈인지 테스트 이슈인지 구분
- 수정 시 테스트 의도 유지

### Coverage
- 의미 있는 테스트 우선 (메트릭보다 품질)
- 크리티컬 경로 집중
- 엣지 케이스 커버

## Integration

### With pr-review-toolkit
- 디버깅 필요 시 `silent-failure-hunter` 활용
- PR 생성 전 테스트 검증

### With Other Skills
- `/dev:test` 명령어와 연동
- `test-runner` agent 자동 호출

## Example Commands

```bash
# Run all tests
/dev:test

# Run specific tests
/dev:test authentication

# Run with coverage
/dev:test --coverage

# Run Python tests
/dev:test pytest

# Run JavaScript tests
/dev:test jest
```

## Error Handling

Common issues and solutions:
- **Import errors**: PYTHONPATH 또는 모듈 구조 확인
- **Fixture issues**: conftest.py 확인, scope 검증
- **Timeout**: 비동기 테스트 설정 확인
- **Permission denied**: 실행 권한 확인

## Success Metrics

- 모든 테스트 통과
- 커버리지 목표 달성 (기본 80%)
- 실패한 테스트 자동 수정
- 명확한 리포트 제공

## Resources

상세 가이드 및 참조 문서:
- `context/python.md` - pytest 상세 가이드
- `context/javascript.md` - jest/vitest/mocha 가이드
- `context/rust.md` - cargo test 가이드
