#!/bin/bash
# Worktree Manager - Task distribution and management tool

set -euo pipefail

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
WORKTREES_DIR=".worktrees"

# Help function
show_help() {
    cat <<EOF
Worktree Manager - Git Worktree task distribution tool

Usage: $0 {init|distribute|status|sync|launch|list|help}

Commands:
  init       - Create PLAN.md template
  distribute - Distribute tasks based on PLAN.md
  status     - Check all worktree status
  sync       - Synchronize environment files between worktrees
  launch     - Launch claude in worktrees (tmux|iterm|list)
  list       - List existing worktrees (alias for launch list)
  help       - Show this help message

Example:
  $0 init                    # Initial setup
  vim .worktrees/PLAN.md     # Edit task plan
  $0 distribute              # Distribute tasks
  $0 launch tmux             # Launch claude in tmux session
  cd .worktrees/auth         # Move to worktree
  claude                     # Run Claude

EOF
}

# Create PLAN.md template
create_plan_template() {
    mkdir -p "$WORKTREES_DIR"
    
    if [[ -f "$WORKTREES_DIR/PLAN.md" ]]; then
        echo -e "${YELLOW}⚠ PLAN.md already exists${NC}"
        read -p "Overwrite? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return
        fi
    fi
    
    cat > "$WORKTREES_DIR/PLAN.md" <<'EOF'
# Task Plan

## Task List
```bash
# Format: task-name: task description
# Example:
auth: Implement user authentication system (OAuth2.0, JWT)
payment: Implement payment module (Stripe integration)
search: Implement search feature (Elasticsearch)
```

## Common Context
- Use TypeScript
- Include test code
- Follow REST API standards
- Unified error handling

## Notes
- Each task must be independently executable
- Branch names are automatically generated as feature/task-name
- Task instructions are generated in .worktrees/tasks/ folder
EOF
    
    echo -e "${GREEN}✓ Created PLAN.md template at $WORKTREES_DIR/PLAN.md${NC}"
    echo -e "${BLUE}Next step: Edit the file and run '$0 distribute'${NC}"
}

# Copy environment files
copy_env_files() {
    local worktree_path=$1
    local root_path=$2
    
    # List of files to copy
    local env_files=(
        ".env"
        ".env.local"
        ".env.development"
        ".env.production"
        "package.json"
        "package-lock.json"
        "yarn.lock"
        "pnpm-lock.yaml"
        "tsconfig.json"
        "tsconfig.node.json"
        "vite.config.ts"
        "vite.config.js"
        "next.config.js"
        "next.config.ts"
        ".eslintrc"
        ".eslintrc.json"
        ".prettierrc"
        ".prettierrc.json"
        "prettier.config.js"
        ".nvmrc"
        ".npmrc"
        "pyproject.toml"
        "requirements.txt"
        "Pipfile"
        "Pipfile.lock"
        "Gemfile"
        "Gemfile.lock"
        "docker-compose.yml"
        "docker-compose.yaml"
    )
    
    local copied_count=0
    for file in "${env_files[@]}"; do
        if [[ -f "$root_path/$file" ]]; then
            cp "$root_path/$file" "$worktree_path/" 2>/dev/null || true
            echo "    ✓ Copied $file"
            ((copied_count++))
        fi
    done
    
    # Symlink node_modules (if exists)
    if [[ -d "$root_path/node_modules" && ! -e "$worktree_path/node_modules" ]]; then
        local abs_node_modules
        abs_node_modules="$(cd "$root_path" && pwd)"/node_modules
        ln -s "$abs_node_modules" "$worktree_path/node_modules"
        echo "    ✓ Linked node_modules"
    fi
    
    # Symlink Python venv
    if [[ -d "$root_path/venv" && ! -e "$worktree_path/venv" ]]; then
        local abs_venv
        abs_venv="$(cd "$root_path" && pwd)"/venv
        ln -s "$abs_venv" "$worktree_path/venv"
        echo "    ✓ Linked venv"
    fi
    
    if [[ $copied_count -eq 0 ]]; then
        echo "    ℹ No environment files found to copy"
    fi
}

# Distribute tasks
distribute_tasks() {
    if [[ ! -f "$WORKTREES_DIR/PLAN.md" ]]; then
        echo -e "${RED}✗ PLAN.md not found${NC}"
        echo -e "${YELLOW}Creating template...${NC}"
        create_plan_template
        return 1
    fi
    
    # Create tasks directory
    if ! mkdir -p "$WORKTREES_DIR/tasks"; then
        echo -e "${RED}✗ Failed to create $WORKTREES_DIR/tasks${NC}"
        return 1
    fi
    
    echo -e "${BLUE}📋 Parsing PLAN.md...${NC}\n"
    
    local task_count=0
    local in_block=false
    
    # Parse PLAN.md
    while IFS= read -r line; do
        if [[ "$line" =~ ^\`\`\`(bash)?[[:space:]]*$ ]]; then
            in_block=true
        elif [[ "$in_block" == true && "$line" =~ ^\`\`\`[[:space:]]*$ ]]; then
            in_block=false
        elif [[ "$in_block" == true ]]; then
            # Skip comment lines
            [[ "$line" =~ ^[[:space:]]*# ]] && continue
            if [[ "$line" =~ ^([a-z][a-z0-9-]*):\ *(.+)$ ]]; then
                local task_name="${BASH_REMATCH[1]}"
                local task_desc="${BASH_REMATCH[2]}"
            else
                continue
            fi
            
            echo -e "${BLUE}📦 Setting up: $task_name${NC}"
            echo "   Description: $task_desc"
            
            # Create worktree
            local worktree_path="$WORKTREES_DIR/$task_name"
            local branch_name="feature/$task_name"
            
            if [[ -d "$worktree_path" ]]; then
                echo -e "    ${YELLOW}⚠ Worktree already exists${NC}"
            else
                # Check if branch already exists
                if git show-ref --verify --quiet "refs/heads/$branch_name"; then
                    if ! git worktree add "$worktree_path" "$branch_name" 2>&1 | grep -q .; then
                        echo "    ✓ Added worktree (existing branch)"
                    else
                        echo -e "    ${YELLOW}⚠ Could not add worktree for $branch_name (branch may be checked out elsewhere)${NC}"
                    fi
                else
                    if ! git worktree add "$worktree_path" -b "$branch_name" 2>&1 | grep -q "fatal"; then
                        echo "    ✓ Created worktree (new branch)"
                    else
                        echo -e "    ${RED}✗ Failed to create worktree/branch $branch_name${NC}"
                    fi
                fi
            fi
            
            # Copy environment files
            echo "    📄 Copying environment files..."
            copy_env_files "$worktree_path" "."
            
            # Generate task instructions
            cat > "$WORKTREES_DIR/tasks/$task_name.md" <<EOF
# Task: $task_name

## 📋 Task Description
$task_desc

## 🚀 Getting Started

1. Move to worktree:
\`\`\`bash
cd $worktree_path
\`\`\`

2. Run Claude:
\`\`\`bash
claude
\`\`\`

3. Refer to this file's task description and start implementation

## 📁 File Locations
- **Working Directory**: \`$worktree_path\`
- **Branch**: \`$branch_name\`
- **Common Context**: \`../CONTEXT.md\`
- **Task Plan**: \`../PLAN.md\`

## ✅ Completion Criteria
- [ ] Feature implementation complete
- [ ] Write test code
- [ ] Update documentation
- [ ] Prepare for code review

## 📝 Notes
- Environment files (.env, etc.) already copied
- node_modules is symlinked
- Can work independently from other worktrees

---
Generated: $(date '+%Y-%m-%d %H:%M:%S')
EOF
            echo "    ✓ Created task file: tasks/$task_name.md"
            echo ""
            
            ((task_count++))
        fi
    done < "$WORKTREES_DIR/PLAN.md"
    
    if [[ $task_count -eq 0 ]]; then
        echo -e "${YELLOW}⚠ No tasks found in PLAN.md${NC}"
        echo "Please check the format in PLAN.md"
        return 1
    fi
    
    # Completion message
    echo -e "${GREEN}✅ Task distribution complete! ($task_count tasks)${NC}\n"
    echo -e "${BLUE}Next steps:${NC}"
    echo "Run Claude in each worktree:"
    echo ""
    
    # Display list of created worktrees
    for dir in "$WORKTREES_DIR"/*/; do
        if [[ -d "$dir" && -f "$dir/.git" ]]; then
            local task_name
            task_name="$(basename "$dir")"
            echo "  cd .worktrees/$task_name && claude"
        fi
    done
    
    echo ""
    echo -e "${YELLOW}Tip:${NC} Run separately in each terminal/tab for parallel work"
}

# Check status
show_status() {
    echo -e "${BLUE}═══════════════════════════════${NC}"
    echo -e "${BLUE}     Worktree Status${NC}"
    echo -e "${BLUE}═══════════════════════════════${NC}\n"
    
    if [[ ! -d "$WORKTREES_DIR" ]]; then
        echo -e "${YELLOW}No worktrees found${NC}"
        echo "Run '$0 init' to get started"
        return
    fi
    
    local worktree_found=false
    
    for dir in "$WORKTREES_DIR"/*/; do
        if [[ -d "$dir" && -f "$dir/.git" ]]; then
            worktree_found=true
            local task_name=$(basename "$dir")
            
            # Change to working directory
            pushd "$dir" > /dev/null
            
            local branch=$(git branch --show-current)
            local changes=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
            local commits=$(git rev-list --count HEAD 2>/dev/null || echo "0")
            local last_commit=$(git log -1 --pretty=format:"%s" 2>/dev/null || echo "No commits yet")
            
            # Determine status icon
            local status_icon="🔄"
            if [[ $changes -eq 0 && $commits -gt 0 ]]; then
                status_icon="✅"
            elif [[ $changes -gt 0 ]]; then
                status_icon="📝"
            fi
            
            echo -e "${GREEN}$status_icon $task_name${NC}"
            echo "   Branch: $branch"
            echo "   Changes: $changes file(s)"
            echo "   Commits: $commits"
            echo "   Last: $last_commit"
            
            # Check task file
            if [[ -f "../tasks/$task_name.md" ]]; then
                echo "   Task: ../tasks/$task_name.md"
            fi
            
            echo ""
            
            popd > /dev/null
        fi
    done
    
    if [[ "$worktree_found" == false ]]; then
        echo -e "${YELLOW}No worktrees found${NC}"
        echo "Run '$0 distribute' after creating PLAN.md"
    fi
    
    # Git worktree list summary
    echo -e "${BLUE}───────────────────────────────${NC}"
    echo -e "${BLUE}Git Worktree Summary:${NC}"
    git worktree list 2>/dev/null | grep "$WORKTREES_DIR" || echo "No git worktrees found"
}

# Synchronize environment files
sync_env_files() {
    echo -e "${BLUE}🔄 Syncing environment files...${NC}\n"
    
    if [[ ! -d "$WORKTREES_DIR" ]]; then
        echo -e "${YELLOW}No worktrees found${NC}"
        return
    fi
    
    local sync_count=0
    
    # List of files to synchronize
    local sync_files=(
        ".env"
        ".env.local"
        "package.json"
    )
    
    for dir in "$WORKTREES_DIR"/*/; do
        if [[ -d "$dir" && -f "$dir/.git" ]]; then
            local task_name=$(basename "$dir")
            echo -e "${BLUE}Checking: $task_name${NC}"
            
            for file in "${sync_files[@]}"; do
                if [[ -f "$file" ]]; then
                    if [[ ! -f "$dir/$file" ]] || [[ "$file" -nt "$dir/$file" ]]; then
                        cp "$file" "$dir/"
                        echo "  ✓ Updated $file"
                        ((sync_count++))
                    fi
                fi
            done
            
            echo ""
        fi
    done
    
    if [[ $sync_count -eq 0 ]]; then
        echo -e "${GREEN}✓ All files are up to date${NC}"
    else
        echo -e "${GREEN}✅ Synced $sync_count file(s)${NC}"
        echo -e "${YELLOW}Note: Run 'npm install' in worktrees if package.json was updated${NC}"
    fi
}

# List existing worktrees
list_worktrees() {
    echo -e "${BLUE}📂 Worktrees in $WORKTREES_DIR:${NC}"
    echo ""

    if [[ ! -d "$WORKTREES_DIR" ]]; then
        echo -e "${YELLOW}No worktrees directory found${NC}"
        return 1
    fi

    local count=0
    shopt -s nullglob
    for dir in "$WORKTREES_DIR"/*/; do
        if [[ -d "$dir" && -f "$dir/.git" ]]; then
            local name
            name=$(basename "$dir")
            local branch
            branch=$(cd "$dir" && git branch --show-current 2>/dev/null || echo "unknown")
            echo "  • $name ($branch)"
            count=$((count + 1))
        fi
    done
    shopt -u nullglob

    if [[ $count -eq 0 ]]; then
        echo -e "${YELLOW}No worktrees found${NC}"
        echo "Use '$0 distribute' to create worktrees first"
        return 1
    fi

    echo ""
    echo -e "${GREEN}Total: $count worktree(s)${NC}"
}

# Check tmux availability
check_tmux() {
    if ! command -v tmux &> /dev/null; then
        echo -e "${RED}✗ tmux not installed${NC}"
        echo "Install: brew install tmux (macOS) or apt install tmux (Linux)"
        return 1
    fi
}

# Launch tmux session
launch_tmux() {
    check_tmux || return 1

    if [[ ! -d "$WORKTREES_DIR" ]]; then
        echo -e "${RED}✗ No worktrees directory${NC}"
        return 1
    fi

    local project_name
    project_name=$(basename "$(pwd)")
    # Sanitize session name: only allow alphanumeric, underscore, hyphen
    project_name="${project_name//[^a-zA-Z0-9_-]/_}"
    local session_name="${project_name}-wt"

    # Check existing session
    if tmux has-session -t "$session_name" 2>/dev/null; then
        echo -e "${YELLOW}⚠ Session '$session_name' already exists${NC}"
        echo ""
        echo "  Attach:  tmux attach -t $session_name"
        echo "  Kill:    tmux kill-session -t $session_name"
        return 0
    fi

    echo -e "${BLUE}🚀 Creating tmux session: $session_name${NC}"

    local first=true
    local count=0
    local failures=0

    shopt -s nullglob
    for dir in "$WORKTREES_DIR"/*/; do
        if [[ -d "$dir" && -f "$dir/.git" ]]; then
            local name
            name=$(basename "$dir")
            local path
            if ! path=$(cd "$dir" && pwd); then
                echo -e "  ${RED}✗ $name (directory inaccessible)${NC}" >&2
                failures=$((failures + 1))
                continue
            fi

            if [[ "$first" == true ]]; then
                if ! tmux new-session -d -s "$session_name" -n "$name" -c "$path"; then
                    echo -e "  ${RED}✗ $name (failed to create session)${NC}" >&2
                    failures=$((failures + 1))
                    continue
                fi
                first=false
            else
                if ! tmux new-window -t "$session_name" -n "$name" -c "$path"; then
                    echo -e "  ${RED}✗ $name (failed to create window)${NC}" >&2
                    failures=$((failures + 1))
                    continue
                fi
            fi

            if ! tmux send-keys -t "$session_name:$name" "claude" C-m; then
                echo -e "  ${YELLOW}⚠ $name (failed to start claude)${NC}" >&2
                failures=$((failures + 1))
                continue
            fi

            echo "  ✓ $name"
            count=$((count + 1))
        fi
    done
    shopt -u nullglob

    if [[ $count -eq 0 && $failures -eq 0 ]]; then
        echo -e "${YELLOW}No worktrees to launch${NC}"
        return 1
    fi

    echo ""
    if [[ $failures -gt 0 ]]; then
        echo -e "${YELLOW}⚠ $failures worktree(s) failed to launch${NC}"
    fi
    if [[ $count -gt 0 ]]; then
        echo -e "${GREEN}✅ Launched $count worktree(s) in tmux${NC}"
        echo "Attach: tmux attach -t $session_name"
    fi

    [[ $failures -gt 0 ]] && return 1
    return 0
}

# Check iTerm availability (macOS only)
check_iterm() {
    if [[ "$(uname)" != "Darwin" ]]; then
        echo -e "${RED}✗ iTerm only available on macOS${NC}"
        return 1
    fi

    if pgrep -x "iTerm2" >/dev/null 2>&1 || pgrep -x "iTerm" >/dev/null 2>&1; then
        return 0
    fi

    if command -v mdfind >/dev/null 2>&1; then
        if mdfind 'kMDItemCFBundleIdentifier == "com.googlecode.iterm2"' | head -n 1 | grep -q .; then
            return 0
        fi
    fi

    if [[ -d "/Applications/iTerm.app" || -d "$HOME/Applications/iTerm.app" ]]; then
        return 0
    fi

    if osascript -e 'id of application id "com.googlecode.iterm2"' >/dev/null 2>&1; then
        return 0
    fi

    echo -e "${RED}✗ iTerm2 not installed${NC}"
    echo "Download: https://iterm2.com/"
    return 1
}

# Escape single quotes for AppleScript
escape_applescript_path() {
    local path="$1"
    # Replace ' with '\'' (end quote, escaped quote, start quote)
    echo "${path//\'/\'\\\'\'}"
}

# Launch iTerm tabs
launch_iterm() {
    check_iterm || return 1

    if [[ ! -d "$WORKTREES_DIR" ]]; then
        echo -e "${RED}✗ No worktrees directory${NC}"
        return 1
    fi

    echo -e "${BLUE}🚀 Opening iTerm tabs...${NC}"

    local first=true
    local count=0
    local failures=0
    local error_output

    shopt -s nullglob
    for dir in "$WORKTREES_DIR"/*/; do
        if [[ -d "$dir" && -f "$dir/.git" ]]; then
            local name
            name=$(basename "$dir")
            local path
            if ! path=$(cd "$dir" && pwd); then
                echo -e "  ${RED}✗ $name (directory inaccessible)${NC}" >&2
                failures=$((failures + 1))
                continue
            fi

            local escaped_path
            escaped_path=$(escape_applescript_path "$path")

            if [[ "$first" == true ]]; then
                if ! error_output=$(osascript <<EOF 2>&1
tell application id "com.googlecode.iterm2"
    activate
    if (count of windows) = 0 then
        create window with default profile
    end if
    tell current window
        tell current session
            write text "cd '${escaped_path}' && claude"
        end tell
    end tell
end tell
EOF
                ); then
                    echo -e "  ${RED}✗ $name (failed: ${error_output:-unknown error})${NC}" >&2
                    failures=$((failures + 1))
                    continue
                fi
                first=false
            else
                if ! error_output=$(osascript <<EOF 2>&1
tell application id "com.googlecode.iterm2"
    tell current window
        create tab with default profile
        tell current session
            write text "cd '${escaped_path}' && claude"
        end tell
    end tell
end tell
EOF
                ); then
                    echo -e "  ${RED}✗ $name (failed: ${error_output:-unknown error})${NC}" >&2
                    failures=$((failures + 1))
                    continue
                fi
            fi

            echo "  ✓ $name"
            count=$((count + 1))
        fi
    done
    shopt -u nullglob

    if [[ $count -eq 0 && $failures -eq 0 ]]; then
        echo -e "${YELLOW}No worktrees to launch${NC}"
        return 1
    fi

    echo ""
    if [[ $failures -gt 0 ]]; then
        echo -e "${YELLOW}⚠ $failures worktree(s) failed to open${NC}"
    fi
    if [[ $count -gt 0 ]]; then
        echo -e "${GREEN}✅ Opened $count iTerm tab(s)${NC}"
    fi

    [[ $failures -gt 0 ]] && return 1
    return 0
}

launch_worktrees() {
    case "${1:-list}" in
        tmux)
            launch_tmux
            ;;
        iterm)
            launch_iterm
            ;;
        list|"")
            list_worktrees
            ;;
        *)
            echo -e "${YELLOW}Usage:${NC} $0 launch {tmux|iterm|list}"
            return 1
            ;;
    esac
}

# Main function
main() {
    # Check Git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}✗ Not a git repository${NC}"
        echo "Please run this script in a git repository"
        exit 1
    fi
    
    case "${1:-help}" in
        init)
            create_plan_template
            ;;
        distribute)
            distribute_tasks
            ;;
        status)
            show_status
            ;;
        sync)
            sync_env_files
            ;;
        launch)
            launch_worktrees "${2:-}"
            ;;
        tmux|iterm|list)
            launch_worktrees "$1"
            ;;
        help|*)
            show_help
            ;;
    esac
}

# Execute script
main "$@"
