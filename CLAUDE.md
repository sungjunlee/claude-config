# Global Preferences

## Language
- Respond in user's language (Korean/English)
- Technical terms in English

## Workflow
- Use `/clear` frequently
- Leverage agents for complex tasks
- Test before commit

## Context Management (Handoff)
- Use `/handoff` before `/clear` to save session state
- Use `/resume` to restore context (auto-invokes plan-agent if complex)
- Handoff modes: quick (default), --detailed, --team
- Auto-trigger at 80% context usage
- Handoffs stored in `docs/handoff/` (max 5 recent)

## Code Style
- Follow existing conventions
- Functions under 20 lines
- Clear variable naming

## Auto-invoke
- Test failures → test-runner
- PR creation → code-reviewer
- Complex errors → debugger

## LLM Model Selection
- Use latest models for API calls: @llm-models-latest.md
- Avoid outdated models (gpt-4-turbo-preview, claude-3-5-sonnet, etc.)
- GPT-5 note: No temperature parameter support (use verbosity/reasoning_effort)

## Note
Project-specific settings in project CLAUDE.md