# Global Preferences

## Language
- Respond in user's language (Korean/English)
- Technical terms in English

## Workflow
- Use `/clear` frequently
- Leverage agents for complex tasks
- Test before commit

## Context Management (Handoff)
- Use `/flow:handoff` before `/clear` to save session state
- Use `/flow:resume` to restore context
- Handoff modes: quick (default), --detailed, --team
- Auto-trigger at 80% context usage
- Handoffs stored in `docs/handoff/` (max 5 recent)

## Code Style
- Follow existing conventions
- Functions under 20 lines
- Clear variable naming

## Auto-invoke
- Test failures → testing skill or test-runner agent
- PR creation → pr-review-toolkit plugin
- Complex errors → silent-failure-hunter plugin
- Time/date needed → time-aware agent

## Skills
- `/flow:*` → workflow skill (handoff, resume, plan, fix-errors)
- `/worktree:*` → worktree skill (distribute, plan, status, sync)
- `/dev:test` → testing skill with language context
- `/dev:lint` → linting skill with language context

## Plugins (Official)
- pr-review-toolkit → code review
- document-skills → documentation generation
- silent-failure-hunter → error detection

## Time Awareness
- time-aware agent automatically provides current time
- Use current year in web searches (2025, not 2024)
- Prioritize latest information for docs/version searches

## LLM Model Selection
- Use latest models for API calls: @llm-models-latest.md
- Avoid outdated models (gpt-4-turbo-preview, claude-3-5-sonnet, etc.)
- GPT-5 note: No temperature parameter support (use verbosity/reasoning_effort)

## Note
Project-specific settings in project CLAUDE.md