---
description: Format Python code with ruff (overrides account-level format)
---

# Format Python Code

> **Project Override**: Python-specific formatter using ruff
> 
> **Override Priority**: Project Level (this file) > Account Level > Built-in

Format Python code in: $ARGUMENTS

## Formatting Strategy

### 1. Check for ruff
```bash
# Check if ruff is available
if command -v ruff &> /dev/null; then
    echo "Using ruff formatter"
elif command -v uv &> /dev/null; then
    echo "Using uv run ruff"
else
    echo "Installing ruff..."
    pip install ruff
fi
```

### 2. Format Code
```bash
# Format all Python files
ruff format .

# Format specific file/directory
ruff format $ARGUMENTS

# With line length configuration
ruff format --line-length 88 $ARGUMENTS
```

### 3. Sort Imports
```bash
# Ruff includes isort functionality
ruff check --select I --fix $ARGUMENTS
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

## Alternative Formatters

If ruff is not available, fall back to:
1. `black` - The uncompromising formatter
2. `autopep8` - PEP 8 compliant formatter
3. `yapf` - Google's formatter

Execute appropriate formatter based on project configuration.