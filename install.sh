#!/usr/bin/env bash
#
# Claude Code Configuration Installer
# https://github.com/sungjunlee/claude-config
#
# This script installs Claude Code account-level configuration
# for consistent development environment across machines.

set -euo pipefail

# Get script directory (works both standalone and from repo)
if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    SCRIPT_DIR="$(pwd)"
fi

# Check if running from repo or standalone
if [[ -d "$SCRIPT_DIR/profiles/account" ]]; then
    # Running from repo
    REPO_DIR="$SCRIPT_DIR"
    PROFILE_DIR="$SCRIPT_DIR/profiles/account"
else
    # Running standalone (downloaded via curl)
    REPO_DIR=""
    PROFILE_DIR=""
fi

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
    CYAN='\033[0;36m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
    NC=''
fi

# Logging functions
log() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1" >&2; }
info() { echo -e "${BLUE}[i]${NC} $1"; }
debug() { 
    if [[ "${DEBUG:-0}" == "1" ]]; then
        echo -e "${CYAN}[D]${NC} $1" >&2
    fi
}

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
        if [ -t 0 ]; then
            read -r response
        else
            response="${CI_RESPONSE:-n}"
        fi
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
    
    # Check if running from local directory or need to download
    if [ -n "$PROFILE_DIR" ] && [ -d "$PROFILE_DIR" ]; then
        # Local installation from repo
        log "Installing from local repository..."
        
        # Copy configuration files from account profile
        if [ -d "$PROFILE_DIR/agents" ]; then
            log "Installing agents..."
            cp -r "$PROFILE_DIR/agents" "$CLAUDE_CONFIG_DIR/"
        else
            warn "Agents directory not found in profile"
        fi
        
        if [ -d "$PROFILE_DIR/commands" ]; then
            log "Installing commands..."
            cp -r "$PROFILE_DIR/commands" "$CLAUDE_CONFIG_DIR/"
        else
            warn "Commands directory not found in profile"
        fi
        
        if [ -d "$PROFILE_DIR/scripts" ]; then
            log "Installing scripts..."
            cp -r "$PROFILE_DIR/scripts" "$CLAUDE_CONFIG_DIR/"
        else
            debug "Scripts directory not found (optional)"
        fi
        
        if [ -f "$PROFILE_DIR/CLAUDE.md" ]; then
            log "Installing CLAUDE.md..."
            cp "$PROFILE_DIR/CLAUDE.md" "$CLAUDE_CONFIG_DIR/"
        else
            warn "CLAUDE.md not found in profile"
        fi
        
        if [ -f "$PROFILE_DIR/llm-models-latest.md" ]; then
            log "Installing llm-models-latest.md..."
            cp "$PROFILE_DIR/llm-models-latest.md" "$CLAUDE_CONFIG_DIR/"
        else
            debug "llm-models-latest.md not found (optional)"
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
    else
        # Remote installation - need to clone from git
        log "Downloading configuration from GitHub..."
        
        # Create temporary directory
        local temp_dir=$(mktemp -d)
        trap "rm -rf $temp_dir" EXIT
        
        # Clone the repository
        if ! git clone --depth 1 "$REPO_URL" "$temp_dir" 2>/dev/null; then
            error "Failed to download configuration files from GitHub"
            error "Please ensure git is installed and you have internet connection"
            exit 1
        fi
        
        # Copy files from account profile
        local source_dir="$temp_dir/profiles/account"
        
        log "Installing agents..."
        cp -r "$source_dir/agents" "$CLAUDE_CONFIG_DIR/"
        
        log "Installing commands..."
        cp -r "$source_dir/commands" "$CLAUDE_CONFIG_DIR/"
        
        log "Installing scripts..."
        cp -r "$source_dir/scripts" "$CLAUDE_CONFIG_DIR/"
        
        log "Installing CLAUDE.md..."
        cp "$source_dir/CLAUDE.md" "$CLAUDE_CONFIG_DIR/"
        
        log "Installing llm-models-latest.md..."
        cp "$source_dir/llm-models-latest.md" "$CLAUDE_CONFIG_DIR/"
        
        # Handle settings.json with merge logic
        if [ -f "$CLAUDE_CONFIG_DIR/settings.json" ]; then
            warn "settings.json already exists, creating settings.json.new"
            cp "$temp_dir/settings.json" "$CLAUDE_CONFIG_DIR/settings.json.new"
            info "Please manually merge settings.json.new with your existing settings.json"
        else
            log "Installing settings.json..."
            cp "$temp_dir/settings.json" "$CLAUDE_CONFIG_DIR/"
        fi
        
        # Create settings.local.json from example
        if [ ! -f "$CLAUDE_CONFIG_DIR/settings.local.json" ]; then
            log "Creating settings.local.json from example..."
            cp "$temp_dir/settings.local.json.example" "$CLAUDE_CONFIG_DIR/settings.local.json"
            warn "Please edit $CLAUDE_CONFIG_DIR/settings.local.json with your personal settings"
        fi
        
        # Copy docs directory if it exists
        if [ -d "$temp_dir/docs" ]; then
            log "Installing documentation..."
            cp -r "$temp_dir/docs" "$CLAUDE_CONFIG_DIR/"
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
    
    if [ -d "$CLAUDE_CONFIG_DIR/scripts" ]; then
        info "✓ Scripts installed ($(ls -1 "$CLAUDE_CONFIG_DIR/scripts" | wc -l) files)"
    else
        warn "✗ Scripts not found"
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
        if [ -t 0 ]; then
            read -r response
        else
            response="${CI_RESPONSE:-n}"
        fi
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
if [ "${BASH_SOURCE[0]:-}" == "${0}" ] || [ -z "${BASH_SOURCE[0]:-}" ]; then
    main "$@"
fi