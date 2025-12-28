# JavaScript/TypeScript Linting Guide

JavaScript 및 TypeScript 프로젝트를 위한 린팅 가이드입니다.

## Tool Stack (2025)

**Modern (Recommended)**:
- **Biome**: Fast, all-in-one (lint + format), Rust-based
- **ESLint v9+**: Flat config, most established

**Formatting**:
- **Prettier**: De facto standard formatter
- **Biome**: Built-in formatting

**Type Checking**:
- **TypeScript (tsc)**: Type validation

## Tool Detection Order

```bash
# 1. Biome (modern, fast)
if [[ -f "biome.json" ]]; then
    bunx biome check --apply .
fi

# 2. ESLint (established)
if [[ -f ".eslintrc.json" ]] || [[ -f "eslint.config.js" ]]; then
    bunx eslint . --fix
fi

# 3. Prettier (formatting)
if [[ -f ".prettierrc" ]] || [[ -f "prettier.config.js" ]]; then
    bunx prettier --write .
fi

# 4. TypeScript (type check)
if [[ -f "tsconfig.json" ]]; then
    bunx tsc --noEmit
fi
```

## Biome (Modern Choice)

### Basic Usage
```bash
# Check and fix all
bunx biome check --apply .

# Lint only
bunx biome lint --apply .

# Format only
bunx biome format --write .

# CI mode (check without fixing)
bunx biome check .
```

### Configuration (biome.json)
```json
{
  "$schema": "https://biomejs.dev/schemas/1.9.0/schema.json",
  "organizeImports": { "enabled": true },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true,
      "complexity": {
        "noExcessiveCognitiveComplexity": "warn"
      },
      "suspicious": {
        "noExplicitAny": "error"
      }
    }
  },
  "formatter": {
    "enabled": true,
    "indentStyle": "space",
    "indentWidth": 2
  }
}
```

## ESLint

### ESLint v9+ (Flat Config)
```javascript
// eslint.config.js
import js from '@eslint/js';
import typescript from '@typescript-eslint/eslint-plugin';
import tsParser from '@typescript-eslint/parser';

export default [
  js.configs.recommended,
  {
    files: ['**/*.ts', '**/*.tsx'],
    languageOptions: {
      parser: tsParser,
      parserOptions: {
        project: './tsconfig.json',
      },
    },
    plugins: {
      '@typescript-eslint': typescript,
    },
    rules: {
      ...typescript.configs.recommended.rules,
      '@typescript-eslint/no-unused-vars': 'error',
      '@typescript-eslint/no-explicit-any': 'warn',
    },
  },
];
```

### Basic Commands
```bash
# Lint with auto-fix
bunx eslint . --fix

# Specific files
bunx eslint src/ --fix

# CI mode (fail on warnings)
bunx eslint . --max-warnings=0

# Show only errors
bunx eslint . --quiet
```

## Prettier

### Basic Usage
```bash
# Format all files
bunx prettier --write .

# Check formatting
bunx prettier --check .

# Specific files
bunx prettier --write "src/**/*.ts"
```

### Configuration (.prettierrc)
```json
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 80
}
```

## TypeScript Type Checking

```bash
# Check types without emitting
bunx tsc --noEmit

# Strict mode
bunx tsc --noEmit --strict

# Watch mode
bunx tsc --noEmit --watch
```

## Recommended Setup

### Biome + TypeScript (Modern)
```json
// package.json
{
  "scripts": {
    "lint": "biome check --apply .",
    "lint:check": "biome check .",
    "typecheck": "tsc --noEmit"
  }
}
```

### ESLint + Prettier + TypeScript (Established)
```json
// package.json
{
  "scripts": {
    "lint": "eslint . --fix",
    "lint:check": "eslint . --max-warnings=0",
    "format": "prettier --write .",
    "format:check": "prettier --check .",
    "typecheck": "tsc --noEmit"
  }
}
```

## CI/CD Integration

```yaml
# GitHub Actions
- name: Lint
  run: |
    npm ci
    npm run lint:check
    npm run typecheck
```

## Common Issues

### ESLint + Prettier Conflicts
Use `eslint-config-prettier` to disable conflicting rules:
```bash
npm install -D eslint-config-prettier
```

### Biome vs Prettier
Choose one formatter. Biome is faster but less configurable.

### Type Errors vs Lint Errors
Run type checking separately from linting for clearer error messages.

## Migration Guide

### From ESLint + Prettier to Biome
```bash
# Install Biome
npm install -D @biomejs/biome

# Migrate config
bunx biome migrate eslint --write
bunx biome migrate prettier --write

# Remove old tools
npm uninstall eslint prettier
```

## Performance Tips

1. Use Biome for fastest execution
2. Enable caching: `eslint . --cache`
3. Lint only changed files in CI
4. Use `--quiet` to show only errors
