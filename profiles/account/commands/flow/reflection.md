---
description: Invoke reflection-agent for Claude self-analysis and workflow optimization
---

# Claude Self-Reflection

Perform Claude self-analysis and workflow optimization: $ARGUMENTS

## Purpose
Invoke the reflection-agent to analyze Claude's own performance, context usage patterns, and workflow efficiency for continuous improvement.

## What This Command Does

### 1. Performance Self-Analysis
- Analyzes current context usage and efficiency
- Evaluates task completion patterns and success rates
- Reviews tool usage patterns and optimization opportunities
- Assesses communication effectiveness and response quality

### 2. Workflow Optimization
- Identifies recurring patterns and bottlenecks
- Suggests improvements for development workflows
- Recommends better tool sequences and agent utilization
- Provides actionable insights for efficiency gains

### 3. Strategic Insights
- Tracks long-term trends and improvements
- Identifies best practices worth replicating
- Suggests process enhancements and automation opportunities
- Provides recommendations for better context management

## Usage Scenarios

### When to Use Reflection
```bash
# End of long development sessions
/flow:reflection "analyze this debugging session performance"

# Before major handoffs
/flow:reflection "prepare handoff optimization recommendations"

# After complex multi-step tasks
/flow:reflection "evaluate the efficiency of this feature implementation"

# General performance check
/flow:reflection "current workflow optimization analysis"

# Strategic planning
/flow:reflection "identify patterns for automation opportunities"
```

### Automatic Triggers
This command can be automatically invoked by hooks:
- End of sessions >50 interactions
- Context usage reaches 80%
- Before major handoffs
- After challenging debugging sessions

## Integration with Workflow

### With Handoff/Resume System
- Provides insights for better handoff timing
- Analyzes context preservation effectiveness  
- Recommends resume strategy improvements
- Monitors workflow continuity quality

### With Other Agents
- Evaluates agent selection and utilization patterns
- Tracks collaboration effectiveness between agents
- Suggests optimal agent invocation strategies
- Monitors specialized agent performance

### With Hook System
- Analyzes automated workflow effectiveness
- Recommends hook optimization strategies
- Tracks automation impact on productivity
- Suggests new automation opportunities

## Expected Output

The reflection-agent will provide:

```markdown
# 🔍 Claude Performance Reflection

## 📊 Current Session Analysis
- Context usage and efficiency metrics
- Task completion success rates
- Tool usage optimization opportunities
- Communication effectiveness assessment

## 💡 Immediate Recommendations
- Specific actionable improvements
- Workflow optimization suggestions
- Context management strategies
- Tool sequence enhancements

## 📈 Long-term Insights
- Pattern recognition and trends
- Best practices identification
- Strategic improvement opportunities
- Automation recommendations
```

## Benefits

### For Development Efficiency
- Identifies workflow bottlenecks and optimization opportunities
- Suggests better tool usage patterns and sequences
- Recommends process improvements and automation
- Provides insights for continuous productivity gains

### For Learning and Adaptation
- Tracks what strategies work best for different task types
- Identifies successful patterns worth replicating
- Provides objective assessment of performance trends
- Guides strategic workflow decisions

### For Context Management
- Optimizes handoff timing and quality
- Improves context preservation strategies
- Reduces context waste and inefficiency
- Enhances session continuity and productivity

## Advanced Usage

### With Arguments for Focused Analysis
```bash
# Focus on specific aspects
/flow:reflection "tool usage patterns"
/flow:reflection "context management efficiency"
/flow:reflection "debugging workflow analysis"
/flow:reflection "agent collaboration effectiveness"
```

### Integration with Planning
- Use before `/plan` commands for strategic insights
- Combine with `/handoff` for optimization recommendations
- Include in `/resume` workflow for continuous improvement
- Leverage for `/worktree` efficiency analysis

Execute reflection-agent analysis for: $ARGUMENTS