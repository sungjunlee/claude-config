#!/usr/bin/env bash
# Worktree Launcher - Launch claude in existing worktrees via tmux/iTerm
#
# Exit codes:
#   0 - Success
#   1 - Error (missing dependencies, no worktrees, partial failures)

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
  tmux attach -t {project}-wt    # Then attach from another terminal

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
    shopt -s nullglob
    for dir in "$WORKTREES_DIR"/*/; do
        if [[ -d "$dir" && -f "$dir/.git" ]]; then
            local name=$(basename "$dir")
            local branch=$(cd "$dir" && git branch --show-current 2>/dev/null || echo "unknown")
            echo "  • $name ($branch)"
            count=$((count + 1))
        fi
    done
    shopt -u nullglob

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
            local name=$(basename "$dir")
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

            if ! tmux send-keys -t "$session_name:$name" "claude" Enter; then
                echo -e "  ${YELLOW}! $name (window created but failed to launch claude)${NC}" >&2
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
        echo -e "${YELLOW}⚠ $failures worktree(s) failed${NC}"
    fi
    if [[ $count -gt 0 ]]; then
        echo -e "${GREEN}✅ Created session '$session_name' with $count window(s)${NC}"
        echo ""
        echo -e "${BLUE}Attach from another terminal:${NC}"
        echo "  tmux attach -t $session_name"
    fi

    [[ $failures -gt 0 ]] && return 1
    return 0
}

# Check iTerm availability
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
            local name=$(basename "$dir")
            local path
            if ! path=$(cd "$dir" && pwd); then
                echo -e "  ${RED}✗ $name (directory inaccessible)${NC}" >&2
                failures=$((failures + 1))
                continue
            fi

            # Escape single quotes in path for AppleScript
            local escaped_path
            escaped_path=$(escape_applescript_path "$path")

            if [[ "$first" == true ]]; then
                # First tab: activate iTerm and ensure window exists
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
                # Subsequent tabs
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
