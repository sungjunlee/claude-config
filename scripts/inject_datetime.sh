#!/usr/bin/env bash
set -euo pipefail
# Minimal datetime injector for Claude Code
# Adds current timestamp to user prompts

# Output timestamp in ISO 8601 format with UTC for consistency
# Fallback chain: TZ=UTC date -> date -u -> placeholder with error log
if output=$(TZ=UTC date +'%Y-%m-%dT%H:%M:%SZ' 2>&1); then
    echo "$output"
elif output=$(date -u +'%Y-%m-%dT%H:%M:%SZ' 2>&1); then
    echo "$output"
else
    echo "inject_datetime: ERROR - date commands failed: $output" >&2
    echo "inject_datetime: Ensure 'date' command is available in PATH" >&2
    echo "timestamp-unavailable"
fi
