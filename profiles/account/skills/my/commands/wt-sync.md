---
description: Synchronize environment files and shared context across all worktrees
---

# Worktree Synchronization

Synchronize shared files across all worktrees for: $ARGUMENTS

## Purpose
Keep environment files, dependencies, and configurations consistent across all parallel worktrees while preserving local changes.

## Process

1. **Identify Changes**:
   - Compare main branch files with worktree copies
   - Detect modified environment files
   - Check configuration updates

2. **Selective Sync**:
   - Sync critical files (.env, .env.local)
   - Update package.json if changed
   - Preserve worktree-specific modifications

3. **Smart Updates**:
   - Only copy newer files
   - Skip files with local changes
   - Maintain symlinks integrity

4. **Notify Actions**:
   - Report synced files
   - Warn about dependency changes
   - Suggest npm/pip install if needed

## Files Synchronized

Currently syncs the following core files:
- `.env` - Environment variables
- `.env.local` - Local environment overrides
- `package.json` - Node.js dependencies (warn about npm install)

### Preserved (Never Overwrite)
- Source code files
- Test files
- Documentation
- Git-tracked content

## Example Output

```text
Syncing environment files...

Checking: auth
  UPD .env updated
  UPD package.json updated

Checking: payment
  UPD .env updated
  SKIP package.json differs (local changes)

Checking: search
  OK  .env is up to date
  OK  package.json is up to date

Done. Synced 3 file(s).
Skipped 1 file(s) with local changes.
Note: run 'npm install' in auth
```

## Integration Points

- Run after environment changes in main
- Before starting work in worktree
- After pulling updates from remote
- Part of regular maintenance workflow

Execute synchronization now using `scripts/worktree-sync.sh`.

