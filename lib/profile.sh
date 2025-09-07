#!/usr/bin/env bash
#
# Profile management functions for Claude Config
#

# Get profile directory
get_profile_dir() {
    local profile_type="${1:-projects}"
    echo "${PROFILES_DIR:-$(dirname "$0")/profiles}/$profile_type"
}

# List available profiles
list_profiles() {
    local profile_type="${1:-all}"
    
    echo -e "${BOLD}Available Profiles:${NC}"
    echo ""
    
    # Account profiles
    if [[ "$profile_type" == "all" ]] || [[ "$profile_type" == "account" ]]; then
        echo -e "${CYAN}Account Level:${NC}"
        local account_dir="$(get_profile_dir account)"
        if [[ -d "$account_dir" ]] && [[ -f "$account_dir/profile.yaml" ]]; then
            local desc=$(parse_yaml_value "$account_dir/profile.yaml" "description")
            echo "  account - $desc"
        fi
        echo ""
    fi
    
    # Project profiles
    if [[ "$profile_type" == "all" ]] || [[ "$profile_type" == "projects" ]]; then
        echo -e "${CYAN}Project Profiles:${NC}"
        local projects_dir="$(get_profile_dir projects)"
        
        for profile_dir in "$projects_dir"/*; do
            if [[ -d "$profile_dir" ]]; then
                local profile_name=$(basename "$profile_dir")
                local profile_yaml="$profile_dir/profile.yaml"
                
                if [[ -f "$profile_yaml" ]]; then
                    local desc=$(parse_yaml_value "$profile_yaml" "description")
                    local parent=$(parse_yaml_value "$profile_yaml" "parent")
                    
                    if [[ "$profile_name" == "_base" ]]; then
                        echo "  _base - $desc (base profile)"
                    else
                        if [[ -n "$parent" ]]; then
                            echo "  $profile_name - $desc (extends: $parent)"
                        else
                            echo "  $profile_name - $desc"
                        fi
                    fi
                fi
            fi
        done
    fi
}

# Load profile configuration
load_profile() {
    local profile_name="$1"
    local profile_type="${2:-projects}"
    
    # Validate profile name to prevent path traversal
    if [[ "$profile_name" =~ \.\. ]] || [[ "$profile_name" =~ / ]]; then
        error "Invalid profile name: $profile_name"
        return 1
    fi
    
    local profile_dir="$(get_profile_dir $profile_type)/$profile_name"
    local profile_yaml="$profile_dir/profile.yaml"
    
    if [[ ! -f "$profile_yaml" ]]; then
        error "Profile not found: $profile_name"
        return 1
    fi
    
    # Export profile information
    export PROFILE_NAME="$profile_name"
    export PROFILE_DIR="$profile_dir"
    export PROFILE_YAML="$profile_yaml"
    
    # Load parent profile if exists (but don't override current profile vars)
    local parent=$(parse_yaml_value "$profile_yaml" "parent")
    if [[ -n "$parent" ]] && [[ "$parent" != "null" ]]; then
        debug "Loading parent profile: $parent"
        local saved_profile_name="$PROFILE_NAME"
        local saved_profile_dir="$PROFILE_DIR"
        local saved_profile_yaml="$PROFILE_YAML"
        load_profile "$parent" "$profile_type"
        # Restore current profile vars
        export PROFILE_NAME="$saved_profile_name"
        export PROFILE_DIR="$saved_profile_dir"
        export PROFILE_YAML="$saved_profile_yaml"
    fi
    
    return 0
}

# Check profile dependencies
check_profile_dependencies() {
    local profile_yaml="$1"
    
    if [[ ! -f "$profile_yaml" ]]; then
        return 0
    fi
    
    local deps_section=false
    local missing_deps=()
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^dependencies: ]]; then
            deps_section=true
            continue
        fi
        
        if $deps_section; then
            # End of dependencies section
            if [[ "$line" =~ ^[^[:space:]-] ]]; then
                break
            fi
            
            # Parse dependency
            if [[ "$line" =~ ^[[:space:]]*-[[:space:]](.+) ]]; then
                local dep="${BASH_REMATCH[1]}"
                
                # Check if it's a simple command or versioned dependency
                if [[ "$dep" =~ ^([^:]+): ]]; then
                    local cmd="${BASH_REMATCH[1]}"
                    if ! command_exists "$cmd"; then
                        missing_deps+=("$cmd")
                    fi
                else
                    if ! command_exists "$dep"; then
                        missing_deps+=("$dep")
                    fi
                fi
            fi
        fi
    done < "$profile_yaml"
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        warn "Missing dependencies for profile: ${missing_deps[*]}"
        return 1
    fi
    
    return 0
}

# Apply profile to project
apply_profile() {
    local profile_name="$1"
    local target_dir="${2:-$(pwd)}"
    local profile_type="${3:-projects}"
    
    # Load profile
    if ! load_profile "$profile_name" "$profile_type"; then
        return 1
    fi
    
    # Check dependencies
    if ! check_profile_dependencies "$PROFILE_YAML"; then
        if ! confirm "Continue without all dependencies?" "n"; then
            return 1
        fi
    fi
    
    info "Applying profile: $profile_name"
    
    # Create .claude directory if needed
    local claude_dir="$target_dir/.claude"
    if [[ -d "$PROFILE_DIR/.claude" ]]; then
        mkdir -p "$claude_dir"
        
        # Copy Claude-specific configurations
        if [[ -d "$PROFILE_DIR/.claude/agents" ]]; then
            cp -r "$PROFILE_DIR/.claude/agents" "$claude_dir/"
            success "Copied agents"
        fi
        
        if [[ -d "$PROFILE_DIR/.claude/commands" ]]; then
            cp -r "$PROFILE_DIR/.claude/commands" "$claude_dir/"
            success "Copied commands"
        fi
    fi
    
    # Copy configuration files
    shopt -s nullglob
    for config_file in "$PROFILE_DIR"/*.toml "$PROFILE_DIR"/*.yaml "$PROFILE_DIR"/*.yml "$PROFILE_DIR"/*.json "$PROFILE_DIR"/*.ini; do
        if [[ -f "$config_file" ]] && [[ "$(basename "$config_file")" != "profile.yaml" ]]; then
            cp "$config_file" "$target_dir/"
            success "Copied $(basename "$config_file")"
        fi
    done
    shopt -u nullglob
    
    # Run install script if exists
    if [[ -f "$PROFILE_DIR/install.sh" ]]; then
        # Validate install script is a regular file and within profiles directory
        local install_script="$(get_absolute_path "$PROFILE_DIR/install.sh")"
        local profiles_abs="$(get_absolute_path "$PROFILES_DIR")"
        
        if [[ ! "$install_script" =~ ^"$profiles_abs" ]]; then
            error "Install script outside allowed directory"
            return 1
        fi
        
        info "Running profile installation script..."
        (cd "$target_dir" && bash "$install_script") || {
            error "Profile installation script failed"
            return 1
        }
    fi
    
    # Copy hooks if exists
    if [[ -d "$PROFILE_DIR/hooks" ]]; then
        info "Setting up hooks..."
        
        # Pre-commit hooks
        if [[ -f "$PROFILE_DIR/hooks/pre-commit.yaml" ]]; then
            cp "$PROFILE_DIR/hooks/pre-commit.yaml" "$target_dir/.pre-commit-config.yaml"
            
            if command_exists pre-commit; then
                (cd "$target_dir" && pre-commit install)
                success "Pre-commit hooks installed"
            else
                warn "pre-commit not installed. Run 'pip install pre-commit' to enable hooks"
            fi
        fi
    fi
    
    success "Profile $profile_name applied successfully"
    return 0
}

# Detect project type
detect_project_type() {
    local dir="${1:-$(pwd)}"
    
    # Python project
    if [[ -f "$dir/pyproject.toml" ]] || [[ -f "$dir/setup.py" ]] || [[ -f "$dir/requirements.txt" ]]; then
        echo "python"
        return 0
    fi
    
    # JavaScript/Node project
    if [[ -f "$dir/package.json" ]]; then
        echo "javascript"
        return 0
    fi
    
    # Rust project
    if [[ -f "$dir/Cargo.toml" ]]; then
        echo "rust"
        return 0
    fi
    
    # Go project
    if [[ -f "$dir/go.mod" ]]; then
        echo "go"
        return 0
    fi
    
    # Default
    echo "unknown"
    return 1
}