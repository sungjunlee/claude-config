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

TIMEOUT = int(os.environ.get("CLAUDE_HOOK_TIMEOUT", "60"))


def run_command(
    cmd: Union[str, List[str]],
    timeout: int = TIMEOUT,
    cwd: Optional[str] = None,
) -> Tuple[bool, str]:
    """Run a command. Returns (success, output)."""
    cmd_list = shlex.split(cmd) if isinstance(cmd, str) else cmd
    try:
        result = subprocess.run(
            cmd_list,
            shell=False,
            capture_output=True,
            text=True,
            timeout=timeout,
            cwd=cwd,
            check=False,
        )
        output = result.stdout or result.stderr or ""
        return result.returncode == 0, output.strip()
    except subprocess.TimeoutExpired:
        return False, "Command timed out"
    except FileNotFoundError:
        return False, f"Command not found: {cmd_list[0]}"
    except OSError as e:
        return False, f"OS error: {e}"


def has_tool(tool: str) -> bool:
    return shutil.which(tool) is not None


def resolve_tool(tool: str) -> List[str]:
    """Resolve tool, falling back to uvx if available."""
    if has_tool(tool):
        return [tool]
    if has_tool("uvx"):
        return ["uvx", tool]
    return []


def resolve_npm_tool(tool: str) -> List[str]:
    """Resolve npm tool, falling back to npx."""
    if has_tool(tool):
        return [tool]
    if has_tool("npx"):
        return ["npx", tool]
    return []


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
    if not ruff:
        print("  ⚠️  ruff not found")
        return

    ok, _ = run_command([*ruff, "format", filepath])
    print("  ✓ formatted" if ok else "  ⚠️  format failed")

    ok, out = run_command([*ruff, "check", "--fix", "--quiet", filepath])
    if not ok:
        lines = out.strip().split("\n") if out else ["Linting failed"]
        print(f"  ⚠️  Linting failed:")
        for line in lines[:3]:
            print(f"      {line}")


def handle_typescript(filepath: str) -> None:
    """Handle TypeScript/JavaScript with prettier + eslint."""
    prettier = resolve_npm_tool("prettier")
    if prettier:
        ok, out = run_command([*prettier, "--write", filepath], timeout=15)
        if ok:
            print("  ✓ prettier")
        else:
            print(
                f"  ⚠️  prettier failed: {out.strip().splitlines()[0] if out else 'Unknown error'}"
            )
    else:
        print("  ⚠️  prettier not found")

    eslint = resolve_npm_tool("eslint")
    if eslint:
        ok, out = run_command([*eslint, "--fix", filepath])
        if ok:
            print("  ✓ eslint")
        else:
            print(f"  ⚠️  eslint failed:")
            lines = out.strip().split("\n") if out else ["Unknown error"]
            for line in lines[:3]:
                print(f"      {line}")
    else:
        print("  ⚠️  eslint not found")


def handle_rust(filepath: str) -> None:
    """Handle Rust files with cargo fmt + clippy."""
    project_root = find_project_root(filepath)
    if not project_root or not Path(project_root, "Cargo.toml").exists():
        print("  ⚠️  No Cargo.toml found")
        return
    if not has_tool("cargo"):
        print("  ⚠️  cargo not found")
        return

    ok, _ = run_command(["cargo", "fmt", "--", filepath], cwd=project_root)
    print("  ✓ cargo fmt" if ok else "  ⚠️  fmt failed")

    ok, out = run_command(
        ["cargo", "clippy", "--message-format=short", "-q"],
        cwd=project_root,
        timeout=60,
    )
    relevant = [l for l in out.split("\n") if filepath in l] if out else []
    if relevant:
        print(f"  ⚠️  {relevant[0]}")
    elif not ok:
        lines = out.strip().split("\n") if out else ["clippy failed"]
        print(f"  ⚠️  {lines[0]}")


def handle_go(filepath: str) -> None:
    """Handle Go files with gofmt + golangci-lint."""
    if has_tool("gofmt"):
        ok, _ = run_command(["gofmt", "-w", filepath])
        print("  ✓ gofmt" if ok else "  ⚠️  gofmt failed")
    elif has_tool("go"):
        ok, _ = run_command(["go", "fmt", filepath])
        print("  ✓ go fmt" if ok else "  ⚠️  go fmt failed")
    else:
        print("  ⚠️  gofmt/go not found")

    if has_tool("golangci-lint"):
        project_root = find_project_root(filepath)
        if project_root and Path(project_root, "go.mod").exists():
            ok, out = run_command(
                ["golangci-lint", "run", "--fast", filepath], cwd=project_root
            )
            if not ok:
                lines = out.strip().split("\n") if out else ["golangci-lint failed"]
                print(f"  ⚠️  {lines[0]}")


# =============================================================================
# Extension mapping and main
# =============================================================================

HANDLERS: dict[str, Callable[[str], None]] = {
    ".py": handle_python,
    ".pyi": handle_python,
    ".ts": handle_typescript,
    ".tsx": handle_typescript,
    ".js": handle_typescript,
    ".jsx": handle_typescript,
    ".mjs": handle_typescript,
    ".mts": handle_typescript,
    ".rs": handle_rust,
    ".go": handle_go,
}


def main() -> None:
    tool_use = os.environ.get("TOOL_USE", "")
    file_path = os.environ.get("FILE_PATH", "")

    if tool_use not in ("Edit", "Write", "MultiEdit"):
        return
    if not file_path or not os.path.exists(file_path):
        return

    ext = Path(file_path).suffix.lower()
    handler = HANDLERS.get(ext)
    if not handler:
        return

    print(f"\n🔧 {Path(file_path).name}")
    try:
        handler(file_path)
    except (OSError, subprocess.SubprocessError) as e:
        print(f"  ⚠️  {e}")
    print()


if __name__ == "__main__":
    main()
