#!/usr/bin/env bash
#
# Profile injection script for Claude Config
# Injects specific profiles into the current project
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
Usage: ccfg inject <profiles> [options]

Inject specific profiles into the current project.

Profiles can be combined with '+' separator:
  python+testing+strict

Options:
  --list      List available profiles
  --force     Overwrite existing files
  --help      Show this help message

Examples:
  ccfg inject python
  ccfg inject testing+linting
  ccfg inject python --force

EOF
}

# Parse profiles string
parse_profiles() {
    local profiles_str="$1"
    IFS='+' read -ra profiles <<< "$profiles_str"
    echo "${profiles[@]}"
}

# Main function
main() {
    local profiles_str="${1:-}"
    local force=false
    
    # Handle special cases
    if [[ -z "$profiles_str" ]] || [[ "$profiles_str" == "--help" ]] || [[ "$profiles_str" == "-h" ]]; then
        show_usage
        exit 0
    fi
    
    if [[ "$profiles_str" == "--list" ]]; then
        list_profiles projects
        exit 0
    fi
    
    # Parse options
    shift
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --force)
                force=true
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
    
    # Parse profiles
    local profiles=($(parse_profiles "$profiles_str"))
    
    if [[ ${#profiles[@]} -eq 0 ]]; then
        error "No profiles specified"
        show_usage
        exit 1
    fi
    
    # Check project root
    if ! get_project_root >/dev/null; then
        warn "Not in a project directory (no .git, package.json, or pyproject.toml found)"
        if ! confirm "Continue anyway?" "n"; then
            exit 0
        fi
    fi
    
    # Apply each profile
    info "Injecting profiles: ${profiles[*]}"
    echo ""
    
    local failed=()
    for profile in "${profiles[@]}"; do
        info "Applying profile: $profile"
        
        if apply_profile "$profile" "$(pwd)" "projects"; then
            success "Profile $profile applied"
        else
            error "Failed to apply profile: $profile"
            failed+=("$profile")
        fi
        
        echo ""
    done
    
    # Summary
    if [[ ${#failed[@]} -eq 0 ]]; then
        success "All profiles injected successfully!"
    else
        warn "Some profiles failed: ${failed[*]}"
        exit 1
    fi
}

# Run main function
main "$@"