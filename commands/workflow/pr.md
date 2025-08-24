---
description: Prepare and create pull request
---

# Pull Request Workflow

Create PR for: $ARGUMENTS

## PR Preparation:

1. **Pre-checks**:
   - Run tests (invoke test-runner if needed)
   - Run linter/formatter
   - Review changes (invoke code-reviewer if needed)

2. **Create PR**:
   - Generate descriptive title
   - Write comprehensive description
   - Include test results
   - Add screenshots if UI changes

3. **PR Template**:
   ```markdown
   ## Summary
   Brief description of changes
   
   ## Changes
   - Change 1
   - Change 2
   
   ## Testing
   - [ ] Unit tests pass
   - [ ] Integration tests pass
   - [ ] Manual testing completed
   
   ## Screenshots
   (if applicable)
   ```

Execute PR workflow now.