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
    if ! mkdir -p "$WORKTREES_DIR"; then
        echo -e "${RED}✗ Failed to create $WORKTREES_DIR${NC}"
        return 1
    fi
    
    if [[ -f "$WORKTREES_DIR/PLAN.md" ]]; then
        echo -e "${YELLOW}⚠ PLAN.md already exists${NC}"
        if [[ -t 0 ]]; then
            read -p "Overwrite? (y/n) " -n 1 -r
            echo
        else
            echo -e "${YELLOW}⚠ Non-interactive shell; aborting overwrite${NC}"
            return 1
        fi
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
    
    if ! cat > "$WORKTREES_DIR/PLAN.md" <<'EOF'; then
        echo -e "${RED}✗ Failed to write $WORKTREES_DIR/PLAN.md${NC}"
        return 1
    fi
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
    local has_error=0
    for file in "${env_files[@]}"; do
        if [[ -f "$root_path/$file" ]]; then
            if [[ -f "$worktree_path/$file" ]]; then
                echo "    ℹ Skipped $file (already exists)"
                continue
            fi
            if cp "$root_path/$file" "$worktree_path/"; then
                echo "    ✓ Copied $file"
                ((copied_count++))
            else
                echo "    ⚠ Failed to copy $file"
                has_error=1
            fi
        fi
    done
    return "$has_error"
    # Symlink node_modules (DISABLED: Too risky for shared state)
    # if [[ -d "$root_path/node_modules" && ! -e "$worktree_path/node_modules" ]]; then
    #     local abs_node_modules
    #     abs_node_modules="$(cd "$root_path" && pwd)"/node_modules
    #     if ln -s "$abs_node_modules" "$worktree_path/node_modules"; then
    #         echo "    ✓ Linked node_modules"
    #     else
    #         echo "    ⚠ Failed to link node_modules"
    #     fi
    # fi
    
    # Symlink Python venv
    if [[ -d "$root_path/venv" && ! -e "$worktree_path/venv" ]]; then
        local abs_venv
        abs_venv="$(cd "$root_path" && pwd)"/venv
        if ln -s "$abs_venv" "$worktree_path/venv"; then
            echo "    ✓ Linked venv"
        else
            echo "    ⚠ Failed to link venv"
        fi
    fi
    
    if [[ $copied_count -eq 0 ]]; then
        echo "    ℹ No environment files found to copy"
    fi
}

# Distribute tasks
ensure_plan_file() {
    if [[ ! -f "$WORKTREES_DIR/PLAN.md" ]]; then
        echo -e "${RED}✗ PLAN.md not found${NC}"
        echo -e "${YELLOW}Creating template...${NC}"
        create_plan_template
        return 1
    fi
}

ensure_tasks_dir() {
    if ! mkdir -p "$WORKTREES_DIR/tasks"; then
        echo -e "${RED}✗ Failed to create $WORKTREES_DIR/tasks${NC}"
        return 1
    fi
}

parse_task_line() {
    local line="$1"
    if [[ "$line" =~ ^([A-Za-z][A-Za-z0-9_-]*):\ *(.+)$ ]]; then
        TASK_NAME="$(echo "${BASH_REMATCH[1]}" | tr '[:upper:]' '[:lower:]')"
        TASK_DESC="${BASH_REMATCH[2]}"
        return 0
    fi
    return 1
}

create_worktree_for_task() {
    local worktree_path="$1"
    local branch_name="$2"
    if [[ -d "$worktree_path" ]]; then
        echo -e "    ${YELLOW}⚠ Worktree already exists${NC}"
        return 0
    fi
    local output=""
    if git show-ref --verify --quiet "refs/heads/$branch_name"; then
        if output=$(git worktree add "$worktree_path" "$branch_name" 2>&1); then
            echo "    ✓ Added worktree (existing branch)"
            return 0
        fi
        echo -e "    ${YELLOW}⚠ Could not add worktree for $branch_name${NC}"
    else
        if output=$(git worktree add "$worktree_path" -b "$branch_name" 2>&1); then
            echo "    ✓ Created worktree (new branch)"
            return 0
        fi
        echo -e "    ${RED}✗ Failed to create worktree/branch $branch_name${NC}"
    fi
    [[ -n "$output" ]] && echo "      ${output%%$'\n'*}"
    return 1
}

write_task_file() {
    local task_name="$1"
    local task_desc="$2"
    local worktree_path="$3"
    local branch_name="$4"
    if ! cat > "$WORKTREES_DIR/tasks/$task_name.md" <<EOF; then
        echo -e "    ${RED}✗ Failed to write task file for $task_name${NC}"
        echo ""
        return 1
    fi
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
}

handle_task() {
    local task_name="$1"
    local task_desc="$2"
    local worktree_path="$WORKTREES_DIR/$task_name"
    local branch_name="feature/$task_name"

    echo -e "${BLUE}📦 Setting up: $task_name${NC}"
    echo "   Description: $task_desc"

    if ! create_worktree_for_task "$worktree_path" "$branch_name"; then
        echo ""
        return 1
    fi

    echo "    📄 Copying environment files..."
    if ! copy_env_files "$worktree_path" "."; then
        echo "    ⚠ Environment file copy had failures"
    fi
    write_task_file "$task_name" "$task_desc" "$worktree_path" "$branch_name"
}

show_distribution_summary() {
    local task_count="$1"
    echo -e "${GREEN}✅ Task distribution complete! ($task_count tasks)${NC}\n"
    echo -e "${BLUE}Next steps:${NC}"
    echo "Run Claude in each worktree:"
    echo ""
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

parse_plan_tasks() {
    local in_block=false
    TASK_COUNT=0
    while IFS= read -r line; do
        if [[ "$line" =~ ^\`\`\`(bash)?[[:space:]]*$ ]]; then
            in_block=true
        elif [[ "$in_block" == true && "$line" =~ ^\`\`\`[[:space:]]*$ ]]; then
            in_block=false
        elif [[ "$in_block" == true ]]; then
            [[ "$line" =~ ^[[:space:]]*# ]] && continue
            parse_task_line "$line" || continue
            if handle_task "$TASK_NAME" "$TASK_DESC"; then
                TASK_COUNT=$((TASK_COUNT + 1))
            fi
        fi
    done < "$WORKTREES_DIR/PLAN.md"
}

distribute_tasks() {
    ensure_plan_file || return 1
    ensure_tasks_dir || return 1

    echo -e "${BLUE}📋 Parsing PLAN.md...${NC}\n"
    parse_plan_tasks

    if [[ $TASK_COUNT -eq 0 ]]; then
        echo -e "${YELLOW}⚠ No tasks found in PLAN.md${NC}"
        echo "Please check the format in PLAN.md"
        return 1
    fi

    show_distribution_summary "$TASK_COUNT"
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
            local task_name
            task_name=$(basename "$dir")

            if ! git -C "$dir" rev-parse --git-dir > /dev/null 2>&1; then
                echo -e "${YELLOW}⚠ Skipping $task_name (invalid git worktree)${NC}"
                continue
            fi

            local branch
            branch=$(git -C "$dir" symbolic-ref -q --short HEAD 2>/dev/null \
                || git -C "$dir" rev-parse --short HEAD 2>/dev/null \
                || echo "detached")
            local changes
            changes=$(git -C "$dir" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
            local commits
            commits=$(git -C "$dir" rev-list --count HEAD 2>/dev/null || echo "0")
            local last_commit
            last_commit=$(git -C "$dir" log -1 --pretty=format:"%s" 2>/dev/null || echo "No commits yet")

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
            if [[ -f "$WORKTREES_DIR/tasks/$task_name.md" ]]; then
                echo "   Task: ../tasks/$task_name.md"
            fi

            echo ""
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
            local task_name
            task_name=$(basename "$dir")

            if ! git -C "$dir" rev-parse --git-dir > /dev/null 2>&1; then
                echo -e "${YELLOW}⚠ Skipping $task_name (invalid git worktree)${NC}"
                continue
            fi

            echo -e "${BLUE}Checking: $task_name${NC}"
            local updated=0
            local skipped=0
            local checked=0
            local status_ok=true
            
            for file in "${sync_files[@]}"; do
                if [[ -f "$file" ]]; then
                    checked=$((checked + 1))
                    local dest="$dir/$file"

                    if [[ -f "$dest" ]]; then
                        local status_output
                        if ! status_output=$(git -C "$dir" status --porcelain -- "$file" 2>&1); then
                            echo "  ⚠ Unable to check git status for $file; skipping worktree"
                            skipped=$((skipped + 1))
                            status_ok=false
                            break
                        fi
                        if [[ -n "$status_output" ]]; then
                            echo "  ⚠ $file differs - skipping (has local changes)"
                            skipped=$((skipped + 1))
                            continue
                        fi
                        if cmp -s "$file" "$dest"; then
                            continue
                        fi
                    fi

                    if cp "$file" "$dest"; then
                        echo "  ✓ Updated $file"
                        updated=$((updated + 1))
                        sync_count=$((sync_count + 1))
                    else
                        echo "  ⚠ Failed to update $file"
                    fi
                fi
            done

            if [[ "$status_ok" == false ]]; then
                echo "  ⚠ Skipped remaining files due to git status error"
                echo ""
                continue
            fi

            if [[ $checked -gt 0 && $updated -eq 0 && $skipped -eq 0 ]]; then
                echo "  ✓ All files up to date"
            fi
            
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
            branch=$(git -C "$dir" symbolic-ref -q --short HEAD 2>/dev/null \
                || git -C "$dir" rev-parse --short HEAD 2>/dev/null \
                || echo "detached")
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

tmux_session_name() {
    local project_name
    project_name=$(basename "$(pwd)")
    project_name="${project_name//[^a-zA-Z0-9_-]/_}"
    echo "${project_name}-wt"
}

tmux_add_window() {
    local session="$1"
    local name="$2"
    local path="$3"
    local is_first="$4"
    if [[ "$is_first" == true ]]; then
        tmux new-session -d -s "$session" -n "$name" -c "$path"
    else
        tmux new-window -t "$session" -n "$name" -c "$path"
    fi
}

tmux_launch_worktrees() {
    local session="$1"
    TMUX_FIRST=true
    TMUX_COUNT=0
    TMUX_FAILURES=0
    TMUX_WARNINGS=0
    shopt -s nullglob
    for dir in "$WORKTREES_DIR"/*/; do
        if [[ -d "$dir" && -f "$dir/.git" ]]; then
            local name
            name=$(basename "$dir")
            local path
            if ! path=$(cd "$dir" && pwd); then
                echo -e "  ${RED}✗ $name (directory inaccessible)${NC}" >&2
                TMUX_FAILURES=$((TMUX_FAILURES + 1))
                continue
            fi
            if ! tmux_add_window "$session" "$name" "$path" "$TMUX_FIRST"; then
                echo -e "  ${RED}✗ $name (failed to create window)${NC}" >&2
                TMUX_FAILURES=$((TMUX_FAILURES + 1))
                continue
            fi
            TMUX_FIRST=false
            TMUX_COUNT=$((TMUX_COUNT + 1))
            if ! tmux send-keys -t "$session:$name" "claude" C-m; then
                echo -e "  ${YELLOW}⚠ $name (window created, failed to start claude)${NC}" >&2
                TMUX_WARNINGS=$((TMUX_WARNINGS + 1))
            else
                echo "  ✓ $name"
            fi
        fi
    done
    shopt -u nullglob
}

tmux_summary() {
    local session="$1"
    if [[ $TMUX_COUNT -eq 0 && $TMUX_FAILURES -eq 0 ]]; then
        echo -e "${YELLOW}No worktrees to launch${NC}"
        return 1
    fi
    echo ""
    if [[ $TMUX_FAILURES -gt 0 ]]; then
        echo -e "${YELLOW}⚠ $TMUX_FAILURES worktree(s) failed to launch${NC}"
    fi
    if [[ $TMUX_WARNINGS -gt 0 ]]; then
        echo -e "${YELLOW}⚠ $TMUX_WARNINGS worktree(s) created without starting claude${NC}"
    fi
    if [[ $TMUX_COUNT -gt 0 ]]; then
        echo -e "${GREEN}✅ Launched $TMUX_COUNT worktree(s) in tmux${NC}"
        echo "Attach: tmux attach -t $session"
    fi
    [[ $TMUX_FAILURES -gt 0 ]] && return 1
}

# Launch tmux session
launch_tmux() {
    check_tmux || return 1

    if [[ ! -d "$WORKTREES_DIR" ]]; then
        echo -e "${RED}✗ No worktrees directory${NC}"
        return 1
    fi

    local session_name
    session_name="$(tmux_session_name)"

    # Check existing session
    if tmux has-session -t "$session_name" 2>/dev/null; then
        echo -e "${YELLOW}⚠ Session '$session_name' already exists${NC}"
        echo ""
        echo "  Attach:  tmux attach -t $session_name"
        echo "  Kill:    tmux kill-session -t $session_name"
        return 0
    fi

    echo -e "${BLUE}🚀 Creating tmux session: $session_name${NC}"

    tmux_launch_worktrees "$session_name"
    tmux_summary "$session_name"
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
