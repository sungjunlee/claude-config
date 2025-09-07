---
description: Universal test runner that auto-detects project type
---

# Smart Test Runner

Automatically detect and run tests for: $ARGUMENTS

## Auto-Detection Logic

### 1. JavaScript/TypeScript
```bash
if [[ -f "package.json" ]]; then
    # Check for test script
    if grep -q '"test":' package.json; then
        npm test
    elif grep -q '"jest"' package.json; then
        npx jest
    elif grep -q '"vitest"' package.json; then
        npx vitest
    elif grep -q '"mocha"' package.json; then
        npx mocha
    fi
fi
```

### 2. Python
```bash
if [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]]; then
    # Try pytest first
    if command -v pytest >/dev/null; then
        pytest
    elif [[ -f "manage.py" ]]; then
        python manage.py test
    elif command -v python -m unittest >/dev/null; then
        python -m unittest discover
    fi
fi
```

### 3. Rust
```bash
if [[ -f "Cargo.toml" ]]; then
    cargo test
fi
```

### 4. Go
```bash
if [[ -f "go.mod" ]]; then
    go test ./...
fi
```

### 5. Java/Kotlin
```bash
if [[ -f "pom.xml" ]]; then
    mvn test
elif [[ -f "build.gradle" ]] || [[ -f "build.gradle.kts" ]]; then
    ./gradlew test
fi
```

### 6. Ruby
```bash
if [[ -f "Gemfile" ]]; then
    if grep -q "rspec" Gemfile; then
        bundle exec rspec
    else
        bundle exec rake test
    fi
fi
```

### 7. PHP
```bash
if [[ -f "composer.json" ]]; then
    if [[ -f "phpunit.xml" ]]; then
        vendor/bin/phpunit
    fi
fi
```

### 8. C#/.NET
```bash
if [[ -f "*.csproj" ]] || [[ -f "*.sln" ]]; then
    dotnet test
fi
```

## Fallback Strategy

If no specific test framework is detected:
1. Look for `test/` or `tests/` directories
2. Search for files matching `*test*` or `*spec*`
3. Provide guidance on setting up tests

## Coverage Options

Add coverage reporting when available:
- JavaScript: `--coverage`
- Python: `--cov`
- Rust: `cargo tarpaulin`
- Go: `-cover`

Execute the most appropriate test command for this project.