# Python Testing Guide

Python 프로젝트를 위한 pytest 기반 테스트 가이드입니다.

## Test Framework

**Primary**: pytest (modern standard)
**Secondary**: unittest, doctest
**Coverage**: pytest-cov

## Tool Resolution (2025 Best Practice)

```bash
# Prefer uvx for isolated execution
if command -v uvx &> /dev/null; then
    PYTEST="uvx pytest"
elif command -v pytest &> /dev/null; then
    PYTEST="pytest"
else
    echo "pytest not found. Install: pip install pytest"
    exit 1
fi
```

## Test Discovery

Configuration priority:
1. `pyproject.toml` with `[tool.pytest.ini_options]`
2. `pytest.ini` or `.pytest.ini`
3. `tox.ini` with `[pytest]`
4. `setup.cfg` with `[tool:pytest]`
5. Default: `tests/` with `test_*.py` or `*_test.py`

## Common Commands

### Basic Execution
```bash
# Run all tests
$PYTEST

# Specific file or directory
$PYTEST tests/unit/

# Specific test function
$PYTEST tests/test_module.py::test_function

# Pattern matching
$PYTEST -k "test_authentication"

# Stop on first failure
$PYTEST -x

# Last failed tests
$PYTEST --lf

# Failed first, then others
$PYTEST --ff
```

### Coverage Analysis
```bash
# With coverage report
$PYTEST --cov=src --cov-branch --cov-report=term-missing

# Multiple formats
$PYTEST --cov=src --cov-report=term-missing --cov-report=html --cov-report=xml

# Fail if below threshold
$PYTEST --cov=src --cov-fail-under=80

# Skip covered lines
$PYTEST --cov=src --cov-report=term-missing:skip-covered
```

### Parallel Execution
```bash
# Auto-detect CPU cores (requires pytest-xdist)
$PYTEST -n auto

# Specific workers
$PYTEST -n 4

# Distribute by file
$PYTEST -n auto --dist loadfile
```

### Async Testing
```bash
# Run async tests (requires pytest-asyncio)
$PYTEST -m asyncio

# Auto mode
$PYTEST --asyncio-mode=auto
```

### Using Markers
```bash
# Only unit tests
$PYTEST -m unit

# Skip slow tests
$PYTEST -m "not slow"

# Integration only
$PYTEST -m integration

# Complex expressions
$PYTEST -m "unit and not slow"

# Show markers
$PYTEST --markers
```

## Debugging Tests

```bash
# Drop into debugger on failure
$PYTEST --pdb

# First failure + debugger
$PYTEST -x --pdb

# Show local variables
$PYTEST -l

# Ultra-verbose
$PYTEST -vv
```

## Performance Profiling

```bash
# Show slowest tests
$PYTEST --durations=10

# All durations
$PYTEST --durations=0

# Timeout (requires pytest-timeout)
$PYTEST --timeout=300
```

## Output Formats

```bash
# JUnit XML for CI
$PYTEST --junit-xml=report.xml

# HTML report
$PYTEST --html=report.html --self-contained-html
```

## Configuration (pyproject.toml)

```toml
[tool.pytest.ini_options]
minversion = "7.0"
addopts = [
    "--strict-markers",
    "--strict-config",
    "--cov=src",
    "--cov-branch",
    "--cov-report=term-missing:skip-covered",
    "--cov-fail-under=80",
    "-ra",
    "--tb=short",
]
testpaths = ["tests"]
python_files = ["test_*.py", "*_test.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
asyncio_mode = "auto"
markers = [
    "slow: marks tests as slow",
    "integration: integration tests",
    "unit: unit tests",
    "e2e: end-to-end tests",
]

[tool.coverage.run]
source = ["src"]
branch = true
omit = ["*/tests/*", "*/__init__.py"]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "if TYPE_CHECKING:",
    "@abstract",
]
precision = 2
show_missing = true
```

## Directory Structure

```
tests/
├── unit/           # Fast, isolated tests
├── integration/    # Component interaction
├── e2e/            # End-to-end tests
├── fixtures/       # Shared fixtures
├── conftest.py     # Configuration
└── __init__.py
```

## Fixture Patterns

```python
# conftest.py
import pytest
from typing import AsyncGenerator

@pytest.fixture
async def async_client() -> AsyncGenerator:
    """Async test client fixture."""
    async with AsyncClient() as client:
        yield client

@pytest.fixture(scope="session")
def test_data():
    """Session-scoped test data."""
    return load_test_data()
```

## Common Issues

### Import Errors
- Check PYTHONPATH: `export PYTHONPATH="${PYTHONPATH}:${PWD}"`
- Ensure `__init__.py` in package directories
- Use relative imports correctly

### Fixture Issues
- Define in `conftest.py`
- Use appropriate scope (function, class, module, session)
- Clean up with yield or finalizers

### Async Tests
- Install pytest-asyncio
- Mark with `@pytest.mark.asyncio`
- Set `asyncio_mode = "auto"` in config

## CI/CD Integration

```bash
# GitHub Actions
$PYTEST --tb=short --quiet --color=yes

# GitLab CI
$PYTEST --junit-xml=report.xml --cov-report=xml

# Pre-commit
$PYTEST --quiet --tb=line -m "not slow"
```

## Common Workflows

```bash
# Development: Fast feedback
$PYTEST -x --tb=short -m "not slow"

# Pre-push: Comprehensive
$PYTEST --cov=src --cov-fail-under=80

# CI: Full validation
$PYTEST --cov=src --cov-report=xml --junit-xml=report.xml

# Debug failing
$PYTEST -x --pdb --tb=long tests/test_failing.py
```

## Tool Installation

```bash
# With uv
uv pip install pytest pytest-cov pytest-xdist pytest-asyncio pytest-timeout

# Isolated execution (no install)
uvx pytest --version
```
