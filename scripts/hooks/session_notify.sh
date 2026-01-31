#!/usr/bin/env bash
#
# Cross-platform notification utility for Claude Code sessions
# Usage: session_notify.sh <event> [message]
#
# Supports: macOS (osascript), Linux (notify-send), Windows (WSL/PowerShell)

set -euo pipefail

# Get event type and optional message
EVENT="${1:-unknown}"
MESSAGE="${2:-Claude Code session event: $EVENT}"

# Determine platform and send notification
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS - use osascript
    if command -v osascript >/dev/null 2>&1; then
        osascript -e "display notification \"$MESSAGE\" with title \"Claude Code\"" || true
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux - check for various notification tools
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "Claude Code" "$MESSAGE" || true
    elif [ -n "${WSL_DISTRO_NAME:-}" ] && command -v powershell.exe >/dev/null 2>&1; then
        # WSL - use Windows PowerShell (escape single quotes)
        ESCAPED_MESSAGE="${MESSAGE//\'/\'\'}"
        powershell.exe -Command "
            Add-Type -AssemblyName System.Windows.Forms
            \$notification = New-Object System.Windows.Forms.NotifyIcon
            \$notification.Icon = [System.Drawing.SystemIcons]::Information
            \$notification.BalloonTipIcon = 'Info'
            \$notification.BalloonTipTitle = 'Claude Code'
            \$notification.BalloonTipText = '$ESCAPED_MESSAGE'
            \$notification.Visible = \$true
            \$notification.ShowBalloonTip(5000)
        " 2>/dev/null || true
    fi
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    # Windows Git Bash or Cygwin (escape single quotes)
    if command -v powershell >/dev/null 2>&1; then
        ESCAPED_MESSAGE="${MESSAGE//\'/\'\'}"
        powershell -Command "
            Add-Type -AssemblyName System.Windows.Forms
            [System.Windows.Forms.MessageBox]::Show('$ESCAPED_MESSAGE', 'Claude Code')
        " 2>/dev/null || true
    fi
fi

# Always log to file as fallback
LOG_FILE="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/session.log"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] $EVENT: $MESSAGE" >> "$LOG_FILE"