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
    if ! uv pip install -e ".[dev]" 2>/dev/null; then
        warn "Failed to install with uv. This is normal if pyproject.toml doesn't exist yet."
    fi
elif command -v pip3 >/dev/null 2>&1; then
    log "Using pip"
    if ! pip3 install -e ".[dev]" 2>/dev/null; then
        warn "Failed to install with pip. This is normal if pyproject.toml doesn't exist yet."
    fi
    
    # Try to install essential tools directly
    info "Installing essential Python tools..."
    if ! pip3 install ruff mypy pytest pytest-cov pre-commit 2>/dev/null; then
        warn "Some Python tools failed to install. You may need to install them manually:"
        warn "  pip3 install ruff mypy pytest pytest-cov pre-commit"
    else
        log "Essential Python tools installed successfully"
    fi
else
    warn "No Python package manager found. Install pip or uv."
    warn "You'll need to manually install: ruff mypy pytest pytest-cov pre-commit"
fi

# Set up pre-commit hooks if available
if [[ -f ".pre-commit-config.yaml" ]]; then
    if command -v pre-commit >/dev/null 2>&1; then
        if pre-commit install 2>/dev/null; then
            log "Pre-commit hooks installed"
        else
            warn "Failed to install pre-commit hooks. You may need to run 'pre-commit install' manually."
        fi
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

# Install Claude commands
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(pwd)"
CLAUDE_DIR="${PROJECT_ROOT}/.claude"

if [[ -d "${SCRIPT_DIR}/.claude/commands" ]]; then
    mkdir -p "${CLAUDE_DIR}/commands"
    cp -r "${SCRIPT_DIR}/.claude/commands/"* "${CLAUDE_DIR}/commands/" 2>/dev/null || true
    log "Installed Claude Code project commands"
fi

log "Python profile installation complete!"
info "Next steps:"
echo "  1. Review and customize pyproject.toml"
echo "  2. Run 'pre-commit install' if not already done"
echo "  3. Run 'pytest' to test your setup"
echo "  4. Run 'ruff check .' to lint your code"
echo ""
info "Available Claude commands:"
echo "  /optimize - Python-specific performance optimization"
echo "  /pytest   - Smart pytest runner with coverage"
echo "  /venv     - Virtual environment management"