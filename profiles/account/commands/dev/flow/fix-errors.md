---
description: Automatically fix all errors in the project
---

# Fix All Errors

Automatically identify and fix errors in: $ARGUMENTS

## Error Resolution Process:

1. **Identify Errors**:
   - Compile/build errors
   - Linting errors
   - Type errors
   - Test failures

2. **Prioritize Fixes**:
   - Critical: Build-breaking errors
   - High: Test failures
   - Medium: Linting issues
   - Low: Warnings

3. **Apply Fixes**:
   - Fix compilation errors first
   - Resolve type issues
   - Fix failing tests
   - Address linting problems

4. **Verify**:
   - Re-run builds
   - Re-run tests
   - Confirm all errors resolved

## Auto-Agent Invocation:
- Use test-runner for test failures
- Use debugger for complex errors
- Use code-reviewer for verification

Start fixing errors now.