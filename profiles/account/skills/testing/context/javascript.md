# JavaScript/TypeScript Testing Guide

JavaScript 및 TypeScript 프로젝트를 위한 테스트 가이드입니다.

## Test Frameworks

**Modern (Recommended)**:
- **Vitest**: Vite 기반, 빠른 실행, ESM 네이티브
- **Bun Test**: Bun 런타임 내장, 가장 빠름

**Established**:
- **Jest**: 가장 널리 사용, 풍부한 에코시스템
- **Mocha**: 유연한 구조, 오래된 프로젝트

**E2E**:
- **Playwright**: 크로스 브라우저, 권장
- **Cypress**: 개발자 경험 우수

## Package Manager Detection

```bash
# Modern-first approach (2025)
if command -v bun &> /dev/null && [[ -f "bun.lockb" ]]; then
    PM="bun"
elif command -v pnpm &> /dev/null && [[ -f "pnpm-lock.yaml" ]]; then
    PM="pnpm"
elif [[ -f "yarn.lock" ]]; then
    PM="yarn"
else
    PM="npm"
fi
```

## Framework Detection

```bash
# Check package.json for test framework
if grep -q '"vitest"' package.json; then
    RUNNER="vitest"
elif grep -q '"jest"' package.json; then
    RUNNER="jest"
elif grep -q '"mocha"' package.json; then
    RUNNER="mocha"
fi
```

## Common Commands

### Vitest
```bash
# Run all tests
bun vitest || pnpm vitest || npx vitest

# Watch mode (default)
vitest

# Single run
vitest run

# With coverage
vitest run --coverage

# Specific file
vitest run path/to/test.spec.ts

# UI mode
vitest --ui
```

### Jest
```bash
# Run all tests
bun test || npm test

# With coverage
jest --coverage

# Watch mode
jest --watch

# Specific file
jest path/to/test.spec.ts

# Update snapshots
jest --updateSnapshot

# Verbose output
jest --verbose
```

### Bun Test
```bash
# Run all tests
bun test

# With coverage
bun test --coverage

# Watch mode
bun test --watch

# Specific file
bun test path/to/test.ts

# Timeout
bun test --timeout 5000
```

### Mocha
```bash
# Run tests
mocha

# With TypeScript
mocha --require ts-node/register

# Specific pattern
mocha "tests/**/*.spec.ts"

# Watch mode
mocha --watch
```

## Configuration

### Vitest (vitest.config.ts)
```typescript
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    globals: true,
    environment: 'node', // or 'jsdom', 'happy-dom'
    include: ['**/*.{test,spec}.{js,ts,jsx,tsx}'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html', 'lcov'],
      exclude: ['node_modules/', 'tests/'],
      thresholds: {
        lines: 80,
        branches: 80,
      },
    },
    setupFiles: ['./tests/setup.ts'],
  },
})
```

### Jest (jest.config.js)
```javascript
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src', '<rootDir>/tests'],
  testMatch: ['**/*.test.ts', '**/*.spec.ts'],
  collectCoverageFrom: [
    'src/**/*.{js,ts}',
    '!src/**/*.d.ts',
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
    },
  },
  setupFilesAfterEnv: ['<rootDir>/tests/setup.ts'],
}
```

## E2E Testing

### Playwright
```bash
# Install browsers
npx playwright install

# Run all tests
npx playwright test

# UI mode
npx playwright test --ui

# Headed mode
npx playwright test --headed

# Specific browser
npx playwright test --project=chromium

# Generate tests
npx playwright codegen
```

### Playwright Config
```typescript
import { defineConfig } from '@playwright/test'

export default defineConfig({
  testDir: './e2e',
  timeout: 30000,
  retries: process.env.CI ? 2 : 0,
  use: {
    baseURL: 'http://localhost:3000',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  projects: [
    { name: 'chromium', use: { browserName: 'chromium' } },
    { name: 'firefox', use: { browserName: 'firefox' } },
    { name: 'webkit', use: { browserName: 'webkit' } },
  ],
})
```

## Directory Structure

```
src/
├── components/
│   └── Button/
│       ├── Button.tsx
│       └── Button.test.tsx  # Co-located tests
tests/
├── unit/
├── integration/
└── e2e/
    └── playwright/
```

## Testing Patterns

### Component Testing (React)
```typescript
import { render, screen, fireEvent } from '@testing-library/react'
import { Button } from './Button'

describe('Button', () => {
  it('renders with text', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByText('Click me')).toBeInTheDocument()
  })

  it('handles click', async () => {
    const onClick = vi.fn()
    render(<Button onClick={onClick}>Click</Button>)
    await fireEvent.click(screen.getByRole('button'))
    expect(onClick).toHaveBeenCalledOnce()
  })
})
```

### API Testing
```typescript
import { describe, it, expect, beforeAll, afterAll } from 'vitest'
import { setupServer } from 'msw/node'
import { rest } from 'msw'

const server = setupServer(
  rest.get('/api/users', (req, res, ctx) => {
    return res(ctx.json([{ id: 1, name: 'John' }]))
  })
)

beforeAll(() => server.listen())
afterAll(() => server.close())

describe('API', () => {
  it('fetches users', async () => {
    const response = await fetch('/api/users')
    const users = await response.json()
    expect(users).toHaveLength(1)
  })
})
```

## Common Issues

### ESM vs CommonJS
- Use `"type": "module"` in package.json for ESM
- Vitest handles ESM natively
- Jest needs `--experimental-vm-modules`

### TypeScript Setup
- Install `@types/jest` or Vitest has built-in types
- Configure `tsconfig.json` with `"types": ["vitest/globals"]`

### Async Testing
```typescript
// Vitest/Jest
it('async test', async () => {
  const result = await asyncFunction()
  expect(result).toBe(expected)
})

// With timeout
it('long async', async () => {
  // ...
}, 10000)
```

### Mocking
```typescript
// Vitest
import { vi } from 'vitest'
vi.mock('./module')

// Jest
jest.mock('./module')
```

## CI/CD Integration

```yaml
# GitHub Actions
- name: Test
  run: |
    npm ci
    npm test -- --coverage --reporter=junit

- name: E2E
  run: |
    npx playwright install --with-deps
    npx playwright test
```

## Performance Tips

1. **Use Vitest/Bun** for faster execution
2. **Run in parallel**: `--pool=threads`
3. **Selective testing**: `--changed` flag
4. **Cache transforms**: Jest `cacheDirectory`
5. **Skip coverage in watch**: Only on CI
