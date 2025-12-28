# Global Preferences

## Language
- Respond in user's language (Korean/English)
- Technical terms in English

## Workflow
- Use `/clear` frequently
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

## Custom Skills (공식 대안 없음)
- `/flow:handoff`, `/flow:resume` → 세션 연속성
- `/flow:plan` → 전략적 계획 수립
- `/worktree:*` → Git worktree 병렬 작업

## Official Plugins (권장)
Use official plugins for common tasks:
- `pr-review-toolkit` → 코드 리뷰 (6개 전문 에이전트)
- `commit-commands` → 커밋 워크플로우
- `feature-dev` → 기능 개발 가이드
- `document-skills` → 문서 생성 (PDF, DOCX, PPTX, XLSX)
- `security-guidance` → 보안 패턴 모니터링

Install: `/plugin install {name}`

## Auto-invoke
- PR creation → pr-review-toolkit plugin
- Time/date needed → time-aware agent

## Time Awareness
- time-aware agent automatically provides current time
- Use current year in web searches (2025, not 2024)
- Prioritize latest information for docs/version searches

## LLM Model Selection
- Use latest models for API calls: @llm-models-latest.md
- Avoid outdated models (gpt-4-turbo-preview, claude-3-5-sonnet, etc.)

## Note
Project-specific settings in project CLAUDE.md
