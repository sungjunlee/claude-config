#!/usr/bin/env bash
#
# Claude Code SessionStart hook
# Runs when a Claude Code session begins

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Send notification
"$SCRIPT_DIR/session_notify.sh" "start" "Claude Code session started"

# Optional: Display git status if in a git repository
if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; then
    echo "📊 Git Status:"
    git status --short --branch
    echo ""
fi

# Optional: Display current date/time
echo "🕐 Session started at: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""