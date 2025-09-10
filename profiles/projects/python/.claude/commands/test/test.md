---
description: Modern pytest runner with coverage, markers, and async support (2025)
---

# Run Python Tests

Execute tests for: $ARGUMENTS

## Tool Resolution (2025 Best Practice)

```bash
# Prefer uvx for isolated execution
if command -v uvx &> /dev/null; then
    PYTEST="uvx pytest"
    echo "Using uvx pytest (isolated execution)"
elif command -v pytest &> /dev/null; then
    PYTEST="pytest"
    echo "Using system pytest"
else
    echo "❌ pytest not found. Install with: 'pip install pytest' or use uv"
    exit 1
fi
```

## Test Discovery

Check for test configuration in order:
1. `pyproject.toml` with `[tool.pytest.ini_options]`
2. `pytest.ini` or `.pytest.ini`
3. `tox.ini` for multi-environment testing
4. `setup.cfg` with `[tool:pytest]`
5. Default: `tests/` directory with `test_*.py` or `*_test.py`

## Modern Testing Strategies (2025)

### Quick Test Run
```bash
# Run all tests
$PYTEST

# Run specific file or directory
$PYTEST tests/unit/

# Run specific test
$PYTEST tests/test_module.py::test_function

# Run tests matching pattern
$PYTEST -k "test_authentication"

# Stop on first failure
$PYTEST -x

# Run last failed tests
$PYTEST --lf

# Run failed tests first, then others
$PYTEST --ff
```

### Coverage Analysis
```bash
# Run with coverage report
$PYTEST --cov=src --cov-branch --cov-report=term-missing

# Generate multiple coverage formats
$PYTEST --cov=src --cov-report=term-missing --cov-report=html --cov-report=xml

# Fail if coverage below threshold
$PYTEST --cov=src --cov-fail-under=80

# Show missing lines only
$PYTEST --cov=src --cov-report=term-missing:skip-covered

# Coverage for specific modules
$PYTEST --cov=src.models --cov=src.views
```

### Parallel Execution
```bash
# Auto-detect CPU cores (requires pytest-xdist)
$PYTEST -n auto

# Use specific number of workers
$PYTEST -n 4

# Distribute by test file
$PYTEST -n auto --dist loadfile

# Distribute by test groups
$PYTEST -n auto --dist loadgroup
```

### Async Testing (2025)
```bash
# Run async tests (requires pytest-asyncio)
$PYTEST -m asyncio

# With async mode auto
$PYTEST --asyncio-mode=auto

# Run async tests in strict mode
$PYTEST --asyncio-mode=strict
```

### Using Markers
```bash
# Run only unit tests
$PYTEST -m unit

# Skip slow tests
$PYTEST -m "not slow"

# Run integration tests only
$PYTEST -m integration

# Complex marker expressions
$PYTEST -m "unit and not slow"
$PYTEST -m "integration or e2e"

# Show available markers
$PYTEST --markers
```

## Advanced Testing Patterns (2025)

### Debugging Tests
```bash
# Drop into debugger on failure
$PYTEST --pdb

# Drop into debugger on first failure
$PYTEST -x --pdb

# Start debugger at beginning of test
$PYTEST --trace

# Show local variables on failure
$PYTEST -l

# Ultra-verbose output
$PYTEST -vv
```

### Performance Testing
```bash
# Profile test execution time
$PYTEST --durations=10

# Show all durations
$PYTEST --durations=0

# Timeout tests (requires pytest-timeout)
$PYTEST --timeout=300

# Benchmark tests (requires pytest-benchmark)
$PYTEST --benchmark-only
```

### Output Formats
```bash
# JUnit XML for CI
$PYTEST --junit-xml=report.xml

# JSON report (requires pytest-json-report)
$PYTEST --json-report --json-report-file=report.json

# HTML report (requires pytest-html)
$PYTEST --html=report.html --self-contained-html

# TAP format
$PYTEST --tap-stream
```

## Modern pytest Configuration (pyproject.toml)

```toml
[tool.pytest.ini_options]
minversion = "7.0"
addopts = [
    "--strict-markers",
    "--strict-config",
    "--cov=src",
    "--cov-branch",
    "--cov-report=term-missing:skip-covered",
    "--cov-report=html",
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
    "slow: marks tests as slow (deselect with '-m \"not slow\"')",
    "integration: marks tests as integration tests",
    "unit: marks tests as unit tests",
    "e2e: marks tests as end-to-end tests",
    "smoke: marks tests as smoke tests",
]
filterwarnings = [
    "error",
    "ignore::UserWarning",
    "ignore::DeprecationWarning",
]

[tool.coverage.run]
source = ["src"]
branch = true
parallel = true
omit = [
    "*/tests/*",
    "*/test_*.py",
    "*/__init__.py",
]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "def __repr__",
    "raise AssertionError",
    "raise NotImplementedError",
    "if __name__ == .__main__.:",
    "if TYPE_CHECKING:",
    "@abstract",
]
precision = 2
show_missing = true
```

## Test Organization Best Practices (2025)

### Directory Structure
```
tests/
├── unit/           # Fast, isolated tests
├── integration/    # Component interaction tests
├── e2e/           # End-to-end tests
├── fixtures/      # Shared fixtures
├── conftest.py    # Pytest configuration
└── __init__.py
```

### Fixture Patterns
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

## CI/CD Integration

```bash
# GitHub Actions compatible output
$PYTEST --tb=short --quiet --color=yes

# GitLab CI compatible
$PYTEST --junit-xml=report.xml --cov-report=xml

# Jenkins compatible
$PYTEST --junit-xml=junit.xml --cov-report=cobertura

# Pre-commit hook
$PYTEST --quiet --tb=line -m "not slow"
```

## Common Workflows

```bash
# Development: Fast feedback
$PYTEST -x --tb=short -m "not slow"

# Pre-push: Comprehensive
$PYTEST --cov=src --cov-fail-under=80

# CI Pipeline: Full validation
$PYTEST --cov=src --cov-report=xml --junit-xml=report.xml

# Debug failing test
$PYTEST -x --pdb --tb=long tests/test_failing.py

# Performance check
$PYTEST --durations=10 -m "not slow"
```

## Tool Installation

```bash
# Install test dependencies with uv
uv pip install pytest pytest-cov pytest-xdist pytest-asyncio pytest-timeout

# Or use uvx for isolated execution (no installation)
uvx pytest --version
```