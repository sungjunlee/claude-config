#!/bin/bash
# Install hooks to a project
#
# Usage:
#   ~/.claude/hooks/install.sh [project_dir]
#
# This script:
#   1. Creates .claude/hooks/ in the project
#   2. Copies unified hooks (post_edit.py, pre_commit.py)
#   3. Adds hook config to .claude/settings.json (overwrites existing hooks config)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${1:-.}"

# Resolve to absolute path
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"

echo "🔧 Installing hooks to: $PROJECT_DIR"

# Verify source files exist
for hook in post_edit.py pre_commit.py; do
    if [[ ! -f "$SCRIPT_DIR/$hook" ]]; then
        echo "❌ Source file not found: $SCRIPT_DIR/$hook"
        exit 1
    fi
done

# Create directories
mkdir -p "$PROJECT_DIR/.claude/hooks"

# Copy hooks
cp "$SCRIPT_DIR/post_edit.py" "$PROJECT_DIR/.claude/hooks/"
cp "$SCRIPT_DIR/pre_commit.py" "$PROJECT_DIR/.claude/hooks/"
chmod +x "$PROJECT_DIR/.claude/hooks/"*.py

echo "✅ Copied hooks"

# Determine settings file
if [[ -f "$PROJECT_DIR/.claude/settings.local.json" ]]; then
    SETTINGS_FILE="$PROJECT_DIR/.claude/settings.local.json"
elif [[ -f "$PROJECT_DIR/.claude/settings.json" ]]; then
    SETTINGS_FILE="$PROJECT_DIR/.claude/settings.json"
else
    SETTINGS_FILE="$PROJECT_DIR/.claude/settings.local.json"
    echo '{}' > "$SETTINGS_FILE"
fi

echo "📝 Updating: $(basename "$SETTINGS_FILE")"

# Check jq
if ! command -v jq &> /dev/null; then
    echo "⚠️  jq not found. Add manually:"
    cat << 'EOF'

{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write|MultiEdit",
      "hooks": [{
        "type": "command",
        "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/post_edit.py"
      }]
    }]
  }
}
EOF
    exit 1
fi

# Merge hooks config
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

jq -s '.[0] * .[1]' "$SETTINGS_FILE" <(echo "$HOOKS_CONFIG") > "$SETTINGS_FILE.tmp"
mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"

echo "✅ Done"
echo ""
echo "Installed:"
echo "  - post_edit.py (auto-format: Python, TS/JS, Rust, Go)"
echo "  - pre_commit.py (Python quality gate)"
echo ""
echo "Optional - git hook:"
echo "  ln -sf .claude/hooks/pre_commit.py .git/hooks/pre-commit"
