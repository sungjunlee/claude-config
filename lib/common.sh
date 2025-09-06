#!/usr/bin/env bash
#
# Common functions for Claude Config scripts
#

# Colors for output (disabled if not TTY)
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
    BOLD=''
    NC=''
fi

# Logging functions
log() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1" >&2; }
info() { echo -e "${BLUE}[i]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
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
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
check_prerequisites() {
    local missing=()
    
    for cmd in "$@"; do
        if ! command_exists "$cmd"; then
            missing+=("$cmd")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        error "Missing required commands: ${missing[*]}"
        return 1
    fi
    
    return 0
}

# Create backup
create_backup() {
    local source="$1"
    local backup_dir="${2:-$HOME/.claude-backup-$(date +%Y%m%d-%H%M%S)}"
    
    if [[ -e "$source" ]]; then
        mkdir -p "$backup_dir"
        cp -r "$source" "$backup_dir/"
        info "Backup created at: $backup_dir"
    fi
}

# Confirm action
confirm() {
    local prompt="${1:-Continue?}"
    local default="${2:-n}"
    
    local yn
    if [[ "$default" == "y" ]]; then
        read -p "$prompt [Y/n]: " yn
        yn=${yn:-y}
    else
        read -p "$prompt [y/N]: " yn
        yn=${yn:-n}
    fi
    
    case $yn in
        [Yy]* ) return 0;;
        * ) return 1;;
    esac
}

# Get absolute path
get_absolute_path() {
    local path="$1"
    if [[ -d "$path" ]]; then
        (cd "$path" && pwd)
    elif [[ -f "$path" ]]; then
        echo "$(cd "$(dirname "$path")" && pwd)/$(basename "$path")"
    else
        echo "$path"
    fi
}

# Parse YAML value (simple implementation)
parse_yaml_value() {
    local file="$1"
    local key="$2"
    
    if [[ -f "$file" ]]; then
        grep "^${key}:" "$file" | sed "s/^${key}:[[:space:]]*//" | sed 's/[[:space:]]*#.*//'
    fi
}

# Get project root (looks for .git or other markers)
get_project_root() {
    local dir="$(cd "${1:-$(pwd)}" && pwd -P)"  # Resolve symlinks
    
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/.git" ]] || [[ -f "$dir/package.json" ]] || [[ -f "$dir/pyproject.toml" ]]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    
    return 1
}