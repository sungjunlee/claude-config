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
# ESLint with auto-fix (modern-first)
bunx eslint . --fix
# pnpm eslint . --fix
# yarn eslint . --fix
# npx eslint . --fix

# CI mode (fail on warnings)
# bunx eslint . --max-warnings=0
# pnpm eslint . --max-warnings=0

# Or Biome
bunx biome check --apply .
# pnpm biome check --apply .
# npx biome check --apply .
```

### Step 3: Format
```bash
# Prettier (modern-first)
bunx prettier --write .
# pnpm prettier --write .
# yarn prettier --write .
# npx prettier --write .

# Or Biome format
bunx biome format --write .
# pnpm biome format --write .
# npx biome format --write .
```

## Common Issues to Fix

- Unused variables and imports
- Missing semicolons (based on project style)
- Inconsistent indentation
- Long lines that need breaking
- Missing or incorrect types

Run appropriate linting based on project configuration.