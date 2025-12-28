# Python Linting Guide

Python 프로젝트를 위한 Ruff 기반 린팅 가이드입니다.

## Tool Stack (2025)

**Primary**: Ruff (linting + formatting)
**Legacy**: Flake8, pylint, black, isort (replaced by Ruff)

## Tool Resolution

```bash
# Prefer uvx for isolated execution
if command -v uvx &> /dev/null; then
    RUFF="uvx ruff"
elif command -v ruff &> /dev/null; then
    RUFF="ruff"
else
    echo "Ruff not found. Install: pip install ruff"
    exit 1
fi
```

## Common Commands

### Basic Usage
```bash
# Check all Python files
$RUFF check .

# Check specific file/directory
$RUFF check src/

# Auto-fix safe issues
$RUFF check --fix .

# Show what would be fixed
$RUFF check --diff .

# Fix all possible issues (use with caution)
$RUFF check --fix --unsafe-fixes .
```

### Formatting
```bash
# Format code
$RUFF format .

# Check formatting without changes
$RUFF format --check .

# Format specific files
$RUFF format src/main.py
```

## Rule Categories

### Core Python Issues
- **E/W** - pycodestyle errors/warnings
- **F** - Pyflakes (undefined names, unused imports)
- **UP** - pyupgrade (modernize syntax)
- **B** - flake8-bugbear (likely bugs)
- **SIM** - flake8-simplify (simplify code)

### Import Management
- **I** - isort (import sorting)
- **TID** - flake8-tidy-imports
- **ICN** - flake8-import-conventions

### Security & Safety
- **S** - flake8-bandit (security issues)
- **BLE** - flake8-blind-except
- **TRY** - tryceratops (exception handling)

### Type Checking
- **ANN** - flake8-annotations
- **TCH** - flake8-type-checking
- **PYI** - flake8-pyi

### Performance
- **PERF** - Perflint
- **C90** - mccabe complexity

## Rule Selection

```bash
# Recommended: Comprehensive but pragmatic
$RUFF check --select E,W,F,UP,B,SIM,I .

# All rules (very strict)
$RUFF check --select ALL .

# Essential rules only
$RUFF check --select E,W,F .

# Security focused
$RUFF check --select S,B .

# Performance focused
$RUFF check --select PERF,C90 .
```

## Configuration (pyproject.toml)

```toml
[tool.ruff]
target-version = "py311"
line-length = 88

[tool.ruff.lint]
select = [
    "E", "W",    # pycodestyle
    "F",         # Pyflakes
    "UP",        # pyupgrade
    "B",         # flake8-bugbear
    "SIM",       # flake8-simplify
    "I",         # isort
]
ignore = [
    "E501",      # line too long (handled by formatter)
    "E203",      # whitespace before ':'
]

[tool.ruff.lint.per-file-ignores]
"tests/*" = ["S101"]  # allow assert in tests
"__init__.py" = ["F401"]  # allow unused imports

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
docstring-code-format = true
```

## CI/CD Integration

```bash
# GitHub Actions format
$RUFF check --output-format github .

# JUnit XML report
$RUFF check --output-format junit --output-file ruff-report.xml .

# JSON output
$RUFF check --output-format json . > ruff-report.json

# Fail if any fixes were applied
$RUFF check --exit-non-zero-on-fix .
```

## Common Workflows

```bash
# Pre-commit: Check without fixing
$RUFF check --no-fix .

# Development: Fix everything
$RUFF check --fix . && $RUFF format .

# CI Pipeline: Strict checking
$RUFF check --no-fix --output-format github .
$RUFF format --check .

# Debug specific rule
$RUFF check --select E501 --show-source .
```

## Ruff vs Legacy Tools

**Ruff replaces:**
- Flake8 + 50+ plugins → `ruff check`
- pylint (most rules) → `ruff check --select PL`
- pycodestyle → `ruff check --select E,W`
- pyflakes → `ruff check --select F`
- isort → `ruff check --select I --fix`
- bandit → `ruff check --select S`
- pyupgrade → `ruff check --select UP --fix`
- Black → `ruff format`

## Common Issues

### Import Sorting Conflicts
If isort is also configured, disable it in favor of Ruff:
```toml
[tool.ruff.lint]
select = ["I"]  # Use Ruff's isort
```

### Line Length
Formatter handles line length, so ignore E501 in linting:
```toml
[tool.ruff.lint]
ignore = ["E501"]
```

### Type Stub Issues
For projects with stubs:
```toml
[tool.ruff.lint]
extend-select = ["PYI"]
```
