#!/usr/bin/env bash
# Minimal datetime injector for Claude Code
# Adds current timestamp to user prompts

# Output timestamp in ISO 8601 format with UTC for consistency
TZ=UTC date +'%Y-%m-%dT%H:%M:%SZ'