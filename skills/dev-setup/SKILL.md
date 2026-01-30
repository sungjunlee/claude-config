---
name: dev-setup
description: |
  Development environment automation - gitleaks, gitignore, pre-commit hooks.
  Use when: "setup", "gitleaks", "pre-commit", "gitignore", "security setup",
  "initialize project", "add hooks", "protect secrets".
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
model: claude-sonnet-4-5-20250929
argument-hint: "[gitleaks|gitignore|hooks|all]"
disable-model-invocation: true
---

# Development Setup

Automated development environment security and quality configuration.

## Quick Reference

| Command | Description |
|---------|-------------|
| `/dev-setup` | Full environment setup |
| `/dev-setup gitleaks` | Install gitleaks pre-commit hook |
| `/dev-setup gitignore` | Enhance .gitignore patterns |
| `/dev-setup hooks` | Set up pre-commit hooks |

## Features

### Gitleaks Integration
- Pre-commit hook installation
- Custom config generation
- Secret pattern detection
- CI/CD integration

### Gitignore Enhancement
- Environment file protection (.env, credentials)
- IDE settings exclusion
- Build artifact exclusion
- OS-specific patterns

### Pre-commit Hooks
- Code formatting
- Linting checks
- Secret scanning
- Commit message validation

## Supporting Files

| File | Purpose |
|------|---------|
| [workflows/setup.md](workflows/setup.md) | Setup workflow |
| [context/gitleaks.md](context/gitleaks.md) | Gitleaks configuration guide |
| [context/gitignore-patterns.md](context/gitignore-patterns.md) | Gitignore pattern collection |
