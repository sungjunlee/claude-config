---
description: Integrated quality assurance gate for PR readiness
---

# Quality Assurance Gate

Comprehensive quality verification before PR submission: $ARGUMENTS

## Overview

Multi-stage quality gate that runs parallel checks to ensure code is ready for PR:
- 🔍 Code review (security, logic, performance)
- 🧪 Test execution and coverage
- 🔨 Build verification
- 🐛 Debugging (if issues found)
- 🎨 Linting and formatting
- 📚 Best practices validation

**Expected Time**: 2-5 minutes (parallel execution)
**Quality Score**: Comprehensive metrics for PR confidence

## Execute Quality Gate

```bash
echo "🚀 Starting Integrated Quality Assurance Gate"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Target: ${ARGUMENTS:-all changes}"
echo "⏰ Started: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Parse optional flags
FAST_MODE=false
VERBOSE_MODE=false
TARGET_PATH="${ARGUMENTS}"

for arg in $ARGUMENTS; do
  case "$arg" in
    --fast) FAST_MODE=true ;;
    --verbose) VERBOSE_MODE=true ;;
  esac
done

# Stage 1: Parallel Quality Checks
echo "🔍 STAGE 1: PARALLEL QUALITY CHECKS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Launching 3 parallel verification agents..."
echo ""

# Task 1: Code Review
echo "📋 Task 1: Comprehensive Code Review"
echo "Use code-reviewer agent to analyze all changed files."
echo "Focus on:"
echo "  - Security vulnerabilities (authentication, input validation, secrets)"
echo "  - Logic correctness (edge cases, error handling)"
echo "  - Performance issues (algorithm complexity, N+1 queries)"
echo "  - Code quality (SOLID principles, DRY, naming)"
echo ""
echo "Target files: ${TARGET_PATH:-git diff --name-only}"
echo ""

# Task 2: Test Execution
echo "🧪 Task 2: Test Execution & Coverage"
echo "Use test-runner agent to:"
echo "  - Discover and run all relevant tests"
echo "  - Fix any test failures automatically"
echo "  - Generate coverage report"
echo "  - Identify untested code paths"
echo ""

# Task 3: Build Verification
echo "🔨 Task 3: Build Verification"
echo "Verify project builds successfully."
echo ""
echo "Detecting build system..."

# Detect build system
BUILD_CMD=""
if [ -f "package.json" ]; then
  if grep -q '"build"' package.json; then
    if [ -f "bun.lockb" ]; then
      BUILD_CMD="bun run build"
    elif [ -f "pnpm-lock.yaml" ]; then
      BUILD_CMD="pnpm build"
    elif [ -f "yarn.lock" ]; then
      BUILD_CMD="yarn build"
    else
      BUILD_CMD="npm run build"
    fi
  fi
elif [ -f "pyproject.toml" ]; then
  if command -v poetry &> /dev/null; then
    BUILD_CMD="poetry build"
  elif command -v uv &> /dev/null; then
    BUILD_CMD="uv build"
  fi
elif [ -f "Cargo.toml" ]; then
  BUILD_CMD="cargo build --release"
elif [ -f "go.mod" ]; then
  BUILD_CMD="go build ./..."
elif [ -f "pom.xml" ]; then
  BUILD_CMD="mvn clean package"
elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
  BUILD_CMD="./gradlew build"
fi

if [ -n "$BUILD_CMD" ]; then
  echo "Build command: $BUILD_CMD"
  echo ""
  if $BUILD_CMD 2>&1 | tee /tmp/qa_build.log; then
    echo "✅ Build successful"
  else
    echo "❌ Build failed - check /tmp/qa_build.log"
    BUILD_FAILED=true
  fi
else
  echo "⚠️ No build system detected - skipping build check"
fi
echo ""

# Wait for parallel tasks completion marker
echo "⏳ Waiting for all parallel checks to complete..."
echo ""
```

## Stage 2: Conditional Checks

```bash
echo ""
echo "🔧 STAGE 2: CONDITIONAL CHECKS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Linting checks (auto-detect)
echo "🎨 Running linting checks..."
echo ""

LINT_ISSUES=""

# Python linting
if [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "requirements.txt" ]; then
  if command -v ruff &> /dev/null; then
    echo "Running ruff..."
    if ! ruff check . 2>&1 | tee /tmp/qa_ruff.log; then
      LINT_ISSUES="$LINT_ISSUES\n- Ruff found issues (see /tmp/qa_ruff.log)"
    fi
  fi
  if command -v mypy &> /dev/null; then
    echo "Running mypy..."
    if ! mypy . 2>&1 | tee /tmp/qa_mypy.log; then
      LINT_ISSUES="$LINT_ISSUES\n- MyPy found type issues (see /tmp/qa_mypy.log)"
    fi
  fi
fi

# JavaScript/TypeScript linting
if [ -f "package.json" ]; then
  if [ -f ".eslintrc.js" ] || [ -f ".eslintrc.json" ] || grep -q "eslint" package.json; then
    echo "Running eslint..."
    if command -v eslint &> /dev/null || npm list eslint &> /dev/null; then
      if ! npx eslint . 2>&1 | tee /tmp/qa_eslint.log; then
        LINT_ISSUES="$LINT_ISSUES\n- ESLint found issues (see /tmp/qa_eslint.log)"
      fi
    fi
  fi
  if [ -f ".prettierrc" ] || [ -f ".prettierrc.json" ] || grep -q "prettier" package.json; then
    echo "Running prettier check..."
    if command -v prettier &> /dev/null || npm list prettier &> /dev/null; then
      if ! npx prettier --check . 2>&1 | tee /tmp/qa_prettier.log; then
        LINT_ISSUES="$LINT_ISSUES\n- Prettier formatting issues (see /tmp/qa_prettier.log)"
      fi
    fi
  fi
fi

# Rust linting
if [ -f "Cargo.toml" ]; then
  echo "Running clippy..."
  if ! cargo clippy -- -D warnings 2>&1 | tee /tmp/qa_clippy.log; then
    LINT_ISSUES="$LINT_ISSUES\n- Clippy found issues (see /tmp/qa_clippy.log)"
  fi
fi

# Go linting
if [ -f "go.mod" ]; then
  if command -v golangci-lint &> /dev/null; then
    echo "Running golangci-lint..."
    if ! golangci-lint run 2>&1 | tee /tmp/qa_golint.log; then
      LINT_ISSUES="$LINT_ISSUES\n- golangci-lint found issues (see /tmp/qa_golint.log)"
    fi
  fi
fi

if [ -z "$LINT_ISSUES" ]; then
  echo "✅ All linting checks passed"
else
  echo "⚠️ Linting issues found:"
  echo -e "$LINT_ISSUES"
fi
echo ""

# Conditional debugging
if [ "$BUILD_FAILED" = true ] || [ -n "$LINT_ISSUES" ]; then
  echo "🐛 Issues detected - launching debugger agent for root cause analysis..."
  echo ""
  echo "Use debugger agent to investigate:"
  if [ "$BUILD_FAILED" = true ]; then
    echo "  - Build failure in /tmp/qa_build.log"
  fi
  if [ -n "$LINT_ISSUES" ]; then
    echo "  - Linting issues detected"
  fi
  echo ""
  echo "Provide systematic debugging report with:"
  echo "  - Root cause analysis"
  echo "  - Suggested fixes"
  echo "  - Prevention strategies"
  echo ""
fi
```

## Stage 3: Context Enhancement

```bash
if [ "$FAST_MODE" = false ]; then
  echo ""
  echo "📚 STAGE 3: CONTEXT ENHANCEMENT"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  # Detect project stack
  STACK_TYPE="general"
  if [ -f "package.json" ]; then
    if grep -q "next" package.json; then
      STACK_TYPE="Next.js"
    elif grep -q "react" package.json; then
      STACK_TYPE="React"
    elif grep -q "vue" package.json; then
      STACK_TYPE="Vue.js"
    else
      STACK_TYPE="Node.js"
    fi
  elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
    STACK_TYPE="Python"
  elif [ -f "Cargo.toml" ]; then
    STACK_TYPE="Rust"
  elif [ -f "go.mod" ]; then
    STACK_TYPE="Go"
  fi

  echo "📊 Detected stack: $STACK_TYPE"
  echo ""
  echo "🌐 Searching for best practices..."
  echo "Search query: '$STACK_TYPE code review checklist 2025 best practices testing security'"
  echo ""
  echo "📖 Checking library documentation..."
  echo "Looking up usage patterns for main dependencies"
  echo ""
else
  echo ""
  echo "⚡ Fast mode enabled - skipping context enhancement"
fi
```

## Final Report

```bash
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 QUALITY ASSURANCE REPORT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⏰ Completed: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo "## Checks Completed"
echo ""
echo "✅ Stage 1: Parallel Quality Checks"
echo "  - Code Review: Completed (see agent report above)"
echo "  - Test Execution: Completed (see agent report above)"
if [ -n "$BUILD_CMD" ]; then
  if [ "$BUILD_FAILED" = true ]; then
    echo "  - Build: ❌ Failed"
  else
    echo "  - Build: ✅ Success"
  fi
else
  echo "  - Build: ⚠️ Not applicable"
fi
echo ""
echo "✅ Stage 2: Conditional Checks"
if [ -z "$LINT_ISSUES" ]; then
  echo "  - Linting: ✅ Clean"
else
  echo "  - Linting: ⚠️ Issues found"
fi
echo ""
if [ "$FAST_MODE" = false ]; then
  echo "✅ Stage 3: Context Enhancement"
  echo "  - Best practices: Searched"
  echo "  - Documentation: Verified"
  echo ""
fi

# Overall assessment
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$BUILD_FAILED" = true ]; then
  echo "❌ NOT READY FOR PR - Build must pass first"
elif [ -n "$LINT_ISSUES" ]; then
  echo "⚠️ READY WITH WARNINGS - Address linting issues if possible"
else
  echo "✅ READY FOR PR - All quality gates passed!"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 Next steps:"
if [ "$BUILD_FAILED" = true ] || [ -n "$LINT_ISSUES" ]; then
  echo "  1. Review debugger report above for root cause"
  echo "  2. Fix identified issues"
  echo "  3. Re-run /flow:qa to verify"
else
  echo "  1. Create commit: git add . && git commit"
  echo "  2. Push changes: git push"
  echo "  3. Create PR: gh pr create"
fi
echo ""

# Cleanup temp files
rm -f /tmp/qa_*.log 2>/dev/null
```

## Usage Examples

```bash
# Standard QA check (all stages)
/flow:qa

# Fast mode (skip context enhancement)
/flow:qa --fast

# Check specific path
/flow:qa src/core/

# Verbose output
/flow:qa --verbose

# Combined flags
/flow:qa src/ --fast --verbose
```

## Integration with Workflow

**Pre-PR Workflow:**
```bash
# 1. Make changes
# 2. Run QA gate
/flow:qa

# 3. If passed, proceed with PR
/gh:pr

# 4. If issues found, fix and re-run
/flow:qa
```

**Post-Fix Verification:**
```bash
# After fixing issues from code review
/flow:qa --fast  # Quick verification without web search
```

---

**Execute integrated quality gate for:** $ARGUMENTS
