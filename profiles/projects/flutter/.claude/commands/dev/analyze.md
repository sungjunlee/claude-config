---
description: Run Flutter analyzer with custom rules and auto-fix
---

# Flutter Analyze

Analyze Flutter code in: $ARGUMENTS

## Analysis Strategy

### 1. Basic Analysis
```bash
# Run Flutter analyzer
flutter analyze

# Analyze with machine-readable output
flutter analyze --write=analyze.log

# Analyze specific directory
flutter analyze lib/features/
```

### 2. Enhanced Analysis with Custom Rules

#### Check analysis_options.yaml
```yaml
# Recommended analysis_options.yaml for 2025
include: package:flutter_lints/flutter.yaml

analyzer:
  strong-mode:
    implicit-casts: false
    implicit-dynamic: false
  errors:
    missing_required_param: error
    missing_return: error
    unused_import: warning
    unnecessary_null_comparison: warning
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "build/**"

linter:
  rules:
    # Error rules
    - always_use_package_imports
    - avoid_dynamic_calls
    - avoid_returning_null_for_future
    - avoid_type_to_string
    - cancel_subscriptions
    - close_sinks
    
    # Style rules
    - always_declare_return_types
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_fields
    - prefer_single_quotes
    - unnecessary_const
    - unnecessary_new
    
    # Performance rules
    - avoid_unnecessary_containers
    - prefer_const_literals_to_create_immutables
    - sized_box_for_whitespace
```

### 3. Auto-Fix Issues

```bash
# Apply safe fixes automatically
dart fix --apply

# Preview fixes without applying
dart fix --dry-run

# Fix specific issues
dart fix --apply --code=unnecessary_const
dart fix --apply --code=prefer_const_constructors
```

### 4. Specialized Analysis

#### Unused Code Detection
```bash
# Find unused files
flutter pub run dart_code_metrics:metrics check-unused-files lib

# Find unused code
flutter pub run dart_code_metrics:metrics check-unused-code lib

# Find unused localization
flutter pub run dart_code_metrics:metrics check-unused-l10n lib
```

#### Code Metrics Analysis
```bash
# Install dart_code_metrics
flutter pub add --dev dart_code_metrics

# Run metrics analysis
flutter pub run dart_code_metrics:metrics analyze lib \
  --reporter=console \
  --set-exit-on-violation-level=warning

# Generate HTML report
flutter pub run dart_code_metrics:metrics analyze lib \
  --reporter=html \
  --output-directory=metrics
```

#### Security Analysis
```bash
# Check for security issues
flutter pub run dart_code_metrics:metrics analyze lib \
  --fatal-security \
  --reporter=console
```

### 5. Widget-Specific Analysis

```bash
# Check for missing const widgets
grep -r "Widget build" lib/ | while read line; do
  file=$(echo $line | cut -d: -f1)
  echo "Checking $file for const opportunities..."
  grep -n "return.*Container\|return.*Text\|return.*Icon" "$file" | grep -v "const"
done

# Find widgets that should use keys
grep -r "class.*extends.*StatefulWidget" lib/ | while read line; do
  file=$(echo $line | cut -d: -f1)
  class=$(echo $line | sed 's/.*class \([^ ]*\).*/\1/')
  if ! grep -q "super.key" "$file"; then
    echo "⚠️  $class might need a Key parameter"
  fi
done
```

### 6. Performance Analysis

```bash
# Check for expensive operations in build methods
echo "Checking for expensive operations in build methods..."
grep -r "Widget build" lib/ -A 20 | grep -E "compute\(|Future\.|async" && \
  echo "⚠️  Found potential expensive operations in build methods"

# Check for missing dispose methods
echo "Checking for missing dispose methods..."
grep -r "StreamSubscription\|AnimationController\|TextEditingController" lib/ | while read line; do
  file=$(echo $line | cut -d: -f1)
  if ! grep -q "dispose()" "$file"; then
    echo "⚠️  $file might be missing dispose() method"
  fi
done
```

### 7. Import Analysis

```bash
# Check for relative imports (should use package imports)
echo "Checking for relative imports..."
grep -r "import '\.\." lib/ && echo "⚠️  Found relative imports, use package imports instead"

# Check for unused imports
dart fix --dry-run | grep "unused_import"

# Sort imports
dart fix --apply --code=directives_ordering
```

### 8. Null Safety Analysis

```bash
# Check null safety migration status
dart pub outdated --mode=null-safety

# Analyze null safety issues
flutter analyze --no-pub \
  --no-congratulate \
  --current-package \
  --fatal-infos \
  --fatal-warnings
```

## Analysis Report Format

```bash
echo "═══════════════════════════════════════"
echo "     Flutter Analysis Report"
echo "═══════════════════════════════════════"
echo ""

# Run analysis and capture output
ANALYSIS_OUTPUT=$(flutter analyze 2>&1)

if echo "$ANALYSIS_OUTPUT" | grep -q "No issues found"; then
  echo "✅ No issues found!"
else
  echo "❌ Issues detected:"
  echo "$ANALYSIS_OUTPUT"
  
  # Count issues by type
  ERRORS=$(echo "$ANALYSIS_OUTPUT" | grep -c "error" || true)
  WARNINGS=$(echo "$ANALYSIS_OUTPUT" | grep -c "warning" || true)
  INFOS=$(echo "$ANALYSIS_OUTPUT" | grep -c "info" || true)
  
  echo ""
  echo "Summary:"
  echo "  🔴 Errors: $ERRORS"
  echo "  🟡 Warnings: $WARNINGS"
  echo "  🔵 Info: $INFOS"
fi

echo ""
echo "Running auto-fix..."
dart fix --apply

echo ""
echo "Additional checks:"

# Const opportunities
CONST_OPPORTUNITIES=$(grep -r "Container\|Text\|Icon\|SizedBox" lib/ | grep -v "const" | wc -l)
echo "  📦 Const opportunities: $CONST_OPPORTUNITIES"

# TODO comments
TODOS=$(grep -r "TODO\|FIXME\|HACK" lib/ | wc -l)
echo "  📝 TODOs found: $TODOS"

# Long methods (>50 lines)
LONG_METHODS=$(awk '/^[[:space:]]*[a-zA-Z].*\(.*\).*{/,/^[[:space:]]*}/' lib/**/*.dart | \
  awk 'BEGIN{count=0} /^[[:space:]]*[a-zA-Z].*\(.*\).*{/{if(count>50)print file":"line; count=0; file=FILENAME; line=NR} {count++}' | wc -l)
echo "  📏 Long methods (>50 lines): $LONG_METHODS"

echo ""
echo "═══════════════════════════════════════"
```

## CI/CD Integration

```bash
# For GitHub Actions
flutter analyze --write=analyze.log
if [ -s analyze.log ]; then
  cat analyze.log
  exit 1
fi

# For pre-commit hook
#!/bin/sh
flutter analyze
if [ $? -ne 0 ]; then
  echo "Fix analysis issues before committing"
  exit 1
fi
```

Execute comprehensive Flutter analysis with auto-fix capabilities.