#!/usr/bin/env bash
#
# Claude Code Configuration Installer
# https://github.com/sungjunlee/claude-config
#

set -euo pipefail

# --- Configuration ---
REPO_URL="https://github.com/sungjunlee/claude-config.git"
CLAUDE_CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
CODEX_CONFIG_DIR="${CODEX_CONFIG_DIR:-$HOME/.codex}"
BACKUP_DIR="$HOME/.claude-backup-$(date +%Y%m%d-%H%M%S)"

# --- Utils ---
if [ -t 1 ]; then
    RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m' BLUE='\033[0;34m' NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' NC=''
fi

log() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1" >&2; }
info() { echo -e "${BLUE}[i]${NC} $1"; }

detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        [ -f /etc/os-release ] && . /etc/os-release && echo "linux:${ID:-unknown}:${VERSION_ID:-unknown}" || echo "linux:unknown:unknown"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos:$(sw_vers -productVersion)"
    else
        echo "unknown"
    fi
}

ask_user() {
    local prompt="$1"
    local default="${2:-n}"
    local response
    
    if [ "${FORCE_INSTALL:-false}" = "true" ]; then
        [[ "$default" =~ ^[Yy]$ ]] && return 0 || return 1
    fi

    echo -n "$prompt "
    if [ -t 0 ]; then
        read -r response
    else
        response="${CI_RESPONSE:-$default}"
    fi
    [[ "${response:-$default}" =~ ^[Yy]$ ]]
}

# --- Prerequisites ---
check_prerequisites() {
    local missing=()
    for tool in git curl; do
        command -v "$tool" &> /dev/null || missing+=("$tool")
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        error "Missing required tools: ${missing[*]}"
        exit 1
    fi

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

check_claude_installation() {
    if command -v claude &> /dev/null; then
        log "Claude Code is installed ($(claude --version 2>/dev/null || echo 'unknown'))"
        return 0
    fi

    warn "Claude Code is not installed"
    if ask_user "Would you like to install it now? (y/N)" "n"; then
        log "Installing Claude Code..."
        if command -v npm &> /dev/null; then
            npm install -g @anthropic-ai/claude-code
        else
            curl -fsSL https://claude.ai/install.sh | bash
        fi
    fi
}

# --- Installation ---
install_component() {
    local name="$1"
    local src="$2"
    local dest="$3"
    
    if [ -e "$src" ]; then
        log "Installing $name..."
        cp -r "$src" "$dest"
        # Set permissions for executable directories
        if [[ "$name" == "scripts" || "$name" == "hooks" ]]; then
            find "$dest" -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} +
        fi
    else
        info "$name not found (optional)"
    fi
}

handle_settings_merge() {
    local src="$1"
    local target="$2"
    
    [ ! -f "$target" ] && cp "$src" "$target" && return 0
    
    warn "Existing settings.json detected"
    if [ "${FORCE_INSTALL:-false}" = "true" ]; then
        cp "$target" "${target}.backup-$(date +%Y%m%d-%H%M%S)"
        cp "$src" "$target"
        return 0
    fi
    
    # Simple prompt for interactive mode
    echo ""
    info "Configuration conflict for settings.json:"
    echo "  [K]eep existing (default)"
    echo "  [R]eplace with new"
    echo "  [B]ackup existing and replace"
    echo -n "Choice [K/r/b]: "
    
    local response
    read -r response
    case "${response,,}" in
        r|replace) cp "$src" "$target" ;;
        b|backup)
            local bk="${target}.backup-$(date +%Y%m%d-%H%M%S)"
            cp "$target" "$bk" && cp "$src" "$target"
            log "Backed up to $bk"
            ;;
        *) log "Keeping existing settings" ;;
    esac
}

install_codex_templates() {
    local src_dir="$1"
    [ ! -d "$src_dir" ] && return 0

    if ask_user "Install Codex templates to $CODEX_CONFIG_DIR? (y/N)" "n"; then
        mkdir -p "$CODEX_CONFIG_DIR"
        for file in config.toml AGENTS.md; do
            if [ -f "$src_dir/$file.example" ] && [ ! -f "$CODEX_CONFIG_DIR/$file" ]; then
                cp "$src_dir/$file.example" "$CODEX_CONFIG_DIR/$file"
                log "Installed Codex $file"
            fi
        done
    else
        info "Skipping Codex templates"
    fi
}

install_config() {
    local repo_dir="$1"
    local account_dir="$2"
    
    log "Installing configuration to $CLAUDE_CONFIG_DIR..."
    mkdir -p "$CLAUDE_CONFIG_DIR"

    # Core components from Account/Profile
    install_component "agents"  "$account_dir/agents"  "$CLAUDE_CONFIG_DIR/"
    install_component "scripts" "$account_dir/scripts" "$CLAUDE_CONFIG_DIR/"
    install_component "hooks"   "$account_dir/hooks"   "$CLAUDE_CONFIG_DIR/"
    
    # Core components from Repo root
    install_component "commands" "$repo_dir/commands" "$CLAUDE_CONFIG_DIR/"
    install_component "skills"   "$repo_dir/skills"   "$CLAUDE_CONFIG_DIR/"

    # Files
    [ -f "$account_dir/CLAUDE.md" ] && cp "$account_dir/CLAUDE.md" "$CLAUDE_CONFIG_DIR/"
    [ -f "$account_dir/llm-models-latest.md" ] && cp "$account_dir/llm-models-latest.md" "$CLAUDE_CONFIG_DIR/"

    # Settings
    if [ -f "$account_dir/settings.json" ]; then
        handle_settings_merge "$account_dir/settings.json" "$CLAUDE_CONFIG_DIR/settings.json"
    fi
    
    if [ -f "$account_dir/settings.local.json.example" ] && [ ! -f "$CLAUDE_CONFIG_DIR/settings.local.json" ]; then
        cp "$account_dir/settings.local.json.example" "$CLAUDE_CONFIG_DIR/settings.local.json"
        warn "Created settings.local.json - please edit with your preferences"
    fi

    # Codex
    if [ -d "$repo_dir/account/codex" ]; then
        install_codex_templates "$repo_dir/account/codex"
    fi
}

verify_installation() {
    log "Verifying installation..."
    local missing=0
    
    [ -d "$CLAUDE_CONFIG_DIR/agents" ] || ((missing++))
    [ -d "$CLAUDE_CONFIG_DIR/commands" ] || ((missing++))
    [ -f "$CLAUDE_CONFIG_DIR/CLAUDE.md" ] || ((missing++))
    
    if [ $missing -eq 0 ]; then
        log "Installation verified successfully!"
    else
        warn "Some components are missing. Check logs above."
    fi
}

main() {
    echo -e "\n=== Claude Code Configuration Setup ===\n"
    
    FORCE_INSTALL=false
    local skip_backup=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --force) FORCE_INSTALL=true ;;
            --skip-backup) skip_backup=true ;;
            *) error "Unknown option: $1"; exit 1 ;;
        esac
        shift
    done

    # Setup directories
    local script_dir
    if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
        script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    else
        script_dir="$(pwd)"
    fi

    local repo_dir=""
    local account_dir=""
    
    if [ -d "$script_dir/account/claude-code" ]; then
        repo_dir="$script_dir"
        account_dir="$script_dir/account/claude-code"
    else
        # Remote/Temp mode setup would go here if needed, 
        # but for simplicity we assume this structure for now 
        # or rely on the previous logic if we need to support curl | bash fully with clone
        # For the simplification task, I will assume the user primarily uses it from repo
        # or consistent structure.
        # To maintain full curl support, we'd keep the temp dir logic but clean it up.
        # Let's keep it simple for this iteration.
        repo_dir="$script_dir" 
        # Fallback if not standard structure, though unlikely with current repo
    fi
    
    # If running via curl (repo_dir doesn't have expected files), clone it
    if [ ! -d "$repo_dir/account/claude-code" ]; then
        log "Downloading configuration..."
        local temp_dir=$(mktemp -d)
        trap "rm -rf $temp_dir" EXIT
        git clone --depth 1 "$REPO_URL" "$temp_dir" -q
        repo_dir="$temp_dir"
        account_dir="$temp_dir/account/claude-code"
    fi

    check_prerequisites
    check_claude_installation

    if ! ask_user "Install configuration to $CLAUDE_CONFIG_DIR?" "y"; then
        info "Cancelled."
        exit 0
    fi

    [ "$skip_backup" = false ] && [ -d "$CLAUDE_CONFIG_DIR" ] && \
        cp -r "$CLAUDE_CONFIG_DIR" "$BACKUP_DIR" && \
        info "Backup created at $BACKUP_DIR"

    install_config "$repo_dir" "$account_dir"
    verify_installation
    
    echo -e "\n${GREEN}Done!${NC} Run 'claude' to start."
}

if [ "${BASH_SOURCE[0]:-}" == "${0}" ] || [ -z "${BASH_SOURCE[0]:-}" ]; then
    main "$@"
fi
