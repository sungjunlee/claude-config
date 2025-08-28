# Command: /worktree-distribute

Distribute tasks to worktrees based on PLAN.md

## Usage

```bash
/worktree-distribute
```

## Description

Parses `.worktrees/PLAN.md` file and distributes each task to independent git worktrees.
Automatically copies environment files (.env, package.json, etc.) to make them immediately ready for work.

## Actions

1. Parse `.worktrees/PLAN.md`
2. Create worktree for each task (branch name: `feature/task-name`)
3. Automatically copy environment files (.env, package.json, lock files, etc.)
4. Generate task instructions in `tasks/` folder
5. Guide how to run Claude in each worktree

## Prerequisites

- Git repository
- `.worktrees/PLAN.md` 파일 존재

## PLAN.md Format

```markdown
# Task Plan

## Task List
​```bash
# Format: task-name: task description
auth: Implement user authentication system
payment: Implement payment module
search: Implement search feature
​```

## Common Context
- Use TypeScript
- Include test code
```

## Output

For each task:
- Create `.worktrees/[task-name]/` directory
- Generate `.worktrees/tasks/[task-name].md` task instructions
- Copy necessary environment files

## Example

```bash
# 1. Write PLAN.md
vim .worktrees/PLAN.md

# 2. Execute distribution
/worktree-distribute

# 3. Work in each worktree
cd .worktrees/auth && claude
```

## Implementation

```bash
scripts/worktree-manager.sh distribute
```