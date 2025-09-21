---
description: CodeRabbit-enhanced comprehensive code review
---

# Enhanced Code Review with CodeRabbit

Review code for: $ARGUMENTS

## 🤖 CodeRabbit CLI Integration

**Pre-Review Analysis:**
1. **Run CodeRabbit CLI**: Execute `coderabbit --plain` for AI-powered analysis
2. **Context-Aware Feedback**: Get line-by-line suggestions with codebase context
3. **Quick Fixes Available**: Apply one-click fixes for simple issues (imports, syntax, formatting)
4. **Issue Detection**: Identify race conditions, memory leaks, security vulnerabilities

**CodeRabbit Output Modes:**
- Interactive mode: `coderabbit` (browsable findings)
- Plain text: `coderabbit --plain` (detailed feedback with fixes)
- Prompt-only: `coderabbit --prompt-only` (minimal, AI agent optimized)

## 🔍 Traditional Review Focus

1. **Security**: Authentication, validation, vulnerabilities
2. **Logic**: Business logic, edge cases, error handling
3. **Performance**: Algorithm complexity, queries, memory
4. **Quality**: SOLID principles, naming, maintainability

## 📊 Review Process

**Phase 1: Automated Analysis**
- Run CodeRabbit CLI for immediate issue detection
- Parse results for actionable suggestions
- Apply simple fixes automatically if requested

**Phase 2: Human Analysis**
- Review CodeRabbit findings for context and accuracy
- Analyze architectural and design patterns
- Check adherence to project conventions

**Phase 3: Comprehensive Assessment**
- Combine AI insights with human judgment
- Prioritize issues by impact and effort
- Generate actionable improvement plan

## 📝 Output Format

- **Critical Issues**: Must fix before merge
- **CodeRabbit Suggestions**: AI-detected improvements with confidence scores
- **Architectural Concerns**: Design and pattern recommendations
- **Quick Wins**: Simple improvements with high impact
- **Good Practices**: Positive patterns to reinforce

## 🤖 Auto-Agent Integration

For thorough review, automatically use the Task tool to invoke the code-reviewer agent.
The agent will:
- Synthesize CodeRabbit findings with traditional review
- Provide comprehensive analysis across multiple files
- Generate detailed improvement recommendations

## 💡 Usage Examples

```text
# Review specific files
/dev:review src/auth.ts src/utils.ts

# Review current changes
/dev:review

# Review with focus area
/dev:review "focus on security vulnerabilities"
```

## ⚙️ CodeRabbit CLI Requirements

This command assumes CodeRabbit CLI is installed:
```bash
curl -fsSL https://cli.coderabbit.ai/install.sh | sh
coderabbit auth login
```

If CodeRabbit CLI is not available, the command falls back to traditional review methods.

Execute enhanced review workflow combining CodeRabbit AI analysis with comprehensive human review now.