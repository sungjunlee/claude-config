#!/bin/bash
# Install Python hooks to a project
#
# Usage:
#   ~/.claude/hooks/python/install.sh [project_dir]
#
# This script:
#   1. Creates .claude/hooks/ in the project
#   2. Copies Python hooks
#   3. Merges hook config into .claude/settings.json (or settings.local.json)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${1:-.}"

# Resolve to absolute path
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"

echo "🐍 Installing Python hooks to: $PROJECT_DIR"

# Create directories
mkdir -p "$PROJECT_DIR/.claude/hooks"

# Copy hooks
cp "$SCRIPT_DIR/post_edit.py" "$PROJECT_DIR/.claude/hooks/"
cp "$SCRIPT_DIR/pre_commit.py" "$PROJECT_DIR/.claude/hooks/"
chmod +x "$PROJECT_DIR/.claude/hooks/"*.py

echo "✅ Copied hooks to .claude/hooks/"

# Determine settings file (prefer local)
if [[ -f "$PROJECT_DIR/.claude/settings.local.json" ]]; then
    SETTINGS_FILE="$PROJECT_DIR/.claude/settings.local.json"
elif [[ -f "$PROJECT_DIR/.claude/settings.json" ]]; then
    SETTINGS_FILE="$PROJECT_DIR/.claude/settings.json"
else
    SETTINGS_FILE="$PROJECT_DIR/.claude/settings.local.json"
    echo '{}' > "$SETTINGS_FILE"
fi

echo "📝 Updating: $SETTINGS_FILE"

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "⚠️  jq not found. Please manually add hooks to settings."
    echo ""
    echo "Add this to $SETTINGS_FILE:"
    cat << 'EOF'
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/post_edit.py"
          }
        ]
      }
    ]
  }
}
EOF
    exit 0
fi

# Merge hooks config using jq
HOOKS_CONFIG='{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/post_edit.py"
          }
        ]
      }
    ]
  }
}'

# Deep merge with existing settings
jq -s '.[0] * .[1]' "$SETTINGS_FILE" <(echo "$HOOKS_CONFIG") > "$SETTINGS_FILE.tmp"
mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"

echo "✅ Updated settings with hooks config"
echo ""
echo "Installed hooks:"
echo "  - post_edit.py (PostToolUse: Edit|Write|MultiEdit)"
echo "  - pre_commit.py (standalone, can be used as git hook)"
echo ""
echo "To use pre_commit.py as git hook:"
echo "  ln -sf .claude/hooks/pre_commit.py .git/hooks/pre-commit"
