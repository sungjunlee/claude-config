---
description: Resume work from previous handoff with intelligent planning
---

# Resume from Handoff

Resume work session from: $ARGUMENTS

## Purpose

Restore context and intelligently determine continuation strategy.

## Resume Options

### Default (No Arguments)
- Load latest handoff from `.current`
- Assess complexity
- Delegate to appropriate strategy

### Specific Handoff (`filename`)
- Load specified document
- Example: `HANDOFF-20250824-1430.md`

### List Mode (`--list`)
- Display available handoffs
- Show summaries

### Verify Mode (`--verify`)
- Check conflicts with current state
- Identify changed files since handoff

## Resume Process

### Phase 1: Load Handoff

```python
if no arguments:
    load docs/handoff/.current
elif filename:
    load docs/handoff/[filename]
elif --list:
    show available handoffs
```

### Phase 2: Load Scratch Notes

Check `docs/handoff/.scratch.md`:
- Load as priority context
- Display blockers prominently
- Use as immediate working memory

### Phase 3: Flow State Assessment

Based on `flow_state` and `confidence_level`:

```python
if flow_state == "debugging" and confidence < 4:
    # Stuck - invoke debugger

elif flow_state == "exploring" and confidence < 6:
    # Searching - need research/plan

elif flow_state == "deep_work" and confidence > 7:
    # Clear path - continue directly
```

### Phase 4: Complexity-Based Delegation

#### Complex Tasks (8-10)
```markdown
## Complex Work Detected

Complexity: [level] | Flow: [state] | Confidence: [level]/10

Invoke plan-agent for:
- Best practices research
- Library version check
- Comprehensive execution plan
```

#### Debugging State
```markdown
## Debugging Session Detected

Confidence: [level]/10
[If < 4: "Previous approach blocked. New strategy needed."]

Invoking debugger agent.
```

#### Medium Tasks (4-7)
```markdown
## Standard Work Ready

Next steps identified:
[List from handoff]

Proceeding with structured approach.
```

#### Simple Tasks (1-3)
```markdown
## Simple Task Ready

Ready to continue with: [task]
Direct continuation available.
```

### Phase 5: Context Restoration

Display:
```markdown
## Restored Context

### Previous Session
- Objective: [from handoff]
- Completed: [tasks]
- Flow State: [state]
- Confidence: [level]/10

### Current State
- Modified files: [list]
- Known issues: [warnings]

### Working Memory
[From scratch.md if exists]
- Current focus
- Blockers
- Try next
```

## Agent Invocation

Automatically triggered based on context:
- **plan-agent**: Complex tasks, modernization, migrations
- **debugger**: Unresolved errors, low confidence debugging
- **test-runner**: Test failures detected
- **code-reviewer**: PR preparation needed

## Git Integration

Automatically check:
- Correct branch
- Uncommitted changes
- Conflicts

## Error Handling

### Missing Handoff
```markdown
No handoff found. Options:
1. /flow:plan [requirements]
2. /flow:handoff (create initial)
```

### Outdated Handoff (> 3 days)
```markdown
Handoff is [X] days old.
Recommend: Use plan-agent to reassess.
```

## Smart Suggestions

```markdown
## Recommended Actions

Flow: [state] | Confidence: [level]/10

1. [Primary recommendation]
2. [Secondary options]

Strategy:
[Tailored advice based on state]
```

Execute resume process now.
