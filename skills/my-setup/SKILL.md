---
name: my-setup
description: |
  Development environment automation - gitleaks, gitignore, hooks.
  Triggers: "setup", "gitleaks", "pre-commit", "gitignore"
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
model: claude-sonnet-4-5-20250929
---

# My Setup Skill

개발 환경 자동화 도구. 보안 및 품질 설정을 표준화합니다.

## Commands

### Setup (`/my-setup:setup`)
전체 개발 환경 설정:
- gitleaks pre-commit hook
- gitignore 강화
- 기타 보안 설정

## Features

### Gitleaks Integration
- Pre-commit hook 설치
- Custom config 생성
- Secret 패턴 감지

### Gitignore Enhancement
- 환경 파일 보호 (.env, credentials)
- IDE 설정 무시
- 빌드 아티팩트 무시

## Context Files

| File | Purpose |
|------|---------|
| `workflows/setup.md` | 설정 워크플로우 |
| `context/gitleaks.md` | Gitleaks 설정 가이드 |
| `context/gitignore-patterns.md` | Gitignore 패턴 모음 |
