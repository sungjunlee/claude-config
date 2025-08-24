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

2. **Complexity Assessment**:
   - Evaluate next steps complexity (1-10 scale)
   - Determine if plan-agent needed for resume
   - Identify research requirements
   - Note external dependencies

3. **Generate Handoff**:
   - Create structured markdown document
   - Update metadata file with complexity info
   - Track used agents and pending reviews
   - Archive old handoffs if needed

4. **Validate**:
   - Ensure all active work captured
   - Verify file lists are complete
   - Check next steps are actionable
   - Confirm complexity assessment accurate

5. **Notify**:
   - Confirm handoff created
   - Show file location
   - Indicate complexity level for next session
   - Suggest `/clear` if appropriate

Generate handoff documentation now based on the specified mode.