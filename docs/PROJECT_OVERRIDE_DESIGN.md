# Project Override System Design

## Core Philosophy
**"Surgical Coding"**: Minimal, targeted overrides that respect existing patterns.

## Override Hierarchy
```text
1. Project Level (.claude/commands/)  ← Highest Priority
2. Account Level (~/.claude/commands/)
3. Built-in Commands                  ← Lowest Priority
```

## Lightweight Project Templates

### 1. JavaScript/TypeScript Projects
```text
profiles/projects/javascript/
├── .claude/
│   └── commands/
│       ├── dev/
│       │   ├── lint.md      # Project-specific linting
│       │   └── bundle.md    # Build optimization
│       └── test/
│           └── e2e.md       # E2E test runner
└── install.sh
```

### 2. Python Projects  
```text
profiles/projects/python/
├── .claude/
│   └── commands/
│       ├── dev/
│       │   ├── optimize.md  # Python-specific optimization (exists)
│       │   └── venv.md      # Virtual environment management
│       └── test/
│           └── pytest.md    # Pytest runner with coverage
└── install.sh
```

### 3. Rust Projects
```text
profiles/projects/rust/
├── .claude/
│   └── commands/
│       ├── dev/
│       │   ├── clippy.md    # Rust linter
│       │   └── bench.md     # Benchmark runner
│       └── test/
│           └── cargo-test.md # Cargo test with features
└── install.sh
```

## Command Design Principles

### 1. Framework-First
Use built-in tools before custom solutions:
- JavaScript: npm/yarn scripts
- Python: pipenv/poetry commands  
- Rust: cargo commands

### 2. Context-Aware
Commands should detect and adapt to project structure:
```markdown
# Example: /test command
Check for test runners in order:
1. package.json scripts
2. pytest.ini / tox.ini
3. Cargo.toml test configuration
```

### 3. Progressive Enhancement
Start simple, add complexity only when needed:
```markdown
Level 1: Run existing scripts
Level 2: Add common flags/options
Level 3: Custom workflows (only if essential)
```

## Implementation Strategy

### Phase 1: Core Commands (Immediate)
Essential project-specific overrides:
- `/test` - Smart test runner detection
- `/lint` - Project-aware linting
- `/build` - Build system integration

### Phase 2: Enhancement Commands (Next Week)
Quality of life improvements:
- `/deps` - Dependency management
- `/bench` - Performance benchmarking
- `/docs` - Documentation generation

### Phase 3: Workflow Commands (Future)
Advanced integrations:
- `/ci` - CI/CD pipeline helpers
- `/deploy` - Deployment automation
- `/release` - Release management

## Anti-Pattern Prevention

### DON'T
- Create abstract base commands
- Add unnecessary configuration files
- Override commands that work well already
- Build complex inheritance chains

### DO
- Leverage existing project tools
- Keep commands focused and simple
- Document override behavior clearly
- Test with minimal projects first

## Example: Smart Test Command

```markdown
---
description: Intelligent test runner that detects project type
---

# Run Tests

Detect and run appropriate test suite for: $ARGUMENTS

## Detection Order

1. Check package.json for test script
2. Check for pytest/unittest
3. Check for cargo test
4. Fall back to generic test search

## Execute Tests

Run the detected test framework with appropriate flags.
```

## Success Metrics

✅ Commands execute in < 2 seconds
✅ No new dependencies required
✅ Works with existing project structure
✅ Clear override documentation
✅ Minimal cognitive overhead