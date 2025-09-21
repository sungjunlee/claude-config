---
description: Complete CodeRabbit workflow integration hub
---

# CodeRabbit Workflow Hub

Manage CodeRabbit review process for: $ARGUMENTS

## 🎯 Smart Context Detection

**When called without arguments**, automatically detects current state and suggests actions:

```text
📊 Repository Status Analysis:
- Working tree: [clean/dirty]
- Staged changes: [yes/no]
- Active PR: [#123 "feature: new auth"] or [none]
- CodeRabbit status: [pending/completed/errors]

💡 Suggested Actions:
- /cr pre     # Pre-commit review
- /cr apply   # Apply suggestions
- /cr pr      # Create PR
- /cr chat    # Interactive discussion
```

## 🚀 Available Actions

### `/cr pre` - Pre-Commit Review
Execute CodeRabbit CLI analysis before committing:
- Run `coderabbit --plain` on current changes
- Display actionable suggestions with confidence scores
- Apply quick fixes for simple issues
- Generate improvement summary

### `/cr apply` - Apply Suggestions
Interactively apply CodeRabbit suggestions:
- Parse CodeRabbit CLI output for actionable items
- Present suggestions grouped by type (syntax, security, performance)
- Allow selective application of fixes
- Stage applied changes automatically

### `/cr pr [title]` - Create PR with CodeRabbit
Create pull request with automatic CodeRabbit review setup:
- Ensure changes are committed and pushed
- Create PR using GitHub CLI with provided title
- Add CodeRabbit as reviewer automatically
- Configure auto-review settings for the PR

### `/cr chat [message]` - Interactive Discussion
Engage with CodeRabbit on active PR:
- Use GitHub API to post CodeRabbit commands
- Execute `@coderabbitai` commands on current PR
- Handle common interactions (review, summary, resolve)
- Display CodeRabbit responses inline

## 📋 Workflow Integration

### Context-Aware Behavior

**No Active Changes:**
```text
✨ Clean repository state
Suggested: /cr pr "title" or start making changes
```

**Uncommitted Changes:**
```text
⚡ Uncommitted changes detected
Suggested: /cr pre (review) → /dev:commit (commit)
```

**Active PR with Comments:**
```text
📝 PR #123 has CodeRabbit feedback
Suggested: /cr apply (fix issues) → /cr chat "ready for re-review"
```

## 🛠️ Command Examples

```text
# Quick status check
/cr
# → Shows current state and suggested actions

# Pre-commit review workflow
/cr pre
# → Runs CodeRabbit CLI, shows issues, applies fixes

# Apply specific suggestions
/cr apply
# → Interactive selection of CodeRabbit suggestions

# Create PR with auto-review
/cr pr "feat: add user authentication"
# → Commits, pushes, creates PR, sets up CodeRabbit

# Interact with CodeRabbit on PR
/cr chat "please focus on security concerns"
# → Posts comment to trigger CodeRabbit analysis

# Quick issue resolution
/cr apply → /dev:commit → /cr pr "title"
# → Complete workflow from suggestions to PR
```

## 🔧 Technical Implementation

### CodeRabbit CLI Integration
```bash
# Check if CodeRabbit CLI is available
if command -v coderabbit >/dev/null 2>&1; then
    # Execute CodeRabbit commands
    coderabbit --plain
else
    # Fallback to manual instructions
    echo "Install CodeRabbit CLI: curl -fsSL https://cli.coderabbit.ai/install.sh | sh"
fi
```

### GitHub API Integration
```bash
# Check PR status
gh pr status --json number,title,state

# Create PR with CodeRabbit reviewer
gh pr create --title "$1" --body "Auto-generated PR with CodeRabbit review"

# Post CodeRabbit command
gh pr comment --body "@coderabbitai $1"
```

## 🎛️ Configuration Options

### Auto-Apply Settings
- `--auto-fix`: Automatically apply safe CodeRabbit suggestions
- `--interactive`: Always prompt before applying changes (default)
- `--dry-run`: Show what would be applied without making changes

### Review Scope
- `--staged-only`: Review only staged changes
- `--all-changes`: Review all modified files
- `--files [list]`: Review specific files only

### PR Creation Settings
- `--draft`: Create draft PR for work-in-progress
- `--auto-merge`: Enable auto-merge after successful review
- `--no-coderabbit`: Skip adding CodeRabbit as reviewer

## 🔄 Integration with Existing Commands

**Seamless Workflow:**
- `/dev:review` → Enhanced with CodeRabbit CLI
- `/dev:commit` → Pre-commit CodeRabbit check
- `/cr apply` → Apply suggestions from reviews
- `/flow:handoff` → Context preservation across sessions

**Command Chaining:**
```text
/cr pre → /cr apply → /dev:commit → /cr pr
# Complete workflow from review to PR
```

## ⚙️ Requirements and Setup

### CodeRabbit CLI
```bash
# Install CodeRabbit CLI
curl -fsSL https://cli.coderabbit.ai/install.sh | sh

# Authenticate
coderabbit auth login
```

### GitHub CLI
```bash
# Ensure GitHub CLI is configured
gh auth status

# Configure default settings
gh config set prompt enabled
```

## 💡 Pro Tips

1. **Start with `/cr`** to understand current state
2. **Use `/cr pre`** before any commit to catch issues early
3. **Chain commands**: `/cr apply` → `/dev:commit` → `/cr pr`
4. **Interactive mode**: Always review suggestions before applying
5. **Context awareness**: The command adapts to your current workflow state

## 🎯 Action Selection Logic

```text
If $ARGUMENTS contains:
  - "pre" | "check" | "review" → Pre-commit review
  - "apply" | "fix" | "suggestions" → Apply suggestions
  - "pr" → Create PR workflow
  - "chat" | "comment" → Interactive discussion
  - specific message → Treat as chat/comment
  - empty → Context analysis and suggestion
```

Execute CodeRabbit workflow hub for: $ARGUMENTS