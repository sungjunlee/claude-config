#!/usr/bin/env bash
set -euo pipefail
# Minimal datetime injector for Claude Code
# Adds current timestamp to user prompts

# Output timestamp in ISO 8601 format with UTC for consistency
# Fallback chain: TZ=UTC date -> date -u -> placeholder with error log
if ! TZ=UTC date +'%Y-%m-%dT%H:%M:%SZ' 2>/dev/null; then
    if ! date -u +'%Y-%m-%dT%H:%M:%SZ' 2>/dev/null; then
        echo "inject_datetime: ERROR - date commands failed" >&2
        echo "timestamp-unavailable"
    fi
fi
