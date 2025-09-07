---
description: Create smart git commit with conventional format
---

# Smart Commit

Create a professional git commit for: $ARGUMENTS

## Process:

1. **Analyze changes**:
   - Run `git status` and `git diff --staged`
   - Understand what changed and why

2. **Generate commit message**:
   - Type: feat|fix|docs|style|refactor|test|chore|perf
   - Scope: affected component
   - Description: clear, concise, present tense
   - Format: `type(scope): description`

3. **Examples**:
   - `feat(auth): add JWT token validation`
   - `fix(api): handle null response correctly`
   - `refactor(utils): simplify date formatting`
   - `perf(db): optimize query performance`

4. **Execute**:
   - Stage appropriate files if needed
   - Create commit with generated message
   - Skip co-authorship footer

Execute smart commit workflow now.