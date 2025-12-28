---
description: Create session handoff documentation for context transfer
---

# Session Handoff

Generate handoff documentation for: $ARGUMENTS

## Purpose

Save current session state before `/clear` to maintain work continuity.

## Handoff Modes

### Quick (Default)
- Current work summary
- Modified files list
- Next immediate steps
- Essential context only

### Detailed (`--detailed`)
- Complete session history
- All technical decisions
- Full code changes review

### Team (`--team`)
- Background and requirements
- Setup instructions
- Dependencies and blockers

## Handoff Document Structure

Create at `docs/handoff/HANDOFF-[YYYYMMDD-HHMM].md`:

```markdown
# Project Handoff - [timestamp]

## Session Summary
[Main objectives and achievements]

## Completed Tasks
- [List of completed work items]

## Current State
### Active Work
[What was being worked on]

### Modified Files
[Files changed with modification types]

### Key Decisions
[Important choices made]

### Working Notes
[From docs/handoff/.scratch.md if exists]

## Next Steps
### Complexity: [Simple|Medium|Complex]
1. [Priority tasks]
2. [Expected upcoming work]

### Recommended Approach
[If complex: "Requires plan-agent for strategic planning"]
[If simple: "Direct continuation possible"]

## Important Notes
- [Warnings and gotchas]
- [Known issues]

## Technical Context
- Build: `[command]`
- Test: `[command]`
- Lint: `[command]`

## Session Metadata
- Model: [current model]
- Complexity Level: [1-10]
- Flow State: [deep_work|exploring|debugging|refactoring|implementing]
- Confidence: [1-10]
```

## Metadata File

Update `docs/handoff/.current`:
```yaml
current: HANDOFF-[timestamp].md
created: [ISO timestamp]
complexity_level: [1-10]
flow_state: [state]
confidence_level: [1-10]
```

## Flow State Assessment

- **deep_work**: Continuous progress (3+ successful steps)
- **exploring**: Searching for solutions
- **debugging**: Fixing errors or failures
- **refactoring**: Code restructuring
- **implementing**: Building new features

## Confidence Level

- 9-10: Clear path forward
- 6-8: Minor uncertainties
- 3-5: Multiple approaches being evaluated
- 1-2: Blocked, need help

## Scratch Notes

Lightweight working memory at `docs/handoff/.scratch.md`:

```markdown
# Scratch Notes

## Current Focus
[One-line description]

## Blockers
- [Things stuck]

## Quick Notes
- [Ideas, reminders]

## Try Next
- [Approaches to attempt]
```

## Auto-trigger Conditions

Suggest handoff when:
- Context usage > 80%
- Before `/clear`
- After major milestone
- When switching features

## Archive Policy

- Keep last 5 handoffs
- Move older to `docs/handoff/archive/`

## Process

1. **Analyze** - Review conversation, identify pending work
2. **Assess** - Evaluate complexity and flow state
3. **Generate** - Create structured document
4. **Validate** - Ensure completeness
5. **Notify** - Confirm location and suggest `/clear`

Generate handoff documentation now.
