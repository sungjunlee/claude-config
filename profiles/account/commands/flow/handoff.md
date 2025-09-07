---
description: Create session handoff documentation for context transfer
---

# Session Handoff

Generate comprehensive handoff documentation for: $ARGUMENTS

## Purpose
Save current session state before `/clear` to maintain work continuity and prevent context loss.

## Handoff Modes

### Default Mode (Quick Handoff)
Without arguments, creates a concise handoff with:
- Current work summary
- Modified files list
- Next immediate steps
- Essential context only

### Detailed Mode (`--detailed`)
Comprehensive handoff including:
- Complete session history
- All technical decisions
- Full code changes review
- Detailed context and rationale

### Team Mode (`--team`)
External collaboration format with:
- Background and requirements
- Setup instructions
- Current implementation status
- Dependencies and blockers

## Handoff Document Structure

Create handoff at `docs/handoff/HANDOFF-[YYYYMMDD-HHMM].md` with:

```markdown
# Project Handoff - [timestamp]

## 🎯 Session Summary
[Main objectives and achievements of this session]

## ✅ Completed Tasks
- [List of completed work items]
- [Key changes per task]

## 🚧 Current State
### Active Work
[What was being worked on when session ended]

### Modified Files
[List of files changed with modification types]

### Key Decisions
[Important architecture/implementation choices made]

### Working Notes
[Include from docs/handoff/.scratch.md if exists]

## 📋 Next Steps
### Complexity: [Simple|Medium|Complex]
1. [Priority tasks to continue]
2. [Expected upcoming work]

### Recommended Approach:
[If complex: "Will require plan-agent for strategic planning"]
[If simple: "Direct continuation possible"]

## ⚠️ Important Notes
- [Warnings and gotchas]
- [Known issues]
- [Temporary workarounds]

## 🔧 Technical Context
### Commands
- Build: `[command]`
- Test: `[command]`
- Lint: `[command]`

### Dependencies Added
[New packages/libraries this session]

### Environment Changes
[Config or setup modifications]

## 💾 Session Metadata
- Start: [session start time]
- End: [current time]
- Model: [current model]
- Context Usage: [estimated tokens used]
- Complexity Level: [1-10 score]
- Related Plans: [reference to /plan docs if any]
```

## Integration with Other Commands

### With `/plan`:
- Include reference to active plan document
- Update progress on plan items
- Carry forward incomplete tasks

### With `/docs`:
- Reference permanent documentation
- Avoid duplicating stable information
- Link to relevant docs

### With `/pr`:
- Summarize PR-ready changes
- Include draft PR description
- Note required pre-PR tasks

## Metadata Management

Update `docs/handoff/.current` file:
```yaml
current: HANDOFF-[timestamp].md
created: [ISO timestamp]
model: [model name]
token_estimate: [number]
session_duration: [minutes]
files_modified: [count]
mode: [quick|detailed|team]
complexity_level: [1-10]
planned_next: [plan-agent|direct_task]
agents_used: [list of agents invoked]
pending_reviews: [CodeRabbit, etc.]
research_needed: [true|false]
flow_state: [deep_work|exploring|debugging|refactoring|implementing]
confidence_level: [1-10]
```

## Auto-trigger Conditions
Suggest handoff creation when:
- Context usage exceeds 80%
- Before executing `/clear`
- After completing major milestone
- When switching to different feature

## Archive Policy
- Keep last 5 handoffs in `docs/handoff/`
- Move older ones to `docs/handoff/archive/`
- Maintain `.current` pointer to latest

## Process

1. **Analyze Current State**:
   - Review conversation history
   - Identify completed vs pending work
   - Extract key decisions and context
   - **Assess complexity of remaining work**
   - **Determine current flow state and confidence level**
   - **Check for scratch notes at `docs/handoff/.scratch.md`**

2. **Flow State Assessment**:
   - **deep_work**: Continuous progress on clear tasks (3+ successful steps)
   - **exploring**: Searching/investigating solutions (high file navigation)
   - **debugging**: Fixing errors or test failures (error patterns detected)
   - **refactoring**: Code restructuring without functionality changes
   - **implementing**: Building new features from scratch

3. **Confidence Level Calculation**:
   - 9-10: Clear path forward, recent successes
   - 6-8: Some progress but minor uncertainties
   - 3-5: Multiple approaches being evaluated
   - 1-2: Blocked or stuck, need external help

4. **Complexity Assessment**:
   - Evaluate next steps complexity (1-10 scale)
   - Determine if plan-agent needed for resume
   - Identify research requirements
   - Note external dependencies

5. **Generate Handoff**:
   - Create structured markdown document
   - Update metadata file with complexity info
   - **Include flow_state and confidence_level in metadata**
   - **Include scratch notes if present**
   - Track used agents and pending reviews
   - Archive old handoffs if needed

6. **Validate**:
   - Ensure all active work captured
   - Verify file lists are complete
   - Check next steps are actionable
   - Confirm complexity assessment accurate
   - **Verify flow state accurately reflects session end state**

7. **Notify**:
   - Confirm handoff created
   - Show file location
   - Indicate complexity level for next session
   - **Display flow state and confidence for context**
   - Suggest `/clear` if appropriate

## Scratch Notes Pattern

The scratch notes provide a lightweight, persistent working memory across sessions:

### File Location
`docs/handoff/.scratch.md` - A simple markdown file for quick notes and thoughts

### Format (Flexible and Simple)
```markdown
# Scratch Notes

## Current Focus
[One-line description of what you're working on]

## Blockers
- [Things that are stuck]
- [Problems to solve next session]

## Quick Notes
- [Any thoughts, ideas, or reminders]
- [Links or references to check]
- [Hypotheses to test]

## Try Next
- [Specific approaches to attempt]
```

### Usage
- **During session**: Update freely as work progresses
- **At handoff**: Automatically included in handoff document
- **At resume**: Loaded first to provide immediate context
- **Keep it simple**: No strict format required, just useful notes

### Benefits
- Persists thoughts that don't fit elsewhere
- Captures "mental state" between sessions
- Lightweight alternative to complex TODO systems
- Natural place for debugging notes and hypotheses

Generate handoff documentation now based on the specified mode.