---
description: Resume work from previous handoff with intelligent planning
---

# Resume from Handoff

Resume work session from handoff: $ARGUMENTS

## Purpose
Restore work context from a previous handoff document and intelligently determine the best continuation strategy.

## Resume Options

### Default (No Arguments)
- Automatically load the latest handoff from `.current` metadata
- Assess complexity and delegate to appropriate agents
- Quick context restoration for simple tasks

### Specific Handoff (`filename`)
- Load specified handoff document
- Example: `HANDOFF-20250824-1430.md`
- Useful for returning to older sessions

### List Mode (`--list`)
- Display available handoff documents
- Show creation dates and summaries
- Allow interactive selection

### Verify Mode (`--verify`)
- Check for conflicts with current state
- Identify files changed since handoff
- Warn about outdated information

## Resume Process

### Phase 1: Load and Analyze Handoff

1. **Load Handoff Document**:
   ```python
   # Check for handoff location
   if no arguments:
       read docs/handoff/.current
       load specified handoff file
   elif filename provided:
       load docs/handoff/[filename]
   elif --list:
       show available handoffs
       prompt for selection
   ```

2. **Parse Handoff Content**:
   - Extract session summary
   - Load technical context
   - Identify next steps
   - Note important warnings
   - **Extract complexity level from metadata**
   - **Extract flow_state and confidence_level**

3. **Load Scratch Notes**:
   - Check for `docs/handoff/.scratch.md`
   - If exists, load as priority context
   - Display any blockers or "try next" items prominently
   - Use as immediate working memory

### Phase 2: Flow State and Complexity Assessment

**Analyze flow_state and confidence_level from metadata:**
```python
# Flow state determines continuation strategy
if flow_state == "debugging" and confidence_level < 4:
    # Stuck in debugging - invoke debugger agent
    invoke_debugger_agent()
elif flow_state == "exploring" and confidence_level < 6:
    # Still searching for approach - research needed
    invoke_research_or_plan_agent()
elif flow_state == "deep_work" and confidence_level > 7:
    # Clear path - continue directly
    continue_with_current_approach()
```

**Evaluate the work complexity based on:**
- Number and nature of next steps
- Technical debt indicators
- Dependency requirements
- Modernization/migration scope
- External integrations needed
- **Combined with flow_state for accurate assessment**

```python
Complexity Indicators:
- Simple (1-3): Single file changes, typos, simple fixes
- Medium (4-7): Multiple files, standard features, clear requirements
- Complex (8-10): Architecture changes, modernization, migrations, research needed
```

### Phase 3: Intelligent Delegation

Based on **flow_state, confidence_level, and complexity assessment**, automatically delegate to appropriate agents:

#### For Complex Tasks (complexity > 7):
```markdown
## 🔄 Complex Work Detected

Complexity: [level] | Flow: [state] | Confidence: [level]/10

Analyzing modernization/migration requirements...

Use plan-agent for strategic planning and research.

The plan-agent will:
- Research best practices
- Check latest library versions
- Generate comprehensive execution plan
- Setup automated workflows
```

#### For Debugging State (flow_state == "debugging"):
```markdown
## 🔍 Debugging Session Detected

Confidence level: [level]/10
[If confidence < 4: "Previous approach blocked. Trying new strategy..."]

Invoking debugger agent for systematic analysis.
```

#### For Exploring State (flow_state == "exploring"):
```markdown
## 🔎 Exploration Mode Active

Confidence level: [level]/10
Multiple approaches being evaluated.

[If days_since > 2: "Refreshing research with latest information..."]
[If confidence < 5: "Consider using plan-agent for structured approach"]
```

#### For Medium Tasks (complexity 4-7):
```markdown
## 📋 Standard Work Ready

Next steps identified:
[List from handoff]

Proceeding with structured approach.
Consider using plan-agent if strategic planning needed.
```

#### For Simple Tasks (complexity < 4):
```markdown
## ✅ Simple Task Ready

Ready to continue with: [specific task]

Direct continuation available.
```

### Phase 4: Context Restoration

Display restored context appropriately:

```markdown
## Restored Context Summary

### Previous Session
- Objective: [from handoff]
- Completed: [task list]
- Complexity: [level]
- Flow State: [deep_work|exploring|debugging|refactoring|implementing]
- Confidence: [level]/10

### Current State
- Modified files: [list]
- Active work: [description]
- Known issues: [warnings]

### Working Memory (from scratch notes)
[If scratch.md exists, show key points:]
- Current focus: [from scratch]
- Blockers: [from scratch]
- Try next: [from scratch]

### Continuation Strategy
[Based on complexity, show delegation or direct path]
```

## Auto-Agent Invocation

The resume command intelligently invokes specialized agents:

### Plan-Agent Invocation
Automatically triggered for:
- Modernization tasks
- Migration work
- Complex features requiring research
- Tasks with unclear requirements
- Work requiring coordination across multiple systems

### Other Agent Invocations
Based on specific needs and flow state:
- **test-runner**: When test failures detected in handoff
- **debugger**: When unresolved errors present OR flow_state="debugging" with low confidence
- **code-reviewer**: When PR preparation needed
- **research-agent**: When flow_state="exploring" with low confidence
- **time-aware**: Automatically when checking dates or versions

## Integration with Git Workflow

Automatically check and prepare git environment:
- Verify correct branch
- Check for uncommitted changes
- Note any conflicts
- Prepare for branching if needed

## Smart Suggestions

Based on handoff analysis and flow state, provide intelligent suggestions:

```markdown
## 🎯 Recommended Actions

Flow State: [state] | Confidence: [level]/10

Based on your handoff:
1. [Primary recommendation based on flow_state + confidence + complexity]
2. [Secondary options]

Detected patterns:
- [Pattern type]: [Suggested approach]

Strategy:
[If debugging + low confidence: "Systematic debugging approach recommended"]
[If exploring + medium confidence: "Continue evaluation, document findings"]
[If deep_work + high confidence: "Direct continuation optimal"]
```

## Scratch Notes Integration

The resume command prioritizes loading scratch notes for immediate context:

### What are Scratch Notes?
- Lightweight working memory stored at `docs/handoff/.scratch.md`
- Contains current focus, blockers, and "try next" approaches
- Loaded automatically if present, displayed prominently

### How Scratch Notes Enhance Resume
```markdown
# If scratch.md exists, you'll see:
## 🧠 Working Memory Restored
Current Focus: "Debugging JWT refresh token rotation"
Blockers: ["Race condition in token invalidation"]
Try Next: ["Implement Redis-based token blacklist"]
```

This provides immediate orientation without reading entire handoff, enabling faster continuation of interrupted work.

## Error Handling

### Missing Handoff:
```markdown
No handoff found. Options:
1. Start fresh with strategic planning: /flow:plan [requirements]
2. Create initial handoff: /flow:handoff
```

### Outdated Handoff:
```markdown
⚠️ Handoff is [X] days old

Recommended: Use plan-agent to reassess current state
This will research current best practices and update approach.
```

## Usage Examples

```text
# Resume with automatic planning for complex work
/flow:resume
# → Detects modernization work
# → "Use plan-agent for strategic planning"
# → Plan-agent automatically handles research and planning

# Resume simple task
/flow:resume
# → Detects simple fix
# → Shows direct continuation

# Resume with verification
/flow:resume --verify
# → Checks conflicts
# → Assesses complexity
# → Suggests appropriate path

# List available handoffs
/flow:resume --list
# → Displays available handoffs and allows selection
```

## Best Practices

1. **Let agents handle complexity**: Trust the automatic delegation
2. **Review git status**: Always check version control state
3. **Update regularly**: Keep handoffs current for accurate complexity assessment
4. **Use verification**: Run `--verify` for handoffs > 3 days old

## Implementation Note

When this command detects complex work requiring planning:
- It will instruct: "Use plan-agent for strategic planning"
- The plan-agent will automatically be invoked
- The agent will handle research, planning, and setup
- You'll receive a comprehensive execution plan

This ensures seamless continuation regardless of task complexity, with appropriate tooling and research automatically applied where needed.

Execute resume process now based on provided arguments and complexity assessment.