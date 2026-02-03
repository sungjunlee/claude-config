---
description: Initialize parallel development with git worktrees - create isolated environments for multi-task development
argument-hint: "<task1, task2, ...> [--continue] [--no-setup]"
allowed-tools: ["Bash", "Read", "Write", "Edit", "Glob", "Grep"]
---

# Worktree Init

Initialize parallel development environment for: $ARGUMENTS

## Role

You are a parallel development orchestrator. Your job is to:
1. Analyze the user's requirements and split them into independent, non-conflicting tasks
2. Create isolated git worktrees for each task
3. Set up the development environment in each worktree
4. Generate task-specific CLAUDE.md files to guide parallel Claude sessions

## Critical Rules

- **Task Independence**: Each task MUST modify different files. If tasks overlap, warn the user and suggest restructuring.
- **No File Conflicts**: Before creating worktrees, verify that tasks won't modify the same files.
- **Environment Isolation**: Each worktree gets its own installed dependencies (no symlinks for node_modules).

## Process

### Phase 1: Planning

1. **Analyze Requirements**:
   - Parse user's task description
   - Identify independent work units
   - Verify no file conflicts between tasks

2. **Generate PLAN.md**:
   - Create `.worktrees/PLAN.md` structure
   - Define task list with descriptions
   - Document common context and constraints

### Phase 2: Distribution

3. **Create Worktrees**:
   - Generate worktree for each task in `.worktrees/[task-name]/`
   - Branch naming: `feature/[task-name]`
   - Handle existing branches gracefully

4. **Copy Environment Files**:
   - `.env`, `.env.local`, `.env.development`
   - `package.json`, `*lock*` files
   - `tsconfig.json`, `.eslintrc.*`, `.prettierrc.*`
   - `pyproject.toml`, `requirements.txt`

### Phase 3: Setup

5. **Auto-detect and Run Package Manager**:
   ```bash
   pnpm-lock.yaml  → pnpm install
   yarn.lock       → yarn install
   package-lock.json → npm install
   bun.lockb       → bun install
   uv.lock         → uv sync
   pyproject.toml  → pip install -e .
   requirements.txt → pip install -r requirements.txt
   ```

6. **Generate Per-worktree CLAUDE.md**:
   - Task-specific instructions
   - Files to modify (scope)
   - Files to avoid (prevent conflicts)

## Examples

```bash
/worktree-init "Implement auth, payment, and search features"
/worktree-init "Fix login timeout, payment error, and search ranking bugs"
/worktree-init "Migrate API routes, update tests, update docs" --continue
```

## Generated Structure

```
.worktrees/
├── PLAN.md                    # Overall plan
├── tasks/
│   ├── auth.md               # Task instructions
│   ├── payment.md
│   └── search.md
├── auth/                      # Worktree directories
│   ├── CLAUDE.md             # Task-specific context
│   ├── .env                  # Copied env files
│   └── node_modules/         # Installed dependencies
├── payment/
└── search/
```

## Options

| Flag | Description |
|------|-------------|
| (no flag) | Create PLAN.md template only |
| `--continue` | Distribute worktrees + auto-setup (after editing PLAN.md) |
| `--no-setup` | Distribute worktrees without package manager install |

## Related Commands

- `/worktree-launch` - Launch Claude sessions in worktrees
- `/worktree-status` - Monitor worktree progress

## Execution

Run the worktree manager script:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/worktree-manager.sh init "$ARGUMENTS"
```
