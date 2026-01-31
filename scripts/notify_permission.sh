#!/usr/bin/env bash
set -euo pipefail
# Notify user when Claude requests permission
# Used by PermissionRequest hook

TITLE="Claude Permission Request"
MESSAGE="Claude is waiting for permission approval"

# macOS: osascript
if command -v osascript &> /dev/null; then
    if osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\" sound name \"Glass\"" 2>/dev/null; then
        exit 0
    fi
fi

# Linux: notify-send
if command -v notify-send &> /dev/null; then
    if notify-send "$TITLE" "$MESSAGE" --urgency=normal 2>/dev/null; then
        exit 0
    fi
fi

# No notification system available
echo "notify_permission: WARNING - No notification system available (osascript/notify-send)" >&2
exit 1
