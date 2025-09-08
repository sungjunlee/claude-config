---
description: Type check Python code with mypy
---

# Type Check Python Code

Type check Python code in: $ARGUMENTS

## Type Checking Strategy

### 1. Run mypy
```bash
# Check all Python files
mypy .

# Check specific file/directory
mypy $ARGUMENTS

# With strict mode
mypy --strict $ARGUMENTS

# Ignore missing imports
mypy --ignore-missing-imports $ARGUMENTS
```

### 2. Configuration Detection

Check for configuration in order:
1. `mypy.ini`
2. `.mypy.ini`
3. `pyproject.toml` with `[tool.mypy]`
4. `setup.cfg` with `[mypy]`

### 3. Common Configurations

```ini
[mypy]
python_version = 3.11
warn_return_any = True
warn_unused_configs = True
disallow_untyped_defs = True
disallow_any_unimported = True
no_implicit_optional = True
warn_redundant_casts = True
warn_unused_ignores = True
warn_no_return = True
warn_unreachable = True
strict_equality = True
```

## Type Annotation Patterns

### Basic Types
```python
def greet(name: str) -> str:
    return f"Hello, {name}"

age: int = 25
scores: list[float] = [98.5, 87.3, 92.1]
config: dict[str, Any] = {"debug": True}
```

### Optional and Union
```python
from typing import Optional, Union

def find_user(id: int) -> Optional[User]:
    # Returns User or None
    pass

def process(data: Union[str, bytes]) -> str:
    # Accepts str or bytes
    pass
```

### Generics and Protocols
```python
from typing import TypeVar, Protocol

T = TypeVar('T')

def first(items: list[T]) -> Optional[T]:
    return items[0] if items else None

class Drawable(Protocol):
    def draw(self) -> None: ...
```

## Gradual Typing Strategy

### Phase 1: Add to New Code
- Type all new functions
- Add return types first
- Then add parameter types

### Phase 2: Critical Paths
- Type public APIs
- Type data models
- Type error-prone functions

### Phase 3: Full Coverage
- Add types to remaining code
- Enable strict mode
- Enforce in CI

## Common Issues and Fixes

### Missing Type Stubs
```bash
# Install type stubs
mypy --install-types

# Common stubs
pip install types-requests types-redis types-PyYAML
```

### Ignore Specific Issues
```python
# Ignore line
result = untypable_function()  # type: ignore

# Ignore specific error
value = data["key"]  # type: ignore[index]

# Ignore file
# mypy: ignore-errors
```

## Integration with IDE

### VS Code Configuration

**Important:** The `python.linting.*` settings are deprecated in the latest Microsoft Python extension (2024+). You need to install the dedicated Mypy extension instead.

1. **Install the Mypy Type Checker extension:**
   - Extension ID: `ms-python.mypy-type-checker`
   - Install from VS Code marketplace or command palette

2. **Update your settings.json:**
```json
{
    // Mypy Type Checker extension settings (replaces deprecated python.linting.*)
    "mypy-type-checker.args": [
        "--ignore-missing-imports",
        "--follow-imports=silent",
        "--show-column-numbers"
    ],
    "mypy-type-checker.path": ["mypy"],
    "mypy-type-checker.importStrategy": "fromEnvironment",
    "mypy-type-checker.reportingScope": "file"
}
```

**Migration from old settings:**
- `python.linting.mypyEnabled` → Install the extension
- `python.linting.mypyArgs` → `mypy-type-checker.args`
- `python.linting.mypyPath` → `mypy-type-checker.path`

## Alternative Type Checkers

1. `pyright` - Microsoft's type checker (faster)
2. `pyre` - Facebook's type checker
3. `pytype` - Google's type checker

Execute appropriate type checker based on project configuration.