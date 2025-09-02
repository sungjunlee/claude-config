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

### High Priority (Always Sync)
- `.env`, `.env.local`, `.env.development`
- Security certificates and keys
- Shared configuration files

### Medium Priority (Sync if Changed)
- `package.json` (warn about npm install)
- `requirements.txt` (warn about pip install)
- Config files (tsconfig, eslint, prettier)

### Preserved (Never Overwrite)
- Source code files
- Test files
- Documentation
- Git-tracked content

## Example Output

```
🔄 Syncing environment files...

Checking: auth
  ✓ Updated .env
  ✓ Updated package.json

Checking: payment
  ✓ Updated .env
  ⚠ package.json differs - skipping (has local changes)

Checking: search
  ✓ All files up to date

✅ Synced 3 file(s)
⚠ Note: Run 'npm install' in auth worktree (package.json updated)
```

## Conflict Resolution

When conflicts detected:
1. Show diff between versions
2. Ask user to choose action
3. Option to backup before overwrite
4. Log all sync operations

## Integration Points

- Run after environment changes in main
- Before starting work in worktree
- After pulling updates from remote
- Part of regular maintenance workflow

## Advanced Features

Future enhancements:
- Two-way sync from worktrees to main
- Automatic dependency installation
- Config validation after sync
- Sync history tracking

Execute synchronization now using `scripts/worktree-manager.sh sync`.