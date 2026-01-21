#!/bin/bash
# Worktree Launcher - Launch claude in existing worktrees via tmux/iTerm

set -euo pipefail

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
WORKTREES_DIR=".worktrees"

show_help() {
    cat <<EOF
Worktree Launcher - Launch claude in existing worktrees

Usage: $0 {tmux|iterm|list|help}

Commands:
  tmux   - Launch claude in tmux session (background, attach manually)
  iterm  - Launch claude in iTerm tabs (macOS only)
  list   - List existing worktrees
  help   - Show this help

Examples:
  $0 tmux              # Create tmux session with all worktrees
  tmux attach -t wt    # Then attach from another terminal

  $0 iterm             # Open iTerm tabs for all worktrees

EOF
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
    for dir in "$WORKTREES_DIR"/*/; do
        if [[ -d "$dir" && -f "$dir/.git" ]]; then
            local name=$(basename "$dir")
            local branch=$(cd "$dir" && git branch --show-current 2>/dev/null || echo "unknown")
            echo "  • $name ($branch)"
            ((count++))
        fi
    done

    if [[ $count -eq 0 ]]; then
        echo -e "${YELLOW}No worktrees found${NC}"
        echo "Use /wt-distribute to create worktrees first"
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

    local project_name=$(basename "$(pwd)")
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

    for dir in "$WORKTREES_DIR"/*/; do
        if [[ -d "$dir" && -f "$dir/.git" ]]; then
            local name=$(basename "$dir")
            local path=$(cd "$dir" && pwd)

            if [[ "$first" == true ]]; then
                tmux new-session -d -s "$session_name" -n "$name" -c "$path"
                first=false
            else
                tmux new-window -t "$session_name" -n "$name" -c "$path"
            fi

            tmux send-keys -t "$session_name:$name" "claude" Enter
            echo "  ✓ $name"
            ((count++))
        fi
    done

    if [[ $count -eq 0 ]]; then
        echo -e "${YELLOW}No worktrees to launch${NC}"
        return 1
    fi

    echo ""
    echo -e "${GREEN}✅ Created session '$session_name' with $count windows${NC}"
    echo ""
    echo -e "${BLUE}Attach from another terminal:${NC}"
    echo "  tmux attach -t $session_name"
}

# Check iTerm availability
check_iterm() {
    if [[ "$(uname)" != "Darwin" ]]; then
        echo -e "${RED}✗ iTerm only available on macOS${NC}"
        return 1
    fi

    if [[ ! -d "/Applications/iTerm.app" ]]; then
        echo -e "${RED}✗ iTerm2 not installed${NC}"
        echo "Download: https://iterm2.com/"
        return 1
    fi
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

    for dir in "$WORKTREES_DIR"/*/; do
        if [[ -d "$dir" && -f "$dir/.git" ]]; then
            local name=$(basename "$dir")
            local path=$(cd "$dir" && pwd)

            if [[ "$first" == true ]]; then
                osascript <<EOF
tell application "iTerm2"
    activate
    tell current window
        tell current session
            write text "cd '$path' && claude"
        end tell
    end tell
end tell
EOF
                first=false
            else
                osascript <<EOF
tell application "iTerm2"
    tell current window
        create tab with default profile
        tell current session
            write text "cd '$path' && claude"
        end tell
    end tell
end tell
EOF
            fi

            echo "  ✓ $name"
            ((count++))
        fi
    done

    if [[ $count -eq 0 ]]; then
        echo -e "${YELLOW}No worktrees to launch${NC}"
        return 1
    fi

    echo ""
    echo -e "${GREEN}✅ Opened $count iTerm tabs${NC}"
}

# Main
main() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}✗ Not a git repository${NC}"
        exit 1
    fi

    case "${1:-help}" in
        tmux)   launch_tmux ;;
        iterm)  launch_iterm ;;
        list)   list_worktrees ;;
        help|*) show_help ;;
    esac
}

main "$@"
