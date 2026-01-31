"""Tests for post_edit.py."""

import os
import sys
from pathlib import Path
from unittest.mock import patch, MagicMock

import pytest


class TestParseTimeout:
    """Tests for parse_timeout function."""

    def test_valid_integer(self):
        """Test valid integer string."""
        from post_edit import parse_timeout

        assert parse_timeout("30", 60) == 30

    def test_none_returns_default(self):
        """Test None returns default value."""
        from post_edit import parse_timeout

        assert parse_timeout(None, 60) == 60

    def test_invalid_string_returns_default(self):
        """Test invalid string returns default."""
        from post_edit import parse_timeout

        assert parse_timeout("invalid", 60) == 60

    def test_negative_returns_default(self):
        """Test negative value returns default."""
        from post_edit import parse_timeout

        assert parse_timeout("-10", 60) == 60

    def test_zero_returns_default(self):
        """Test zero returns default."""
        from post_edit import parse_timeout

        assert parse_timeout("0", 60) == 60


class TestRunCommand:
    """Tests for run_command function."""

    def test_successful_command(self):
        """Test successful command returns True and output."""
        from post_edit import run_command

        ok, output = run_command("echo hello")
        assert ok is True
        assert "hello" in output

    def test_failed_command(self):
        """Test failed command returns False."""
        from post_edit import run_command

        ok, output = run_command("false")
        assert ok is False

    def test_command_not_found(self):
        """Test non-existent command returns False with message."""
        from post_edit import run_command

        ok, output = run_command("nonexistent_command_12345")
        assert ok is False
        assert "not found" in output.lower()

    def test_timeout(self):
        """Test command timeout returns False with message."""
        from post_edit import run_command

        ok, output = run_command("sleep 10", timeout=1)
        assert ok is False
        assert "timed out" in output.lower()


class TestHasTool:
    """Tests for has_tool function."""

    def test_existing_tool(self):
        """Test existing tool returns True."""
        from post_edit import has_tool

        assert has_tool("python3") is True

    def test_nonexistent_tool(self):
        """Test non-existent tool returns False."""
        from post_edit import has_tool

        assert has_tool("nonexistent_tool_12345") is False


class TestResolveTool:
    """Tests for resolve_tool function."""

    def test_existing_tool(self):
        """Test existing tool returns tool name."""
        from post_edit import resolve_tool

        result = resolve_tool("python3")
        assert result == ["python3"]

    def test_nonexistent_tool_with_uvx(self):
        """Test non-existent tool falls back to uvx if available."""
        from post_edit import resolve_tool

        with patch("post_edit.has_tool") as mock_has:
            mock_has.side_effect = lambda t: t == "uvx"
            result = resolve_tool("ruff")
            assert result == ["uvx", "ruff"]

    def test_nonexistent_tool_without_fallback(self):
        """Test non-existent tool returns empty list."""
        from post_edit import resolve_tool

        with patch("post_edit.has_tool", return_value=False):
            result = resolve_tool("nonexistent")
            assert result == []


class TestFindProjectRoot:
    """Tests for find_project_root function."""

    def test_git_directory(self, tmp_path):
        """Test finds project root with .git directory."""
        from post_edit import find_project_root

        git_dir = tmp_path / ".git"
        git_dir.mkdir()
        subdir = tmp_path / "src" / "lib"
        subdir.mkdir(parents=True)

        result = find_project_root(str(subdir / "file.py"))
        assert result == str(tmp_path)

    def test_pyproject_toml(self, tmp_path):
        """Test finds project root with pyproject.toml."""
        from post_edit import find_project_root

        (tmp_path / "pyproject.toml").touch()
        subdir = tmp_path / "src"
        subdir.mkdir()

        result = find_project_root(str(subdir / "file.py"))
        assert result == str(tmp_path)

    def test_no_project_markers(self, tmp_path):
        """Test returns None when no project markers found."""
        from post_edit import find_project_root

        subdir = tmp_path / "isolated"
        subdir.mkdir()

        result = find_project_root(str(subdir / "file.py"))
        assert result is None


class TestHandlers:
    """Tests for HANDLERS dictionary."""

    def test_python_extensions_mapped(self):
        """Test Python file extensions are mapped."""
        from post_edit import HANDLERS

        assert ".py" in HANDLERS
        assert ".pyi" in HANDLERS

    def test_typescript_extensions_mapped(self):
        """Test TypeScript/JavaScript extensions are mapped."""
        from post_edit import HANDLERS

        for ext in [".ts", ".tsx", ".js", ".jsx", ".mjs", ".mts"]:
            assert ext in HANDLERS

    def test_rust_extension_mapped(self):
        """Test Rust file extension is mapped."""
        from post_edit import HANDLERS

        assert ".rs" in HANDLERS

    def test_go_extension_mapped(self):
        """Test Go file extension is mapped."""
        from post_edit import HANDLERS

        assert ".go" in HANDLERS

    def test_unknown_extension_not_mapped(self):
        """Test unknown extensions are not mapped."""
        from post_edit import HANDLERS

        assert ".xyz" not in HANDLERS
        assert ".txt" not in HANDLERS


class TestMain:
    """Tests for main function."""

    def test_missing_tool_use_env_returns_early(self, capsys):
        """Test missing TOOL_USE env var prints warning."""
        from post_edit import main

        with patch.dict(os.environ, {}, clear=True):
            main()

        captured = capsys.readouterr()
        assert "WARNING" in captured.err or captured.out == ""

    def test_non_edit_tool_returns_early(self):
        """Test non-edit tool returns early without processing."""
        from post_edit import main

        with patch.dict(os.environ, {"TOOL_USE": "Read", "FILE_PATH": "/test.py"}):
            main()  # Should return without error

    def test_missing_file_path_returns_early(self, capsys):
        """Test missing FILE_PATH env var prints warning."""
        from post_edit import main

        with patch.dict(os.environ, {"TOOL_USE": "Edit"}, clear=True):
            main()

        captured = capsys.readouterr()
        assert "WARNING" in captured.err or captured.out == ""

    def test_nonexistent_file_returns_early(self):
        """Test nonexistent file returns early."""
        from post_edit import main

        with patch.dict(
            os.environ,
            {"TOOL_USE": "Edit", "FILE_PATH": "/nonexistent/file.py"},
        ):
            main()  # Should return without error

    def test_unknown_extension_returns_early(self, tmp_path):
        """Test unknown file extension returns early."""
        from post_edit import main

        txt_file = tmp_path / "test.txt"
        txt_file.write_text("hello")

        with patch.dict(
            os.environ,
            {"TOOL_USE": "Edit", "FILE_PATH": str(txt_file)},
        ):
            main()  # Should return without error

    def test_python_file_triggers_formatting(self, python_file, capsys):
        """Test Python file triggers formatting output."""
        from post_edit import main

        with patch.dict(
            os.environ,
            {"TOOL_USE": "Edit", "FILE_PATH": str(python_file)},
        ):
            main()

        captured = capsys.readouterr()
        # Should show the file being processed
        assert "test_file.py" in captured.out


class TestHandlePython:
    """Tests for handle_python function."""

    def test_no_ruff_prints_warning(self, python_file, capsys):
        """Test missing ruff prints warning."""
        from post_edit import handle_python

        with patch("post_edit.resolve_tool", return_value=[]):
            handle_python(str(python_file))

        captured = capsys.readouterr()
        assert "ruff not found" in captured.out

    def test_ruff_format_called(self, python_file):
        """Test ruff format is called."""
        from post_edit import handle_python

        with patch("post_edit.resolve_tool", return_value=["ruff"]):
            with patch("post_edit.run_command") as mock_run:
                mock_run.return_value = (True, "")
                handle_python(str(python_file))

                # Check format was called
                calls = [str(c) for c in mock_run.call_args_list]
                assert any("format" in c for c in calls)


class TestExceptionHandling:
    """Tests for exception handling in main."""

    def test_oserror_prints_error_message(self, python_file, capsys):
        """Test OSError prints error message to stderr."""
        from post_edit import main

        with patch.dict(
            os.environ,
            {"TOOL_USE": "Edit", "FILE_PATH": str(python_file)},
        ):
            with patch("post_edit.HANDLERS", {".py": MagicMock(side_effect=OSError("test error"))}):
                try:
                    main()
                except SystemExit as e:
                    assert e.code == 2

        captured = capsys.readouterr()
        assert "error" in captured.err.lower() or "error" in captured.out.lower()

    def test_subprocess_error_prints_error_message(self, python_file, capsys):
        """Test SubprocessError prints error message to stderr."""
        import subprocess
        from post_edit import main

        with patch.dict(
            os.environ,
            {"TOOL_USE": "Edit", "FILE_PATH": str(python_file)},
        ):
            with patch("post_edit.HANDLERS", {".py": MagicMock(side_effect=subprocess.SubprocessError("test error"))}):
                try:
                    main()
                except SystemExit as e:
                    assert e.code == 2

        captured = capsys.readouterr()
        assert "error" in captured.err.lower() or "error" in captured.out.lower()
