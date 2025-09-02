---
description: Distribute parallel tasks to independent git worktrees based on PLAN.md
---

# Worktree Distribution

Distribute tasks from PLAN.md to independent git worktrees for: $ARGUMENTS

## Purpose
Parse `.worktrees/PLAN.md` and create isolated worktrees for parallel development, enabling multiple Claude instances to work simultaneously without interference.

## Process

1. **Validate Prerequisites**:
   - Verify git repository exists
   - Check `.worktrees/PLAN.md` file presence
   - Ensure no conflicting branches exist

2. **Parse Task Plan**:
   - Read `.worktrees/PLAN.md` structure
   - Extract task definitions and descriptions
   - Identify common context and dependencies

3. **Create Worktrees**:
   - Generate worktree for each task
   - Branch naming: `feature/[task-name]`
   - Handle existing branches gracefully

4. **Environment Setup**:
   - Copy environment files (.env, package.json, lock files)
   - Create node_modules symlinks for efficiency
   - Link Python venv if present
   - Copy 17+ config file types automatically

5. **Generate Documentation**:
   - Create task instruction at `.worktrees/tasks/[task-name].md`
   - Include acceptance criteria
   - Document Claude invocation commands
   - Add troubleshooting guidance

6. **Provide Launch Instructions**:
   - Display commands for each worktree
   - Suggest terminal/tab organization
   - Indicate parallel execution capability

## PLAN.md Structure

Expected format at `.worktrees/PLAN.md`:

````markdown
# Task Plan

## Task List
```bash
# Format: task-name: task description (estimated time)
auth: Implement OAuth2.0 authentication (2h)
payment: Integrate Stripe payment processing (3h)
search: Add Elasticsearch full-text search (2h)
```

## Common Context
- TypeScript with strict mode
- Jest for testing (min 80% coverage)
- Follow REST API conventions

## Task Dependencies
- All tasks can run independently
- Merge order: auth → payment → search
````

## Output Structure

Creates for each task:
- `.worktrees/[task-name]/` - Independent worktree directory
- `.worktrees/tasks/[task-name].md` - Detailed task instructions
- Environment files copied and symlinks created
- Branch `feature/[task-name]` ready for work

## Success Indicators

- All worktrees created successfully
- Environment files properly copied
- Task instructions generated
- No branch conflicts
- Clear launch commands provided

## Error Handling

Common issues and solutions:
- **Branch exists**: Check and clean existing branches
- **PLAN.md missing**: Create template or use `/worktree-plan`
- **Permission denied**: Check script execution permissions
- **Disk space**: Verify sufficient space before distribution

## Integration Points

- Use after `/worktree-plan` for automatic planning
- Monitor with `/worktree-status`
- Synchronize with `/worktree-sync`
- Clean up with `git worktree remove`

## Example Workflow

```bash
# Generate plan (if not exists)
/worktree-plan "implement auth, payment, and search"

# Distribute tasks
/worktree-distribute

# Work in parallel (different terminals)
cd .worktrees/auth && claude
cd .worktrees/payment && claude
cd .worktrees/search && claude
```

Execute worktree distribution now using `scripts/worktree-manager.sh distribute`.