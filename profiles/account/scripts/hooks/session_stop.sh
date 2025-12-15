#!/usr/bin/env bash
#
# Claude Code Stop hook
# Runs when a Claude Code session ends

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Calculate session duration if possible
SESSION_LOG="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/session.log"
if [ -f "$SESSION_LOG" ]; then
    # Try to find the last session start time
    LAST_START=$(grep "start:" "$SESSION_LOG" 2>/dev/null | tail -1 | cut -d' ' -f1-2 | tr -d '[]')
    if [ -n "$LAST_START" ]; then
        # Cross-platform date parsing
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            START_SECONDS=$(date -j -f "%Y-%m-%d %H:%M:%S" "$LAST_START" +%s 2>/dev/null || echo "0")
        else
            # Linux and others
            START_SECONDS=$(date -d "$LAST_START" +%s 2>/dev/null || echo "0")
        fi
        
        if [ "$START_SECONDS" -ne "0" ]; then
            CURRENT_SECONDS=$(date +%s)
            DURATION=$((CURRENT_SECONDS - START_SECONDS))
            DURATION_MIN=$((DURATION / 60))
            MESSAGE="Claude Code session completed (duration: ${DURATION_MIN} minutes)"
        else
            MESSAGE="Claude Code session completed"
        fi
    else
        MESSAGE="Claude Code session completed"
    fi
else
    MESSAGE="Claude Code session completed"
fi

# Send notification
"$SCRIPT_DIR/session_notify.sh" "stop" "$MESSAGE"

# Display session summary
echo "👋 Session ended at: $(date '+%Y-%m-%d %H:%M:%S')"
if [ -n "${DURATION_MIN:-}" ] && [ "$DURATION_MIN" -gt 0 ]; then
    echo "⏱️  Duration: ${DURATION_MIN} minutes"
fi