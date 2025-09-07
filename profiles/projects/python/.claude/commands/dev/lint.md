---
description: Lint Python code with ruff check (overrides account-level lint)
---

# Lint Python Code

> **Project Override**: Python-specific linting using ruff
> 
> **Override Priority**: Project Level (this file) > Account Level > Built-in

Lint Python code in: $ARGUMENTS

## Linting Strategy

### 1. Run Ruff Check
```bash
# Check all Python files
ruff check .

# Check specific file/directory
ruff check $ARGUMENTS

# Auto-fix safe issues
ruff check --fix $ARGUMENTS

# Fix all possible issues (including unsafe)
ruff check --fix --unsafe-fixes $ARGUMENTS
```

### 2. Common Rule Sets

```bash
# Enable all rules
ruff check --select ALL $ARGUMENTS

# Python best practices
ruff check --select E,W,F,B,C90,I,N,UP $ARGUMENTS

# Security checks
ruff check --select S $ARGUMENTS

# Type checking related
ruff check --select ANN,ARG,PYI $ARGUMENTS
```

### 3. Show Detailed Output
```bash
# Show rule explanations
ruff check --show-fixes $ARGUMENTS

# Output in different formats
ruff check --output-format json $ARGUMENTS
ruff check --output-format github $ARGUMENTS
```

## Configuration Detection

Check for configuration in order:
1. `ruff.toml`
2. `.ruff.toml`
3. `pyproject.toml` with `[tool.ruff]`
4. Use project defaults

## Common Issues and Fixes

### Import Issues
- `I001`: Import sorting
- `F401`: Unused imports
- `F403`: Star imports

### Code Quality
- `E501`: Line too long
- `W293`: Blank line with whitespace
- `B008`: Function calls in default arguments

### Security
- `S105`: Hardcoded passwords
- `S106`: Hardcoded secrets
- `S301`: Pickle usage

## Integration with CI/CD

```bash
# For CI - fail on any issue
ruff check --exit-non-zero-on-fix .

# Generate report
ruff check --output-format junit --output-file ruff-report.xml .
```

## Alternative Linters

If ruff is not available:
1. `flake8` - Traditional Python linter
2. `pylint` - Comprehensive linter
3. `pycodestyle` - PEP 8 checker

Execute appropriate linter based on project configuration.