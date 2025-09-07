---
description: Virtual environment and dependency management
---

# Python Environment Management

Manage virtual environment for: $ARGUMENTS

## Environment Detection

Check for environment tools:
1. Poetry (pyproject.toml with [tool.poetry])
2. Pipenv (Pipfile)
3. venv/virtualenv (.venv or venv/)
4. Conda environment (environment.yml)
5. pip with requirements.txt

## Common Operations

### Create/Activate Environment

```bash
# uv (fast Rust-based)
uv venv
source .venv/bin/activate  # Unix
.venv\Scripts\activate     # Windows

# Poetry
poetry install
poetry shell

# Pipenv
pipenv install
pipenv shell

# venv
python -m venv .venv
source .venv/bin/activate  # Unix
.venv\Scripts\activate     # Windows

# Conda
conda env create -f environment.yml
conda activate myenv
```

### Dependency Management

```bash
# Add dependency
poetry add requests
pipenv install requests
pip install requests
# uv
uv pip install requests

# Add dev dependency
poetry add --dev pytest
pipenv install --dev pytest
pip install -r requirements-dev.txt
# uv (with pyproject.toml)
# uv add --dev pytest

# Update dependencies
poetry update
pipenv update
pip install --upgrade -r requirements.txt
# uv
# uv pip install -r requirements.txt --upgrade

# Lock dependencies
poetry lock
pipenv lock
pip freeze > requirements.txt
# uv sync (with pyproject.toml)
# uv sync
```

### Clean Operations

```bash
# Remove unused dependencies
poetry remove unused-package
pipenv uninstall unused-package

# Clean cache
poetry cache clear --all pypi
pipenv --clear

# Rebuild environment
poetry install --remove-untracked
pipenv install --dev --deploy
```

## Best Practices

1. Always use virtual environments
2. Pin dependency versions
3. Separate dev and production dependencies
4. Regular dependency updates with testing
5. Use lockfiles for reproducible builds

Execute appropriate environment operation.