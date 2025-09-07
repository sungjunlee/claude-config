#!/bin/bash
set -euo pipefail

# Rust Project Profile Installer

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(pwd)"
CLAUDE_DIR="${PROJECT_ROOT}/.claude"

# Colors
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

echo -e "${GREEN}Installing Rust project profile...${NC}"

# Check Rust installation
if command -v cargo >/dev/null 2>&1; then
    rust_version=$(rustc --version | cut -d' ' -f2)
    log "Found Rust $rust_version"
else
    warn "Rust not found. Please install Rust from https://rustup.rs/"
    exit 1
fi

# Install Claude commands
if [[ -d "${SCRIPT_DIR}/.claude/commands" ]]; then
    mkdir -p "${CLAUDE_DIR}/commands"
    cp -r "${SCRIPT_DIR}/.claude/commands/"* "${CLAUDE_DIR}/commands/" 2>/dev/null || true
    log "Installed Claude Code project commands"
fi

# Detect Rust project setup
echo -e "\n${YELLOW}Detecting Rust project setup...${NC}"

if [ -f "Cargo.toml" ]; then
    echo "✓ Found Cargo.toml"
    
    # Check for workspace
    if grep -q "\[workspace\]" Cargo.toml; then
        echo "✓ Workspace project detected"
    fi
    
    # Check for common dependencies
    if grep -q "tokio" Cargo.toml; then
        echo "✓ Async runtime (tokio) detected"
    fi
    if grep -q "serde" Cargo.toml; then
        echo "✓ Serialization (serde) detected"
    fi
    if grep -q "criterion" Cargo.toml; then
        echo "✓ Benchmarking (criterion) detected"
    fi
else
    warn "No Cargo.toml found - run 'cargo init' to create a Rust project"
fi

# Check for configuration files
if [ -f ".clippy.toml" ] || [ -f "clippy.toml" ]; then
    echo "✓ Clippy configuration found"
fi
if [ -f ".rustfmt.toml" ] || [ -f "rustfmt.toml" ]; then
    echo "✓ Rustfmt configuration found"
fi

# Install useful Rust tools if not present
info "Checking for Rust development tools..."

# Check and suggest tool installation
tools_to_install=""

if ! command -v cargo-clippy >/dev/null 2>&1; then
    tools_to_install="$tools_to_install clippy"
fi

if ! command -v cargo-fmt >/dev/null 2>&1; then
    tools_to_install="$tools_to_install rustfmt"
fi

if [ -n "$tools_to_install" ]; then
    warn "Some Rust tools are missing. Install with:"
    echo "  rustup component add$tools_to_install"
fi

# Suggest additional tools
info "Recommended additional tools:"
echo "  cargo install cargo-watch    # Auto-rebuild on file changes"
echo "  cargo install cargo-tarpaulin # Code coverage"
echo "  cargo install flamegraph      # Performance profiling"
echo "  cargo install cargo-audit     # Security audit"

echo -e "\n${GREEN}Rust project profile installed!${NC}"
echo "Available commands:"
echo "  /clippy      - Rust linting with clippy"
echo "  /bench       - Benchmarking with cargo bench"
echo "  /cargo-test  - Comprehensive testing"