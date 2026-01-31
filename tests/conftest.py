"""Pytest configuration and shared fixtures."""

import json
import os
import sys
from pathlib import Path

import pytest

# Add scripts directory to path for imports
REPO_ROOT = Path(__file__).parent.parent
sys.path.insert(0, str(REPO_ROOT / "scripts"))
sys.path.insert(0, str(REPO_ROOT / "scripts" / "hooks"))


@pytest.fixture
def temp_home(tmp_path):
    """Create a temporary HOME directory for testing."""
    home = tmp_path / "home"
    home.mkdir()
    old_home = os.environ.get("HOME")
    os.environ["HOME"] = str(home)
    yield home
    if old_home:
        os.environ["HOME"] = old_home


@pytest.fixture
def temp_claude_dir(temp_home):
    """Create a temporary ~/.claude directory."""
    claude_dir = temp_home / ".claude"
    claude_dir.mkdir()
    return claude_dir


@pytest.fixture
def sample_hook_input():
    """Sample input data for hook testing."""
    return {
        "hook_event_name": "PreToolUse",
        "tool_name": "Bash",
        "tool_input": {
            "command": "git status",
            "description": "Check git status",
        },
        "session_id": "test-session-12345678",
        "cwd": "/tmp/test-project",
    }


@pytest.fixture
def sample_hook_input_json(sample_hook_input):
    """Sample input as JSON string."""
    return json.dumps(sample_hook_input)


@pytest.fixture
def python_file(tmp_path):
    """Create a temporary Python file."""
    py_file = tmp_path / "test_file.py"
    py_file.write_text("def foo():\n    x=1\n")
    return py_file


@pytest.fixture
def typescript_file(tmp_path):
    """Create a temporary TypeScript file."""
    ts_file = tmp_path / "test_file.ts"
    ts_file.write_text("const x = 1;\n")
    return ts_file


@pytest.fixture
def rust_file(tmp_path):
    """Create a temporary Rust file with Cargo.toml."""
    rust_dir = tmp_path / "rust_project"
    rust_dir.mkdir()
    (rust_dir / "Cargo.toml").write_text('[package]\nname = "test"\n')
    rs_file = rust_dir / "main.rs"
    rs_file.write_text("fn main() {}\n")
    return rs_file


@pytest.fixture
def go_file(tmp_path):
    """Create a temporary Go file with go.mod."""
    go_dir = tmp_path / "go_project"
    go_dir.mkdir()
    (go_dir / "go.mod").write_text("module test\n")
    go_file = go_dir / "main.go"
    go_file.write_text("package main\n")
    return go_file
