#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = []
# ///
"""
Unified post-edit hook for all languages.
Automatically formats and checks files based on extension.

Supported:
  - Python (.py, .pyi): ruff format + check
  - TypeScript/JavaScript (.ts, .tsx, .js, .jsx, .mjs, .mts): prettier + eslint
  - Rust (.rs): cargo fmt + clippy
  - Go (.go): gofmt + golangci-lint

Usage: Set in .claude/settings.json PostToolUse hook
Environment variables (from Claude Code):
  - TOOL_USE: The tool that was used (Edit, Write, MultiEdit)
  - FILE_PATH: Path to the edited file
"""

import os
import subprocess
import shutil
import shlex
from pathlib import Path
from typing import Tuple, List, Union, Optional, Callable

# Timeout constants (seconds)
TIMEOUT_FAST = 15
TIMEOUT_DEFAULT = 30
TIMEOUT_SLOW = 60


# =============================================================================
# Core utilities
# =============================================================================

def run_command(
    cmd: Union[str, List[str]],
    timeout: int = TIMEOUT_DEFAULT,
    cwd: Optional[str] = None,
) -> Tuple[bool, str, str]:
    """Run a command securely. Returns (success, stdout, stderr)."""
    cmd_list = shlex.split(cmd) if isinstance(cmd, str) else cmd
    try:
        result = subprocess.run(
            cmd_list, shell=False, capture_output=True, text=True,
            timeout=timeout, cwd=cwd, check=False,
        )
        return result.returncode == 0, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return False, "", f"Timeout ({timeout}s)"
    except FileNotFoundError:
        return False, "", f"Not found: {cmd_list[0]}"
    except OSError as e:
        return False, "", f"OS error: {e}"


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


def resolve_npm_tool(tool: str) -> Optional[List[str]]:
    """Resolve npm tool, falling back to npx."""
    if has_tool(tool):
        return [tool]
    if has_tool("npx"):
        return ["npx", tool]
    return None


def find_project_root(start: str) -> Optional[str]:
    """Find project root by looking for common markers."""
    markers = [".git", "pyproject.toml", "package.json", "Cargo.toml", "go.mod"]
    path = Path(start).resolve()
    for parent in [path] + list(path.parents):
        if any((parent / marker).exists() for marker in markers):
            return str(parent)
    return None


def read_file_safe(filepath: str) -> Optional[str]:
    """Read file content safely, returning None on failure."""
    try:
        return Path(filepath).read_text(encoding="utf-8")
    except FileNotFoundError:
        return None
    except (PermissionError, UnicodeDecodeError, OSError) as e:
        print(f"  ⚠️  read error: {e}")
        return None


# =============================================================================
# Python handler
# =============================================================================

def _run_ruff_format(ruff: List[str], filepath: str) -> None:
    success, stdout, stderr = run_command([*ruff, "format", filepath])
    if success:
        print("  ✓ formatted")
    else:
        msg = stderr or stdout or "unknown error"
        print(f"  ⚠️  format: {msg[:60]}")


def _run_ruff_check(ruff: List[str], filepath: str) -> None:
    success, stdout, stderr = run_command([*ruff, "check", "--fix", "--quiet", filepath])
    if not success:
        output = stderr or stdout or "failed"
        lines = output.strip().split("\n")
        print(f"  ⚠️  check: {lines[0][:60]}")


def _check_python_async(filepath: str) -> None:
    """Check for blocking calls in async code."""
    content = read_file_safe(filepath)
    if not content or "async def" not in content:
        return

    issues = []
    if "time.sleep(" in content:
        issues.append("time.sleep → asyncio.sleep")
    if "requests." in content and "import requests" in content:
        issues.append("requests → httpx/aiohttp")

    if issues:
        print(f"  ⚠️  async: {', '.join(issues)}")


def handle_python(filepath: str) -> None:
    """Handle Python files with ruff."""
    ruff = resolve_tool("ruff")
    if ruff == ["ruff"] and not has_tool("ruff"):
        print("  ⚠️  ruff not found")
        return

    _run_ruff_format(ruff, filepath)
    _run_ruff_check(ruff, filepath)
    _check_python_async(filepath)


# =============================================================================
# TypeScript/JavaScript handler
# =============================================================================

def _run_prettier(filepath: str) -> None:
    prettier = resolve_npm_tool("prettier")
    if not prettier:
        print("  ⚠️  prettier not found")
        return

    success, stdout, stderr = run_command([*prettier, "--write", filepath], timeout=TIMEOUT_FAST)
    if success:
        print("  ✓ prettier")
    elif "No parser" not in (stderr or ""):
        msg = stderr or stdout or "unknown error"
        print(f"  ⚠️  prettier: {msg[:60]}")


def _run_eslint(filepath: str) -> None:
    eslint = resolve_npm_tool("eslint")
    if not eslint:
        print("  ⚠️  eslint not found")
        return

    success, stdout, stderr = run_command([*eslint, "--fix", filepath])
    if success:
        print("  ✓ eslint")
    else:
        output = stdout or stderr or "unknown error"
        lines = output.strip().split("\n")
        print(f"  ⚠️  eslint: {lines[0][:60]}")


def handle_typescript(filepath: str) -> None:
    """Handle TypeScript/JavaScript with prettier + eslint."""
    _run_prettier(filepath)
    _run_eslint(filepath)


# =============================================================================
# Rust handler
# =============================================================================

def _run_cargo_fmt(filepath: str, project_root: str) -> None:
    success, stdout, stderr = run_command(
        ["cargo", "fmt", "--", filepath], cwd=project_root
    )
    if success:
        print("  ✓ cargo fmt")
    else:
        msg = stderr or stdout or "failed"
        print(f"  ⚠️  fmt: {msg[:60]}")


def _run_clippy(filepath: str, project_root: str) -> None:
    success, stdout, stderr = run_command(
        ["cargo", "clippy", "--message-format=short", "-q"],
        cwd=project_root, timeout=TIMEOUT_SLOW,
    )
    output = stdout or stderr
    if output:
        lines = [l for l in output.strip().split("\n") if filepath in l]
        if lines:
            print(f"  ⚠️  clippy: {lines[0][:60]}")


def handle_rust(filepath: str) -> None:
    """Handle Rust files with cargo fmt + clippy."""
    project_root = find_project_root(filepath)
    if not project_root or not Path(project_root, "Cargo.toml").exists():
        print("  ⚠️  No Cargo.toml found")
        return

    if not has_tool("cargo"):
        print("  ⚠️  cargo not found")
        return

    _run_cargo_fmt(filepath, project_root)
    _run_clippy(filepath, project_root)


# =============================================================================
# Go handler
# =============================================================================

def _run_gofmt(filepath: str) -> None:
    if has_tool("gofmt"):
        success, stdout, stderr = run_command(["gofmt", "-w", filepath])
        if success:
            print("  ✓ gofmt")
        else:
            msg = stderr or stdout or "failed"
            print(f"  ⚠️  gofmt: {msg[:60]}")
    elif has_tool("go"):
        success, stdout, stderr = run_command(["go", "fmt", filepath])
        if success:
            print("  ✓ go fmt")
        else:
            msg = stderr or stdout or "failed"
            print(f"  ⚠️  go fmt: {msg[:60]}")
    else:
        print("  ⚠️  gofmt/go not found")


def _run_golangci_lint(filepath: str) -> None:
    if not has_tool("golangci-lint"):
        return

    project_root = find_project_root(filepath)
    if not project_root:
        print("  ⚠️  golangci-lint: no go.mod found")
        return

    success, stdout, stderr = run_command(
        ["golangci-lint", "run", "--fast", filepath],
        cwd=project_root,
    )
    if not success:
        output = stdout or stderr
        if output:
            lines = output.strip().split("\n")
            print(f"  ⚠️  lint: {lines[0][:60]}")


def handle_go(filepath: str) -> None:
    """Handle Go files with gofmt + golangci-lint."""
    _run_gofmt(filepath)
    _run_golangci_lint(filepath)


# =============================================================================
# Extension mapping
# =============================================================================

HANDLERS: dict[str, Callable[[str], None]] = {
    ".py": handle_python, ".pyi": handle_python,
    ".ts": handle_typescript, ".tsx": handle_typescript,
    ".js": handle_typescript, ".jsx": handle_typescript,
    ".mjs": handle_typescript, ".mts": handle_typescript,
    ".rs": handle_rust,
    ".go": handle_go,
}


# =============================================================================
# Main
# =============================================================================

def main() -> None:
    """Main hook execution."""
    tool_use = os.environ.get("TOOL_USE", "")
    file_path = os.environ.get("FILE_PATH", "")

    # Skip non-edit tools (expected, no logging needed)
    if tool_use not in ("Edit", "Write", "MultiEdit"):
        return

    # Log missing file path (helps debugging misconfiguration)
    if not file_path:
        print("⚠️  post_edit: FILE_PATH not set")
        return
    if not os.path.exists(file_path):
        return  # File deleted after edit - acceptable

    ext = Path(file_path).suffix.lower()
    handler = HANDLERS.get(ext)
    if not handler:
        return

    print(f"\n🔧 {Path(file_path).name}")
    try:
        handler(file_path)
    except (OSError, subprocess.SubprocessError) as e:
        print(f"  ⚠️  error: {e}")
    print()


if __name__ == "__main__":
    main()
