---
description: Virtual environment and dependency management (2025)
---

# Python Environment Management

Manage Python environment for: $ARGUMENTS

## Project Detection Strategy

```bash
# Detect project type and environment
if [ -f "uv.lock" ] || [ -f "pyproject.toml" ] && grep -q "tool.uv" pyproject.toml 2>/dev/null; then
    echo "📦 UV project detected"
    PROJECT_TYPE="uv"
elif [ -f "poetry.lock" ] || [ -f "pyproject.toml" ] && grep -q "tool.poetry" pyproject.toml 2>/dev/null; then
    echo "📦 Poetry project detected"
    PROJECT_TYPE="poetry"
elif [ -f "Pipfile.lock" ] || [ -f "Pipfile" ]; then
    echo "📦 Pipenv project detected"
    PROJECT_TYPE="pipenv"
elif [ -f "requirements.txt" ] || [ -f "requirements.in" ]; then
    echo "📦 Pip project detected"
    PROJECT_TYPE="pip"
elif [ -f "environment.yml" ] || [ -f "conda.yml" ]; then
    echo "📦 Conda project detected"
    PROJECT_TYPE="conda"
else
    echo "📦 Standard Python project (will use uv/pip)"
    PROJECT_TYPE="standard"
fi
```

## Environment Creation (2025)

### UV (Fastest - Recommended for new projects)
```bash
# Create virtual environment
uv venv

# Activate environment
source .venv/bin/activate  # Unix/macOS
# or
.venv\Scripts\activate     # Windows

# Install from pyproject.toml
uv pip install -e .

# Install from requirements.txt
uv pip install -r requirements.txt

# Sync with lock file
uv pip sync requirements.txt
```

### Poetry (Popular for libraries)
```bash
# Install dependencies and create venv
poetry install

# Activate shell
poetry shell

# Or run commands in venv
poetry run python script.py
```

### Standard venv (Universal)
```bash
# Create virtual environment
python -m venv .venv

# Activate
source .venv/bin/activate  # Unix/macOS
.venv\Scripts\activate     # Windows

# Install dependencies
pip install -r requirements.txt
```

## Dependency Management (2025)

### Adding Dependencies

```bash
# UV (when in any Python project)
uv pip install package-name

# UV with extras
uv pip install "package[extra1,extra2]"

# Poetry project
poetry add package-name

# Pipenv project
pipenv install package-name

# Standard pip
pip install package-name
```

### Development Dependencies

```bash
# UV with pyproject.toml
uv pip install -e ".[dev]"

# Poetry
poetry add --group dev pytest ruff mypy

# Pipenv
pipenv install --dev pytest ruff mypy

# Pip with separate file
pip install -r requirements-dev.txt
```

### Updating Dependencies

```bash
# UV - update all
uv pip install --upgrade -r requirements.txt

# UV - update specific
uv pip install --upgrade package-name

# Poetry
poetry update  # all
poetry update package-name  # specific

# Pipenv
pipenv update  # all
pipenv update package-name  # specific
```

### Lock Files

```bash
# UV - generate lock
uv pip freeze > requirements.txt

# UV - compile requirements (with pip-tools)
uv pip compile pyproject.toml -o requirements.txt
uv pip compile requirements.in -o requirements.txt

# Poetry
poetry lock

# Pipenv
pipenv lock
```

## Tool Execution (Without Project Modification)

### Using uvx (Isolated execution)
```bash
# Run tools without installing in project
uvx ruff check .
uvx mypy .
uvx pytest
uvx black .  # if you still need it
uvx isort .  # if you still need it

# Run specific versions
uvx ruff@0.1.0 check .
uvx --python 3.11 mypy .
```

### Benefits of uvx
- No project pollution
- Automatic tool isolation
- Version pinning support
- Works with any Python project type

## Python Version Management

### Using UV
```bash
# Create venv with specific Python
uv venv --python 3.11

# Use Python from pyproject.toml
uv venv  # reads requires-python
```

### Using pyenv
```bash
# Install Python version
pyenv install 3.11.7

# Set for project
pyenv local 3.11.7

# Create venv with pyenv Python
python -m venv .venv
```

## Environment Information

```bash
# Show current environment
which python
python --version
pip list

# UV specific
uv pip list
uv pip freeze

# Poetry specific
poetry show
poetry env info

# Pipenv specific
pipenv graph
pipenv --where
```

## Cleanup Operations

```bash
# Remove virtual environment
rm -rf .venv

# Clear UV cache
uv cache clean

# Clear pip cache
pip cache purge

# Poetry cache
poetry cache clear --all pypi

# Pipenv cache
pipenv --clear
```

## Best Practices (2025)

1. **Use UV for speed**: 10-100x faster than pip
2. **Always use virtual environments**: Never install globally
3. **Pin dependency versions**: Use lock files for reproducibility
4. **Separate dev/prod deps**: Keep production minimal
5. **Use uvx for tools**: Don't pollute project with tool dependencies
6. **Version Python explicitly**: Specify in pyproject.toml
7. **Regular updates**: Update deps monthly with testing

## Modern pyproject.toml Example

```toml
[project]
name = "my-project"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = [
    "fastapi>=0.104.0",
    "pydantic>=2.5.0",
    "httpx>=0.25.0",
]

[project.optional-dependencies]
dev = [
    "ruff>=0.1.0",
    "mypy>=1.7.0",
    "pytest>=7.4.0",
    "pytest-cov>=4.1.0",
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.uv]
dev-dependencies = [
    "ruff>=0.1.0",
    "mypy>=1.7.0",
]
```

## Quick Commands Reference

```bash
# Create and activate environment (any project)
uv venv && source .venv/bin/activate

# Install all dependencies (any project)
uv pip install -r requirements.txt  # or
uv pip install -e ".[dev]"  # with pyproject.toml

# Run tool without installation
uvx ruff check . && uvx ruff format .

# Update everything
uv pip install --upgrade -r requirements.txt
```