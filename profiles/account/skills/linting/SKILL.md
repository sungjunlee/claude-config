---
name: linting
description: |
  Universal linter with language auto-detection and formatting support.
  Use when: linting code, fixing style issues, formatting files, or checking code quality.
  Triggers: "lint", "format", "ruff", "eslint", "clippy", "린트", "포맷"
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
model: sonnet
---

# Linting Skill

언어 자동 감지 기반의 범용 린팅 및 포맷팅 스킬입니다. 프로젝트 타입을 자동으로 인식하고 적절한 린터와 포맷터를 적용합니다.

## Overview

프로젝트 파일을 분석하여 언어를 감지하고, 해당 언어에 최적화된 린팅 도구를 실행합니다. 자동 수정 및 포맷팅을 지원합니다.

## Capabilities

### 1. Language Auto-Detection
- 프로젝트 파일 및 설정 파일 기반 언어 감지
- 언어별 최적 린터/포맷터 선택
- 적절한 context 파일 자동 로딩

### 2. Linting & Formatting
- 코드 스타일 검사 및 자동 수정
- 포맷팅 적용
- pre-commit 통합 지원

### 3. Multi-Language Support
- 다중 언어 프로젝트 지원
- 언어별 순차 실행
- 통합 리포트 생성

## Language Detection Logic

| 프로젝트 파일 | 언어 | Context | 도구 |
|--------------|------|---------|------|
| `pyproject.toml`, `ruff.toml`, `*.py` | Python | `context/python.md` | ruff |
| `package.json`, `.eslintrc*`, `biome.json` | JavaScript/TypeScript | `context/javascript.md` | eslint, biome, prettier |
| `Cargo.toml` | Rust | `context/rust.md` | clippy, rustfmt |
| `go.mod` | Go | (builtin) | gofmt, golangci-lint |
| `.rubocop.yml` | Ruby | (builtin) | rubocop |
| `build.gradle` | Java/Kotlin | (builtin) | spotless |

## Routing Logic

| 요청 패턴 | Workflow |
|----------|----------|
| "lint", "format", "린트", "포맷" | `workflows/lint.md` |
| 언어별 상세 가이드 필요 시 | `context/{language}.md` 로딩 |

## Workflow Sequence

```text
언어 감지 → context 로딩 → 린터 실행 → 자동 수정 → 포맷팅 → 리포트
```

## Output Format

```markdown
## Linting Report

### Summary
- Files Checked: X
- Issues Found: Y
- Auto-fixed: Z
- Remaining: W

### Issues by Category
- Style: X issues
- Bugs: Y issues
- Security: Z issues

### Fixed Issues
1. [file:line] Issue description - Fixed

### Remaining Issues
1. [file:line] Issue description - Manual fix required
```

## Best Practices

### Execution
- `--fix` 옵션으로 자동 수정 우선
- CI에서는 `--check` 모드 사용
- pre-commit 훅 활용 권장

### Configuration
- 프로젝트 루트에 설정 파일 유지
- 팀 컨벤션에 맞게 규칙 조정
- 불필요한 규칙은 명시적으로 비활성화

### Performance
- 변경된 파일만 검사 (가능한 경우)
- 병렬 실행 활용
- 캐시 활용

## Integration

이 스킬은 기존 `/dev:lint` 명령어를 대체하며, 글로벌 린팅 워크플로우와 연동됩니다.

### Command Mapping
- `/dev:lint` → 이 스킬의 `workflows/lint.md` 실행
- 자연어 트리거: "lint", "format", "ruff check" 등

### With Other Skills
- `testing` skill과 함께 사용하여 품질 검증
- PR 생성 전 린팅 권장

## Example Usage

```bash
# Natural language triggers
"lint the code"
"코드 포맷팅해줘"
"ruff로 검사"

# Or via command
/dev:lint
/dev:lint src/
/dev:lint --fix
```

## Error Handling

Common issues and solutions:
- **Config not found**: 프로젝트 루트에 설정 파일 확인
- **Tool not installed**: 도구 설치 안내 제공
- **Conflicting rules**: 설정 파일 우선순위 확인
- **Performance issues**: 캐시 또는 증분 검사 활용

## Success Metrics

- 모든 린트 이슈 해결
- 일관된 코드 스타일 적용
- CI 파이프라인 통과
- 명확한 리포트 제공
