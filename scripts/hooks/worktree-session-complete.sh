#!/bin/bash

# Worktree Session Complete Hook
# Claude 세션 완료 시 worktree 상태 확인 및 정리 제안

set -euo pipefail

SESSION_ID="${SESSION_ID:-}"
CWD="${CWD:-}"
LOG_FILE="/tmp/claude-worktree-hooks.log"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SESSION-COMPLETE] $1" >> "$LOG_FILE"
}

# Worktree 상태 확인
check_worktree_status() {
    if ! git rev-parse --git-common-dir &>/dev/null; then
        return 0
    fi
    
    local is_worktree=false
    if [[ "$(git rev-parse --git-common-dir)" != "$(git rev-parse --git-dir)" ]]; then
        is_worktree=true
    fi
    
    if [[ "$is_worktree" == true ]]; then
        local branch=$(git branch --show-current)
        local changes=$(git status --porcelain | wc -l)
        
        log_message "Session $SESSION_ID completed in worktree: $branch"
        
        # 완료 마커 생성
        echo "Session completed at $(date)" > "TASK_COMPLETE.md"
        
        if [[ $changes -gt 0 ]]; then
            echo ""
            echo "📋 Worktree has uncommitted changes:"
            git status --short
            echo ""
            echo "💡 Suggestions:"
            echo "  1. Commit changes: git add . && git commit -m 'Complete $branch'"
            echo "  2. Push to remote: git push origin $branch"
            echo "  3. Create PR: gh pr create"
            echo "  4. Clean worktree: git worktree remove $(pwd)"
        else
            echo ""
            echo "✅ Worktree session completed cleanly"
            echo "💡 You can now:"
            echo "  1. Merge to main: git checkout main && git merge $branch"
            echo "  2. Remove worktree: git worktree remove $(pwd)"
        fi
    fi
}

main() {
    log_message "Session complete hook for: $SESSION_ID"
    check_worktree_status
}

main "$@"