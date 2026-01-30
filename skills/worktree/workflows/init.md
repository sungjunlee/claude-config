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
   - And 15+ other config file types

### Phase 3: Setup

5. **Auto-detect and Run Package Manager**:
   ```bash
   # Detection order
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
# Feature development
/worktree-init "Implement auth, payment, and search features"

# Bug fixes
/worktree-init "Fix login timeout, payment error, and search ranking bugs"

# Refactoring
/worktree-init "Migrate API routes to new pattern, update tests, update docs"
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
│   ├── node_modules/         # Installed dependencies
│   └── src/...
├── payment/
└── search/
```

## Per-worktree CLAUDE.md Example

```markdown
# Task: auth

## Objective
Implement OAuth2.0 authentication system

## Scope - Files to Modify
- src/auth/*
- src/middleware/auth.ts
- tests/auth/*

## Out of Scope - DO NOT MODIFY
- src/payment/* (another worktree)
- src/search/* (another worktree)

## Acceptance Criteria
- OAuth2.0 flow working
- JWT token generation
- Test coverage > 80%

## Common Context
- Use TypeScript strict mode
- Follow existing patterns in src/
```

## Output Example

```
🚀 Initializing parallel worktrees...

📋 Planning Phase
   Analyzed: 3 independent tasks identified
   Created: .worktrees/PLAN.md

📦 Distribution Phase
   ✅ auth worktree created (feature/auth)
   ✅ payment worktree created (feature/payment)
   ✅ search worktree created (feature/search)

🔧 Setup Phase
   auth: pnpm install... done (3.2s)
   payment: pnpm install... done (1.1s, cached)
   search: pnpm install... done (1.0s, cached)

📝 CLAUDE.md generated for each worktree

🎉 Ready! Next steps:
   /worktree-launch tmux    # Launch Claude sessions
   /worktree-status         # Monitor progress
```

## Options

| Flag | Description |
|------|-------------|
| (no flag) | Create PLAN.md template only |
| `--continue` | Distribute worktrees + auto-setup (after editing PLAN.md) |
| `--no-setup` | Distribute worktrees without package manager install |

## Error Handling

- **Branch exists**: Offer to reuse or create new name
- **Conflicting tasks**: Warn about overlapping file modifications
- **Setup failure**: Continue with other worktrees, report issues

## Related Commands

- `/worktree-launch` - Launch Claude sessions in worktrees
- `/worktree-status` - Monitor worktree progress

## Execution

Run the worktree manager script:
```bash
~/.claude/scripts/worktree-manager.sh init "$ARGUMENTS"
```
