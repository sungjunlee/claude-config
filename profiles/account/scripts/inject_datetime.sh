#!/usr/bin/env bash
# Universal datetime context injector for Claude Code
# Automatically detects and uses system timezone
# Compatible with Linux, macOS, and WSL

set -euo pipefail

# Function to detect system timezone
detect_timezone() {
    # Check if TZ is already set
    if [ -n "${TZ:-}" ]; then
        echo "$TZ"
        return
    fi
    
    # Try timedatectl (systemd-based systems)
    if command -v timedatectl &> /dev/null; then
        local tz=$(timedatectl show -p Timezone --value 2>/dev/null || true)
        if [ -n "$tz" ]; then
            echo "$tz"
            return
        fi
    fi
    
    # Try /etc/timezone (Debian/Ubuntu)
    if [ -f /etc/timezone ]; then
        local tz=$(cat /etc/timezone 2>/dev/null || true)
        if [ -n "$tz" ]; then
            echo "$tz"
            return
        fi
    fi
    
    # Try /etc/localtime symlink
    if [ -L /etc/localtime ]; then
        local tz=$(readlink /etc/localtime | sed 's/.*zoneinfo\///' 2>/dev/null || true)
        if [ -n "$tz" ]; then
            echo "$tz"
            return
        fi
    fi
    
    # macOS specific
    if [ -f /etc/localtime ] && [ "$(uname)" = "Darwin" ]; then
        local tz=$(ls -l /etc/localtime | sed 's/.*zoneinfo\///' 2>/dev/null || true)
        if [ -n "$tz" ]; then
            echo "$tz"
            return
        fi
    fi
    
    # Default to UTC
    echo "UTC"
}

# Detect and export timezone
TZ=$(detect_timezone)
export TZ

# Provide comprehensive time context
echo "[System Context]"
echo "Current time: $(date +'%Y-%m-%d %H:%M:%S %Z (%z)')"
echo "Day: $(date +'%A, %B %d, %Y')"
echo "Week: $(date +'Week %V of %Y')"
echo "Timezone: $TZ"
echo "Unix timestamp: $(date +%s)"

# Add UTC reference for global context
echo "UTC: $(TZ=UTC date +'%Y-%m-%d %H:%M:%S')"

# Optional: Show major timezones if CLAUDE_EXTRA_TZ is set
if [ -n "${CLAUDE_EXTRA_TZ:-}" ]; then
    echo "---"
    IFS=',' read -ra ZONES <<< "$CLAUDE_EXTRA_TZ"
    for zone in "${ZONES[@]}"; do
        zone=$(echo "$zone" | xargs)  # Trim whitespace
        if [ -n "$zone" ]; then
            echo "$zone: $(TZ="$zone" date +'%H:%M %Z' 2>/dev/null || echo 'Invalid timezone')"
        fi
    done
fi

echo ""