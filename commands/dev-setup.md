---
description: Development environment automation - gitleaks, gitignore, pre-commit hooks setup
argument-hint: "[gitleaks|gitignore|hooks]"
allowed-tools: ["Bash", "Read", "Write", "Edit", "Glob", "Grep"]
---

# Development Setup

Automated development environment security and quality configuration.

**Arguments:** $ARGUMENTS

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

## Workflow

### 1. Environment Analysis
```bash
# Detect project type
ls package.json pyproject.toml Cargo.toml go.mod 2>/dev/null

# Check existing setup
ls .gitignore .gitleaks.toml .pre-commit-config.yaml 2>/dev/null
```

### 2. Gitleaks Setup
```bash
# Install pre-commit
pip install pre-commit || pipx install pre-commit

# Add gitleaks hook (check latest: https://github.com/gitleaks/gitleaks/releases)
cat >> .pre-commit-config.yaml << 'EOF'
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.21.2  # Update to latest
    hooks:
      - id: gitleaks
EOF

# Install hook
pre-commit install
```

### 3. Gitignore Enhancement
```bash
cat >> .gitignore << 'EOF'

# Security - Secrets
.env
.env.*
!.env.example
*.pem
*.key
credentials.json
secrets.yaml

# IDE
.idea/
.vscode/
*.swp
*.swo

# Build artifacts
dist/
build/
*.egg-info/
node_modules/
target/
EOF
```

### 4. Verification
```bash
# Test gitleaks
pre-commit run gitleaks --all-files

# Check gitignore
git status --ignored
```

## Custom Gitleaks Rules

For project-specific patterns, create `.gitleaks.toml`:
```toml
[extend]
useDefault = true

[[rules]]
id = "custom-api-key"
description = "Custom API Key Pattern"
regex = '''(?i)my_api_key\s*=\s*['"][^'"]+['"]'''
```

## Language-specific Patterns

### Node.js
```
node_modules/
.npm/
*.log
```

### Python
```
__pycache__/
*.py[cod]
.venv/
*.egg-info/
```

### Go
```
/bin/
/vendor/
*.exe
```

## Output Example

```
[OK] Pre-commit installed
[OK] Gitleaks hook added
[OK] Gitignore updated (15 patterns added)
[OK] Verification passed

Setup complete! Run 'pre-commit run --all-files' to verify.
```
