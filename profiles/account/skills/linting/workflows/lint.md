---
description: Universal linter with auto-detection and formatting support
---

# Lint & Format

Run linting and formatting for: $ARGUMENTS

## Language Auto-Detection

Detect project type and execute appropriate linting tools:

### Detection Order

```bash
# 1. Python
if [[ -f "pyproject.toml" ]] || [[ -f "ruff.toml" ]] || [[ -f ".ruff.toml" ]]; then
    # Load context/python.md for detailed guidance
    # Ruff (fastest, modern standard)
    if command -v ruff >/dev/null || command -v uvx >/dev/null; then
        uvx ruff check --fix . && uvx ruff format .
    elif command -v black >/dev/null; then
        black .
    fi
fi

# 2. JavaScript/TypeScript
if [[ -f "package.json" ]]; then
    # Load context/javascript.md for detailed guidance

    # Biome (modern, fast)
    if [[ -f "biome.json" ]]; then
        bunx biome check --apply . || npx biome check --apply .
    fi

    # ESLint
    if [[ -f ".eslintrc.json" ]] || [[ -f ".eslintrc.js" ]] || [[ -f "eslint.config.js" ]]; then
        bunx eslint . --fix || npx eslint . --fix
    fi

    # Prettier
    if [[ -f ".prettierrc" ]] || [[ -f "prettier.config.js" ]]; then
        bunx prettier --write . || npx prettier --write .
    fi

    # TypeScript type check
    if [[ -f "tsconfig.json" ]]; then
        bunx tsc --noEmit || npx tsc --noEmit
    fi
fi

# 3. Rust
if [[ -f "Cargo.toml" ]]; then
    # Load context/rust.md for detailed guidance
    cargo clippy --fix --allow-dirty
    cargo fmt
fi

# 4. Go
if [[ -f "go.mod" ]]; then
    gofmt -w .
    if command -v golangci-lint >/dev/null; then
        golangci-lint run --fix
    fi
fi

# 5. Ruby
if [[ -f ".rubocop.yml" ]]; then
    rubocop -a
fi

# 6. Java/Kotlin
if [[ -f "build.gradle" ]] || [[ -f "build.gradle.kts" ]]; then
    ./gradlew spotlessApply
fi

# 7. Shell Scripts
if command -v shellcheck >/dev/null; then
    shellcheck **/*.sh 2>/dev/null || true
fi
if command -v shfmt >/dev/null; then
    shfmt -w . 2>/dev/null || true
fi
```

## Execution Strategy

### Step 1: Discovery
- Find configuration files for linters
- Load appropriate context file for language-specific guidance
- Identify available tools

### Step 2: Run Linters
- Execute with auto-fix enabled
- Collect warnings and errors
- Apply formatting

### Step 3: Report Results
- Summarize issues found
- List auto-fixed items
- Highlight remaining issues

## Quick Commands

### Python (Ruff)
```bash
# Check and fix
uvx ruff check --fix .
uvx ruff format .

# Check only (CI mode)
uvx ruff check --no-fix .
uvx ruff format --check .

# Specific rules
uvx ruff check --select E,W,F,UP,B,SIM,I .
```

### JavaScript/TypeScript
```bash
# ESLint
bunx eslint . --fix

# Biome (modern alternative)
bunx biome check --apply .

# Prettier
bunx prettier --write .

# Type check
bunx tsc --noEmit
```

### Rust
```bash
# Clippy with auto-fix
cargo clippy --fix --allow-dirty

# Format
cargo fmt

# CI mode (strict)
cargo clippy -- -D warnings
cargo fmt -- --check
```

## Pre-commit Integration

If `.pre-commit-config.yaml` exists:
```bash
pre-commit run --all-files
```

## CI Mode

For CI/CD pipelines (check without fixing):

```bash
# Python
uvx ruff check --no-fix . && uvx ruff format --check .

# JavaScript
bunx eslint . --max-warnings=0
bunx prettier --check .

# Rust
cargo clippy -- -D warnings && cargo fmt -- --check
```

## Context Loading

언어 감지 후 상세 가이드가 필요하면 해당 context 파일을 참조:
- Python → `context/python.md` (ruff best practices)
- JavaScript/TypeScript → `context/javascript.md` (eslint/biome patterns)
- Rust → `context/rust.md` (clippy strategies)

Execute appropriate linting based on project setup now.
