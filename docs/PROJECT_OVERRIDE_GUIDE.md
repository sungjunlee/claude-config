# Project Override System Guide

## Overview

The Project Override System allows project-specific Claude Code commands to override account-level commands, providing tailored development experiences for different languages and frameworks.

## How It Works

### Command Resolution Order
```
1. Project Level (.claude/commands/)  ← Highest Priority
2. Account Level (~/.claude/commands/)
3. Built-in Commands                  ← Lowest Priority
```

When you type a command like `/test`, Claude Code will:
1. First check your project's `.claude/commands/` directory
2. If not found, check your account's `~/.claude/commands/` directory  
3. Finally, fall back to built-in commands

## Installation

### Quick Install for Projects

```bash
# Auto-detect and install appropriate profile
ccfg init auto

# Or manually specify
ccfg init python
ccfg init javascript
ccfg init rust
```

### Manual Installation

```bash
# From claude-config directory
cd profiles/projects/python
./install.sh

# This will:
# 1. Copy commands to your project's .claude/commands/
# 2. Detect your project setup
# 3. Provide recommendations
```

## Available Project Profiles

### Python Projects
Specialized commands for Python development:
- `/optimize` - Python-specific performance profiling and optimization
- `/pytest` - Smart pytest runner with coverage and markers
- `/venv` - Virtual environment and dependency management

### JavaScript/TypeScript Projects
Modern web development commands:
- `/test` - Detects Jest, Vitest, Mocha, Playwright
- `/lint` - ESLint, Biome, Prettier, TypeScript checking
- `/bundle` - Webpack, Vite, Next.js build optimization

### Rust Projects
Systems programming commands:
- `/clippy` - Comprehensive Rust linting
- `/bench` - Benchmarking with cargo bench and criterion
- `/cargo-test` - Advanced testing with features and coverage

### Universal Commands (_base)
Smart commands that work with any project:
- `/smart-test` - Auto-detects test framework for 8+ languages
- `/smart-lint` - Auto-detects linters and formatters
- `/smart-build` - Auto-detects build systems

## Creating Custom Overrides

### Project-Specific Override
Create `.claude/commands/dev/my-command.md` in your project:

```markdown
---
description: Custom build process for my project
---

# Build My Project

Custom build logic for: $ARGUMENTS

This overrides the account-level build command for this project only.
```

### Extending Base Commands
Reference the account-level command and add project-specific logic:

```markdown
---
description: Extended test runner with project-specific setup
---

# Run Tests with Setup

## Project Setup
- Start database container
- Load test fixtures
- Set environment variables

## Run Base Tests
Execute the standard test suite from account-level command.

## Cleanup
- Stop containers
- Clear test data
```

## Best Practices

### 1. Keep It Simple
- Don't over-engineer commands
- Leverage existing project tools
- Start with base commands, override only when needed

### 2. Document Overrides
Always indicate when a command is an override:
```markdown
> **Project Override**: This command overrides the account-level `/test`
```

### 3. Use Smart Detection
Instead of hardcoding, detect project configuration:
```markdown
Check for test configuration:
1. package.json scripts
2. pytest.ini
3. Cargo.toml
4. Fall back to generic search
```

### 4. Progressive Enhancement
Start with simple commands and add complexity only when needed:
- Level 1: Run existing scripts
- Level 2: Add common flags
- Level 3: Custom workflows

## Examples

### Example 1: Django-Specific Test Command
`.claude/commands/test/django-test.md`:
```markdown
---
description: Django test runner with database setup
---

# Django Tests

Run Django tests for: $ARGUMENTS

## Setup Test Database
```bash
python manage.py migrate --run-syncdb --database=test
```

## Run Tests
```bash
python manage.py test $ARGUMENTS --parallel --keepdb
```

## Coverage Report
```bash
coverage run --source='.' manage.py test
coverage report
```
```

### Example 2: Monorepo Build Command
`.claude/commands/dev/monorepo-build.md`:
```markdown
---
description: Build all packages in monorepo
---

# Monorepo Build

Build packages in order:

1. Build shared libraries
2. Build backend services
3. Build frontend apps
4. Run integration tests

Handle dependencies and parallel builds appropriately.
```

## Troubleshooting

### Commands Not Found
- Check `.claude/commands/` exists in your project
- Verify command file has `.md` extension
- Ensure proper YAML frontmatter

### Override Not Working
- Project commands take precedence
- Check for typos in command names
- Verify file permissions

### Performance Issues
- Keep commands lightweight
- Avoid complex detection logic
- Cache detection results when possible

## Anti-Patterns to Avoid

❌ **Don't**:
- Create abstract command hierarchies
- Override every single command
- Add unnecessary configuration files
- Build complex command inheritance

✅ **Do**:
- Override only when truly needed
- Keep commands focused and simple
- Use existing project tools
- Document why override exists

## Integration with CI/CD

Project overrides work seamlessly with CI/CD:

```yaml
# GitHub Actions example
- name: Run project tests
  run: |
    # Uses project-specific /test command
    claude code /test
```

## Sharing Project Commands

Include `.claude/` in version control:
```bash
# .gitignore
# Don't ignore Claude commands - share with team!
# !.claude/commands/
```

This ensures all team members have the same project-specific commands.