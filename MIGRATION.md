# Migration Guide

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