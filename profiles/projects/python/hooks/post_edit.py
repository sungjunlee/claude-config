#!/usr/bin/env python3
"""
Post-edit hook for Python files
Automatically formats and checks Python files after editing
"""

import os
import sys
import json
import subprocess
from pathlib import Path

def run_command(cmd):
    """Run a shell command and return output"""
    try:
        result = subprocess.run(
            cmd,
            shell=True,
            capture_output=True,
            text=True,
            timeout=10
        )
        return result.returncode == 0, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return False, "", "Command timed out"
    except Exception as e:
        return False, "", str(e)

def check_tool_availability(tool):
    """Check if a tool is available"""
    success, _, _ = run_command(f"which {tool}")
    if not success:
        # Try with uv
        success, _, _ = run_command(f"uv run which {tool}")
    return success

def format_python_file(filepath):
    """Format Python file with ruff"""
    if not check_tool_availability("ruff"):
        print("⚠️  Ruff not found, skipping formatting")
        return
    
    print(f"🎨 Formatting {filepath}...")
    
    # Format with ruff
    success, _, error = run_command(f"ruff format {filepath}")
    if success:
        print("✅ Formatted successfully")
    else:
        print(f"⚠️  Formatting failed: {error}")
    
    # Fix imports and safe issues
    success, output, _ = run_command(f"ruff check --fix {filepath}")
    if success and output:
        print("✅ Fixed linting issues")

def check_async_patterns(filepath):
    """Check for common async/await issues in FastAPI files"""
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Check if it's a FastAPI file
    if 'fastapi' not in content.lower() and 'FastAPI' not in content:
        return
    
    issues = []
    
    # Check for blocking operations in async functions
    if 'async def' in content:
        blocking_patterns = [
            ('time.sleep(', 'Use await asyncio.sleep() instead'),
            ('requests.', 'Use httpx or aiohttp for async requests'),
            ('.read()', 'Use async file operations'),
            ('.write()', 'Use async file operations'),
        ]
        
        for pattern, suggestion in blocking_patterns:
            if pattern in content:
                issues.append(f"⚠️  Found blocking operation '{pattern}': {suggestion}")
    
    # Check for missing await
    if 'def ' in content and not 'async def' in content:
        async_patterns = ['asyncio.', 'await ', 'async with', 'async for']
        for pattern in async_patterns:
            if pattern in content:
                issues.append(f"⚠️  Found '{pattern}' in non-async function")
    
    if issues:
        print("\n🔍 Async pattern checks:")
        for issue in issues:
            print(f"  {issue}")

def check_type_hints(filepath):
    """Check if type hints are missing"""
    if not check_tool_availability("mypy"):
        return
    
    success, output, _ = run_command(f"mypy --no-error-summary --no-pretty {filepath}")
    
    if not success and output:
        missing_types = []
        for line in output.split('\n'):
            if 'has no attribute' in line or 'missing type' in line.lower():
                missing_types.append(line.strip())
        
        if missing_types:
            print("\n📝 Type hint suggestions:")
            for issue in missing_types[:5]:  # Show max 5 issues
                print(f"  {issue}")

def sync_to_notebook(filepath):
    """Sync Python file changes to corresponding Jupyter notebook"""
    # Check if there's a corresponding notebook
    notebook_path = filepath.replace('.py', '.ipynb')
    if not os.path.exists(notebook_path):
        return
    
    print(f"📓 Syncing to notebook {notebook_path}...")
    # This would require jupytext or similar tool
    success, _, _ = run_command(f"jupytext --sync {filepath}")
    if success:
        print("✅ Notebook synchronized")

def main():
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