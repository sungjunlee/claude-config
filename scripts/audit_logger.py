#!/usr/bin/env python3
"""
Claude Code Enhanced Audit Logger
Logs detailed command execution information with context.

Exit codes:
    0 - Success
    1 - Invalid JSON input (blocking error)
    2 - Non-critical error (file write failed, unexpected error) - does not block operations
"""

import json
import sys
import shlex
import subprocess
import os
import socket
import getpass
import traceback
from datetime import datetime
from pathlib import Path


def run_command(cmd, cwd=None, timeout=5):
    """Run a command safely with timeout."""
    cmd_list = shlex.split(cmd) if isinstance(cmd, str) else cmd
    try:
        result = subprocess.run(
            cmd_list,
            shell=False,
            capture_output=True,
            text=True,
            timeout=timeout,
            cwd=cwd,
        )
        return result.stdout.strip() if result.returncode == 0 else None
    except (
        subprocess.TimeoutExpired,
        subprocess.SubprocessError,
        FileNotFoundError,
        OSError,
    ) as e:
        print(f"audit_logger: command failed: {' '.join(cmd_list)} ({e})", file=sys.stderr)
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
    repo_root = run_command(["git", "rev-parse", "--show-toplevel"], cwd)
    git_info["repo"] = os.path.basename(repo_root) if repo_root else "unknown"

    # Current branch
    branch = run_command(["git", "branch", "--show-current"], cwd)
    if not branch:
        branch = run_command(["git", "describe", "--tags", "--exact-match"], cwd)
    git_info["branch"] = branch or "unknown"

    # Commit hash (short)
    commit = run_command(["git", "rev-parse", "--short", "HEAD"], cwd)
    git_info["commit"] = commit or "unknown"

    # Check if repo is dirty (opt-in to avoid slowdowns)
    if os.environ.get("CLAUDE_AUDIT_GIT_STATUS") == "1":
        dirty = run_command(["git", "status", "--porcelain"], cwd)
        git_info["dirty"] = bool(dirty)
    else:
        git_info["dirty"] = False

    return git_info


def get_system_info():
    """Get system information"""
    try:
        hostname = socket.gethostname()
    except OSError as e:
        print(f"audit_logger: failed to get hostname: {e}", file=sys.stderr)
        hostname = "unknown"

    try:
        username = getpass.getuser()
    except (OSError, KeyError) as e:
        print(f"audit_logger: failed to get username: {e}", file=sys.stderr)
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
        print(f"audit_logger: Invalid JSON input: {e}", file=sys.stderr)
        sys.exit(1)
    except OSError as e:
        # Audit failure should not block operations; use exit code 2 for monitoring
        print(f"audit_logger: Failed to write log: {e}", file=sys.stderr)
        sys.exit(2)
    except Exception as e:
        # Catch-all for unexpected errors - don't block operations
        print(f"audit_logger: Unexpected error ({type(e).__name__}): {e}", file=sys.stderr)
        print(f"audit_logger: {traceback.format_exc()}", file=sys.stderr)
        sys.exit(2)


if __name__ == "__main__":
    main()
