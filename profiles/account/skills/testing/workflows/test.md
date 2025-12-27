---
description: Universal test runner with auto-detection and comprehensive testing support
---

# Test Execution

Run tests for: $ARGUMENTS

## Language Auto-Detection

Detect project type and execute appropriate test command:

### Detection Order

```bash
# 1. Python
if [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]] || [[ -f "requirements.txt" ]]; then
    # Load context/python.md for detailed guidance
    # Try pytest first (modern standard)
    if command -v pytest >/dev/null || command -v uvx >/dev/null; then
        uvx pytest || pytest
    elif [[ -f "manage.py" ]]; then
        python manage.py test
    else
        python -m unittest discover
    fi
fi

# 2. JavaScript/TypeScript
if [[ -f "package.json" ]]; then
    # Load context/javascript.md for detailed guidance
    # Modern-first package manager detection
    if grep -q '"test":' package.json; then
        bun test || pnpm test || yarn test || npm test
    elif grep -q '"vitest"' package.json; then
        bunx vitest || pnpm vitest || npx vitest
    elif grep -q '"jest"' package.json; then
        bunx jest || pnpm jest || npx jest
    elif grep -q '"mocha"' package.json; then
        bunx mocha || pnpm mocha || npx mocha
    fi
fi

# 3. Rust
if [[ -f "Cargo.toml" ]]; then
    # Load context/rust.md for detailed guidance
    cargo test
fi

# 4. Go
if [[ -f "go.mod" ]]; then
    go test ./...
fi

# 5. Java/Kotlin
if [[ -f "pom.xml" ]]; then
    mvn test
elif [[ -f "build.gradle" ]] || [[ -f "build.gradle.kts" ]]; then
    ./gradlew test
fi

# 6. Ruby
if [[ -f "Gemfile" ]]; then
    if grep -q "rspec" Gemfile; then
        bundle exec rspec
    else
        bundle exec rake test
    fi
fi

# 7. PHP
if [[ -f "composer.json" ]] && [[ -f "phpunit.xml" ]]; then
    vendor/bin/phpunit
fi

# 8. C#/.NET
if ls *.csproj 1>/dev/null 2>&1 || ls *.sln 1>/dev/null 2>&1; then
    dotnet test
fi
```

## Execution Strategy

### Step 1: Discovery
- Find test files and detect test framework
- Load appropriate context file for language-specific guidance
- Identify test configuration files

### Step 2: Run Tests
- Execute with coverage when available
- Focus on changed files when possible
- Use parallel execution if supported

### Step 3: Analyze Results
- Parse test output for failures
- Identify root cause (test issue vs code issue)
- Generate actionable fix suggestions

### Step 4: Auto-Fix (if enabled)
- Apply minimal changes to fix failures
- Preserve original test intent
- Add comments explaining fixes

### Step 5: Coverage Report
- Generate coverage summary
- Identify untested paths
- Recommend priority areas

## Coverage Options by Language

| Language | Command | Report |
|----------|---------|--------|
| Python | `--cov --cov-report=term-missing` | pytest-cov |
| JavaScript | `--coverage` | jest/vitest |
| Rust | `cargo tarpaulin` | tarpaulin |
| Go | `-cover` | go cover |

## Quick Commands

### Python
```bash
# All tests with coverage
pytest --cov=src --cov-report=term-missing

# Specific test
pytest tests/test_module.py::test_function -v

# Stop on first failure
pytest -x

# Last failed only
pytest --lf
```

### JavaScript/TypeScript
```bash
# All tests
bun test || npm test

# With coverage
bun test --coverage

# Watch mode
bun test --watch

# Specific file
bun test path/to/test
```

### Rust
```bash
# All tests
cargo test

# With output
cargo test -- --nocapture

# Specific test
cargo test test_name

# All features
cargo test --all-features
```

## Failure Handling

When tests fail:
1. **Analyze**: Read error message and stack trace
2. **Categorize**: Test bug vs code bug
3. **Fix**: Apply minimal fix preserving test intent
4. **Verify**: Re-run to confirm fix

## Auto-Agent Invocation

If test failures are found or coverage is low, automatically use the Task tool to invoke the test-runner agent for:
- Comprehensive failure analysis
- Automatic test repair
- Coverage improvement suggestions

## Integration

- Use `context/python.md` for pytest best practices
- Use `context/javascript.md` for jest/vitest patterns
- Use `context/rust.md` for cargo test strategies
- Use `pr-review-toolkit:silent-failure-hunter` for debugging silent failures

Execute appropriate test command based on project setup now.
