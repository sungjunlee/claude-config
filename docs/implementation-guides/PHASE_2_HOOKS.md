# Phase 2: Hook System Expansion - Implementation Guide

## Overview
This guide provides detailed implementation instructions for Phase 2 of the Claude Config roadmap, focusing on expanding the hook system for workflow automation.

## Prerequisites
- Phase 1 merged (optimize/explain commands)
- Existing hooks structure in `profiles/account/scripts/hooks/`
- Basic understanding of bash scripting

## Implementation Steps

### Step 1: Context Monitor Hook

#### File: `profiles/account/scripts/hooks/context_monitor.sh`

```bash
#!/usr/bin/env bash
#
# Context Monitor Hook
# Monitors Claude Code context usage and triggers actions at thresholds
#
set -euo pipefail

# Configuration
THRESHOLD_WARNING=${CONTEXT_THRESHOLD_WARNING:-70}
THRESHOLD_CRITICAL=${CONTEXT_THRESHOLD_CRITICAL:-80}
THRESHOLD_AUTO_HANDOFF=${CONTEXT_AUTO_HANDOFF:-80}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACCOUNT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Function to estimate context usage
estimate_context_usage() {
    # This is a placeholder - actual implementation would need
    # to interface with Claude Code's context tracking
    # For now, return a mock value for testing
    echo "${MOCK_CONTEXT_USAGE:-50}"
}

# Function to send notification
notify_user() {
    local level="$1"
    local message="$2"
    
    # Use existing notification system if available
    if [[ -f "$SCRIPT_DIR/session_notify.sh" ]]; then
        "$SCRIPT_DIR/session_notify.sh" "$level" "$message"
    else
        echo "[$level] $message"
    fi
}

# Function to trigger auto handoff
trigger_auto_handoff() {
    echo "🔄 Auto-triggering handoff at ${1}% context usage..."
    
    # Check if handoff command exists
    local handoff_cmd="$ACCOUNT_DIR/commands/flow/handoff.md"
    if [[ -f "$handoff_cmd" ]]; then
        echo "Executing handoff with --auto flag..."
        # Note: Actual execution would need Claude Code command invocation
        echo "Suggested: /handoff --auto"
    fi
}

# Main monitoring logic
main() {
    local usage=$(estimate_context_usage)
    
    if (( usage >= THRESHOLD_AUTO_HANDOFF )); then
        notify_user "CRITICAL" "Context usage at ${usage}% - Auto-handoff triggered"
        trigger_auto_handoff "$usage"
    elif (( usage >= THRESHOLD_CRITICAL )); then
        notify_user "WARNING" "Context usage at ${usage}% - Consider handoff"
    elif (( usage >= THRESHOLD_WARNING )); then
        notify_user "INFO" "Context usage at ${usage}% - Monitor closely"
    fi
    
    # Log for debugging
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Context usage: ${usage}%" >> ~/.claude/logs/context.log
}

# Run if not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

### Step 2: Auto Handoff Hook

#### File: `profiles/account/scripts/hooks/auto_handoff.sh`

```bash
#!/usr/bin/env bash
#
# Auto Handoff Hook
# Automatically triggers handoff when conditions are met
#
set -euo pipefail

# Configuration
HANDOFF_THRESHOLD=${HANDOFF_THRESHOLD:-80}
HANDOFF_MODE=${HANDOFF_MODE:-"quick"}  # quick, detailed, team

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to check if handoff is needed
should_handoff() {
    local context_usage="$1"
    local session_duration="$2"
    local interactions="$3"
    
    # Handoff if context usage exceeds threshold
    if (( context_usage >= HANDOFF_THRESHOLD )); then
        return 0
    fi
    
    # Handoff if session is very long (>2 hours) with many interactions
    if (( session_duration > 7200 && interactions > 50 )); then
        return 0
    fi
    
    return 1
}

# Function to create handoff
create_handoff() {
    local mode="$1"
    local reason="$2"
    
    echo "📝 Creating automatic handoff..."
    echo "  Mode: $mode"
    echo "  Reason: $reason"
    
    # Create handoff with metadata
    cat << EOF > ~/.claude/handoff-auto.md
# Automatic Handoff
Generated: $(date '+%Y-%m-%d %H:%M:%S')
Reason: $reason
Mode: $mode

## Session Metrics
- Context Usage: ${CONTEXT_USAGE}%
- Session Duration: ${SESSION_DURATION}s
- Interactions: ${INTERACTION_COUNT}

## Recommendation
Use /resume to continue this session after clearing context.
EOF
    
    echo "✅ Auto-handoff created. Use /resume to continue."
}

# Main function
main() {
    # Get current metrics (mock values for implementation)
    CONTEXT_USAGE=${CONTEXT_USAGE:-85}
    SESSION_DURATION=${SESSION_DURATION:-8000}
    INTERACTION_COUNT=${INTERACTION_COUNT:-60}
    
    if should_handoff "$CONTEXT_USAGE" "$SESSION_DURATION" "$INTERACTION_COUNT"; then
        local reason="Context usage: ${CONTEXT_USAGE}%"
        if (( SESSION_DURATION > 7200 )); then
            reason="$reason, Long session: $(( SESSION_DURATION / 3600 ))h"
        fi
        
        create_handoff "$HANDOFF_MODE" "$reason"
    fi
}

# Run if not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

### Step 3: Post-Tool Format Hook

#### File: `profiles/account/scripts/hooks/post_tool_format.sh`

```bash
#!/usr/bin/env bash
#
# Post-Tool Format Hook
# Automatically formats code after edit operations
#
set -euo pipefail

# Configuration
ENABLE_AUTO_FORMAT=${ENABLE_AUTO_FORMAT:-true}
FORMAT_ON_SAVE=${FORMAT_ON_SAVE:-true}

# Function to detect language
detect_language() {
    local file="$1"
    local ext="${file##*.}"
    
    case "$ext" in
        py) echo "python" ;;
        js|jsx|ts|tsx) echo "javascript" ;;
        rs) echo "rust" ;;
        go) echo "go" ;;
        rb) echo "ruby" ;;
        java) echo "java" ;;
        *) echo "unknown" ;;
    esac
}

# Function to format Python files
format_python() {
    local file="$1"
    
    # Check for formatters in order of preference
    if command -v black >/dev/null 2>&1; then
        echo "Formatting with black: $file"
        black "$file" 2>/dev/null || true
    elif command -v autopep8 >/dev/null 2>&1; then
        echo "Formatting with autopep8: $file"
        autopep8 --in-place "$file" 2>/dev/null || true
    fi
    
    # Run isort if available
    if command -v isort >/dev/null 2>&1; then
        isort "$file" 2>/dev/null || true
    fi
}

# Function to format JavaScript/TypeScript
format_javascript() {
    local file="$1"
    
    # Check for formatters
    if command -v prettier >/dev/null 2>&1; then
        echo "Formatting with prettier: $file"
        prettier --write "$file" 2>/dev/null || true
    elif command -v eslint >/dev/null 2>&1; then
        echo "Formatting with eslint: $file"
        eslint --fix "$file" 2>/dev/null || true
    fi
}

# Function to format Rust
format_rust() {
    local file="$1"
    
    if command -v rustfmt >/dev/null 2>&1; then
        echo "Formatting with rustfmt: $file"
        rustfmt "$file" 2>/dev/null || true
    fi
}

# Function to format Go
format_go() {
    local file="$1"
    
    if command -v gofmt >/dev/null 2>&1; then
        echo "Formatting with gofmt: $file"
        gofmt -w "$file" 2>/dev/null || true
    fi
}

# Main formatting function
format_file() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    local lang=$(detect_language "$file")
    
    case "$lang" in
        python) format_python "$file" ;;
        javascript) format_javascript "$file" ;;
        rust) format_rust "$file" ;;
        go) format_go "$file" ;;
        *) 
            # Unknown language, skip
            return 0
            ;;
    esac
}

# Main function - called by Claude Code after file edits
main() {
    local file="${1:-}"
    
    if [[ -z "$file" ]]; then
        echo "Usage: $0 <file>"
        exit 1
    fi
    
    if [[ "$ENABLE_AUTO_FORMAT" != "true" ]]; then
        exit 0
    fi
    
    format_file "$file"
}

# Run if not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

### Step 4: Hook Configuration

#### File: `profiles/account/settings/hooks-config.json`

```json
{
  "version": "1.0.0",
  "enabled": true,
  "hooks": {
    "pre_tool": {
      "enabled": true,
      "hooks": {
        "Edit": {
          "scripts": ["backup_file.sh"],
          "enabled": true
        },
        "Bash": {
          "scripts": ["security_check.sh"],
          "enabled": false
        }
      }
    },
    "post_tool": {
      "enabled": true,
      "hooks": {
        "Edit": {
          "scripts": ["post_tool_format.sh"],
          "enabled": true,
          "config": {
            "auto_format": true,
            "format_on_save": true
          }
        },
        "Write": {
          "scripts": ["post_tool_format.sh"],
          "enabled": true
        }
      }
    },
    "session": {
      "enabled": true,
      "hooks": {
        "start": {
          "scripts": ["session_start.sh"],
          "enabled": true
        },
        "stop": {
          "scripts": ["session_stop.sh"],
          "enabled": true
        },
        "context_monitor": {
          "scripts": ["context_monitor.sh"],
          "enabled": true,
          "interval": 300,
          "config": {
            "warning_threshold": 70,
            "critical_threshold": 80,
            "auto_handoff_threshold": 80
          }
        }
      }
    },
    "notification": {
      "enabled": true,
      "hooks": {
        "context_high": {
          "scripts": ["auto_handoff.sh"],
          "enabled": true,
          "threshold": 80
        },
        "long_session": {
          "scripts": ["session_notify.sh"],
          "enabled": true,
          "threshold_minutes": 120
        }
      }
    }
  },
  "global_config": {
    "log_dir": "~/.claude/logs",
    "enable_debug": false,
    "dry_run": false
  }
}
```

### Step 5: Installation Script Update

#### File: `profiles/account/scripts/install_hooks.sh`

```bash
#!/usr/bin/env bash
#
# Install and configure hooks for Claude Code
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$SCRIPT_DIR/hooks"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")/settings"
CLAUDE_DIR="$HOME/.claude"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${NC}"
}

# Create necessary directories
create_directories() {
    print_status "$YELLOW" "Creating directories..."
    mkdir -p "$CLAUDE_DIR/hooks"
    mkdir -p "$CLAUDE_DIR/logs"
    mkdir -p "$CLAUDE_DIR/settings"
}

# Install hook scripts
install_hooks() {
    print_status "$YELLOW" "Installing hooks..."
    
    for hook in "$HOOKS_DIR"/*.sh; do
        if [[ -f "$hook" ]]; then
            local basename=$(basename "$hook")
            print_status "$GREEN" "  Installing $basename"
            cp "$hook" "$CLAUDE_DIR/hooks/"
            chmod +x "$CLAUDE_DIR/hooks/$basename"
        fi
    done
}

# Install configuration
install_config() {
    print_status "$YELLOW" "Installing configuration..."
    
    if [[ -f "$CONFIG_DIR/hooks-config.json" ]]; then
        cp "$CONFIG_DIR/hooks-config.json" "$CLAUDE_DIR/settings/"
        print_status "$GREEN" "  Configuration installed"
    fi
}

# Main installation
main() {
    print_status "$GREEN" "🚀 Installing Claude Code Hooks System"
    
    create_directories
    install_hooks
    install_config
    
    print_status "$GREEN" "✅ Installation complete!"
    print_status "$YELLOW" "\nNext steps:"
    echo "  1. Review configuration at: $CLAUDE_DIR/settings/hooks-config.json"
    echo "  2. Enable/disable hooks as needed"
    echo "  3. Test with: claude --test-hooks"
}

main "$@"
```

## Testing Guide

### Test Context Monitor
```bash
# Set mock context usage
export MOCK_CONTEXT_USAGE=75
./context_monitor.sh

# Test critical threshold
export MOCK_CONTEXT_USAGE=85
./context_monitor.sh
```

### Test Auto Format
```bash
# Create test file
echo "def test(): pass" > test.py

# Run formatter
./post_tool_format.sh test.py

# Check if formatted
cat test.py
```

### Test Auto Handoff
```bash
# Set test conditions
export CONTEXT_USAGE=85
export SESSION_DURATION=8000
export INTERACTION_COUNT=60

# Run auto handoff
./auto_handoff.sh

# Check created handoff
cat ~/.claude/handoff-auto.md
```

## Configuration Options

### Environment Variables
- `CONTEXT_THRESHOLD_WARNING`: Warning threshold (default: 70)
- `CONTEXT_THRESHOLD_CRITICAL`: Critical threshold (default: 80)
- `CONTEXT_AUTO_HANDOFF`: Auto-handoff threshold (default: 85)
- `ENABLE_AUTO_FORMAT`: Enable auto-formatting (default: true)
- `HANDOFF_MODE`: Handoff mode (quick/detailed/team)

### Customization
Users can customize behavior by:
1. Editing `hooks-config.json`
2. Setting environment variables
3. Modifying individual hook scripts
4. Disabling specific hooks

## Rollback Instructions

To completely remove the hook system:

```bash
# Remove hook scripts
rm -rf ~/.claude/hooks

# Remove configuration
rm -f ~/.claude/settings/hooks-config.json

# Remove logs
rm -rf ~/.claude/logs

# Remove from profile hooks directory
rm -f profiles/account/scripts/hooks/{context_monitor,auto_handoff,post_tool_format}.sh
```

## Future Enhancements

### Planned for Phase 2.1
- Integration with Claude Code's actual context API
- More sophisticated formatting rules
- Team-shared hook configurations
- Hook performance monitoring

### Community Contributions
- Additional language formatters
- Custom notification systems
- Integration with external tools
- Workflow-specific hooks

## Troubleshooting

### Common Issues

#### Hooks not triggering
- Check if hooks are enabled in config
- Verify script permissions (`chmod +x`)
- Check Claude Code integration settings

#### Formatting not working
- Ensure formatters are installed
- Check language detection
- Verify file permissions

#### Auto-handoff not creating files
- Check write permissions
- Verify handoff directory exists
- Review threshold settings

## Conclusion

This implementation provides a robust, extensible hook system that enhances Claude Code workflows without interfering with core functionality. The system is designed to be optional, configurable, and safe to use or remove.