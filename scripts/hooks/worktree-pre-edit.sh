#!/bin/bash

# Worktree Pre-Edit Hook
# 파일 편집 전에 worktree가 필요한지 확인하고 자동 생성

set -euo pipefail

# Hook으로부터 받는 환경 변수
SESSION_ID="${SESSION_ID:-}"
TOOL_NAME="${TOOL_NAME:-}"
TOOL_INPUT="${TOOL_INPUT:-}"
CWD="${CWD:-}"

# 로그 파일
LOG_FILE="/tmp/claude-worktree-hooks.log"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [PRE-EDIT] $1" >> "$LOG_FILE"
}

# 현재 git worktree인지 확인
is_in_worktree() {
    git rev-parse --git-common-dir &>/dev/null && \
    [[ "$(git rev-parse --git-common-dir)" != "$(git rev-parse --git-dir)" ]]
}

# 메인 브랜치에서 작업 중인지 확인
is_on_main_branch() {
    local current_branch=$(git branch --show-current 2>/dev/null || echo "")
    [[ "$current_branch" == "main" || "$current_branch" == "master" ]]
}

# Worktree 자동 생성 제안
suggest_worktree_creation() {
    local file_path=$(echo "$TOOL_INPUT" | jq -r '.file_path // ""' 2>/dev/null || echo "")
    
    if [[ -z "$file_path" ]]; then
        return 0
    fi
    
    # 메인 브랜치에서 중요한 파일을 편집하려는 경우
    if is_on_main_branch && ! is_in_worktree; then
        log_message "Detected edit on main branch for: $file_path"
        
        # 세션 기반 worktree 이름 생성
        local session_short=$(echo "$SESSION_ID" | cut -c1-8)
        local suggested_branch="work-${session_short}"
        
        cat <<EOF
{
  "action": "ask",
  "message": "You're editing on the main branch. Would you like to create a worktree for this change?",
  "suggestion": "git worktree add ../$(basename "$PWD")-worktrees/$suggested_branch -b $suggested_branch"
}
EOF
        exit 0
    fi
}

# Hook 실행
main() {
    log_message "Pre-edit hook triggered for session: $SESSION_ID"
    
    # Git 저장소가 아닌 경우 스킵
    if ! git rev-parse --git-dir &>/dev/null; then
        log_message "Not a git repository, skipping"
        echo '{"action": "allow"}'
        exit 0
    fi
    
    # Worktree 생성 제안
    suggest_worktree_creation
    
    # 기본적으로 허용
    echo '{"action": "allow"}'
}

main "$@"