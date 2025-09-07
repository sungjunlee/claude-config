---
description: Universal linter that auto-detects project type and tools
---

# Smart Linting & Formatting

Auto-detect and run appropriate linters for: $ARGUMENTS

## Language Detection & Linting

### JavaScript/TypeScript
```bash
# ESLint
if [[ -f ".eslintrc.json" ]] || [[ -f ".eslintrc.js" ]]; then
    npx eslint . --fix
fi

# Biome
if [[ -f "biome.json" ]]; then
    npx biome check --apply .
fi

# Prettier
if [[ -f ".prettierrc" ]]; then
    npx prettier --write .
fi

# TypeScript
if [[ -f "tsconfig.json" ]]; then
    npx tsc --noEmit
fi
```

### Python
```bash
# Ruff (fastest)
if command -v ruff >/dev/null; then
    ruff check . --fix
    ruff format .
# Black
elif command -v black >/dev/null; then
    black .
fi

# Flake8
if [[ -f ".flake8" ]]; then
    flake8 .
fi

# mypy
if [[ -f "mypy.ini" ]] || grep -q "\[tool.mypy\]" pyproject.toml; then
    mypy .
fi
```

### Rust
```bash
# Clippy
cargo clippy --fix --allow-dirty

# Rustfmt
cargo fmt
```

### Go
```bash
# gofmt
gofmt -w .

# golangci-lint
if command -v golangci-lint >/dev/null; then
    golangci-lint run --fix
fi
```

### Ruby
```bash
# RuboCop
if [[ -f ".rubocop.yml" ]]; then
    rubocop -a
fi
```

### Java/Kotlin
```bash
# Spotless (Gradle)
if [[ -f "build.gradle" ]]; then
    ./gradlew spotlessApply
fi

# Google Java Format
if command -v google-java-format >/dev/null; then
    google-java-format -i **/*.java
fi
```

### PHP
```bash
# PHP CS Fixer
if [[ -f ".php-cs-fixer.php" ]]; then
    vendor/bin/php-cs-fixer fix
fi

# PHPCS
if [[ -f "phpcs.xml" ]]; then
    vendor/bin/phpcbf
fi
```

### C/C++
```bash
# clang-format
if [[ -f ".clang-format" ]]; then
    find . -name "*.c" -o -name "*.cpp" -o -name "*.h" | xargs clang-format -i
fi
```

### Shell Scripts
```bash
# ShellCheck
if command -v shellcheck >/dev/null; then
    shellcheck **/*.sh
fi

# shfmt
if command -v shfmt >/dev/null; then
    shfmt -w .
fi
```

## Multi-Language Projects

For projects with multiple languages:
1. Run all applicable linters
2. Report results by language
3. Fix issues in order of severity

## Pre-commit Integration

If `.pre-commit-config.yaml` exists:
```bash
pre-commit run --all-files
```

## CI-Ready Mode

For CI/CD pipelines (no auto-fix):
- Add `--check` or equivalent flags
- Return non-zero exit code on issues
- Generate reports for artifacts

Execute appropriate linting and formatting.