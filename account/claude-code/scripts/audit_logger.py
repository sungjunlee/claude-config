#!/usr/bin/env -S uv run --quiet --with python-dateutil python3
"""
Claude Code Enhanced Audit Logger
Logs detailed command execution information with context
"""

import json
import sys
import subprocess
import os
import socket
import getpass
from datetime import datetime
from pathlib import Path


def run_command(cmd, cwd=None, timeout=5):
    """Run a command safely with timeout"""
    try:
        result = subprocess.run(
            cmd, shell=True, capture_output=True, text=True, timeout=timeout, cwd=cwd
        )
        return result.stdout.strip() if result.returncode == 0 else None
    except (subprocess.TimeoutExpired, subprocess.SubprocessError, FileNotFoundError):
        return None


def get_git_info(cwd):
    """Get Git repository information"""
    git_info = {}

    # Check if directory exists
    if not os.path.exists(cwd):
        return {
            "repo": "unknown",
            "branch": "unknown",
            "commit": "unknown",
            "dirty": False,
        }

    # Repository name
    repo_name = run_command("basename `git rev-parse --show-toplevel`", cwd)
    git_info["repo"] = repo_name or "unknown"

    # Current branch
    branch = run_command("git branch --show-current", cwd)
    if not branch:
        branch = run_command("git describe --tags --exact-match", cwd)
    git_info["branch"] = branch or "unknown"

    # Commit hash (short)
    commit = run_command("git rev-parse --short HEAD", cwd)
    git_info["commit"] = commit or "unknown"

    # Check if repo is dirty
    dirty = run_command("git status --porcelain", cwd)
    git_info["dirty"] = bool(dirty)

    return git_info


def get_system_info():
    """Get system information"""
    try:
        hostname = socket.gethostname()
    except Exception:
        hostname = "unknown"

    try:
        username = getpass.getuser()
    except Exception:
        username = "unknown"

    return {"hostname": hostname, "username": username}


def format_log_entry(hook_data, git_info, system_info):
    """Format the log entry"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]

    # Extract command info
    tool_input = hook_data.get("tool_input", {})
    command = tool_input.get("command", "unknown")
    description = tool_input.get("description", "No description")

    # Build log entry
    lines = [
        f"[{timestamp}] SESSION:{hook_data.get('session_id', 'unknown')[:8]} "
        f"HOST:{system_info['hostname']} USER:{system_info['username']}",
        f"CWD: {hook_data.get('cwd', 'unknown')} "
        f"REPO: {git_info['repo']} "
        f"BRANCH: {git_info['branch']}"
        + (f"@{git_info['commit']}" if git_info["commit"] != "unknown" else "")
        + (" [dirty]" if git_info.get("dirty") else ""),
        f"COMMAND: {command}",
        f"DESCRIPTION: {description}",
        f"EVENT: {hook_data.get('hook_event_name', 'unknown')} "
        f"TOOL: {hook_data.get('tool_name', 'unknown')}",
        "---",
    ]

    return "\n".join(lines)


def main():
    try:
        # Read JSON input from stdin
        input_data = json.load(sys.stdin)

        # Get current working directory
        cwd = input_data.get("cwd")
        if not cwd:
            try:
                cwd = os.getcwd()
            except OSError:
                # Current directory doesn't exist
                cwd = os.path.expanduser("~")

        # Validate and fallback to home if cwd doesn't exist
        if not os.path.exists(cwd):
            cwd = os.path.expanduser("~")

        # Collect information
        git_info = get_git_info(cwd)
        system_info = get_system_info()

        # Format and write log entry
        log_entry = format_log_entry(input_data, git_info, system_info)

        # Ensure log directory exists and append to audit log
        log_file = Path.home() / ".claude" / "command-audit.log"
        log_file.parent.mkdir(parents=True, exist_ok=True)
        with open(log_file, "a", encoding="utf-8") as f:
            f.write(log_entry + "\n")

        # Silent operation - no output unless error

    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON input: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
