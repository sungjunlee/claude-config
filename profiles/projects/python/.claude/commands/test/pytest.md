---
description: Smart pytest runner with coverage and markers
---

# Run Python Tests

Execute pytest for: $ARGUMENTS

## Test Discovery

Check for test configuration:
1. pytest.ini or pyproject.toml
2. tox.ini for multi-environment testing
3. setup.cfg with test configuration
4. Unittest discover pattern

## Execution Strategies

### Quick Test Run
```bash
# Run all tests
pytest

# Run specific file or directory
pytest tests/unit/

# Run specific test
pytest tests/test_module.py::test_function
```

### With Coverage
```bash
# Run with coverage report
pytest --cov=src --cov-report=term-missing

# Generate HTML coverage
pytest --cov=src --cov-report=html

# Fail if coverage below threshold
pytest --cov=src --cov-fail-under=80
```

### Using Markers
```bash
# Run only unit tests
pytest -m unit

# Skip slow tests
pytest -m "not slow"

# Run integration tests
pytest -m integration
```

### Parallel Execution
```bash
# Use pytest-xdist for parallel runs
pytest -n auto

# Run with 4 workers
pytest -n 4
```

## Common Flags

- `-v` : Verbose output
- `-s` : Show print statements  
- `-x` : Stop on first failure
- `--lf` : Run last failed tests
- `--ff` : Run failed tests first
- `-k` : Run tests matching expression

Execute appropriate test strategy based on project needs.