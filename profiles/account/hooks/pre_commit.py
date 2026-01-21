#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = []
# ///
"""
Pre-commit hook for Python projects.
Ensures code quality before committing.

Usage:
  - As git pre-commit hook
  - As Claude Code PreToolUse hook (matcher: "Bash" with git commit)
"""

import os
import sys
import subprocess
import shutil
import shlex
from pathlib import Path
from typing import Tuple, List, Union


def run_command(cmd: Union[str, List[str]], timeout: int = 30) -> Tuple[bool, str, str]:
    """Run a command and return (success, stdout, stderr)."""
    cmd_list = shlex.split(cmd) if isinstance(cmd, str) else cmd
    try:
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
        return False, "", "Command timed out"
    except FileNotFoundError:
        return False, "", f"Command not found: {cmd_list[0]}"
    except OSError as e:
        return False, "", f"OS error: {e}"


def check_tool(tool: str) -> bool:
    """Check if a tool is available."""
    return shutil.which(tool) is not None


def resolve_tool(tool: str) -> List[str]:
    """Resolve tool to command, falling back to uvx."""
    if check_tool(tool):
        return [tool]
    if shutil.which("uvx"):
        return ["uvx", tool]
    return [tool]


def check_formatting() -> bool:
    """Check if all Python files are formatted."""
    print("🎨 Checking formatting...")
    ruff = resolve_tool("ruff")
    success, output, _ = run_command([*ruff, "format", "--check", "."])

    if not success:
        print("❌ Formatting issues. Run: ruff format .")
        return False

    print("✅ Formatting OK")
    return True


def check_linting() -> bool:
    """Check for linting issues."""
    print("🔍 Running linter...")
    ruff = resolve_tool("ruff")
    success, output, error = run_command([*ruff, "check", "."])

    if not success:
        print("❌ Linting issues:")
        print((output or error)[:500])
        print("\nRun: ruff check --fix .")
        return False

    print("✅ Linting OK")
    return True


def check_types() -> bool:
    """Run type checking with mypy (optional)."""
    if not check_tool("mypy"):
        return True  # Skip if not available

    # Check if mypy is configured
    has_config = any([
        Path("mypy.ini").exists(),
        Path("pyproject.toml").exists(),
        Path("setup.cfg").exists(),
    ])

    if not has_config:
        return True  # Skip if not configured

    print("📝 Checking types...")
    success, output, error = run_command(["mypy", "."], timeout=60)

    if not success:
        # Ignore missing stubs
        if "Cannot find implementation or library stub" in (output + error):
            print("⚠️  Some type stubs missing (non-blocking)")
            return True

        print("❌ Type errors:")
        print((output or error)[:500])
        return False

    print("✅ Types OK")
    return True


def check_security() -> bool:
    """Basic security checks for hardcoded secrets."""
    print("🔒 Security check...")

    # Patterns to search for
    patterns = [
        ("api_key.*=.*['\"]", "API key"),
        ("password.*=.*['\"]", "Password"),
        ("secret.*=.*['\"]", "Secret"),
        ("token.*=.*['\"]", "Token"),
    ]

    found_issues = []

    for pattern, name in patterns:
        success, output, _ = run_command(
            ["grep", "-r", "-n", "-E", pattern, "--include=*.py", "."]
        )

        if success and output:
            lines = output.strip().split("\n")
            # Filter out false positives
            real_issues = [
                line
                for line in lines
                if not any(
                    safe in line.lower()
                    for safe in [
                        "example",
                        "test",
                        "mock",
                        "fake",
                        "dummy",
                        "getenv",
                        "environ",
                        "config",
                        "setting",
                        "# ",
                    ]
                )
            ]

            if real_issues:
                found_issues.extend(real_issues[:2])

    if found_issues:
        print("⚠️  Potential hardcoded secrets:")
        for issue in found_issues[:5]:
            print(f"  {issue[:100]}")
        print("\nConsider using environment variables.")
        # Warning only, not blocking
        return True

    print("✅ Security OK")
    return True


def main() -> int:
    """Main pre-commit hook."""
    print("\n🐍 Python Pre-commit Check\n")

    checks = [
        ("Formatting", check_formatting),
        ("Linting", check_linting),
        ("Types", check_types),
        ("Security", check_security),
    ]

    failed = []
    for name, check_func in checks:
        try:
            if not check_func():
                failed.append(name)
        except (OSError, subprocess.SubprocessError) as e:
            print(f"⚠️  {name} error: {e}")
            failed.append(name)

    print("\n" + "=" * 40)

    if failed:
        print(f"❌ Failed: {', '.join(failed)}")
        print("Fix the issues and try again.")
        return 1

    print("✅ All checks passed!")
    return 0


if __name__ == "__main__":
    sys.exit(main())
