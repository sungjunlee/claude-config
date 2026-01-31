#!/usr/bin/env bats
# Tests for shell hook scripts

SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../.." && pwd)/scripts"

# =============================================================================
# inject_datetime.sh tests
# =============================================================================

@test "inject_datetime.sh outputs ISO 8601 format" {
    run "$SCRIPT_DIR/inject_datetime.sh"
    [ "$status" -eq 0 ]
    # Check format: YYYY-MM-DDTHH:MM:SSZ
    [[ "$output" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$ ]]
}

@test "inject_datetime.sh outputs UTC timezone" {
    run "$SCRIPT_DIR/inject_datetime.sh"
    [ "$status" -eq 0 ]
    # Should end with Z (UTC)
    [[ "$output" =~ Z$ ]]
}

@test "inject_datetime.sh date is reasonable" {
    run "$SCRIPT_DIR/inject_datetime.sh"
    [ "$status" -eq 0 ]
    # Extract year and check it's 2024-2030 range
    year="${output:0:4}"
    [ "$year" -ge 2024 ]
    [ "$year" -le 2030 ]
}

# =============================================================================
# notify_permission.sh tests
# =============================================================================

@test "notify_permission.sh exits with 0 (non-blocking)" {
    # Even if notification fails, should exit 0 to not block
    run "$SCRIPT_DIR/notify_permission.sh"
    [ "$status" -eq 0 ]
}

@test "notify_permission.sh outputs info when no notification system" {
    # Mock environment without notification tools
    run env PATH=/usr/bin:/bin "$SCRIPT_DIR/notify_permission.sh"
    # Should contain INFO message (not blocking error)
    [[ "$output" =~ INFO ]] || [[ "$status" -eq 0 ]]
}

# =============================================================================
# audit_logger.py tests (via shell)
# =============================================================================

@test "audit_logger.py handles invalid JSON with exit 1" {
    run bash -c "echo 'invalid json' | python3 '$SCRIPT_DIR/audit_logger.py'"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Invalid JSON" ]]
}

@test "audit_logger.py handles valid JSON" {
    # Create temp home for log file
    export HOME=$(mktemp -d)
    mkdir -p "$HOME/.claude"

    input='{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"ls"},"session_id":"test123","cwd":"/tmp"}'
    run bash -c "echo '$input' | python3 '$SCRIPT_DIR/audit_logger.py'"

    [ "$status" -eq 0 ]
    [ -f "$HOME/.claude/command-audit.log" ]

    # Cleanup
    rm -rf "$HOME"
}

# =============================================================================
# post_edit.py tests (via shell)
# =============================================================================

@test "post_edit.py returns early without TOOL_USE" {
    run env -u TOOL_USE python3 "$SCRIPT_DIR/hooks/post_edit.py"
    [ "$status" -eq 0 ]
    [[ "$output" =~ WARNING ]] || [ -z "$output" ]
}

@test "post_edit.py returns early for non-edit tools" {
    run env TOOL_USE=Read FILE_PATH=/test.py python3 "$SCRIPT_DIR/hooks/post_edit.py"
    [ "$status" -eq 0 ]
}

@test "post_edit.py handles missing file gracefully" {
    run env TOOL_USE=Edit FILE_PATH=/nonexistent/file.py python3 "$SCRIPT_DIR/hooks/post_edit.py"
    [ "$status" -eq 0 ]
}

@test "post_edit.py ignores unknown extensions" {
    tmpfile=$(mktemp /tmp/test.XXXXXX.txt)
    echo "hello" > "$tmpfile"

    run env TOOL_USE=Edit FILE_PATH="$tmpfile" python3 "$SCRIPT_DIR/hooks/post_edit.py"
    [ "$status" -eq 0 ]

    rm -f "$tmpfile"
}

# =============================================================================
# git_status.sh tests
# =============================================================================

@test "git_status.sh runs without error" {
    run "$SCRIPT_DIR/git_status.sh"
    # May fail if not in git repo, but should not crash
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "git_status.sh in git repo shows branch info" {
    # Run in the repo directory
    cd "$(dirname "$SCRIPT_DIR")"
    run "$SCRIPT_DIR/git_status.sh"
    [ "$status" -eq 0 ]
    # Should contain branch information (case-insensitive)
    [[ "$output" =~ [Bb]ranch ]]
}
