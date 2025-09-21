---
description: CodeRabbit pre-reviewed smart git commit
---

# Smart Commit with Pre-Review

Create a professional git commit for: $ARGUMENTS

## 🤖 Pre-Commit CodeRabbit Review

**Automated Quality Check:**
1. **Run CodeRabbit CLI**: Execute `coderabbit --plain` on staged/unstaged changes
2. **Issue Detection**: Identify potential problems before commit
3. **Quick Fixes**: Apply simple improvements (syntax, imports, formatting)
4. **Quality Gate**: Ensure code meets basic standards

**CodeRabbit Integration Options:**
- `--skip-review`: Skip CodeRabbit check for urgent commits
- `--fix-auto`: Automatically apply simple CodeRabbit suggestions
- `--review-only`: Run review without committing

## 📊 Commit Process

**Phase 1: Pre-Commit Analysis**
- Check for unstaged changes that should be included
- Run CodeRabbit CLI analysis on changes
- Display actionable suggestions and critical issues
- Apply quick fixes if requested

**Phase 2: Change Analysis**
- Run `git status` and `git diff --staged`
- Understand scope and impact of changes
- Analyze dependencies and affected components

**Phase 3: Commit Message Generation**
- Type: feat|fix|docs|style|refactor|test|chore|perf
- Scope: affected component (auto-detected from file paths)
- Description: clear, concise, present tense
- Format: `type(scope): description`

**Phase 4: Commit Execution**
- Stage appropriate files if needed
- Create commit with generated message
- Skip co-authorship footer

## 🎯 Conventional Commit Examples

- `feat(auth): add JWT token validation`
- `fix(api): handle null response correctly`
- `refactor(utils): simplify date formatting`
- `perf(db): optimize query performance`
- `docs(readme): update installation instructions`
- `test(auth): add unit tests for login flow`

## 🚨 Quality Gates

**Critical Issues (Block Commit):**
- Security vulnerabilities detected by CodeRabbit
- Syntax errors or compilation failures
- Unresolved merge conflicts

**Warnings (Proceed with Caution):**
- Potential performance issues
- Missing test coverage
- Code style violations

**Suggestions (Optional):**
- Refactoring opportunities
- Documentation improvements
- Best practice recommendations

## 💡 Usage Examples

```text
# Standard commit with pre-review
/dev:commit "implement user authentication"

# Quick commit, skip review for hotfix
/dev:commit --skip-review "fix critical bug"

# Review first, commit later
/dev:commit --review-only

# Auto-apply simple fixes
/dev:commit --fix-auto "refactor utility functions"
```

## ⚙️ CodeRabbit CLI Integration

This command integrates with CodeRabbit CLI for enhanced quality:
```bash
# Installation (if not present)
curl -fsSL https://cli.coderabbit.ai/install.sh | sh
coderabbit auth login
```

**Fallback Behavior:**
If CodeRabbit CLI is not available, the command gracefully falls back to traditional commit workflow without the pre-review phase.

## 🔄 Integration with Other Commands

This command works seamlessly with:
- `/dev:review`: For comprehensive code review before commit
- `/cr apply`: To apply CodeRabbit suggestions before committing
- `/flow:handoff`: For context preservation across commits

Execute smart commit workflow with CodeRabbit pre-review for: $ARGUMENTS