# Gitleaks Configuration Guide

## 기본 설정

### .gitleaks.toml
```toml
title = "Gitleaks Configuration"

[allowlist]
description = "Allowlisted files and patterns"
paths = [
    '''\.gitleaks\.toml$''',
    '''go\.sum$''',
    '''package-lock\.json$''',
    '''yarn\.lock$''',
    '''pnpm-lock\.yaml$''',
    '''(test|spec|fixture|mock)''',
    '''(README|docs|\.md$)''',
]
```

## Pre-commit 설정

### .pre-commit-config.yaml
```yaml
# Check latest version: https://github.com/gitleaks/gitleaks/releases
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.21.2  # Update to latest
    hooks:
      - id: gitleaks
        args: ["--config", ".gitleaks.toml"]
```

## 커스텀 규칙

### API Key 패턴
```toml
[[rules]]
id = "custom-api-key"
description = "Custom API Key Pattern"
regex = '''(?i)(api[_-]?key|apikey)\s*[:=]\s*['"]?([a-zA-Z0-9_-]{20,})['"]?'''
tags = ["key", "API"]
```

### 내부 서비스 토큰
```toml
[[rules]]
id = "internal-token"
description = "Internal Service Token"
regex = '''(?i)internal[_-]token\s*[:=]\s*['"]?([a-zA-Z0-9_-]{32,})['"]?'''
```

## Allowlist 패턴

### 특정 파일
```toml
[allowlist]
paths = [
    '''test/fixtures/''',
    '''\.example$''',
]
```

### 특정 커밋
```toml
[allowlist]
commits = [
    "abc123def456",
]
```

## 문제 해결

### False Positive 처리
```bash
# 특정 라인 무시
SOME_KEY="fake-value" # gitleaks:allow

# 커밋 전 검증
gitleaks detect --source . --verbose
```

### 기존 커밋 스캔
```bash
gitleaks detect --source . --log-opts="--all"
```
