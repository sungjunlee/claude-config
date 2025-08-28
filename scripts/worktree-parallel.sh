#!/bin/bash

# Git Worktree Parallel Execution Orchestrator
# 여러 Claude Code 인스턴스를 병렬로 실행하는 핵심 스크립트

set -euo pipefail

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 설정
WORKTREE_BASE_DIR="../${PWD##*/}-worktrees"
MAX_PARALLEL_SESSIONS=5
BASE_PORT=3000
BASE_DB_PORT=5432

# 터미널 감지
detect_terminal() {
    if command -v ghostty &> /dev/null; then
        echo "ghostty"
    elif [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
        echo "iterm"
    elif command -v wezterm &> /dev/null; then
        echo "wezterm"
    else
        echo "terminal"  # 기본 터미널
    fi
}

# 포트 오프셋 계산 (충돌 방지)
calculate_port_offset() {
    local branch_name=$1
    echo $(($(echo "$branch_name" | cksum | cut -d' ' -f1) % 100))
}

# Worktree 환경 설정 파일 생성
create_worktree_env() {
    local worktree_path=$1
    local branch_name=$2
    local task_description=$3
    local port_offset=$4
    
    cat > "$worktree_path/.env.worktree" <<EOF
# Worktree Environment Configuration
WORKTREE_BRANCH=$branch_name
WORKTREE_TASK="$task_description"
DEV_PORT=$((BASE_PORT + port_offset))
API_PORT=$((8000 + port_offset))
DB_PORT=$((BASE_DB_PORT + port_offset))
REDIS_PORT=$((6379 + port_offset))
COMPOSE_PROJECT_NAME=${PWD##*/}_${branch_name}
CLAUDE_SESSION_ID=$(uuidgen || cat /proc/sys/kernel/random/uuid)
EOF

    # Claude Code 작업 지시서 생성
    cat > "$worktree_path/CLAUDE_TASK.md" <<EOF
# Claude Code Task Instructions

## Branch: $branch_name
## Task: $task_description

### Environment
- Development Port: $((BASE_PORT + port_offset))
- API Port: $((8000 + port_offset))
- Database Port: $((BASE_DB_PORT + port_offset))

### Your Mission
1. Complete the task: "$task_description"
2. All changes should be made in this worktree
3. Use the configured ports to avoid conflicts
4. Commit your changes when complete
5. Signal completion by creating TASK_COMPLETE.md

### Important
- You are working in an isolated worktree
- Other Claude instances may be working in parallel
- Do not modify files outside this worktree
- Test your changes thoroughly
EOF
}

# 단일 worktree 생성 및 Claude 실행
create_single_worktree() {
    local branch_name=$1
    local task_description=${2:-"Work on $branch_name"}
    local worktree_path="$WORKTREE_BASE_DIR/$branch_name"
    local port_offset=$(calculate_port_offset "$branch_name")
    
    echo -e "${BLUE}Creating worktree for: $branch_name${NC}"
    
    # Worktree 생성
    if git worktree add "$worktree_path" -b "$branch_name" 2>/dev/null || \
       git worktree add "$worktree_path" "$branch_name" 2>/dev/null; then
        echo -e "${GREEN}✓ Worktree created: $worktree_path${NC}"
    else
        echo -e "${RED}Failed to create worktree${NC}"
        return 1
    fi
    
    # 환경 설정
    create_worktree_env "$worktree_path" "$branch_name" "$task_description" "$port_offset"
    
    # .env 파일 복사 (있는 경우)
    if [[ -f .env ]]; then
        cp .env "$worktree_path/.env.base"
    fi
    
    echo -e "${GREEN}✓ Environment configured (ports: $((BASE_PORT + port_offset)), $((BASE_DB_PORT + port_offset)))${NC}"
    
    # Claude Code 실행
    launch_claude_in_terminal "$worktree_path" "$branch_name"
}

# 터미널에서 Claude 실행
launch_claude_in_terminal() {
    local worktree_path=$1
    local branch_name=$2
    local terminal=$(detect_terminal)
    
    echo -e "${YELLOW}Launching Claude Code in $terminal for: $branch_name${NC}"
    
    case $terminal in
        ghostty)
            # Ghostty는 빠르고 현대적인 터미널
            ghostty --title="Claude: $branch_name" \
                    --working-directory="$worktree_path" \
                    --command="claude" &
            ;;
        iterm)
            # iTerm2 AppleScript
            osascript <<EOF
tell application "iTerm"
    create window with default profile
    tell current session of current window
        write text "cd '$worktree_path' && claude"
        set name to "Claude: $branch_name"
    end tell
end tell
EOF
            ;;
        wezterm)
            # WezTerm CLI
            wezterm cli spawn --cwd "$worktree_path" -- claude &
            ;;
        *)
            # 기본 터미널 (macOS Terminal.app 등)
            osascript <<EOF
tell application "Terminal"
    do script "cd '$worktree_path' && claude"
    set custom title of front window to "Claude: $branch_name"
end tell
EOF
            ;;
    esac
    
    echo -e "${GREEN}✓ Claude Code launched for: $branch_name${NC}"
}

# 병렬 실행 (여러 worktree 동시 생성)
parallel_execution() {
    local branches=("$@")
    local count=${#branches[@]}
    
    if [[ $count -gt $MAX_PARALLEL_SESSIONS ]]; then
        echo -e "${YELLOW}Warning: Limiting to $MAX_PARALLEL_SESSIONS parallel sessions${NC}"
        branches=("${branches[@]:0:$MAX_PARALLEL_SESSIONS}")
        count=$MAX_PARALLEL_SESSIONS
    fi
    
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
    echo -e "${BLUE}Starting $count parallel Claude Code sessions${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
    
    # Worktree 기본 디렉토리 생성
    mkdir -p "$WORKTREE_BASE_DIR"
    
    # 각 브랜치별로 worktree 생성 및 Claude 실행
    for i in "${!branches[@]}"; do
        local branch="${branches[$i]}"
        echo -e "\n${YELLOW}[$((i+1))/$count] Processing: $branch${NC}"
        create_single_worktree "$branch" "Implement $branch feature"
        sleep 2  # 터미널 창이 겹치지 않도록 약간의 딜레이
    done
    
    echo -e "\n${GREEN}═══════════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ All $count Claude Code sessions are running!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════${NC}"
    
    # 상태 요약
    show_status
}

# 현재 worktree 상태 표시
show_status() {
    echo -e "\n${BLUE}Current Worktree Status:${NC}"
    echo -e "${BLUE}───────────────────────────${NC}"
    
    git worktree list | while read -r line; do
        if [[ "$line" == *"$WORKTREE_BASE_DIR"* ]]; then
            local path=$(echo "$line" | awk '{print $1}')
            local branch=$(echo "$line" | awk '{print $3}' | tr -d '[]')
            local task_file="$path/CLAUDE_TASK.md"
            local complete_file="$path/TASK_COMPLETE.md"
            
            if [[ -f "$complete_file" ]]; then
                echo -e "${GREEN}✓ $branch (completed)${NC}"
            elif [[ -f "$task_file" ]]; then
                echo -e "${YELLOW}⚡ $branch (in progress)${NC}"
            else
                echo -e "${BLUE}○ $branch (created)${NC}"
            fi
        fi
    done
    
    echo -e "\n${BLUE}Port Allocations:${NC}"
    find "$WORKTREE_BASE_DIR" -name ".env.worktree" 2>/dev/null | while read -r env_file; do
        local branch=$(basename $(dirname "$env_file"))
        local dev_port=$(grep "DEV_PORT=" "$env_file" | cut -d'=' -f2)
        local db_port=$(grep "DB_PORT=" "$env_file" | cut -d'=' -f2)
        echo "  $branch: dev=$dev_port, db=$db_port"
    done
}

# Worktree 정리
cleanup_worktree() {
    local branch_name=$1
    local worktree_path="$WORKTREE_BASE_DIR/$branch_name"
    
    echo -e "${YELLOW}Cleaning up worktree: $branch_name${NC}"
    
    if [[ -d "$worktree_path" ]]; then
        git worktree remove "$worktree_path" --force 2>/dev/null || true
        echo -e "${GREEN}✓ Worktree removed${NC}"
    fi
    
    # 브랜치 삭제 확인
    read -p "Delete branch $branch_name? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git branch -D "$branch_name" 2>/dev/null || true
        echo -e "${GREEN}✓ Branch deleted${NC}"
    fi
}

# 모든 worktree 정리
cleanup_all() {
    echo -e "${YELLOW}Cleaning up all worktrees...${NC}"
    
    git worktree list | grep "$WORKTREE_BASE_DIR" | while read -r line; do
        local path=$(echo "$line" | awk '{print $1}')
        local branch=$(basename "$path")
        cleanup_worktree "$branch"
    done
    
    # 디렉토리 정리
    if [[ -d "$WORKTREE_BASE_DIR" ]]; then
        rmdir "$WORKTREE_BASE_DIR" 2>/dev/null || true
    fi
    
    echo -e "${GREEN}✓ All worktrees cleaned${NC}"
}

# 메인 함수
main() {
    local command=${1:-help}
    shift || true
    
    case $command in
        parallel)
            parallel_execution "$@"
            ;;
        new)
            create_single_worktree "$@"
            ;;
        status)
            show_status
            ;;
        clean)
            if [[ $# -eq 0 ]]; then
                cleanup_all
            else
                cleanup_worktree "$1"
            fi
            ;;
        help|*)
            cat <<EOF
Git Worktree Parallel Orchestrator

Usage:
  $0 parallel branch1 branch2 branch3  # 병렬 실행
  $0 new branch-name "task description" # 단일 생성
  $0 status                             # 상태 확인
  $0 clean [branch-name]                # 정리

Examples:
  $0 parallel auth payment search       # 3개 동시 실행
  $0 new feature-x "Add login feature"  # 단일 실행
  $0 status                             # 진행 상황 확인
  $0 clean                              # 전체 정리
  $0 clean feature-x                    # 특정 브랜치 정리

This script creates isolated worktrees and launches multiple
Claude Code instances in parallel for maximum development speed.
EOF
            ;;
    esac
}

# 스크립트 실행
main "$@"