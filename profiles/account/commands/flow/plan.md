---
description: Create detailed work plan using strategic planning agent
---

# Work Planning

Create a detailed plan for: $ARGUMENTS

## Purpose
Delegate complex planning tasks to the plan-agent for comprehensive research and strategic execution planning.

## Planning Approach

This command leverages the specialized plan-agent to:
- Research current best practices
- Analyze technical requirements
- Generate actionable execution plans
- Setup automated workflows

## Process

### For Complex Tasks
When planning complex work (modernization, migrations, architecture changes):

```markdown
Delegating to plan-agent for strategic planning...

Use plan-agent for comprehensive planning with research.

The agent will:
1. Analyze requirements and context
2. Research best practices via web search
3. Check latest library versions via Context7
4. Generate detailed execution strategy
5. Setup quality gates and automation
```

### For Standard Tasks
When planning straightforward work:

```markdown
Creating structured plan...

Use plan-agent for task breakdown and organization.

The agent will:
1. Break down requirements
2. Identify dependencies
3. Create actionable steps
4. Define success criteria
```

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