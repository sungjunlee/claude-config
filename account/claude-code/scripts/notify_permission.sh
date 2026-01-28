#!/bin/bash
# Notify user when Claude requests permission
# Used by PermissionRequest hook

TITLE="Claude Permission Request"
MESSAGE="Claude is waiting for permission approval"

# macOS: osascript
if command -v osascript &> /dev/null; then
    osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\" sound name \"Glass\""
    exit 0
fi

# Linux: notify-send
if command -v notify-send &> /dev/null; then
    notify-send "$TITLE" "$MESSAGE" --urgency=normal
    exit 0
fi

# No notification system available - silent exit
exit 0
