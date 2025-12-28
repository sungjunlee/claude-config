---
description: Automatically fix all errors in the project
---

# Fix All Errors

Automatically identify and fix errors in: $ARGUMENTS

## Error Types

### By Priority

1. **Critical**: Build-breaking errors
   - Compilation failures
   - Syntax errors
   - Missing dependencies

2. **High**: Test failures
   - Unit test failures
   - Integration test errors
   - Type mismatches

3. **Medium**: Linting issues
   - Style violations
   - Code smells
   - Unused imports

4. **Low**: Warnings
   - Deprecation notices
   - Performance hints

## Resolution Process

### Step 1: Identify Errors

```bash
# Build/compile errors
npm run build 2>&1 | head -50
# or
cargo build 2>&1

# Type errors
npx tsc --noEmit
# or
mypy .

# Test failures
npm test
# or
pytest -v

# Linting
npm run lint
# or
ruff check .
```

### Step 2: Prioritize

1. Fix compilation errors first
2. Resolve type issues
3. Fix failing tests
4. Address linting

### Step 3: Apply Fixes

For each error:
1. Identify root cause
2. Apply minimal fix
3. Verify fix works
4. Move to next error

### Step 4: Verify

```bash
# Re-run all checks
npm run build && npm test && npm run lint
# or
cargo build && cargo test && cargo clippy
```

## Agent Invocation

Automatically invoke when needed:

| Situation | Agent |
|-----------|-------|
| Complex test failures | test-runner |
| Unclear root cause | debugger |
| Multiple file fixes | code-reviewer |

## Language-Specific

### JavaScript/TypeScript
```bash
# Type errors
npx tsc --noEmit

# ESLint fix
npx eslint . --fix

# Prettier fix
npx prettier --write .
```

### Python
```bash
# Type check
mypy .

# Lint and fix
ruff check --fix .
ruff format .
```

### Rust
```bash
# Clippy fix
cargo clippy --fix --allow-dirty

# Format
cargo fmt
```

## Best Practices

1. **One fix at a time**: Easier to track
2. **Verify after each fix**: Catch cascading issues
3. **Commit incrementally**: Safe rollback points
4. **Document non-obvious fixes**: Future reference

## Output Format

```markdown
## Error Resolution Report

### Summary
- Errors Found: X
- Fixed: Y
- Remaining: Z

### Fixed Issues
1. [file:line] Error description - Fixed by [action]

### Remaining Issues
1. [file:line] Error description - Needs [manual action]

### Verification
- Build: [pass/fail]
- Tests: [pass/fail]
- Lint: [pass/fail]
```

Start fixing errors now.
