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
   - Check `.worktrees/PLAN.md` presence (create template if missing)
   - Ensure no conflicting branches

2. **Parse PLAN.md**:
   - Understand task definitions and descriptions
   - Identify dependencies between tasks
   - Note common context and conventions

3. **Analyze Project Structure**:
   - Identify project type (Node.js, Python, Rust, etc.)
   - Find environment files to copy (.env, config files)
   - Detect package managers and lock files
   - Note any project-specific setup requirements

4. **Create Worktrees**:
   For each task in PLAN.md:
   ```bash
   git worktree add .worktrees/{task-name} -b feature/{task-name}
   ```

5. **Setup Environment**:
   Copy/symlink files based on project analysis:
   - Environment files (.env, .env.local, etc.)
   - Config files (tsconfig.json, pyproject.toml, etc.)
   - Lock files (package-lock.json, yarn.lock, etc.)
   - Symlink heavy directories (node_modules, venv, target)

6. **Generate Task Instructions**:
   Create `.worktrees/tasks/{task-name}.md` with:
   - Task description from PLAN.md
   - Relevant context for this specific task
   - Acceptance criteria
   - Notes on dependencies with other tasks

7. **Provide Next Steps**:
   - Show created worktrees
   - Suggest using `/my:wt-launch tmux` or `/my:wt-launch iterm` for auto-launch
   - Or show manual commands for each worktree

## PLAN.md Template

If `.worktrees/PLAN.md` doesn't exist, create:

```markdown
# Task Plan

## Task List
\`\`\`bash
# Format: task-name: description
auth: Implement user authentication (OAuth2.0, JWT)
payment: Integrate payment processing (Stripe)
search: Add full-text search (Elasticsearch)
\`\`\`

## Common Context
- [Project conventions and standards]
- [Testing requirements]
- [API patterns]

## Dependencies
- [Note any task dependencies or merge order]
```

## Dynamic File Detection

Instead of a fixed list, analyze the project to copy:

**Node.js projects:**
- package.json, package-lock.json, yarn.lock, pnpm-lock.yaml
- tsconfig*.json, .eslintrc*, .prettierrc*
- vite.config.*, next.config.*, webpack.config.*
- Symlink: node_modules/

**Python projects:**
- pyproject.toml, setup.py, requirements*.txt
- Pipfile, Pipfile.lock, poetry.lock
- .python-version, .flake8, mypy.ini
- Symlink: venv/, .venv/

**Rust projects:**
- Cargo.toml, Cargo.lock
- rust-toolchain.toml, .cargo/config.toml
- Symlink: target/

**Common:**
- .env, .env.local, .env.development, .env.production
- docker-compose.yml, Dockerfile
- .nvmrc, .node-version, .tool-versions

## Success Criteria

- All worktrees created with correct branches
- Environment properly configured for each worktree
- Task instructions generated with relevant context
- Clear guidance for launching parallel sessions

## Integration

- **Before**: Use `/my:wt-plan` to generate PLAN.md
- **After**: Use `/my:wt-launch tmux` or `/my:wt-launch iterm` to start sessions
- **Monitor**: Use `/my:wt-status` to check progress
- **Sync**: Use `/my:wt-sync` to synchronize env files
