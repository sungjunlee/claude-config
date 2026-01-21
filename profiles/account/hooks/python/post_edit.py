#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = []
# ///
"""
Post-edit hook for Python files.
Automatically formats and checks Python files after editing.

Usage: Set in .claude/settings.json PostToolUse hook
Environment variables (from Claude Code):
  - TOOL_USE: The tool that was used (Edit, Write, MultiEdit)
  - FILE_PATH: Path to the edited file
"""

import os
import sys
import subprocess
import shutil
import shlex
from pathlib import Path
from typing import Tuple, List, Union


def run_command(cmd: Union[str, List[str]], timeout: int = 10) -> Tuple[bool, str, str]:
    """Run a command securely without shell=True."""
    try:
        if isinstance(cmd, str):
            cmd_list = shlex.split(cmd)
        else:
            cmd_list = cmd

        result = subprocess.run(
            cmd_list,
            shell=False,
            capture_output=True,
            text=True,
            timeout=timeout,
            check=False,
        )
        return result.returncode == 0, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return False, "", f"Command timed out after {timeout} seconds"
    except FileNotFoundError:
        return False, "", f"Command not found: {cmd_list[0] if cmd_list else cmd}"
    except Exception as e:
        return False, "", str(e)


def check_tool_availability(tool: str) -> bool:
    """Check if a tool is available on PATH."""
    return shutil.which(tool) is not None


def resolve_tool(tool: str) -> List[str]:
    """Return the executable argv for a tool, preferring system binary, falling back to uvx."""
    if check_tool_availability(tool):
        return [tool]
    if shutil.which("uvx"):
        return ["uvx", tool]
    return [tool]


def format_python_file(filepath: str) -> None:
    """Format Python file with ruff."""
    ruff = resolve_tool("ruff")

    if ruff == ["ruff"] and not check_tool_availability("ruff"):
        print("⚠️  Ruff not found. Install: pip install ruff")
        return

    print(f"🎨 Formatting {filepath}...")

    # Format with ruff
    success, stdout, stderr = run_command([*ruff, "format", filepath])
    if success:
        print("✅ Formatted")
    else:
        error_msg = stderr or stdout
        if "not found" in error_msg.lower():
            print("⚠️  Ruff not found")
        else:
            print(f"⚠️  Format failed: {error_msg[:100]}")

    # Fix imports and safe issues
    success, stdout, stderr = run_command([*ruff, "check", "--fix", "--quiet", filepath])
    if not success and stderr and "error" in stderr.lower():
        print(f"⚠️  Some issues couldn't be auto-fixed")


def check_async_patterns(filepath: str) -> None:
    """Check for common async/await issues in FastAPI files."""
    try:
        with open(filepath, "r") as f:
            content = f.read()
    except Exception:
        return

    # Check if it's likely a FastAPI/async file
    if "fastapi" not in content.lower() and "async def" not in content:
        return

    issues = []
    blocking_patterns = [
        ("time.sleep(", "Use await asyncio.sleep() instead"),
        ("requests.", "Use httpx or aiohttp for async requests"),
    ]

    for pattern, suggestion in blocking_patterns:
        if pattern in content and "async def" in content:
            issues.append(f"⚠️  Found '{pattern}': {suggestion}")

    # Check for missing await
    lines = content.split("\n")
    for i, line in enumerate(lines, 1):
        if "asyncio.sleep(" in line and "await" not in line:
            issues.append(f"⚠️  Line {i}: Missing 'await' before asyncio.sleep()")

    if issues:
        print("\n🔍 Async pattern issues:")
        for issue in issues[:3]:
            print(f"  {issue}")


def check_type_hints(filepath: str) -> None:
    """Quick type hint check with mypy (if available)."""
    if not check_tool_availability("mypy"):
        return

    success, stdout, stderr = run_command(
        ["mypy", "--no-error-summary", "--no-pretty", "--ignore-missing-imports", filepath],
        timeout=15,
    )

    if not success and (stdout or stderr):
        output = stdout or stderr
        issues = [
            line.strip()
            for line in output.split("\n")
            if "error:" in line.lower() and not "Cannot find implementation" in line
        ]

        if issues:
            print("\n📝 Type issues:")
            for issue in issues[:3]:
                # Shorten the output
                short = issue.split(":")[-1].strip() if ":" in issue else issue
                print(f"  {short[:80]}")


def main() -> None:
    """Main hook execution."""
    tool_use = os.environ.get("TOOL_USE", "")
    file_path = os.environ.get("FILE_PATH", "")

    # Only process Edit/Write tools
    if tool_use not in ("Edit", "Write", "MultiEdit"):
        return

    # Only process Python files
    if not file_path.endswith(".py"):
        return

    # Check if file exists
    if not os.path.exists(file_path):
        return

    print(f"\n🐍 Python post-edit: {Path(file_path).name}")

    format_python_file(file_path)
    check_async_patterns(file_path)
    check_type_hints(file_path)

    print("✅ Done\n")


if __name__ == "__main__":
    main()
