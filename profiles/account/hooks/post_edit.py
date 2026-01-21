#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = []
# ///
"""
Unified post-edit hook for all languages.
Automatically formats and checks files based on extension.

Supported:
  - Python (.py): ruff format + check
  - TypeScript/JavaScript (.ts, .tsx, .js, .jsx): prettier + eslint
  - Rust (.rs): cargo fmt + clippy
  - Go (.go): gofmt + golangci-lint

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
from typing import Tuple, List, Union, Optional, Callable


# =============================================================================
# Core utilities
# =============================================================================

def run_command(
    cmd: Union[str, List[str]],
    timeout: int = 30,
    cwd: Optional[str] = None
) -> Tuple[bool, str, str]:
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
            cwd=cwd,
            check=False,
        )
        return result.returncode == 0, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return False, "", f"Timeout after {timeout}s"
    except FileNotFoundError:
        return False, "", f"Not found: {cmd_list[0] if cmd_list else 'unknown'}"
    except Exception as e:
        return False, "", str(e)


def has_tool(tool: str) -> bool:
    """Check if a tool is available on PATH."""
    return shutil.which(tool) is not None


def resolve_tool(tool: str, fallback_uvx: bool = True) -> List[str]:
    """Resolve tool to command, optionally falling back to uvx."""
    if has_tool(tool):
        return [tool]
    if fallback_uvx and has_tool("uvx"):
        return ["uvx", tool]
    return [tool]


def find_project_root(start: str) -> Optional[str]:
    """Find project root by looking for common markers."""
    markers = [".git", "pyproject.toml", "package.json", "Cargo.toml", "go.mod"]
    path = Path(start).resolve()

    for parent in [path] + list(path.parents):
        if any((parent / marker).exists() for marker in markers):
            return str(parent)
    return None


# =============================================================================
# Language handlers
# =============================================================================

def handle_python(filepath: str) -> None:
    """Handle Python files with ruff."""
    ruff = resolve_tool("ruff")

    if ruff == ["ruff"] and not has_tool("ruff"):
        print("  ⚠️  ruff not found")
        return

    # Format
    success, _, stderr = run_command([*ruff, "format", filepath])
    if success:
        print("  ✓ formatted")
    else:
        print(f"  ⚠️  format: {stderr[:50]}")

    # Fix
    success, stdout, stderr = run_command([*ruff, "check", "--fix", "--quiet", filepath])
    if not success and stderr:
        # Show first issue only
        lines = stderr.strip().split("\n")
        if lines and "error" in lines[0].lower():
            print(f"  ⚠️  {lines[0][:60]}")

    # Async pattern check for FastAPI
    _check_python_async(filepath)


def _check_python_async(filepath: str) -> None:
    """Check for blocking calls in async code."""
    try:
        content = Path(filepath).read_text()
    except Exception:
        return

    if "async def" not in content:
        return

    issues = []
    if "time.sleep(" in content:
        issues.append("time.sleep → asyncio.sleep")
    if "requests." in content and "import requests" in content:
        issues.append("requests → httpx/aiohttp")

    if issues:
        print(f"  ⚠️  async: {', '.join(issues)}")


def handle_typescript(filepath: str) -> None:
    """Handle TypeScript/JavaScript with prettier + eslint."""
    # Prettier
    if has_tool("prettier") or has_tool("npx"):
        prettier = ["prettier"] if has_tool("prettier") else ["npx", "prettier"]
        success, _, stderr = run_command([*prettier, "--write", filepath], timeout=15)
        if success:
            print("  ✓ prettier")
        elif "No parser" not in stderr:
            print(f"  ⚠️  prettier failed")

    # ESLint fix
    if has_tool("eslint") or has_tool("npx"):
        eslint = ["eslint"] if has_tool("eslint") else ["npx", "eslint"]
        success, _, stderr = run_command([*eslint, "--fix", filepath], timeout=30)
        if success:
            print("  ✓ eslint")
        elif stderr and "error" in stderr.lower():
            lines = stderr.strip().split("\n")
            print(f"  ⚠️  eslint: {lines[0][:50]}")


def handle_rust(filepath: str) -> None:
    """Handle Rust files with cargo fmt + clippy."""
    project_root = find_project_root(filepath)
    if not project_root or not Path(project_root, "Cargo.toml").exists():
        print("  ⚠️  No Cargo.toml found")
        return

    # cargo fmt
    if has_tool("cargo"):
        success, _, stderr = run_command(
            ["cargo", "fmt", "--", filepath],
            cwd=project_root,
            timeout=30
        )
        if success:
            print("  ✓ cargo fmt")
        else:
            print(f"  ⚠️  fmt: {stderr[:50]}")

        # clippy (just warnings, no fix)
        success, stdout, _ = run_command(
            ["cargo", "clippy", "--message-format=short", "-q"],
            cwd=project_root,
            timeout=60
        )
        if stdout:
            lines = [l for l in stdout.strip().split("\n") if filepath in l]
            if lines:
                print(f"  ⚠️  clippy: {lines[0][:60]}")


def handle_go(filepath: str) -> None:
    """Handle Go files with gofmt + golangci-lint."""
    # gofmt
    if has_tool("gofmt"):
        success, _, stderr = run_command(["gofmt", "-w", filepath])
        if success:
            print("  ✓ gofmt")
        else:
            print(f"  ⚠️  gofmt: {stderr[:50]}")
    elif has_tool("go"):
        success, _, _ = run_command(["go", "fmt", filepath])
        if success:
            print("  ✓ go fmt")

    # golangci-lint (if available)
    if has_tool("golangci-lint"):
        project_root = find_project_root(filepath)
        if project_root:
            success, stdout, _ = run_command(
                ["golangci-lint", "run", "--fast", filepath],
                cwd=project_root,
                timeout=30
            )
            if not success and stdout:
                lines = stdout.strip().split("\n")
                print(f"  ⚠️  lint: {lines[0][:60]}")


# =============================================================================
# Extension mapping
# =============================================================================

HANDLERS: dict[str, Callable[[str], None]] = {
    # Python
    ".py": handle_python,
    ".pyi": handle_python,

    # TypeScript / JavaScript
    ".ts": handle_typescript,
    ".tsx": handle_typescript,
    ".js": handle_typescript,
    ".jsx": handle_typescript,
    ".mjs": handle_typescript,
    ".mts": handle_typescript,

    # Rust
    ".rs": handle_rust,

    # Go
    ".go": handle_go,
}


# =============================================================================
# Main
# =============================================================================

def main() -> None:
    """Main hook execution."""
    tool_use = os.environ.get("TOOL_USE", "")
    file_path = os.environ.get("FILE_PATH", "")

    # Only process Edit/Write tools
    if tool_use not in ("Edit", "Write", "MultiEdit"):
        return

    # Check file exists
    if not file_path or not os.path.exists(file_path):
        return

    # Get extension
    ext = Path(file_path).suffix.lower()
    handler = HANDLERS.get(ext)

    if not handler:
        return  # Unsupported file type, silently skip

    # Run handler
    filename = Path(file_path).name
    print(f"\n🔧 {filename}")

    try:
        handler(file_path)
    except Exception as e:
        print(f"  ⚠️  error: {e}")

    print()


if __name__ == "__main__":
    main()
