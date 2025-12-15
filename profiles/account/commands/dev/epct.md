Please follow this structured development approach for: $ARGUMENTS

## 🧠 Thinking Mode Selection
**Automatic activation based on complexity:**
- 10+ files changed → `think` mode enabled
- Architecture changes → `ultra think` mode enabled
- Simple fixes → Normal mode

## Phase 1: Explore 🔍 [Parallel Execution]
**Purpose:** Research and understand the problem space before implementation.

### Parallel Tasks:
```bash
# Tasks executed in parallel for efficiency
Task 1: Search for similar patterns using Grep
Task 2: Check git history for related changes
Task 3: Identify affected files using Glob
Task 4: Review dependencies and imports
```

### Complexity Auto-Assessment:
- Files affected: [auto-calculated]
- Estimated LOC: [auto-calculated]
- Risk level: [Low/Medium/High]
- **Auto-escalate**: Complexity > 7 → `/flow:plan` automatically suggested

**Example:**
```bash
/dev:epct "Add user authentication to the Flask app"
# Phase 1 will search existing auth patterns, identify Flask-Login usage, check database models
```

## Phase 2: Plan 📋
**Purpose:** Design a clear implementation strategy with Git workflow integration.

### Git Workflow Integration:
```bash
# Automatic branch strategy
if [new feature]: branch = "feature/$TASK_NAME"
if [bug fix]: branch = "fix/$ISSUE_NUMBER"
if [refactor]: branch = "refactor/$SCOPE"

# Commit strategy
- Atomic commits every 20-50 lines
- Conventional commit messages
- PR draft auto-preparation
```

### Task Breakdown with Progress Tracking:
- Use TodoWrite for real-time progress tracking
- Break down into manageable tasks (< 30 min each)
- Identify potential risks and mitigation strategies
- Mark checkpoints for validation

**Example Output:**
```markdown
- [ ] Task 1: Create User model with password hashing
- [ ] Task 2: Implement login/logout endpoints
- [ ] Task 3: Add session management
- [ ] Checkpoint: Security review
Risk: Session security → Mitigation: Use secure cookies + HTTPS only
```

*💡 Tip: For complex architectural planning (>10 files), `/flow:plan` will be automatically suggested.*

## Phase 3: Code 💻 [Selective Parallel]
**Purpose:** Implement the solution with quality and maintainability.

### Thinking Mode Auto-Application:
```python
# Critical sections → think mode auto-enabled
if modifying_core_logic:
    enable_think_mode()
```

### Real-time Progress:
- Track progress with TodoWrite
- Immediate lint check after each file modification
- Follow established patterns and conventions

**Best Practices:**
- Functions under 20 lines
- Clear variable naming
- Comprehensive error handling
- Atomic commits with conventional messages

## Phase 4: Test 🧪 [Optional]
**Purpose:** Ensure reliability and correctness.

### Flexibility Options:
- `--skip-test`: Skip test phase for simple changes
- `--test-only`: Run only the test phase
- `--auto-fix`: Attempt automatic fix on test failures

### Automatic Agent Invocation:
```yaml
on_test_failure:
  invoke: test-runner
on_complex_error:
  invoke: debugger
```

**Example:**
```python
# Unit test for login functionality
def test_login_valid_credentials():
    response = client.post('/login', data={'username': 'test', 'password': 'pass'})
    assert response.status_code == 200
```

## 🎛️ Configuration Options
```bash
# Usage examples with flags
/dev:epct --skip-test "Simple UI fix"
/dev:epct --parallel "Multi-file refactoring"
/dev:epct --ultra-think "Complex architecture change"
/dev:epct --dry-run "Plan only, no implementation"
```

## 📊 Automatic Escalation
When complexity > 7 or files > 10:
```
→ "This looks complex. Switching to /flow:plan for comprehensive research and planning..."
```

## Workflow Guidelines

- ✅ **Smart Execution:** Sequential or parallel based on task nature
- 📊 **Progress Tracking:** Real-time updates with TodoWrite
- 🎯 **Project Standards:** Follow CLAUDE.md guidelines
- 🔄 **Adaptive Workflow:** Auto-escalate to appropriate tools
- 🌿 **Git Integration:** Automatic branch and commit strategies

## Common Use Cases

1. **New Feature Development**
   ```bash
   /dev:epct "Implement real-time notifications"
   /dev:epct --skip-test "Add simple UI component"
   ```

2. **Bug Fix with Root Cause Analysis**
   ```bash
   /dev:epct "Fix memory leak in data processing pipeline"
   /dev:epct --auto-fix "Resolve failing test cases"
   ```

3. **Performance Optimization**
   ```bash
   /dev:epct --ultra-think "Optimize database query performance"
   /dev:epct --parallel "Refactor multiple service modules"
   ```

## Related Commands

- `/flow:plan` - Comprehensive planning with research (auto-suggested for complex tasks)
- `/test` - Focused testing workflows
- `/debug` - Debugging specific issues
- `/review` - Code review process
