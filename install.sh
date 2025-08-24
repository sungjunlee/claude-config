#!/usr/bin/env bash
#
# Claude Code Configuration Installer
# https://github.com/sungjunlee/claude-config
#
# This script installs Claude Code configuration files for consistent
# development environment across machines, including headless Linux servers.

set -euo pipefail

# Configuration
CLAUDE_CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
BACKUP_DIR="$HOME/.claude-backup-$(date +%Y%m%d-%H%M%S)"
REPO_URL="https://github.com/sungjunlee/claude-config.git"

# Colors for output (disabled if not TTY)
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

# Logging functions
log() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1" >&2; }
info() { echo -e "${BLUE}[i]${NC} $1"; }

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            echo "linux:$ID:$VERSION_ID"
        else
            echo "linux:unknown:unknown"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos:$(sw_vers -productVersion)"
    else
        echo "unknown"
    fi
}

# Check prerequisites
check_prerequisites() {
    local missing_tools=()
    
    # Check for required tools
    for tool in git curl; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        error "Missing required tools: ${missing_tools[*]}"
        info "Please install them first:"
        
        OS_INFO=$(detect_os)
        if [[ "$OS_INFO" == linux:* ]]; then
            info "  sudo apt-get install ${missing_tools[*]}  # Debian/Ubuntu"
            info "  sudo yum install ${missing_tools[*]}      # RHEL/CentOS"
        elif [[ "$OS_INFO" == macos:* ]]; then
            info "  brew install ${missing_tools[*]}"
        fi
        exit 1
    fi
}

# Check if Claude Code is installed
check_claude_installation() {
    if command -v claude &> /dev/null; then
        log "Claude Code is already installed ($(claude --version 2>/dev/null || echo 'version unknown'))"
        return 0
    else
        warn "Claude Code is not installed"
        info "Would you like to install it now? (y/N)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            install_claude_code
        else
            warn "Continuing without Claude Code installation..."
        fi
    fi
}

# Install Claude Code
install_claude_code() {
    log "Installing Claude Code..."
    
    # Check for Node.js/npm first
    if command -v npm &> /dev/null; then
        log "Installing via npm..."
        npm install -g @anthropic-ai/claude-code
    else
        log "Installing via official script..."
        curl -fsSL https://claude.ai/install.sh | bash
    fi
    
    if command -v claude &> /dev/null; then
        log "Claude Code installed successfully!"
    else
        error "Claude Code installation failed"
        exit 1
    fi
}

# Backup existing configuration
backup_existing_config() {
    if [ -d "$CLAUDE_CONFIG_DIR" ]; then
        log "Backing up existing configuration to $BACKUP_DIR"
        cp -r "$CLAUDE_CONFIG_DIR" "$BACKUP_DIR"
        info "Backup created at: $BACKUP_DIR"
    fi
}

# Install configuration files
install_config() {
    log "Installing Claude Code configuration..."
    
    # Create config directory if it doesn't exist
    mkdir -p "$CLAUDE_CONFIG_DIR"
    
    # Copy configuration files
    if [ -d "agents" ]; then
        log "Installing agents..."
        cp -r agents "$CLAUDE_CONFIG_DIR/"
    fi
    
    if [ -d "commands" ]; then
        log "Installing commands..."
        cp -r commands "$CLAUDE_CONFIG_DIR/"
    fi
    
    if [ -f "CLAUDE.md" ]; then
        log "Installing CLAUDE.md..."
        cp CLAUDE.md "$CLAUDE_CONFIG_DIR/"
    fi
    
    # Handle settings.json with merge logic
    if [ -f "settings.json" ]; then
        if [ -f "$CLAUDE_CONFIG_DIR/settings.json" ]; then
            warn "settings.json already exists, creating settings.json.new"
            cp settings.json "$CLAUDE_CONFIG_DIR/settings.json.new"
            info "Please manually merge settings.json.new with your existing settings.json"
        else
            log "Installing settings.json..."
            cp settings.json "$CLAUDE_CONFIG_DIR/"
        fi
    fi
    
    # Create settings.local.json from example if it exists
    if [ -f "settings.local.json.example" ]; then
        if [ ! -f "$CLAUDE_CONFIG_DIR/settings.local.json" ]; then
            log "Creating settings.local.json from example..."
            cp settings.local.json.example "$CLAUDE_CONFIG_DIR/settings.local.json"
            warn "Please edit $CLAUDE_CONFIG_DIR/settings.local.json with your personal settings"
        fi
    fi
}

# Verify installation
verify_installation() {
    log "Verifying installation..."
    
    local success=true
    
    # Check if files were copied
    if [ -d "$CLAUDE_CONFIG_DIR/agents" ]; then
        info "✓ Agents installed ($(ls -1 "$CLAUDE_CONFIG_DIR/agents" | wc -l) files)"
    else
        warn "✗ Agents not found"
        success=false
    fi
    
    if [ -d "$CLAUDE_CONFIG_DIR/commands" ]; then
        info "✓ Commands installed ($(find "$CLAUDE_CONFIG_DIR/commands" -name "*.md" | wc -l) files)"
    else
        warn "✗ Commands not found"
        success=false
    fi
    
    if [ -f "$CLAUDE_CONFIG_DIR/CLAUDE.md" ]; then
        info "✓ CLAUDE.md installed"
    else
        warn "✗ CLAUDE.md not found"
        success=false
    fi
    
    if [ "$success" = true ]; then
        log "Installation verified successfully!"
    else
        warn "Some components may be missing"
    fi
}

# Main installation flow
main() {
    echo ""
    echo "=================================="
    echo " Claude Code Configuration Setup"
    echo "=================================="
    echo ""
    
    # Parse arguments
    local skip_backup=false
    local force_install=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-backup)
                skip_backup=true
                shift
                ;;
            --force)
                force_install=true
                shift
                ;;
            --help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --skip-backup    Skip backing up existing configuration"
                echo "  --force          Force installation without prompts"
                echo "  --help           Show this help message"
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Check OS
    OS_INFO=$(detect_os)
    info "Detected OS: $OS_INFO"
    
    # Check prerequisites
    check_prerequisites
    
    # Check Claude Code installation
    check_claude_installation
    
    # Confirmation prompt (unless --force is used)
    if [ "$force_install" = false ]; then
        echo ""
        warn "This will install Claude Code configuration files to $CLAUDE_CONFIG_DIR"
        echo -n "Continue? (y/N) "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            info "Installation cancelled"
            exit 0
        fi
    fi
    
    # Backup existing configuration
    if [ "$skip_backup" = false ]; then
        backup_existing_config
    fi
    
    # Install configuration
    install_config
    
    # Verify installation
    verify_installation
    
    echo ""
    log "Installation complete!"
    echo ""
    info "Next steps:"
    info "1. Run 'claude' to start using Claude Code"
    info "2. Review your configuration in $CLAUDE_CONFIG_DIR"
    info "3. Customize settings.local.json for personal preferences"
    echo ""
}

# Run main function if script is not being sourced
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi