# Command: /worktree-sync

Synchronize shared information between worktrees

## Usage

```bash
/worktree-sync
```

## Description

Synchronizes information that needs to be shared between worktrees.
Propagates environment variable changes, common settings, context information, etc.

## Actions

1. **Environment file synchronization**
   - Propagate .env changes from main branch to all worktrees
   - Detect and notify package.json dependency changes

2. **Update shared context**
   - Update `.worktrees/CONTEXT.md` file
   - Record progress of each worktree in STATUS.md

3. **Configuration file synchronization**
   - Propagate changes to configuration files like tsconfig.json, .eslintrc

## Example

```bash
# After modifying .env in main
/worktree-sync

# 출력:
✓ Synced .env to auth worktree
✓ Synced .env to payment worktree
✓ Updated CONTEXT.md
⚠ package.json changed - run npm install in worktrees
```

## Implementation

Detect environment file changes and selective synchronization:
- Copy only changed files
- Confirm with user for potentially conflicting files
- Maintain node_modules symlink

## Notes

- Do not overwrite files being worked on
- Important changes require user confirmation