---
description: Automatically generate PLAN.md for parallel task distribution using plan-agent
---

# Worktree Planning

Generate parallel task plan using plan-agent for: $ARGUMENTS

## Purpose
Leverage plan-agent to analyze complex requirements, identify parallelizable work units, and generate structured PLAN.md for worktree distribution.

## Process

1. **Invoke plan-agent**:
   - Analyze task complexity and scope
   - Research best practices if needed
   - Identify independent work units
   - Assess parallelization opportunities

2. **Task Analysis**:
   - Split work into independent units
   - Verify no file conflicts between tasks
   - Consider resource constraints
   - Estimate time for each task

3. **Generate PLAN.md**:
   - Create `.worktrees/PLAN.md` structure
   - Define task list with descriptions
   - Document common context
   - Specify dependencies if any

4. **Prepare for Distribution**:
   - Validate branch name availability
   - Check for existing worktrees
   - Ready for `/worktree-distribute`

## Examples

```bash
# Example 1: E-commerce site core features
/worktree-plan "Add authentication, payment, and search features to e-commerce site"

# Example 2: Large-scale refactoring
/worktree-plan "Migrate from React 16 to 18 while introducing TypeScript"

# Example 3: Bug fixes
/worktree-plan "Fix bugs found in login, payment, and search"
```

## Integration with plan-agent

This command leverages plan-agent's capabilities:
- **Complexity Assessment**: Evaluate overall project complexity
- **Task Division**: Intelligent splitting into parallel units
- **Research Integration**: Apply best practices from web/Context7
- **Risk Analysis**: Identify potential conflicts or blockers

## Generated PLAN.md Structure

````markdown
# Task Plan
Created: [YYYY-MM-DD]
Generator: plan-agent

## Task List
```bash
# Independent tasks that can run in parallel
auth: OAuth2.0 login system implementation (estimated: 2h)
payment: Stripe payment integration (estimated: 3h)  
search: Elasticsearch search feature (estimated: 2h)
```

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
````

## Workflow Sequence

```text
/worktree-plan → plan-agent analysis → PLAN.md generation → /worktree-distribute → Parallel execution
```

## Success Indicators

- PLAN.md created at `.worktrees/PLAN.md`
- All tasks truly independent (no file conflicts)
- Clear time estimates provided
- Common context properly documented
- Ready for immediate distribution

## Benefits

- **Intelligent Division**: AI-powered task splitting
- **Best Practices**: Research-informed planning
- **Time Savings**: Automated PLAN.md generation
- **Conflict Prevention**: Ensures task independence

## Error Handling

- **Complex Dependencies**: Warn if tasks can't be parallelized
- **File Conflicts**: Identify overlapping file modifications
- **Resource Constraints**: Note port/database conflicts
- **Existing Plans**: Prompt before overwriting

## Related Commands

- `/plan` - General strategic planning
- `/worktree-distribute` - Execute task distribution
- `/worktree-status` - Monitor progress
- `/worktree-sync` - Synchronize environments

Execute plan-agent now to analyze and generate parallel task plan.