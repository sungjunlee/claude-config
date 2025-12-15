---
description: Run Flutter tests (unit, widget, golden, integration) with coverage
---

# Flutter Test Execution

> **Project Override**: Flutter-specific testing
> 
> **Override Priority**: Project Level (this file) > Account Level > Built-in

Run Flutter tests for: $ARGUMENTS

## Test Execution Strategy

### 1. Test Discovery
```bash
# Find all test files
echo "🔍 Discovering tests..."
UNIT_TESTS=$(find test -name "*_test.dart" 2>/dev/null | grep -v widget | grep -v golden | wc -l)
WIDGET_TESTS=$(find test -name "*widget_test.dart" -o -name "*widgets_test.dart" 2>/dev/null | wc -l)
GOLDEN_TESTS=$(find test -name "*golden_test.dart" 2>/dev/null | wc -l)
INTEGRATION_TESTS=$(find integration_test -name "*_test.dart" 2>/dev/null | wc -l)

echo "Found:"
echo "  📦 Unit tests: $UNIT_TESTS"
echo "  🧩 Widget tests: $WIDGET_TESTS"
echo "  🎨 Golden tests: $GOLDEN_TESTS"
echo "  🔄 Integration tests: $INTEGRATION_TESTS"
```

### 2. Run Tests by Type

#### All Tests with Coverage
```bash
# Run all tests with coverage report
flutter test --coverage --test-randomize-ordering-seed random

# Generate coverage report
if [ -f "coverage/lcov.info" ]; then
  # Calculate coverage percentage
  if command -v lcov &> /dev/null; then
    lcov --summary coverage/lcov.info
  fi
  
  # Generate HTML report
  if command -v genhtml &> /dev/null; then
    genhtml coverage/lcov.info -o coverage/html
    echo "📊 Coverage report: coverage/html/index.html"
  fi
fi
```

#### Specific Test Types
```bash
# Unit tests only
flutter test test/unit/

# Widget tests only
flutter test test/widgets/

# Golden tests (update if needed)
if [[ "$ARGUMENTS" == *"update-golden"* ]]; then
  flutter test --update-goldens
else
  flutter test test/golden/
fi

# Integration tests
if [ -d "integration_test" ]; then
  flutter test integration_test/
fi
```

### 3. Smart Test Selection

```bash
# Run tests for changed files only
if command -v git &> /dev/null; then
  CHANGED_FILES=$(git diff --name-only HEAD | grep -E "\.dart$" | grep -v test)
  
  for FILE in $CHANGED_FILES; do
    # Find corresponding test file
    TEST_FILE=$(echo $FILE | sed 's/lib/test/' | sed 's/\.dart$/_test.dart/')
    if [ -f "$TEST_FILE" ]; then
      echo "Running tests for $FILE..."
      flutter test "$TEST_FILE"
    fi
  done
fi
```

### 4. Test with Different Configurations

#### Platform-Specific Testing
```bash
# Test on Chrome (Web)
if [[ "$ARGUMENTS" == *"web"* ]]; then
  flutter test --platform chrome
fi

# Test with specific device
if [[ "$ARGUMENTS" == *"device"* ]]; then
  flutter test integration_test/ -d "$DEVICE_ID"
fi
```

#### Performance Testing
```bash
# Run tests with performance tracking
flutter test --coverage --reporter expanded --timeout 60s
```

### 5. Watch Mode
```bash
# Run tests in watch mode
if [[ "$ARGUMENTS" == *"watch"* ]]; then
  flutter test --watch
fi
```

### 6. Test Organization & Execution

```bash
# Group execution
flutter test --name="Authentication" # Run tests matching name
flutter test --plain-name="should login" # Exact name match

# Exclude tests
flutter test --exclude-tags=slow

# Run only tagged tests
flutter test --tags=critical
```

## Test Quality Checks

### Coverage Enforcement
```bash
# Check coverage threshold
COVERAGE_THRESHOLD=80
if [ -f "coverage/lcov.info" ]; then
  COVERAGE=$(lcov --summary coverage/lcov.info 2>/dev/null | grep lines | sed 's/.*: \([0-9.]*\)%.*/\1/')
  
  if (( $(echo "$COVERAGE < $COVERAGE_THRESHOLD" | bc -l) )); then
    echo "❌ Coverage $COVERAGE% is below threshold $COVERAGE_THRESHOLD%"
    exit 1
  else
    echo "✅ Coverage $COVERAGE% meets threshold"
  fi
fi
```

### Test Timing Analysis
```bash
# Find slow tests
flutter test --reporter json | jq '.tests[] | select(.time > 1000) | {name: .name, time: .time}'
```

## Failure Recovery

### Auto-Fix Common Issues
```bash
# If tests fail, try common fixes
if [ $? -ne 0 ]; then
  echo "Tests failed. Attempting recovery..."
  
  # Clean and rebuild
  flutter clean
  flutter pub get
  
  # Regenerate mocks if using mockito
  if grep -q "mockito" pubspec.yaml; then
    flutter pub run build_runner build --delete-conflicting-outputs
  fi
  
  # Retry tests
  flutter test
fi
```

### Generate Missing Tests
```bash
# Find widgets without tests
for WIDGET in $(find lib -name "*.dart" -exec grep -l "class.*Widget\|class.*Screen\|class.*Page" {} \;); do
  TEST_FILE=$(echo $WIDGET | sed 's/lib/test/' | sed 's/\.dart$/_test.dart/')
  if [ ! -f "$TEST_FILE" ]; then
    echo "⚠️  Missing test for: $WIDGET"
    # Optionally generate test template
    if [[ "$ARGUMENTS" == *"generate"* ]]; then
      mkdir -p $(dirname "$TEST_FILE")
      cat > "$TEST_FILE" << 'EOF'
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  group('Widget Test', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Container()));
      expect(find.byType(Container), findsOneWidget);
    });
  });
}
EOF
      echo "Generated: $TEST_FILE"
    fi
  fi
done
```

## Test Report

```bash
echo "════════════════════════════════════════"
echo "        Flutter Test Report"
echo "════════════════════════════════════════"

# Run tests and capture output
TEST_OUTPUT=$(flutter test --coverage --machine 2>&1 | tail -n 1)

if echo "$TEST_OUTPUT" | grep -q '"success":true'; then
  echo "✅ All tests passed!"
  
  # Parse JSON for details
  if command -v jq &> /dev/null; then
    echo "$TEST_OUTPUT" | jq -r '"Tests: \(.testCount), Time: \(.time)ms"'
  fi
else
  echo "❌ Tests failed"
  
  # Show failed tests
  flutter test --reporter expanded | grep -A 5 "FAILED"
fi

# Coverage summary
if [ -f "coverage/lcov.info" ]; then
  echo ""
  echo "📊 Coverage Summary:"
  lcov --summary coverage/lcov.info 2>/dev/null | grep -E "lines|functions|branches"
fi

echo "════════════════════════════════════════"
```

## CI/CD Integration

```bash
# GitHub Actions
flutter test --coverage --machine > test-results.json
flutter pub run test_reporter test-results.json

# Generate test report for CI
flutter test --reporter json > test-report.json

# Upload coverage to Codecov
bash <(curl -s https://codecov.io/bash) -f coverage/lcov.info
```

Execute comprehensive Flutter test suite with coverage analysis.