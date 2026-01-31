#!/usr/bin/env bash
#
# Dev Environment Configuration Installer
# https://github.com/sungjunlee/claude-config
#
# Installs account-level configuration for AI coding assistants:
# - Claude Code (~/.claude)
# - Codex (~/.codex)
# - Antigravity (~/.gemini/antigravity, ~/.gemini/GEMINI.md)

set -euo pipefail

# Get script directory (works both standalone and from repo)
if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    SCRIPT_DIR="$(pwd)"
fi

# Check if running from repo or standalone
if [[ -d "$SCRIPT_DIR/account/claude-code" ]]; then
    REPO_DIR="$SCRIPT_DIR"
else
    REPO_DIR=""
fi

# Tool configurations (compatible with bash 3.2)
ALL_TOOLS="claude codex antigravity"
DEFAULT_TOOLS="claude"
REPO_URL="https://github.com/sungjunlee/claude-config.git"

# Get config directory for a tool
get_config_dir() {
    local tool="$1"
    case "$tool" in
        claude) echo "${CLAUDE_CONFIG_DIR:-$HOME/.claude}" ;;
        codex) echo "${CODEX_CONFIG_DIR:-$HOME/.codex}" ;;
        antigravity) echo "${ANTIGRAVITY_CONFIG_DIR:-$HOME/.gemini/antigravity}" ;;
    esac
}

# Get additional config directories for a tool (if any)
get_extra_config_dir() {
    local tool="$1"
    case "$tool" in
        antigravity) echo "$HOME/.gemini" ;;  # For GEMINI.md
        *) echo "" ;;
    esac
}

# Get account directory for a tool
get_account_dir() {
    local tool="$1"
    case "$tool" in
        claude) echo "account/claude-code" ;;
        codex) echo "account/codex" ;;
        antigravity) echo "account/antigravity" ;;
    esac
}

# Get command name for a tool
# Note: Currently same as tool name, but kept separate for future flexibility
# (e.g., if a tool's CLI command differs from its name)
get_tool_command() {
    local tool="$1"
    echo "$tool"
}

# Colors for output (disabled if not TTY)
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' CYAN='' NC=''
fi

# Logging functions
log() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1" >&2; }
info() { echo -e "${BLUE}[i]${NC} $1"; }
debug() { [[ "${DEBUG:-0}" == "1" ]] && echo -e "${CYAN}[D]${NC} $1" >&2 || true; }

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

    # Check optional Python deps for handoff_manager
    if command -v python3 &> /dev/null; then
        if ! python3 - <<'PY' 2>/dev/null; then
import importlib.util
missing = []
for mod in ("yaml", "tiktoken"):
    if importlib.util.find_spec(mod) is None:
        missing.append(mod)
if missing:
    raise SystemExit(1)
PY
            warn "Optional Python deps missing (pyyaml, tiktoken)."
            info "For handoff_manager: pip install pyyaml tiktoken"
        fi
    fi
}

# Check if a tool is installed
check_tool_installation() {
    local tool="$1"
    local force="${2:-false}"
    local cmd
    cmd=$(get_tool_command "$tool")

    if command -v "$cmd" &> /dev/null; then
        log "$tool is installed ($($cmd --version 2>/dev/null || echo 'version unknown'))"
        return 0
    else
        warn "$tool is not installed"

        if [[ "$force" == "true" ]]; then
            install_tool "$tool"
            return
        fi

        info "Would you like to install $tool now? (y/N)"
        local response
        if [ -t 0 ]; then
            read -r response
        else
            response="${CI_RESPONSE:-n}"
        fi
        if [[ "$response" =~ ^[Yy]$ ]]; then
            install_tool "$tool"
        else
            warn "Continuing without $tool installation..."
        fi
    fi
}

# Install a tool
install_tool() {
    local tool="$1"
    local install_result=0
    log "Installing $tool..."

    case "$tool" in
        claude)
            if command -v npm &> /dev/null; then
                if ! npm install -g @anthropic-ai/claude-code; then
                    error "npm install failed for Claude Code"
                    install_result=1
                fi
            else
                if ! curl -fsSL https://claude.ai/install.sh | bash; then
                    error "Claude Code installation script failed"
                    install_result=1
                fi
            fi
            ;;
        codex)
            if command -v npm &> /dev/null; then
                if ! npm install -g @openai/codex; then
                    error "npm install failed for Codex"
                    install_result=1
                fi
            else
                warn "npm required to install Codex"
                return 1
            fi
            ;;
        antigravity)
            info "Antigravity is installed via Google Cloud. Visit: https://antigravity.dev"
            return 0
            ;;
    esac

    if [ "$install_result" -ne 0 ]; then
        return 1
    fi

    local cmd
    cmd=$(get_tool_command "$tool")
    if command -v "$cmd" &> /dev/null; then
        log "$tool installed successfully!"
    else
        warn "$tool installation may have failed - command '$cmd' not found"
        return 1
    fi
}

# Backup existing configuration for a tool
backup_tool_config() {
    local tool="$1"
    local config_dir
    config_dir=$(get_config_dir "$tool")

    if [ -d "$config_dir" ]; then
        local backup_dir="$HOME/.${tool}-backup-$(date +%Y%m%d-%H%M%S)"
        log "Backing up $tool config to $backup_dir"
        if ! cp -r "$config_dir" "$backup_dir"; then
            error "Failed to backup $config_dir to $backup_dir"
            error "  Check disk space and permissions"
            return 1
        fi
        info "Backup created at: $backup_dir"
    fi
}

# Handle config file merge interactively
handle_config_merge() {
    local source_file="$1"
    local target_file="$2"
    local force_mode="${3:-false}"
    local file_label="${4:-config file}"

    if [ ! -f "$target_file" ]; then
        log "Installing $file_label..."
        mkdir -p "$(dirname "$target_file")"
        cp "$source_file" "$target_file"
        return 0
    fi

    warn "Existing $file_label detected at $target_file"

    if [ "$force_mode" = "true" ]; then
        warn "Force mode: backing up existing and installing new"
        cp "$target_file" "${target_file}.backup-$(date +%Y%m%d-%H%M%S)"
        cp "$source_file" "$target_file"
        return 0
    fi

    echo ""
    info "Configuration file conflict detected. What would you like to do?"
    echo "  [K]eep existing (default)"
    echo "  [R]eplace with new"
    echo "  [B]ackup existing and install new"
    echo "  [D]iff - show differences"
    echo "  [N]ew - save as .new for manual merge"
    echo -n "Choice [K/r/b/d/n]: "

    local response
    if [ -t 0 ]; then
        read -r response
    else
        response="${CI_RESPONSE:-k}"
    fi

    response=$(echo "$response" | tr '[:upper:]' '[:lower:]')
    case "$response" in
        r|replace)
            warn "Replacing $file_label"
            cp "$source_file" "$target_file"
            ;;
        b|backup)
            local backup_name="${target_file}.backup-$(date +%Y%m%d-%H%M%S)"
            log "Backing up to $backup_name"
            if ! cp "$target_file" "$backup_name"; then
                error "Failed to create backup at $backup_name"
                error "  Aborting to prevent data loss"
                return 1
            fi
            if ! cp "$source_file" "$target_file"; then
                error "Failed to install $target_file"
                return 1
            fi
            ;;
        d|diff)
            info "Showing differences (existing < > new):"
            echo "----------------------------------------"
            diff -u "$target_file" "$source_file" || true
            echo "----------------------------------------"
            handle_config_merge "$source_file" "$target_file" "$force_mode" "$file_label"
            ;;
        n|new)
            warn "Saving as ${target_file}.new"
            cp "$source_file" "${target_file}.new"
            info "Please manually merge ${target_file}.new"
            ;;
        k|keep|"")
            log "Keeping existing $file_label"
            ;;
        *)
            warn "Invalid choice. Keeping existing."
            ;;
    esac
}

# Install example file (only if target doesn't exist)
install_example_file() {
    local src="$1"
    local dest="$2"
    local label="$3"

    if [ -f "$src" ]; then
        if [ ! -f "$dest" ]; then
            if ! mkdir -p "$(dirname "$dest")"; then
                error "Failed to create directory for $label"
                return 1
            fi
            if ! cp "$src" "$dest"; then
                error "Failed to install $label"
                return 1
            fi
            log "Installed $label"
        else
            info "$label already exists; leaving as-is"
        fi
    fi
}

# Install directory
install_dir() {
    local label="$1"
    local src="$2"
    local dest="$3"
    local exec_flag="${4:-false}"

    if [ -d "$src" ]; then
        log "Installing $label..."
        if ! mkdir -p "$dest"; then
            error "Failed to create directory: $dest"
            return 1
        fi
        if ! cp -r "$src" "$dest"; then
            error "Failed to copy $src to $dest"
            return 1
        fi
        if [ "$exec_flag" = "true" ]; then
            local target="$dest/$(basename "$src")"
            if ! find "$target" -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} \; ; then
                error "Failed to set executable permissions in $target"
                return 1
            fi
        fi
    else
        debug "$label not found at $src"
    fi
}

# Install file
install_file() {
    local label="$1"
    local src="$2"
    local dest="$3"

    if [ -f "$src" ]; then
        log "Installing $label..."
        if ! mkdir -p "$(dirname "$dest")"; then
            error "Failed to create directory for $label"
            return 1
        fi
        if ! cp "$src" "$dest"; then
            error "Failed to install $label"
            return 1
        fi
    else
        debug "$label not found at $src"
    fi
}

#############################################
# Tool-specific installation functions
#############################################

install_claude() {
    local repo_dir="$1"
    local account_dir="$2"
    local force_install="$3"
    local config_dir
    config_dir=$(get_config_dir "claude")

    log "Installing Claude Code configuration..."
    mkdir -p "$config_dir"

    # NOTE: scripts, hooks, and skills are now distributed via the plugin.
    # They are no longer installed to ~/.claude/ by this script.
    # Instead, they reside in the plugin directory and are referenced via ${CLAUDE_PLUGIN_ROOT}.
    # Reason: Plugin architecture enables:
    #   - Auto-updates via /plugin update (no manual re-installation)
    #   - Version management via marketplace
    #   - Separation of frequently-updated code (skills/hooks) from stable configs

    # Files
    install_file "CLAUDE.md" "$account_dir/CLAUDE.md" "$config_dir/CLAUDE.md"
    install_file "llm-models-latest.md" "$account_dir/llm-models-latest.md" "$config_dir/llm-models-latest.md"

    # Settings with merge handling
    # Note: permissions must remain in ~/.claude/settings.json as plugins
    # cannot modify account-level security settings (Claude Code platform restriction)
    if [ -f "$account_dir/settings.json" ]; then
        handle_config_merge "$account_dir/settings.json" "$config_dir/settings.json" "$force_install" "settings.json"
    fi

    # Local settings example
    if [ -f "$account_dir/settings.local.json.example" ] && [ ! -f "$config_dir/settings.local.json" ]; then
        cp "$account_dir/settings.local.json.example" "$config_dir/settings.local.json"
        warn "Please edit $config_dir/settings.local.json with your personal settings"
    fi

    # Cleanup legacy files that are no longer needed (now in plugin)
    # Note: verify_claude() will give detailed message if cleanup fails
    if ! cleanup_claude_legacy "$config_dir"; then
        warn "Legacy cleanup failed - see errors above"
        warn "Installation will continue, but manual cleanup may be required"
    fi
}

# Cleanup legacy files from pre-v2.1.0 installations
# Prior to v2.1.0, scripts/hooks/skills were installed to ~/.claude/
# They are now distributed via the plugin and should not exist locally.
# Returns 0 on success, 1 if any cleanup failed
cleanup_claude_legacy() {
    local config_dir="$1"
    local cleaned=false
    local failed=false

    # Pre-flight check: can we write to config_dir?
    if [ ! -w "$config_dir" ]; then
        error "Cannot clean up legacy directories: $config_dir is not writable"
        error "  Try: chmod u+w \"$config_dir\" and re-run"
        return 1
    fi

    for legacy_dir in scripts hooks skills; do
        local target="$config_dir/$legacy_dir"

        # Handle symlinks separately to avoid deleting symlink targets
        if [ -L "$target" ]; then
            local symlink_target
            symlink_target=$(readlink "$target" 2>/dev/null) || symlink_target=""
            if [ -n "$symlink_target" ]; then
                warn "Removing legacy $legacy_dir symlink (was pointing to: $symlink_target)..."
            else
                warn "Removing legacy $legacy_dir symlink (target could not be determined)..."
            fi
            local rm_err
            if rm_err=$(rm "$target" 2>&1); then
                [ -n "$symlink_target" ] && info "Symlink removed. Original target at $symlink_target was preserved."
                cleaned=true
            else
                error "Failed to remove symlink $target"
                [ -n "$rm_err" ] && error "  Reason: $rm_err"
                error "  Try: rm -f \"$target\""
                failed=true
            fi
        elif [ -d "$target" ]; then
            warn "Removing legacy $legacy_dir directory (now in plugin)..."

            if [ ! -w "$target" ]; then
                error "Cannot remove $target: directory is not writable"
                error "  Try: chmod -R u+w \"$target\" && rm -rf \"$target\""
                failed=true
                continue
            fi

            # Attempt removal and verify the directory is gone
            local rm_output
            if rm_output=$(rm -r "$target" 2>&1) && [ ! -d "$target" ]; then
                cleaned=true
            else
                error "Failed to remove $target"
                [ -n "$rm_output" ] && error "  Reason: $rm_output"
                error "  Try: sudo rm -rf \"$target\""
                failed=true
            fi
        fi
    done

    if [ "$cleaned" = true ]; then
        info "Legacy files cleaned up. Skills/hooks are now provided via plugin."
    fi

    if [ "$failed" = true ]; then
        return 1
    fi
    return 0
}

install_codex() {
    local repo_dir="$1"
    local account_dir="$2"
    local force_install="$3"
    local config_dir
    config_dir=$(get_config_dir "codex")

    if [ ! -d "$account_dir" ]; then
        info "Codex templates not found"
        return 0
    fi

    log "Installing Codex configuration..."
    mkdir -p "$config_dir"

    # Install example files (only if not exists)
    install_example_file "$account_dir/config.toml.example" "$config_dir/config.toml" "Codex config.toml"
    install_example_file "$account_dir/AGENTS.md.example" "$config_dir/AGENTS.md" "Codex AGENTS.md"
}

install_antigravity() {
    local repo_dir="$1"
    local account_dir="$2"
    local force_install="$3"
    local config_dir
    local gemini_dir
    config_dir=$(get_config_dir "antigravity")
    gemini_dir=$(get_extra_config_dir "antigravity")

    if [ ! -d "$account_dir" ]; then
        info "Antigravity templates not found"
        return 0
    fi

    log "Installing Antigravity configuration..."
    mkdir -p "$config_dir"
    mkdir -p "$gemini_dir"

    # Install example files (only if not exists)
    # Settings go to ~/.gemini/antigravity/
    install_example_file "$account_dir/settings.json.example" "$config_dir/settings.json" "Antigravity settings.json"
    install_example_file "$account_dir/mcp_config.json.example" "$config_dir/mcp_config.json" "Antigravity mcp_config.json"

    # GEMINI.md goes to ~/.gemini/ (shared with Gemini CLI)
    install_example_file "$account_dir/GEMINI.md.example" "$gemini_dir/GEMINI.md" "GEMINI.md (global instructions)"
}

#############################################
# Verification functions
#############################################

verify_claude() {
    local config_dir
    config_dir=$(get_config_dir "claude")
    local success=true

    info "Verifying Claude Code installation..."

    # Account-level configs (installed by this script)
    [ -f "$config_dir/CLAUDE.md" ] && info "  ✓ CLAUDE.md" || { warn "  ✗ CLAUDE.md"; success=false; }
    [ -f "$config_dir/settings.json" ] && info "  ✓ settings.json (permissions)" || { warn "  ✗ settings.json"; success=false; }
    [ -f "$config_dir/llm-models-latest.md" ] && info "  ✓ llm-models-latest.md" || info "  - llm-models-latest.md (optional)"

    # Plugin components (should NOT exist - they're in the plugin now)
    local legacy_warning=false
    for legacy_dir in scripts hooks skills; do
        if [ -L "$config_dir/$legacy_dir" ] || [ -d "$config_dir/$legacy_dir" ]; then
            warn "  ! Legacy $legacy_dir still present"
            legacy_warning=true
        else
            info "  ✓ No legacy $legacy_dir"
        fi
    done

    if [ "$legacy_warning" = true ]; then
        echo ""
        error "CLEANUP REQUIRED: Legacy directories still present"
        error "This will cause conflicts with the plugin architecture."
        error "Please remove manually:"
        error "  rm -rf \"$config_dir/scripts\" \"$config_dir/hooks\" \"$config_dir/skills\""
        echo ""
        success=false
    fi

    [ "$success" = true ]
}

verify_codex() {
    local config_dir
    config_dir=$(get_config_dir "codex")

    info "Verifying Codex installation..."

    if [ -d "$config_dir" ]; then
        [ -f "$config_dir/config.toml" ] && info "  ✓ config.toml" || info "  - config.toml (optional)"
        [ -f "$config_dir/AGENTS.md" ] && info "  ✓ AGENTS.md" || info "  - AGENTS.md (optional)"
        return 0
    else
        info "  - Not installed"
        return 0
    fi
}

verify_antigravity() {
    local config_dir
    local gemini_dir
    config_dir=$(get_config_dir "antigravity")
    gemini_dir=$(get_extra_config_dir "antigravity")

    info "Verifying Antigravity installation..."

    if [ -d "$config_dir" ] || [ -d "$gemini_dir" ]; then
        [ -f "$config_dir/settings.json" ] && info "  ✓ settings.json (~/.gemini/antigravity/)" || info "  - settings.json (optional)"
        [ -f "$config_dir/mcp_config.json" ] && info "  ✓ mcp_config.json (~/.gemini/antigravity/)" || info "  - mcp_config.json (optional)"
        [ -f "$gemini_dir/GEMINI.md" ] && info "  ✓ GEMINI.md (~/.gemini/)" || info "  - GEMINI.md (optional)"
        return 0
    else
        info "  - Not installed"
        return 0
    fi
}

#############################################
# Main installation logic
#############################################

clone_repo() {
    local temp_dir
    temp_dir=$(mktemp -d)
    # Show git errors but capture them for better error messages
    if ! git clone --depth 1 "$REPO_URL" "$temp_dir" 2>&1; then
        rm -rf "$temp_dir"
        return 1
    fi
    echo "$temp_dir"
}

install_tools() {
    local tools="$1"
    local force_install="$2"
    local skip_backup="$3"
    local repo_dir="$REPO_DIR"

    # Clone repo if running standalone
    if [ -z "$repo_dir" ]; then
        log "Downloading configuration from GitHub..."
        if ! repo_dir=$(clone_repo); then
            error "Failed to download configuration from GitHub"
            error "Please ensure git is installed and you have internet connection"
            exit 1
        fi
        # Use quoted variable in trap for paths with spaces
        trap 'rm -rf "$repo_dir"' EXIT
    fi

    # Install each tool
    for tool in $tools; do
        local account_dir="$repo_dir/$(get_account_dir "$tool")"

        echo ""
        log "=== Installing $tool ==="

        # Backup if needed
        if [ "$skip_backup" = "false" ]; then
            backup_tool_config "$tool"
        fi

        # Check tool installation
        check_tool_installation "$tool" "$force_install"

        # Install configuration
        case "$tool" in
            claude)
                install_claude "$repo_dir" "$account_dir" "$force_install"
                ;;
            codex)
                install_codex "$repo_dir" "$account_dir" "$force_install"
                ;;
            antigravity)
                install_antigravity "$repo_dir" "$account_dir" "$force_install"
                ;;
        esac
    done

    # Verify installations
    echo ""
    log "=== Verification ==="
    local verify_failed=false
    for tool in $tools; do
        case "$tool" in
            claude) verify_claude || verify_failed=true ;;
            codex) verify_codex || verify_failed=true ;;
            antigravity) verify_antigravity || verify_failed=true ;;
        esac
    done

    if [ "$verify_failed" = true ]; then
        error "Verification failed - see errors above"
        return 1
    fi
}

show_help() {
    cat << EOF
Dev Environment Configuration Installer

Usage: $0 [OPTIONS]

Options:
  --tools TOOLS    Comma-separated list of tools to install
                   Available: claude, codex, antigravity
                   Default: claude
  --all            Install all available tools
  --skip-backup    Skip backing up existing configuration
  --force          Force installation without prompts
  --help           Show this help message

Examples:
  $0                              # Install claude only (default)
  $0 --tools codex                # Install codex only
  $0 --tools claude,codex         # Install claude and codex
  $0 --all                        # Install all tools
  $0 --force --all                # Force install all tools
EOF
}

main() {
    echo ""
    echo "========================================"
    echo " Dev Environment Configuration Installer"
    echo "========================================"
    echo ""

    # Parse arguments
    local skip_backup=false
    local force_install=false
    local tools="$DEFAULT_TOOLS"

    while [[ $# -gt 0 ]]; do
        case $1 in
            --tools)
                tools="${2//,/ }"  # Convert comma to space
                shift 2
                ;;
            --all)
                tools="$ALL_TOOLS"
                shift
                ;;
            --skip-backup)
                skip_backup=true
                shift
                ;;
            --force)
                force_install=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    # Validate tools
    for tool in $tools; do
        if [[ ! " $ALL_TOOLS " =~ " $tool " ]]; then
            error "Unknown tool: $tool"
            info "Available tools: $ALL_TOOLS"
            exit 1
        fi
    done

    # Show what will be installed
    info "Tools to install: $tools"
    info "Detected OS: $(detect_os)"

    # Check prerequisites
    check_prerequisites

    # Confirmation prompt (unless --force)
    if [ "$force_install" = false ]; then
        echo ""
        warn "This will install configuration for: $tools"
        echo -n "Continue? (y/N) "
        local response
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

    # Install
    if ! install_tools "$tools" "$force_install" "$skip_backup"; then
        echo ""
        error "Installation completed with errors - see messages above"
        exit 1
    fi

    # Done
    echo ""
    log "Installation complete!"
    echo ""

    # Show plugin installation guide for Claude
    if [[ " $tools " =~ " claude " ]]; then
        show_claude_plugin_guide
    fi

    info "Next steps:"
    for tool in $tools; do
        info "  - Review $tool config in $(get_config_dir "$tool")"
    done
    echo ""
}

# Show plugin installation guide for Claude Code
show_claude_plugin_guide() {
    echo ""
    echo "========================================"
    echo " Plugin Installation (Skills & Hooks)"
    echo "========================================"
    echo ""
    info "Skills and hooks are now distributed via plugin."
    info "Run these commands in Claude Code:"
    echo ""
    echo "  1. Add marketplace:"
    echo "     ${CYAN}/plugin marketplace add sungjunlee/claude-config${NC}"
    echo ""
    echo "  2. Install plugin:"
    echo "     ${CYAN}/plugin install my@sungjunlee-claude-config${NC}"
    echo ""
    echo "  3. Enable auto-update (recommended):"
    echo "     ${CYAN}/plugin${NC} → Select marketplace → Enable auto-update"
    echo ""
    info "The plugin provides:"
    info "  - Skills: /session, /worktree, /dev-setup"
    info "  - Hooks: datetime injection, audit logging, permission notifications, auto-formatting"
    echo ""
}

# Run main function if script is not being sourced
if [ "${BASH_SOURCE[0]:-}" == "${0}" ] || [ -z "${BASH_SOURCE[0]:-}" ]; then
    main "$@"
fi
