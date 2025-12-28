# Migration Guide

## Skills Architecture Migration (v3.0)

### What Changed

We've migrated from a commands/agents structure to a **Skills-based architecture** that integrates with official Claude Code plugins.

**Old Structure:**
```
~/.claude/
├── agents/       # Multiple agents (code-reviewer, test-runner, etc.)
├── commands/
│   ├── dev/      # test, review, debug, etc.
│   ├── flow/     # handoff, resume, plan, etc.
│   ├── gh/       # pr, docs
│   └── worktree/ # distribute, status, sync
└── scripts/
```

**New Structure:**
```
~/.claude/
├── skills/           # Skills architecture
│   ├── workflow/     # handoff, resume, plan, fix-errors
│   ├── worktree/     # distribute, plan, status, sync
│   ├── testing/      # test with language context
│   ├── linting/      # lint with language context
│   └── frameworks/   # fastapi patterns
├── commands/         # Standalone commands only
│   ├── dev/          # commit, refactor, optimize, explain, epct, cr
│   ├── gh/           # pr
│   └── ai/           # multi-model integration
├── agents/           # Only time-aware.md
└── scripts/
```

### Removed Commands (Use Official Plugins)

| Old Command | Replacement |
|-------------|-------------|
| `/dev:review` | `/pr-review-toolkit:review-pr` |
| `/dev:debug` | `silent-failure-hunter` plugin or Task tool |
| `/gh:docs` | `/document-skills:docx` or `/document-skills:pdf` |
| `/flow:scaffold` | Removed (manual setup) |
| `/flow:qa` | `/pr-review-toolkit:review-pr` |
| `/flow:reflection` | `reflection-agent` via Task tool |

### Commands Migrated to Skills

| Old Command | New Command |
|-------------|-------------|
| `/flow:handoff` | `/flow:handoff` (skill-based) |
| `/flow:resume` | `/flow:resume` (skill-based) |
| `/flow:plan` | `/flow:plan` (skill-based) |
| `/flow:fix-errors` | `/flow:fix-errors` (skill-based) |
| `/worktree:*` | `/worktree:*` (skill-based) |
| `/dev:test` | `/dev:test` (skill-based with context) |

### Removed Agents

| Agent | Replacement |
|-------|-------------|
| `code-reviewer.md` | `pr-review-toolkit` plugin |
| `test-runner.md` | `skills/testing/` |
| `debugger.md` | `silent-failure-hunter` plugin |
| `plan-agent.md` | `skills/workflow/` |
| `reflection-agent.md` | `skills/workflow/` |
| `worktree-coordinator.md` | `skills/worktree/` |

Only `time-aware.md` remains for datetime context.

### Migration Steps

1. **Update Installation:**
   ```bash
   curl -fsSL https://raw.githubusercontent.com/sungjunlee/claude-config/main/install.sh | bash
   ```

2. **Install Official Plugins (Recommended):**
   - `pr-review-toolkit` - Code review
   - `document-skills` - Documentation
   - `anthropic-agent-skills` - Additional capabilities

3. **Clean Up Old Files (Optional):**
   ```bash
   rm -rf ~/.claude/commands/flow/
   rm -rf ~/.claude/commands/worktree/
   rm -f ~/.claude/commands/dev/{review,debug,test}.md
   rm -f ~/.claude/commands/gh/docs.md
   rm -f ~/.claude/agents/{code-reviewer,test-runner,debugger,plan-agent,reflection-agent,worktree-coordinator}.md
   ```

### Skills Architecture

Each skill has this structure:
```
skill-name/
├── SKILL.md           # Skill definition
├── workflows/         # Executable workflows
└── context/           # Domain knowledge
```

Invoke with: `/skill-name:workflow`

---

## Command Structure Reorganization (v2.0)

### What Changed

We've reorganized the command file structure for better discoverability and logical grouping. Commands are now organized by their purpose rather than abstract categories.

**Old Structure:**
```
commands/
├── core/        # Abstract "core" commands
└── workflow/    # Abstract "workflow" commands
```

**New Structure:**
```
commands/
├── dev/         # Development tasks (coding work)
├── flow/        # Workflow management (process control)
├── gh/          # GitHub operations (collaboration)
└── worktree/    # Git worktree management (parallel work)
```

### Impact on Users

**No Breaking Changes!** All commands work exactly the same:
- `/commit` - Still creates smart commits
- `/test` - Still runs tests
- `/handoff` - Still manages session state
- `/pr` - Still creates pull requests

The only change is internal file organization for better maintainability.

### Command Locations

| Command | Old Location | New Location | Purpose |
|---------|-------------|--------------|---------|
| `/commit` | `core/commit.md` | `dev/commit.md` | Git commits |
| `/test` | `core/test.md` | `dev/test.md` | Run tests |
| `/debug` | `core/debug.md` | `dev/debug.md` | Debug issues |
| `/review` | `core/review.md` | `dev/review.md` | Code review |
| `/refactor` | `core/refactor.md` | `dev/refactor.md` | Refactor code |
| `/optimize` | `core/optimize.md` | `dev/optimize.md` | Performance optimization |
| `/explain` | `core/explain.md` | `dev/explain.md` | Code explanation |
| `/reflection` | `core/reflection.md` | `flow/reflection.md` | Claude self-analysis |
| `/plan` | `workflow/plan.md` | `flow/plan.md` | Task planning |
| `/handoff` | `workflow/handoff.md` | `flow/handoff.md` | Session handoff |
| `/resume` | `workflow/resume.md` | `flow/resume.md` | Session resume |
| `/scaffold` | `workflow/scaffold.md` | `flow/scaffold.md` | Project scaffolding |
| `/fix-errors` | `workflow/fix-errors.md` | `flow/fix-errors.md` | Auto-fix errors |
| `/pr` | `workflow/pr.md` | `gh/pr.md` | Pull requests |
| `/docs` | `workflow/docs.md` | `gh/docs.md` | Documentation |
| `/worktree-*` | `workflow/worktree-*.md` | `worktree/*.md` | Worktree commands |

### For Developers

If you have custom scripts or configurations that reference command file paths:
1. Update paths from `commands/core/` to `commands/dev/` or `commands/flow/`
2. Update paths from `commands/workflow/` to `commands/flow/`, `commands/gh/`, or `commands/worktree/`
3. Worktree command files no longer have the `worktree-` prefix in their filenames

### Benefits of the New Structure

1. **Better Discoverability**: Commands are grouped by what you want to do
2. **Clearer Mental Model**: Think in terms of development, workflow, GitHub, and worktree tasks
3. **Easier Navigation**: Shorter, more intuitive directory names
4. **Future Extensibility**: Room for new command categories as needed

### Need Help?

- All commands continue to work with `/command-name` syntax
- Use `/help` to see available commands
- The command behavior and options remain unchanged

## Project Override System (v2.1)

### What's New

We've introduced a **Project Override System** that allows project-specific commands to override account-level commands. This provides tailored development experiences for different languages and frameworks.

### Key Features

1. **Command Priority**: Project commands > Account commands > Built-in commands
2. **Language-Specific Profiles**: Pre-configured commands for Python, JavaScript, Rust
3. **Smart Auto-Detection**: Universal commands that detect project type automatically
4. **Zero Breaking Changes**: All existing commands continue to work

### New Project Profiles

#### Python Projects
- `/optimize` - Python-specific performance optimization with profiling
- `/pytest` - Smart pytest runner with coverage and markers
- `/venv` - Virtual environment and dependency management

#### JavaScript/TypeScript Projects  
- `/test` - Detects Jest, Vitest, Mocha, Playwright
- `/lint` - ESLint, Biome, Prettier, TypeScript checking
- `/bundle` - Webpack, Vite, Next.js build optimization

#### Rust Projects
- `/clippy` - Comprehensive Rust linting
- `/bench` - Benchmarking with cargo bench and criterion
- `/cargo-test` - Advanced testing with features and coverage

#### Universal Smart Commands
- `/smart-test` - Auto-detects test framework for 8+ languages
- `/smart-lint` - Auto-detects linters and formatters
- `/smart-build` - Auto-detects build systems

### Installation

```bash
# Auto-detect and install appropriate profile
ccfg init auto

# Or specify manually
ccfg init python
ccfg init javascript
ccfg init rust
```

### Creating Custom Overrides

Create `.claude/commands/dev/my-command.md` in your project:

```markdown
---
description: Project-specific build process
---

# Build My Project

> **Project Override**: This overrides the account-level build

Custom build logic for: $ARGUMENTS
```

### Migration Path

**For existing users**: No action required! Your current setup continues to work.

**To add project overrides**:
1. Run `ccfg init auto` in your project directory
2. Project-specific commands will be added to `.claude/commands/`
3. These commands take priority over account-level commands

### Benefits

- **Language-Specific Optimization**: Commands tailored to your tech stack
- **Team Consistency**: Share project commands via version control
- **No Configuration Overhead**: Smart detection works out of the box
- **Progressive Enhancement**: Start simple, add complexity as needed