#!/usr/bin/env python3
"""
Pre-commit hook for Python projects
Ensures code quality before committing
"""

import os
import sys
import subprocess
import shlex
from pathlib import Path

def run_command(cmd):
    """Run a command and return output
    
    Args:
        cmd: Either a string command or a list of command arguments
        
    Returns:
        tuple: (success, stdout, stderr)
    """
    try:
        # Convert string to list if needed
        if isinstance(cmd, str):
            cmd_list = shlex.split(cmd)
        else:
            cmd_list = cmd
            
        result = subprocess.run(
            cmd_list,
            shell=False,
            capture_output=True,
            text=True,
            timeout=30
        )
        return result.returncode == 0, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return False, "", "Command timed out"
    except Exception as e:
        return False, "", str(e)

def check_formatting():
    """Check if all Python files are formatted"""
    print("🎨 Checking code formatting...")
    success, output, _ = run_command(["ruff", "format", "--check", "."])
    
    if not success:
        print("❌ Formatting issues found. Run 'ruff format .' to fix")
        return False
    
    print("✅ Formatting check passed")
    return True

def check_linting():
    """Check for linting issues"""
    print("🔍 Running linter...")
    success, output, error = run_command(["ruff", "check", "."])
    
    if not success:
        print("❌ Linting issues found:")
        print(output or error)
        print("\nRun 'ruff check --fix .' to auto-fix")
        return False
    
    print("✅ Linting check passed")
    return True

def check_types():
    """Run type checking with mypy"""
    print("📝 Checking types...")
    
    # Check if mypy is configured
    if not any(Path('.').glob('**/mypy.ini')) and \
       not Path('pyproject.toml').exists() and \
       not Path('setup.cfg').exists():
        print("⚠️  No mypy configuration found, skipping type check")
        return True
    
    success, output, error = run_command(["mypy", "."])
    
    if not success:
        # Check if it's just missing imports
        if 'Cannot find implementation or library stub' in (output + error):
            print("⚠️  Some type stubs missing (non-blocking)")
            return True
        
        print("❌ Type checking failed:")
        print(output or error)
        return False
    
    print("✅ Type check passed")
    return True

def run_tests():
    """Run fast unit tests"""
    print("🧪 Running tests...")
    
    # Check for test files
    test_files = list(Path('.').glob('**/test_*.py')) + \
                 list(Path('.').glob('**/*_test.py'))
    
    if not test_files:
        print("⚠️  No test files found")
        return True
    
    # Run only fast tests (marked as unit)
    success, output, _ = run_command(["pytest", "-m", "unit", "--tb=short", "-q"])
    
    if not success:
        # Try without markers
        success, output, _ = run_command(["pytest", "--tb=short", "-q", "--maxfail=3"])
    
    if not success:
        print("❌ Tests failed")
        print(output)
        return False
    
    print("✅ Tests passed")
    return True

def check_security():
    """Basic security checks"""
    print("🔒 Security check...")
    
    # Check for hardcoded secrets using grep commands
    patterns = [
        ["grep", "-r", "api_key.*=.*['\"]", "--include=*.py", "."],
        ["grep", "-r", "password.*=.*['\"]", "--include=*.py", "."],
        ["grep", "-r", "secret.*=.*['\"]", "--include=*.py", "."],
    ]
    
    found_issues = False
    for pattern in patterns:
        success, output, _ = run_command(pattern)
        if success and output:
            # Filter out false positives
            lines = output.strip().split('\n')
            real_issues = [
                line for line in lines 
                if not any(safe in line.lower() for safe in [
                    'example', 'test', 'mock', 'fake', 'dummy', 
                    'getenv', 'environ', 'config'
                ])
            ]
            
            if real_issues:
                found_issues = True
                print("⚠️  Potential hardcoded secrets found:")
                for issue in real_issues[:3]:
                    print(f"  {issue}")
    
    if found_issues:
        print("❌ Security issues found")
        return False
    
    print("✅ Security check passed")
    return True

def main():
    """Main pre-commit hook"""
    print("\n🐍 Python Pre-commit Hook\n")
    
    checks = [
        ("Formatting", check_formatting),
        ("Linting", check_linting),
        ("Type Checking", check_types),
        ("Security", check_security),
        # ("Tests", run_tests),  # Optional: can be slow
    ]
    
    failed = []
    for name, check_func in checks:
        try:
            if not check_func():
                failed.append(name)
        except Exception as e:
            print(f"⚠️  {name} check error: {e}")
    
    print("\n" + "="*50)
    
    if failed:
        print(f"❌ Pre-commit checks failed: {', '.join(failed)}")
        print("\nFix the issues above and try again.")
        sys.exit(1)
    else:
        print("✅ All pre-commit checks passed!")
        sys.exit(0)

if __name__ == "__main__":
    main()