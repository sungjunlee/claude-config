---
description: Format Python code with ruff (overrides account-level format)
---

# Format Python Code

> **Project Override**: Python-specific formatter using ruff
> 
> **Override Priority**: Project Level (this file) > Account Level > Built-in

Format Python code in: $ARGUMENTS

## Formatting Strategy

### 1. Tool Resolution (2025 Best Practice)
```bash
# Prefer uvx for isolated execution (no project pollution)
if command -v uvx &> /dev/null; then
    RUFF="uvx ruff"
    echo "Using uvx ruff (isolated execution)"
elif command -v ruff &> /dev/null; then
    RUFF="ruff"
    echo "Using system ruff"
else
    echo "❌ Ruff not found. Install with: 'pip install ruff' or 'brew install ruff'"
    echo "   Or install uv for better isolation: 'curl -LsSf https://astral.sh/uv/install.sh | sh'"
    exit 1
fi
```

### 2. Format Code
```bash
# Format all Python files in current directory
$RUFF format .

# Format specific file/directory
$RUFF format $ARGUMENTS

# Check formatting without applying (CI/pre-commit)
$RUFF format --check $ARGUMENTS

# Show diff of what would change
$RUFF format --diff $ARGUMENTS
```

### 3. Fix Imports & Safe Issues
```bash
# Ruff combines formatting + import sorting + safe fixes
$RUFF check --fix $ARGUMENTS

# Only fix import sorting (isort replacement)
$RUFF check --select I --fix $ARGUMENTS

# Fix all safe issues and format
$RUFF check --fix $ARGUMENTS && $RUFF format $ARGUMENTS
```

## Configuration Detection

Check for configuration in order:
1. `ruff.toml`
2. `.ruff.toml`
3. `pyproject.toml` with `[tool.ruff]`
4. Use sensible defaults

## Common Patterns

### Format Entire Project
```bash
ruff format .
ruff check --select I --fix .
```

### Format Changed Files
```bash
# Format only modified files
git diff --name-only --diff-filter=M | grep '\.py$' | xargs ruff format
```

### Pre-commit Integration
```bash
# Check if formatting is needed
ruff format --check .

# Apply formatting
ruff format .
```

## Ruff vs Legacy Tools (2025)

**Ruff replaces these tools:**
- ✅ Black (formatting) → `ruff format`
- ✅ isort (import sorting) → `ruff check --select I --fix`
- ✅ Flake8 (linting) → `ruff check`
- ✅ pyupgrade (syntax upgrades) → `ruff check --select UP --fix`
- ✅ autoflake (unused imports) → `ruff check --select F401 --fix`

**Performance comparison:**
- Ruff: ~10-100x faster than Black
- Black: ~2-5 seconds for large codebases
- Ruff: ~0.1-0.5 seconds for same codebases

## Example Workflow

```bash
# Complete formatting workflow
$RUFF check --fix . && $RUFF format .

# Format only changed files in git
git diff --name-only --diff-filter=AM | grep '\.py$' | xargs $RUFF format

# Pre-commit check
$RUFF format --check . && $RUFF check .
```