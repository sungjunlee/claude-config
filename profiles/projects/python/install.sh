#!/usr/bin/env bash
#
# Python profile installation script
# This script is run when applying the Python profile to a project
#

set -euo pipefail

# Colors for output
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
else
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

log() { echo -e "${GREEN}[+]${NC} $1"; }
info() { echo -e "${BLUE}[i]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }

# Check Python version
if command -v python3 >/dev/null 2>&1; then
    python_version=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
    log "Found Python $python_version"
else
    warn "Python 3 not found. Please install Python 3.8 or later."
    exit 1
fi

# Create project structure if it doesn't exist
if [[ ! -d "src" ]]; then
    mkdir -p src
    log "Created src directory"
fi

if [[ ! -d "tests" ]]; then
    mkdir -p tests
    touch tests/__init__.py
    log "Created tests directory"
fi

# Install development dependencies
info "Installing development dependencies..."

# Check for package manager preference
if command -v uv >/dev/null 2>&1; then
    log "Using uv (fast Rust-based package manager)"
    uv pip install -e ".[dev]" 2>/dev/null || true
elif command -v pip3 >/dev/null 2>&1; then
    log "Using pip"
    pip3 install -e ".[dev]" 2>/dev/null || true
else
    warn "No Python package manager found. Install pip or uv."
fi

# Set up pre-commit hooks if available
if [[ -f ".pre-commit-config.yaml" ]]; then
    if command -v pre-commit >/dev/null 2>&1; then
        pre-commit install
        log "Pre-commit hooks installed"
    else
        info "Install pre-commit with: pip install pre-commit"
        info "Then run: pre-commit install"
    fi
fi

# Create .gitignore if it doesn't exist
if [[ ! -f ".gitignore" ]]; then
    cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
.venv
pip-log.txt
pip-delete-this-directory.txt
.pytest_cache/
.mypy_cache/
.ruff_cache/
*.egg-info/
dist/
build/
*.egg

# IDE
.vscode/
.idea/
*.swp
*.swo
.DS_Store

# Coverage
.coverage
htmlcov/
*.cover
.hypothesis/

# Secrets
.env
.secrets.baseline
EOF
    log "Created .gitignore"
fi

log "Python profile installation complete!"
info "Next steps:"
echo "  1. Review and customize pyproject.toml"
echo "  2. Run 'pre-commit install' if not already done"
echo "  3. Run 'pytest' to test your setup"
echo "  4. Run 'ruff check .' to lint your code"