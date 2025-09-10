Please follow this structured development approach for: $ARGUMENTS

## Phase 1: Explore 🔍
**Purpose:** Research and understand the problem space before implementation.

- Research the current codebase and relevant patterns
- Identify existing similar implementations
- Understand dependencies and constraints
- Document key findings and considerations

**Example:**
```bash
/epct "Add user authentication to the Flask app"
# Phase 1 will search for existing auth patterns, identify Flask-Login usage, check database models
```

## Phase 2: Plan 📋
**Purpose:** Design a clear implementation strategy.

- Design the implementation approach
- Break down into manageable tasks
- Identify potential risks and mitigation strategies
- Create a detailed execution timeline

*💡 Tip: For complex architectural planning, use `/plan` for more detailed designs.*

**Example Output:**
- Task 1: Create User model with password hashing
- Task 2: Implement login/logout endpoints
- Task 3: Add session management
- Risk: Session security → Mitigation: Use secure cookies

## Phase 3: Code 💻
**Purpose:** Implement the solution with quality and maintainability.

- Implement the solution following coding standards
- Write clean, maintainable code
- Include appropriate error handling and edge cases
- Follow established patterns and conventions

**Best Practices:**
- Functions under 20 lines
- Clear variable naming
- Comprehensive error handling

## Phase 4: Test 🧪
**Purpose:** Ensure reliability and correctness.

- Create comprehensive unit tests
- Add integration tests where appropriate
- Test edge cases and error conditions
- Verify performance meets requirements

**Example:**
```python
# Unit test for login functionality
def test_login_valid_credentials():
    response = client.post('/login', data={'username': 'test', 'password': 'pass'})
    assert response.status_code == 200
```

## Workflow Guidelines

- ✅ **Sequential Execution:** Complete each phase before proceeding
- 📊 **Detailed Output:** Provide comprehensive results for each phase
- 🎯 **Project Standards:** Follow CLAUDE.md guidelines
- 🔄 **Iterative Refinement:** Adjust plan based on exploration findings

## Common Use Cases

1. **New Feature Development**
   ```bash
   /epct "Implement real-time notifications"
   ```

2. **Bug Fix with Root Cause Analysis**
   ```bash
   /epct "Fix memory leak in data processing pipeline"
   ```

3. **Performance Optimization**
   ```bash
   /epct "Optimize database query performance"
   ```

## Related Commands

- `/plan` - Detailed architectural planning
- `/test` - Focused testing workflows
- `/debug` - Debugging specific issues
- `/review` - Code review process
