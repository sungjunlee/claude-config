#!/usr/bin/env bats
# Integration tests for install.sh

REPO_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../.." && pwd)"
INSTALL_SCRIPT="$REPO_DIR/install.sh"

setup() {
    # Create temporary HOME for each test
    export ORIGINAL_HOME="$HOME"
    export HOME=$(mktemp -d)
    export CI_RESPONSE="y"  # Auto-accept prompts
}

teardown() {
    # Restore original HOME and cleanup
    rm -rf "$HOME"
    export HOME="$ORIGINAL_HOME"
}

# =============================================================================
# Basic installation tests
# =============================================================================

@test "install.sh creates ~/.claude directory" {
    run bash "$INSTALL_SCRIPT" --force
    [ "$status" -eq 0 ]
    [ -d "$HOME/.claude" ]
}

@test "install.sh creates CLAUDE.md" {
    run bash "$INSTALL_SCRIPT" --force
    [ "$status" -eq 0 ]
    [ -f "$HOME/.claude/CLAUDE.md" ]
}

@test "install.sh creates settings.json" {
    run bash "$INSTALL_SCRIPT" --force
    [ "$status" -eq 0 ]
    [ -f "$HOME/.claude/settings.json" ]
}

@test "install.sh creates llm-models-latest.md" {
    run bash "$INSTALL_SCRIPT" --force
    [ "$status" -eq 0 ]
    [ -f "$HOME/.claude/llm-models-latest.md" ]
}

# =============================================================================
# Legacy cleanup tests
# =============================================================================

@test "install.sh removes legacy scripts directory" {
    mkdir -p "$HOME/.claude/scripts"
    echo "legacy" > "$HOME/.claude/scripts/test.sh"

    run bash "$INSTALL_SCRIPT" --force
    [ "$status" -eq 0 ]
    [ ! -d "$HOME/.claude/scripts" ]
}

@test "install.sh removes legacy hooks directory" {
    mkdir -p "$HOME/.claude/hooks"
    echo "legacy" > "$HOME/.claude/hooks/test.json"

    run bash "$INSTALL_SCRIPT" --force
    [ "$status" -eq 0 ]
    [ ! -d "$HOME/.claude/hooks" ]
}

@test "install.sh removes legacy skills directory" {
    mkdir -p "$HOME/.claude/skills/session"
    echo "legacy" > "$HOME/.claude/skills/session/SKILL.md"

    run bash "$INSTALL_SCRIPT" --force
    [ "$status" -eq 0 ]
    [ ! -d "$HOME/.claude/skills" ]
}

@test "install.sh removes legacy symlinks" {
    mkdir -p "$HOME/.claude"
    mkdir -p /tmp/test_scripts_$$
    ln -s /tmp/test_scripts_$$ "$HOME/.claude/scripts"

    run bash "$INSTALL_SCRIPT" --force
    [ "$status" -eq 0 ]
    [ ! -L "$HOME/.claude/scripts" ]

    # Original directory should still exist
    [ -d "/tmp/test_scripts_$$" ]
    rm -rf /tmp/test_scripts_$$
}

# =============================================================================
# Backup tests
# =============================================================================

@test "install.sh creates backup with --force on existing config" {
    # Create existing config
    mkdir -p "$HOME/.claude"
    echo "existing" > "$HOME/.claude/CLAUDE.md"

    run bash "$INSTALL_SCRIPT" --force
    [ "$status" -eq 0 ]

    # Check backup was created
    backup_count=$(ls -d "$HOME/.claude-backup-"* 2>/dev/null | wc -l)
    [ "$backup_count" -ge 1 ] || [ -f "$HOME/.claude/CLAUDE.md.backup-"* ]
}

# =============================================================================
# Idempotency tests
# =============================================================================

@test "install.sh is idempotent" {
    # Run twice
    run bash "$INSTALL_SCRIPT" --force
    [ "$status" -eq 0 ]

    run bash "$INSTALL_SCRIPT" --force
    [ "$status" -eq 0 ]

    # All files should still exist
    [ -f "$HOME/.claude/CLAUDE.md" ]
    [ -f "$HOME/.claude/settings.json" ]
}

# =============================================================================
# Verification tests
# =============================================================================

@test "install.sh verification passes on clean install" {
    run bash "$INSTALL_SCRIPT" --force
    [ "$status" -eq 0 ]

    # Output should not contain CLEANUP REQUIRED
    [[ ! "$output" =~ "CLEANUP REQUIRED" ]]
}

@test "install.sh verification warns about remaining legacy dirs" {
    # Create unremovable legacy directory (read-only)
    mkdir -p "$HOME/.claude/scripts"
    chmod 000 "$HOME/.claude/scripts"

    run bash "$INSTALL_SCRIPT" --force

    # Should warn about cleanup
    [[ "$output" =~ "Legacy" ]] || [[ "$output" =~ "cleanup" ]] || [[ "$output" =~ "CLEANUP" ]]

    # Cleanup for test
    chmod 755 "$HOME/.claude/scripts"
}

# =============================================================================
# Option tests
# =============================================================================

@test "install.sh --help shows usage" {
    run bash "$INSTALL_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Usage" ]]
    [[ "$output" =~ "--force" ]]
}

@test "install.sh --skip-backup skips backup" {
    mkdir -p "$HOME/.claude"
    echo "existing" > "$HOME/.claude/CLAUDE.md"

    run bash "$INSTALL_SCRIPT" --force --skip-backup
    [ "$status" -eq 0 ]

    # No backup directory should be created
    backup_count=$(ls -d "$HOME/.claude-backup-"* 2>/dev/null | wc -l || echo 0)
    [ "$backup_count" -eq 0 ]
}

# =============================================================================
# Content validation tests
# =============================================================================

@test "settings.json contains valid JSON" {
    run bash "$INSTALL_SCRIPT" --force
    [ "$status" -eq 0 ]

    run python3 -c "import json; json.load(open('$HOME/.claude/settings.json'))"
    [ "$status" -eq 0 ]
}

@test "settings.json contains permissions" {
    run bash "$INSTALL_SCRIPT" --force
    [ "$status" -eq 0 ]

    run grep -q "permissions" "$HOME/.claude/settings.json"
    [ "$status" -eq 0 ]
}

@test "CLAUDE.md is not empty" {
    run bash "$INSTALL_SCRIPT" --force
    [ "$status" -eq 0 ]

    [ -s "$HOME/.claude/CLAUDE.md" ]
}

# =============================================================================
# Error handling tests
# =============================================================================

@test "install.sh handles read-only HOME gracefully" {
    chmod 444 "$HOME"

    run bash "$INSTALL_SCRIPT" --force

    # Should fail but not crash
    [ "$status" -ne 0 ] || [[ "$output" =~ "error" ]] || [[ "$output" =~ "Error" ]]

    # Cleanup
    chmod 755 "$HOME"
}

@test "install.sh shows plugin guide on success" {
    run bash "$INSTALL_SCRIPT" --force
    [ "$status" -eq 0 ]

    # Should show plugin installation instructions
    [[ "$output" =~ "plugin" ]] || [[ "$output" =~ "Plugin" ]]
}
