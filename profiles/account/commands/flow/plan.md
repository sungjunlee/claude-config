---
description: Create detailed work plan using strategic planning agent
---

# Work Planning

Create a detailed plan for: $ARGUMENTS

## 🔍 Enhanced Research Phase
Automatically performed research:
1. **Web Search**: Latest best practices (2025)
2. **Context7**: Library latest versions and recommendations
3. **GitHub**: Similar implementation examples
4. **Internal**: Existing codebase patterns

## 📋 Structured Output Template

### Execution Plan Generation
```markdown
# 🎯 Task: [Clear task name]
Created: [YYYY-MM-DD HH:MM]
Complexity: [Simple|Medium|Complex] (auto-calculated)
Estimated Time: [auto-estimated]

## 🧠 Thinking Mode
- [ ] Normal (< 5 files)
- [ ] Think (5-15 files)
- [ ] Ultra Think (> 15 files or architecture changes)

## 🌿 Git Workflow
Branch: `[branch-type]/[task-name]`
Commits:
  1. Initial setup: [description]
  2. Core implementation: [description]
  3. Tests & docs: [description]
PR Strategy: Draft → Review (code-reviewer) → Merge

## 📊 Implementation Phases
### Phase 1: [Name] (Parallel ✓)
- [ ] Step 1.1: [Action]
- [ ] Step 1.2: [Action] [parallel]
- [ ] Step 1.3: [Action] [parallel]
⏱️ Estimated: 30min

### Phase 2: [Name] (Sequential)
- [ ] Step 2.1: [Action] [depends: 1.1]
- [ ] Step 2.2: [Action]
⏱️ Estimated: 45min

## 🤖 Automated Triggers
```yaml
on_phase_complete:
  phase_1: "git commit -m 'feat: complete initial setup'"
  phase_2: "invoke test-runner"
on_pr_ready: "invoke code-reviewer"
on_context_80: "invoke handoff-agent"
```

## ⚠️ Risk Matrix
| Risk | Impact | Mitigation | Auto-Action |
|------|--------|------------|-------------|
| DB Migration | High | Backup first | `--dry-run` |
| API Breaking | Medium | Version it | deprecation notice |

## 🎬 Quick Start Commands
```bash
# Ready-to-execute commands
git checkout -b feature/task-name
npm install required-packages
/dev:code "Phase 1 implementation"
```
```

## Purpose
Delegate complex planning tasks to the plan-agent for comprehensive research and strategic execution planning.

## Planning Approach

This command leverages the specialized plan-agent to:
- Research current best practices with web search
- Check latest library versions via Context7
- Analyze technical requirements and existing patterns
- Generate actionable execution plans with Git integration
- Setup automated workflows and quality gates

## Process

### For Complex Tasks
When planning complex work (modernization, migrations, architecture changes):

```markdown
Delegating to plan-agent for strategic planning...

Use plan-agent for comprehensive planning with research.

The agent will:
1. Analyze requirements and context
2. Research best practices via web search (2025)
3. Check latest library versions via Context7
4. Generate detailed execution strategy with Git workflow
5. Setup quality gates and automation
6. Define thinking mode based on complexity
```

### For Standard Tasks
When planning straightforward work:

```markdown
Creating structured plan...

Use plan-agent for task breakdown and organization.

The agent will:
1. Break down requirements into phases
2. Identify dependencies and parallel opportunities
3. Create actionable steps with time estimates
4. Setup Git branch and commit strategy
5. Define success criteria
```

### 🚀 Parallel Work Support
When using worktrees for parallel development:
```bash
# .worktrees/PLAN.md auto-generation
auth: OAuth implementation (2h) [parallel]
payment: Stripe integration (3h) [parallel]
search: Elasticsearch setup (2h) [parallel]
```

## 🔄 Handoff Integration
When context reaches 80%:
- Automatic handoff document generation
- Current progress state preservation
- Resumable with `/flow:resume`

## Plan-Agent Integration

The plan-agent automatically handles:

### Research Phase
- Web searches for current patterns and practices
- Context7 queries for library recommendations
- Security best practices investigation
- Performance optimization strategies

### Strategic Planning
- Multi-phase execution strategies
- Risk assessment and mitigation
- Automated workflow configuration
- Quality gate definitions

### Output Generation
Produces comprehensive plans including:
- Complexity assessment
- Research findings summary
- Phase-by-phase implementation
- Automated workflow setup
- Documentation requirements
- Success criteria

## Usage Examples

```text
# Plan a modernization task
/flow:plan modernize authentication system to use JWT
# → plan-agent researches JWT best practices
# → Generates migration strategy
# → Sets up testing and review workflows

# Plan a new feature
/flow:plan implement user dashboard with analytics
# → plan-agent analyzes requirements
# → Researches dashboard patterns
# → Creates phased implementation plan

# Plan from resume context
/flow:resume
# → Complex work detected
# → /flow:plan automatically suggested
/flow:plan
# → plan-agent imports handoff context
# → Continues planning from previous state
```

## Direct Invocation vs Resume Flow

### When called directly:
- Full context discovery
- Complete requirements analysis
- Standalone planning

### When suggested by /flow:resume:
- Automatic context import from handoff
- Continuation of previous work
- Focused forward planning

## Output Format

The plan-agent will provide:

```markdown
# Execution Plan: [Task]

## 📊 Complexity Assessment
[Level and factors]

## 🔍 Research Findings
[Key insights from web/Context7]

## 📋 Implementation Strategy
[Phased approach with checkpoints]

## 🤖 Automated Workflows
[Git, testing, review automation]

## ⚠️ Risk Mitigation
[Identified risks and strategies]

## ✅ Success Criteria
[Measurable outcomes]
```

## Best Practices

1. **Provide clear requirements**: The more specific, the better the plan
2. **Trust the research**: plan-agent uses current best practices
3. **Review automation setup**: Ensure workflows match your process
4. **Iterate if needed**: Request refinements for specific concerns

## Note

This command is a lightweight wrapper that delegates to the plan-agent. The agent handles all heavy lifting including research, analysis, and plan generation. This ensures consistent, high-quality planning with current best practices.

Initiate planning now using plan-agent for: $ARGUMENTS