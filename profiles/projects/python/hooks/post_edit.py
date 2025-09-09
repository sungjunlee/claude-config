#!/usr/bin/env python3
"""
Post-edit hook for Python files
Automatically formats and checks Python files after editing
"""

import os
import sys
import json
import subprocess
import shlex
import shutil
from pathlib import Path
from typing import Tuple, List, Optional

def run_command(cmd: str | list, timeout: int = 10) -> Tuple[bool, str, str]:
    """
    Run a command securely without shell=True.
    
    Args:
        cmd: Command as string or list
        timeout: Command timeout in seconds
        
    Returns:
        Tuple of (success, stdout, stderr)
    """
    try:
        # Convert string to list if needed
        if isinstance(cmd, str):
            cmd_list = shlex.split(cmd)
        else:
            cmd_list = cmd
            
        result = subprocess.run(
            cmd_list,
            shell=False,  # Security: Never use shell=True
            capture_output=True,
            text=True,
            timeout=timeout,
            check=False
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
    """
    Return the executable argv for a tool, preferring system binary and
    falling back to `uvx <tool>` if missing.
    
    Args:
        tool: Tool name to resolve
        
    Returns:
        List of command arguments to run the tool
    """
    if check_tool_availability(tool):
        return [tool]
    if shutil.which("uvx"):
        return ["uvx", tool]
    return [tool]  # Best-effort; caller can handle failures

def format_python_file(filepath: str) -> None:
    """Format Python file with ruff"""
    ruff = resolve_tool("ruff")
    
    print(f"🎨 Formatting {filepath}...")
    
    # Format with ruff
    success, stdout, stderr = run_command([*ruff, "format", filepath])
    if success:
        print("✅ Formatted successfully")
    else:
        error_msg = stderr or stdout
        print(f"⚠️  Formatting failed: {error_msg}")
    
    # Fix imports and safe issues
    success, stdout, stderr = run_command([*ruff, "check", "--fix", filepath])
    if success:
        if stdout or stderr:
            output = stdout or stderr
            print(f"✅ Fixed linting issues:\n{output}")
    else:
        # Non-zero exit doesn't always mean failure for ruff check
        if stderr and "error" in stderr.lower():
            print(f"⚠️  Some issues couldn't be auto-fixed: {stderr}")

def check_async_patterns(filepath: str) -> None:
    """Check for common async/await issues in FastAPI files"""
    try:
        with open(filepath, 'r') as f:
            content = f.read()
    except Exception as e:
        print(f"⚠️  Could not read file for async check: {e}")
        return
    
    # Check if it's a FastAPI file
    if 'fastapi' not in content.lower() and 'FastAPI' not in content:
        return
    
    issues = []
    
    # Check for blocking operations in async functions
    if 'async def' in content:
        blocking_patterns = [
            ('time.sleep(', 'Use await asyncio.sleep() instead'),
            ('requests.', 'Use httpx or aiohttp for async requests'),
            ('open(', 'Consider using aiofiles for async file operations'),
            ('sqlite3.', 'Use aiosqlite for async SQLite operations'),
        ]
        
        for pattern, suggestion in blocking_patterns:
            if pattern in content:
                issues.append(f"⚠️  Found blocking operation '{pattern}': {suggestion}")
    
    # Check for missing await
    lines = content.split('\n')
    for i, line in enumerate(lines, 1):
        if 'asyncio.sleep(' in line and 'await' not in line:
            issues.append(f"⚠️  Line {i}: Missing 'await' before asyncio.sleep()")
        if '.create_task(' in line and 'await' not in line and '=' not in line:
            issues.append(f"⚠️  Line {i}: Consider if create_task() result should be stored")
    
    if issues:
        print("\n🔍 Async pattern checks:")
        for issue in issues:
            print(f"  {issue}")

def check_type_hints(filepath: str) -> None:
    """Check if type hints are missing"""
    mypy = resolve_tool("mypy")
    
    success, stdout, stderr = run_command(
        [*mypy, "--no-error-summary", "--no-pretty", filepath],
        timeout=30
    )
    
    if not success and (stdout or stderr):
        output = stdout or stderr
        missing_types = []
        for line in output.split('\n'):
            if any(pattern in line.lower() for pattern in [
                'has no attribute',
                'missing type',
                'type annotation',
                'untyped def'
            ]):
                missing_types.append(line.strip())
        
        if missing_types:
            print("\n📝 Type hint suggestions:")
            for issue in missing_types[:5]:  # Show max 5 issues
                print(f"  {issue}")

def sync_to_notebook(filepath: str) -> None:
    """Sync Python file changes to corresponding Jupyter notebook"""
    # Check if there's a corresponding notebook
    notebook_path = filepath.replace('.py', '.ipynb')
    if not os.path.exists(notebook_path):
        return
    
    # Check if jupytext is available
    jupytext = resolve_tool("jupytext")
    if jupytext == ["jupytext"] and not check_tool_availability("jupytext"):
        return  # jupytext not available
    
    print(f"📓 Syncing to notebook {notebook_path}...")
    success, stdout, stderr = run_command([*jupytext, "--sync", filepath])
    if success:
        print("✅ Notebook synchronized")
    else:
        error_msg = stderr or stdout
        if error_msg:
            print(f"⚠️  Notebook sync failed: {error_msg}")

def main() -> None:
    """Main hook execution"""
    # Get hook context from environment
    tool_use = os.environ.get('TOOL_USE', '')
    file_path = os.environ.get('FILE_PATH', '')
    
    # Only process Edit and Write tools
    if tool_use not in ['Edit', 'Write', 'MultiEdit']:
        return
    
    # Only process Python files
    if not file_path.endswith('.py'):
        return
    
    print(f"\n🐍 Python post-edit hook triggered for {file_path}")
    
    # Check if file exists
    if not os.path.exists(file_path):
        print(f"⚠️  File not found: {file_path}")
        return
    
    # Run formatting
    format_python_file(file_path)
    
    # Check async patterns for FastAPI
    check_async_patterns(file_path)
    
    # Check type hints
    check_type_hints(file_path)
    
    # Sync to notebook if exists
    sync_to_notebook(file_path)
    
    print("✅ Post-edit hook completed\n")

if __name__ == "__main__":
    main()