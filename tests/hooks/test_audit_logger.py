"""Tests for audit_logger.py."""

import io
import json
import os
import sys
from pathlib import Path
from unittest.mock import patch, MagicMock

import pytest


class TestRunCommand:
    """Tests for run_command function."""

    def test_successful_command(self):
        """Test successful command execution."""
        from audit_logger import run_command

        result = run_command("echo hello")
        assert result == "hello"

    def test_failed_command(self):
        """Test failed command returns None."""
        from audit_logger import run_command

        result = run_command("false")
        assert result is None

    def test_command_not_found(self):
        """Test non-existent command returns None."""
        from audit_logger import run_command

        result = run_command("nonexistent_command_12345")
        assert result is None

    def test_timeout(self):
        """Test command timeout returns None."""
        from audit_logger import run_command

        result = run_command("sleep 10", timeout=0.1)
        assert result is None

    def test_command_with_cwd(self, tmp_path):
        """Test command with custom working directory."""
        from audit_logger import run_command

        result = run_command("pwd", cwd=str(tmp_path))
        assert result == str(tmp_path)


class TestGetGitInfo:
    """Tests for get_git_info function."""

    def test_non_git_directory(self, tmp_path):
        """Test non-git directory returns unknown values."""
        from audit_logger import get_git_info

        info = get_git_info(str(tmp_path))
        assert info["repo"] == "unknown"
        assert info["branch"] == "unknown"
        assert info["commit"] == "unknown"

    def test_nonexistent_directory(self):
        """Test nonexistent directory returns unknown values."""
        from audit_logger import get_git_info

        info = get_git_info("/nonexistent/path/12345")
        assert info["repo"] == "unknown"
        assert info["branch"] == "unknown"


class TestGetSystemInfo:
    """Tests for get_system_info function."""

    def test_returns_hostname_and_username(self):
        """Test that system info contains hostname and username."""
        from audit_logger import get_system_info

        info = get_system_info()
        assert "hostname" in info
        assert "username" in info
        assert info["hostname"] != ""
        assert info["username"] != ""


class TestFormatLogEntry:
    """Tests for format_log_entry function."""

    def test_format_includes_required_fields(self, sample_hook_input):
        """Test log entry contains all required fields."""
        from audit_logger import format_log_entry

        git_info = {"repo": "test-repo", "branch": "main", "commit": "abc123", "dirty": False}
        system_info = {"hostname": "test-host", "username": "test-user"}

        entry = format_log_entry(sample_hook_input, git_info, system_info)

        assert "SESSION:" in entry
        assert "HOST:test-host" in entry
        assert "USER:test-user" in entry
        assert "REPO: test-repo" in entry
        assert "BRANCH: main" in entry
        assert "COMMAND: git status" in entry
        assert "---" in entry

    def test_format_includes_commit_hash(self, sample_hook_input):
        """Test log entry includes commit hash when available."""
        from audit_logger import format_log_entry

        git_info = {"repo": "test-repo", "branch": "main", "commit": "abc123", "dirty": False}
        system_info = {"hostname": "test-host", "username": "test-user"}

        entry = format_log_entry(sample_hook_input, git_info, system_info)

        assert "@abc123" in entry

    def test_format_includes_dirty_flag(self, sample_hook_input):
        """Test log entry includes dirty flag when repo is dirty."""
        from audit_logger import format_log_entry

        git_info = {"repo": "test-repo", "branch": "main", "commit": "abc123", "dirty": True}
        system_info = {"hostname": "test-host", "username": "test-user"}

        entry = format_log_entry(sample_hook_input, git_info, system_info)

        assert "[dirty]" in entry


class TestMain:
    """Tests for main function."""

    def test_invalid_json_exits_with_code_1(self, temp_claude_dir):
        """Test invalid JSON input exits with code 1."""
        from audit_logger import main

        with patch("sys.stdin", io.StringIO("invalid json {")):
            with pytest.raises(SystemExit) as exc_info:
                main()
            assert exc_info.value.code == 1

    def test_valid_input_creates_log_file(self, temp_claude_dir, sample_hook_input):
        """Test valid input creates audit log file."""
        from audit_logger import main

        input_json = json.dumps(sample_hook_input)

        with patch("sys.stdin", io.StringIO(input_json)):
            with patch("audit_logger.get_git_info") as mock_git:
                mock_git.return_value = {
                    "repo": "test",
                    "branch": "main",
                    "commit": "abc",
                    "dirty": False,
                }
                main()

        log_file = temp_claude_dir / "command-audit.log"
        assert log_file.exists()
        content = log_file.read_text()
        assert "COMMAND: git status" in content

    def test_fallback_cwd_when_not_provided(self, temp_claude_dir):
        """Test fallback to current directory when cwd not in input."""
        from audit_logger import main

        input_data = {
            "hook_event_name": "PreToolUse",
            "tool_name": "Bash",
            "tool_input": {"command": "ls"},
        }

        with patch("sys.stdin", io.StringIO(json.dumps(input_data))):
            with patch("audit_logger.get_git_info") as mock_git:
                mock_git.return_value = {
                    "repo": "test",
                    "branch": "main",
                    "commit": "abc",
                    "dirty": False,
                }
                main()

        log_file = temp_claude_dir / "command-audit.log"
        assert log_file.exists()
