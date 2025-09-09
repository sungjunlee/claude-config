---
description: Lint Python code with ruff check (overrides account-level lint)
---

# Lint Python Code

> **Project Override**: Python-specific linting using ruff
> 
> **Override Priority**: Project Level (this file) > Account Level > Built-in

Lint Python code in: $ARGUMENTS

## Linting Strategy

### 1. Tool Resolution (2025 Best Practice)
```bash
# Prefer uvx for isolated execution
if command -v uvx &> /dev/null; then
    RUFF="uvx ruff"
    echo "Using uvx ruff (isolated execution)"
elif command -v ruff &> /dev/null; then
    RUFF="ruff"
    echo "Using system ruff"
else
    echo "❌ Ruff not found. Install with: 'pip install ruff' or 'brew install ruff'"
    echo "   Or install uv: 'curl -LsSf https://astral.sh/uv/install.sh | sh'"
    exit 1
fi
```

### 2. Run Linting
```bash
# Check all Python files
$RUFF check .

# Check specific file/directory
$RUFF check $ARGUMENTS

# Auto-fix safe issues
$RUFF check --fix $ARGUMENTS

# Show what would be fixed without applying
$RUFF check --diff $ARGUMENTS

# Fix all possible issues (use with caution)
$RUFF check --fix --unsafe-fixes $ARGUMENTS
```

### 3. Modern Rule Sets (2025)

```bash
# Recommended: Comprehensive but pragmatic
$RUFF check --select E,W,F,UP,B,SIM,I $ARGUMENTS

# All rules (very strict)
$RUFF check --select ALL $ARGUMENTS

# Essential rules only
$RUFF check --select E,W,F $ARGUMENTS

# Security focused
$RUFF check --select S,B $ARGUMENTS

# Type checking focused
$RUFF check --select ANN,ARG,PYI,TCH $ARGUMENTS

# Performance focused
$RUFF check --select PERF,C90 $ARGUMENTS
```

## Rule Categories (2025)

### Core Python Issues
- **E/W** - pycodestyle errors/warnings
- **F** - Pyflakes (undefined names, unused imports)
- **UP** - pyupgrade (modernize syntax for target Python version)
- **B** - flake8-bugbear (likely bugs and design problems)
- **SIM** - flake8-simplify (simplify code)

### Import Management
- **I** - isort (import sorting)
- **TID** - flake8-tidy-imports (banned imports)
- **ICN** - flake8-import-conventions (import aliases)

### Security & Safety
- **S** - flake8-bandit (security issues)
- **BLE** - flake8-blind-except (blind exceptions)
- **TRY** - tryceratops (exception handling antipatterns)

### Type Checking
- **ANN** - flake8-annotations (missing type hints)
- **TCH** - flake8-type-checking (runtime vs type checking imports)
- **PYI** - flake8-pyi (stub file issues)

### Code Quality
- **C4** - flake8-comprehensions (comprehension improvements)
- **PIE** - flake8-pie (miscellaneous improvements)
- **RET** - flake8-return (return statement improvements)
- **SLF** - flake8-self (private member access)
- **RSE** - flake8-raise (exception raising improvements)

### Performance
- **PERF** - Perflint (performance antipatterns)
- **C90** - mccabe (complexity checks)

## Configuration Detection

Check for configuration in order:
1. `ruff.toml` or `.ruff.toml`
2. `pyproject.toml` with `[tool.ruff]`
3. `setup.cfg` with `[tool:ruff]`
4. Use sensible defaults

## Recommended pyproject.toml Configuration

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
```

## CI/CD Integration

```bash
# GitHub Actions format
$RUFF check --output-format github .

# Generate JUnit XML report
$RUFF check --output-format junit --output-file ruff-report.xml .

# JSON output for tooling
$RUFF check --output-format json . > ruff-report.json

# Fail if any fixes were applied
$RUFF check --exit-non-zero-on-fix .
```

## Common Workflows

```bash
# Pre-commit: Check without fixing
$RUFF check --no-fix .

# Development: Fix everything safe
$RUFF check --fix . && $RUFF format .

# CI Pipeline: Strict checking
$RUFF check --no-fix --output-format github .

# Debug specific rule
$RUFF check --select E501 --show-source .
```

## Ruff vs Legacy Tools (2025)

**Ruff replaces:**
- ✅ Flake8 + 50+ plugins → `ruff check`
- ✅ pylint (most rules) → `ruff check --select PL`
- ✅ pycodestyle → `ruff check --select E,W`
- ✅ pyflakes → `ruff check --select F`
- ✅ isort → `ruff check --select I --fix`
- ✅ bandit → `ruff check --select S`
- ✅ pyupgrade → `ruff check --select UP --fix`

**Performance:**
- Ruff: 10-100x faster than Flake8
- Processes entire codebases in milliseconds
- Written in Rust for maximum performance