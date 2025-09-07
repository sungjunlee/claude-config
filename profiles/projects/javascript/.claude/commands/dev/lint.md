---
description: Intelligent linting and formatting for JavaScript/TypeScript
---

# Lint and Format Code

Run linting and formatting for: $ARGUMENTS

## Tool Detection

Check for linting tools in order:
1. ESLint configuration (.eslintrc.*)
2. Biome configuration (biome.json)
3. Prettier for formatting (.prettierrc.*)
4. TypeScript compiler (tsc) for type checking

## Execution Flow

### Step 1: Type Check (if TypeScript)
```bash
npx tsc --noEmit
```

### Step 2: Lint
```bash
# ESLint with auto-fix
npx eslint . --fix
# pnpm eslint . --fix
# bunx eslint . --fix

# CI mode (fail on warnings)
# npx eslint . --max-warnings=0

# Or Biome
npx biome check --apply .
# pnpm biome check --apply .
```

### Step 3: Format
```bash
# Prettier
npx prettier --write .

# Or Biome format
npx biome format --write .
```

## Common Issues to Fix

- Unused variables and imports
- Missing semicolons (based on project style)
- Inconsistent indentation
- Long lines that need breaking
- Missing or incorrect types

Run appropriate linting based on project configuration.