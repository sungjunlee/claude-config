# Command: /worktree-plan

Automatically generate PLAN.md for parallel tasks using plan-agent

## Usage

```bash
/worktree-plan [task description]
```

## Description

Calls plan-agent to analyze tasks, splits them into independent tasks that can be executed in parallel,
and automatically generates `.worktrees/PLAN.md` file.

## Examples

```bash
# Example 1: E-commerce site core features
/worktree-plan "Add authentication, payment, and search features to e-commerce site"

# Example 2: Large-scale refactoring
/worktree-plan "Migrate from React 16 to 18 while introducing TypeScript"

# Example 3: Bug fixes
/worktree-plan "Fix bugs found in login, payment, and search"
```

## Process

1. **Call plan-agent**
   - Evaluate task complexity
   - Split into units that can run in parallel
   - Verify independence of each task

2. **Generate PLAN.md**
   - Create task list in standard format
   - Define common context
   - Specify dependencies between tasks

3. **Prepare automatic distribution**
   - Prepare for `/worktree-distribute` execution
   - Determine branch names for each task
   - Estimate task duration

## Generated PLAN.md Format

```markdown
# Task Plan
Created: 2025-01-28
Generator: plan-agent

## Task List
​```bash
# Independent tasks that can run in parallel
auth: OAuth2.0 login system implementation (estimated: 2h)
payment: Stripe payment integration (estimated: 3h)  
search: Elasticsearch search feature (estimated: 2h)
​```

## Common Context
- Use TypeScript
- Tests required
- Follow REST API standards

## Task Dependencies
- All tasks can run independently
- Merge order: no restrictions

## Notes
- Based on plan-agent research findings
- Applies current best practices
```

## Integration with Plan-agent

This command leverages the following plan-agent capabilities:

1. **Complexity Assessment**: Analyze overall task complexity
2. **Task Division**: Break down into parallel-executable units
3. **Research**: Web search and Context7 queries when needed
4. **Risk Assessment**: Identify risk factors for each task

## Workflow

```mermaid
/worktree-plan → plan-agent → Generate PLAN.md → /worktree-distribute → Parallel tasks
```

## Benefits

- **Automation**: No need to manually write PLAN.md
- **Optimization**: plan-agent performs optimal task division
- **Consistency**: Generated in standardized format
- **Research-based**: Applies latest best practices

## Related Commands

- `/plan` - General task planning (not parallel execution)
- `/worktree-distribute` - Distribute tasks based on PLAN.md
- `/worktree-status` - Check parallel task progress

## Implementation

```bash
# 1. Call plan-agent to analyze tasks
# 2. Split into parallel-executable tasks
# 3. Generate .worktrees/PLAN.md
# 4. Guide user to next steps
```