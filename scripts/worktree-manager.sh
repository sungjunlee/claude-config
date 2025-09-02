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

Usage: $0 {init|distribute|status|sync|help}

Commands:
  init       - Create PLAN.md template
  distribute - Distribute tasks based on PLAN.md
  status     - Check all worktree status
  sync       - Synchronize environment files between worktrees
  help       - Show this help message

Example:
  $0 init                    # Initial setup
  vim .worktrees/PLAN.md     # Edit task plan
  $0 distribute              # Distribute tasks
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
        local abs_node_modules=$(cd "$root_path" && pwd)/node_modules
        ln -s "$abs_node_modules" "$worktree_path/node_modules"
        echo "    ✓ Linked node_modules"
    fi
    
    # Symlink Python venv
    if [[ -d "$root_path/venv" && ! -e "$worktree_path/venv" ]]; then
        local abs_venv=$(cd "$root_path" && pwd)/venv
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
    mkdir -p "$WORKTREES_DIR/tasks"
    
    echo -e "${BLUE}📋 Parsing PLAN.md...${NC}\n"
    
    local task_count=0
    local in_block=false
    
    # Parse PLAN.md
    while IFS= read -r line; do
        if [[ "$line" == '```bash' ]]; then
            in_block=true
        elif [[ "$line" == '```' ]]; then
            in_block=false
        elif [[ "$in_block" == true ]] && [[ "$line" =~ ^([a-z][a-z0-9-]*):\ *(.+)$ ]]; then
            local task_name="${BASH_REMATCH[1]}"
            local task_desc="${BASH_REMATCH[2]}"
            
            # Skip comment lines
            if [[ "$line" =~ ^#.*$ ]]; then
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
                    git worktree add "$worktree_path" "$branch_name" 2>/dev/null
                    echo "    ✓ Added worktree (existing branch)"
                else
                    git worktree add "$worktree_path" -b "$branch_name" 2>/dev/null
                    echo "    ✓ Created worktree (new branch)"
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
- **Common Context**: \`../$WORKTREES_DIR/CONTEXT.md\`
- **Task Plan**: \`../$WORKTREES_DIR/PLAN.md\`

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
            local task_name=$(basename "$dir")
            echo "  cd $dir && claude"
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
        help|*)
            show_help
            ;;
    esac
}

# Execute script
main "$@"