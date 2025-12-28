---
description: Create detailed work plan using strategic planning
---

# Work Planning

Create a detailed plan for: $ARGUMENTS

## Research Phase

Automatically perform:
1. **Web Search**: Latest best practices (2025)
2. **Context7**: Library versions and recommendations
3. **GitHub**: Similar implementations
4. **Internal**: Existing codebase patterns

## Output Template

```markdown
# Task: [Clear task name]
Created: [YYYY-MM-DD HH:MM]
Complexity: [Simple|Medium|Complex]

## Thinking Mode
- [ ] Normal (< 5 files)
- [ ] Think (5-15 files)
- [ ] Ultra Think (> 15 files or architecture)

## Git Workflow
Branch: `[type]/[name]`
Commits:
  1. Initial setup
  2. Core implementation
  3. Tests & docs
PR Strategy: Draft → Review → Merge

## Implementation Phases

### Phase 1: [Name] (Parallel)
- [ ] Step 1.1
- [ ] Step 1.2 [parallel]
- [ ] Step 1.3 [parallel]
Estimated: 30min

### Phase 2: [Name] (Sequential)
- [ ] Step 2.1 [depends: 1.1]
- [ ] Step 2.2
Estimated: 45min

## Automated Triggers
on_phase_complete:
  phase_1: "git commit -m 'feat: ...'"
  phase_2: "invoke test-runner"
on_pr_ready: "invoke code-reviewer"
on_context_80: "invoke handoff"

## Risk Matrix
| Risk | Impact | Mitigation |
|------|--------|------------|
| [Risk 1] | High | [Strategy] |

## Quick Start
git checkout -b [branch]
[setup commands]
```

## Complexity Levels

### Simple (1-3)
- Quick execution checklist
- Direct action items
- Skip extensive research

### Medium (4-7)
- Structured checkpoints
- Identify blockers
- Basic research

### Complex (8-10)
- Comprehensive breakdown
- Risk assessment
- Extensive research
- Multiple review points

## Parallel Work Support

For worktree parallel development:
```bash
# .worktrees/PLAN.md format
auth: OAuth implementation (2h) [parallel]
payment: Stripe integration (3h) [parallel]
search: Elasticsearch setup (2h) [parallel]
```

## Handoff Integration

At 80% context:
- Auto handoff generation
- Progress state preservation
- Resumable with `/flow:resume`

## Usage

```bash
# Plan modernization
/flow:plan modernize auth to JWT
# → Research JWT best practices
# → Generate migration strategy

# Plan new feature
/flow:plan implement user dashboard
# → Analyze requirements
# → Create phased plan

# Continue from resume
/flow:resume  # Complex detected
/flow:plan    # Import handoff context
```

## Best Practices

1. **Clear requirements**: More specific = better plan
2. **Trust research**: Uses current best practices
3. **Review automation**: Ensure workflows match process
4. **Iterate**: Request refinements as needed

Initiate planning now for: $ARGUMENTS
