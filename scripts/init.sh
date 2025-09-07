#!/usr/bin/env bash
#
# Project initialization script for Claude Config
# Initializes a project with a specific language profile
#

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
LIB_DIR="$ROOT_DIR/lib"
PROFILES_DIR="$ROOT_DIR/profiles"

# Load common functions
source "$LIB_DIR/common.sh"
source "$LIB_DIR/profile.sh"

# Show usage
show_usage() {
    cat << EOF
Usage: ccfg init <language> [options]

Initialize a project with a language-specific profile.

Languages:
  python      Python development environment
  javascript  JavaScript/Node.js environment
  rust        Rust development environment
  auto        Auto-detect based on project files

Options:
  --force     Overwrite existing configurations
  --minimal   Apply minimal configuration
  --help      Show this help message

Examples:
  ccfg init python
  ccfg init auto
  ccfg init javascript --force

EOF
}

# Main function
main() {
    local language="${1:-}"
    local force=false
    local minimal=false
    
    # Parse arguments
    shift || true
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --force)
                force=true
                shift
                ;;
            --minimal)
                minimal=true
                shift
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Check language argument
    if [[ -z "$language" ]]; then
        show_usage
        exit 1
    fi
    
    # Auto-detect if requested
    if [[ "$language" == "auto" ]]; then
        info "Auto-detecting project type..."
        language=$(detect_project_type)
        
        if [[ "$language" == "unknown" ]]; then
            error "Could not detect project type"
            info "Please specify explicitly: ccfg init <language>"
            exit 1
        fi
        
        success "Detected: $language"
    fi
    
    # Check if profile exists
    local profile_dir="$ROOT_DIR/profiles/projects/$language"
    if [[ ! -d "$profile_dir" ]]; then
        error "Profile not found: $language"
        info "Available profiles:"
        list_profiles projects
        exit 1
    fi
    
    # Check for existing configuration
    if [[ -d ".claude" ]] && [[ "$force" != true ]]; then
        warn "Claude configuration already exists in this project"
        if ! confirm "Overwrite existing configuration?" "n"; then
            info "Initialization cancelled"
            exit 0
        fi
    fi
    
    # Apply profile
    info "Initializing $language project..."
    
    if apply_profile "$language" "$(pwd)" "projects"; then
        success "Project initialized with $language profile!"
        
        # Show next steps
        echo ""
        info "Next steps:"
        
        case "$language" in
            python)
                echo "  1. Review pyproject.toml for your project settings"
                echo "  2. Install dependencies: pip install -e '.[dev]'"
                echo "  3. Set up pre-commit: pre-commit install"
                echo "  4. Run tests: pytest"
                ;;
            javascript)
                echo "  1. Review package.json for your project settings"
                echo "  2. Install dependencies: npm install"
                echo "  3. Set up husky: npx husky install"
                echo "  4. Run tests: npm test"
                ;;
            rust)
                echo "  1. Review Cargo.toml for your project settings"
                echo "  2. Build project: cargo build"
                echo "  3. Run tests: cargo test"
                echo "  4. Format code: cargo fmt"
                ;;
        esac
    else
        error "Failed to initialize project"
        exit 1
    fi
}

# Run main function
main "$@"