#!/usr/bin/env bash
set -euo pipefail
# Minimal datetime injector for Claude Code
# Adds current timestamp to user prompts

# Output timestamp in ISO 8601 format with UTC for consistency
# Fallback to non-TZ version if TZ=UTC causes issues
if ! TZ=UTC date +'%Y-%m-%dT%H:%M:%SZ' 2>/dev/null; then
    date -u +'%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || echo "timestamp-unavailable"
fi