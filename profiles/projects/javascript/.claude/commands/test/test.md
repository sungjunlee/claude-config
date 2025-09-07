---
description: Smart test runner for JavaScript/TypeScript projects
---

# Run JavaScript Tests

Execute tests for: $ARGUMENTS

## Test Runner Detection

Check for test configuration in this order:
1. `npm test` or `yarn test` in package.json
2. Jest configuration (jest.config.*)
3. Vitest configuration (vitest.config.*)
4. Mocha configuration (.mocharc.*)
5. Playwright for E2E tests

## Execution Strategy

### For Unit Tests
- Run with coverage if available
- Focus on changed files when possible
- Show only failed tests in watch mode

### For E2E Tests  
- Check if dev server is running
- Use headless mode in CI
- Generate screenshots on failure

## Quick Commands

```bash
# Run all tests (modern-first package manager detection)
bun test || pnpm test || yarn test || npm test

# Run with coverage
bun test --coverage
# pnpm test -- --coverage
# yarn test --coverage
# npm test -- --coverage

# Run specific file
bun test path/to/test
# pnpm test -- path/to/test
# yarn test path/to/test
# npm test -- path/to/test

# Watch mode
bun test --watch
# pnpm test -- --watch
# yarn test --watch
# npm test -- --watch

# E2E tests (Playwright)
# bunx playwright test
# pnpm playwright test
# npx playwright test --ui
```

Execute appropriate test command based on project setup.