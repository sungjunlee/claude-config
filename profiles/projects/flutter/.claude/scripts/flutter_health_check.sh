#!/usr/bin/env bash
#
# Flutter Health Check Script
# Validates Flutter development environment and project setup
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }
log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

echo "═══════════════════════════════════════"
echo "    Flutter Health Check"
echo "═══════════════════════════════════════"
echo ""

# 1. Check Flutter Installation
echo "1. Flutter Installation"
echo "────────────────────"
if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    log_success "Flutter installed: $FLUTTER_VERSION"
    
    # Check channel
    FLUTTER_CHANNEL=$(flutter channel | grep '^\*' | awk '{print $2}')
    log_info "Channel: $FLUTTER_CHANNEL"
    
    if [[ "$FLUTTER_CHANNEL" == "stable" ]]; then
        log_success "Using stable channel (recommended)"
    else
        log_warning "Consider switching to stable channel: flutter channel stable"
    fi
else
    log_error "Flutter not found. Install from https://flutter.dev"
    exit 1
fi
echo ""

# 2. Run Flutter Doctor
echo "2. Flutter Doctor"
echo "────────────────────"
DOCTOR_OUTPUT=$(flutter doctor -v 2>&1)

# Check for issues
if echo "$DOCTOR_OUTPUT" | grep -q '\[✗\]'; then
    log_warning "Flutter Doctor found issues:"
    echo "$DOCTOR_OUTPUT" | grep '\[✗\]'
    echo ""
    log_info "Run 'flutter doctor -v' for details"
else
    log_success "Flutter Doctor: No issues found"
fi

# Check specific components
if echo "$DOCTOR_OUTPUT" | grep -q "Android toolchain.*✓"; then
    log_success "Android development ready"
else
    log_warning "Android development not configured"
fi

if echo "$DOCTOR_OUTPUT" | grep -q "Xcode.*✓"; then
    log_success "iOS development ready"
else
    log_warning "iOS development not configured"
fi

if echo "$DOCTOR_OUTPUT" | grep -q "Chrome.*✓"; then
    log_success "Web development ready"
else
    log_warning "Web development not configured"
fi
echo ""

# 3. Check Project Structure
echo "3. Project Structure"
echo "────────────────────"
if [ -f "pubspec.yaml" ]; then
    log_success "Flutter project detected"
    
    # Check Flutter version constraint
    if grep -q "sdk: flutter" pubspec.yaml; then
        SDK_CONSTRAINT=$(grep "sdk:" pubspec.yaml | head -n 1 | sed 's/.*sdk: *//')
        log_info "SDK constraint: $SDK_CONSTRAINT"
    fi
    
    # Check for key directories
    [ -d "lib" ] && log_success "lib/ directory exists" || log_error "lib/ directory missing"
    [ -d "test" ] && log_success "test/ directory exists" || log_warning "test/ directory missing"
    [ -d "assets" ] && log_success "assets/ directory exists" || log_info "assets/ directory not found (optional)"
else
    log_error "Not a Flutter project (pubspec.yaml not found)"
    exit 1
fi
echo ""

# 4. Check Dependencies
echo "4. Dependencies"
echo "────────────────────"
# Check if packages are installed
if [ -f "pubspec.lock" ]; then
    log_success "Dependencies installed (pubspec.lock exists)"
    
    # Check for outdated packages
    OUTDATED=$(flutter pub outdated --no-dev-dependencies 2>&1 | grep "dependencies are up to date" || true)
    if [ -n "$OUTDATED" ]; then
        log_success "All dependencies up to date"
    else
        log_warning "Some packages may be outdated. Run: flutter pub outdated"
    fi
else
    log_warning "Dependencies not installed. Run: flutter pub get"
fi

# Check for common packages
echo ""
log_info "Checking common packages:"
for package in "flutter_test" "cupertino_icons" "http" "provider" "bloc" "get" "riverpod"; do
    if grep -q "$package:" pubspec.yaml 2>/dev/null; then
        echo "  ✓ $package"
    fi
done
echo ""

# 5. Check Code Quality Tools
echo "5. Code Quality Tools"
echo "────────────────────"
if [ -f "analysis_options.yaml" ]; then
    log_success "Linter configured (analysis_options.yaml exists)"
    
    # Check if using recommended lints
    if grep -q "flutter_lints" analysis_options.yaml; then
        log_success "Using flutter_lints (recommended)"
    fi
else
    log_warning "No analysis_options.yaml found. Consider adding flutter_lints"
fi

# Run analyzer
ANALYZE_OUTPUT=$(flutter analyze --no-pub 2>&1 || true)
if echo "$ANALYZE_OUTPUT" | grep -q "No issues found"; then
    log_success "No analyzer issues"
else
    ISSUE_COUNT=$(echo "$ANALYZE_OUTPUT" | grep -c "•" || echo "0")
    if [ "$ISSUE_COUNT" -gt 0 ]; then
        log_warning "Analyzer found $ISSUE_COUNT issues. Run: flutter analyze"
    fi
fi
echo ""

# 6. Check Test Coverage
echo "6. Test Coverage"
echo "────────────────────"
if [ -d "test" ]; then
    TEST_COUNT=$(find test -name "*_test.dart" | wc -l | tr -d ' ')
    if [ "$TEST_COUNT" -gt 0 ]; then
        log_success "Found $TEST_COUNT test files"
        
        # Check if coverage exists
        if [ -f "coverage/lcov.info" ]; then
            log_info "Coverage report exists"
            
            # Try to get coverage percentage
            if command -v lcov &> /dev/null; then
                COVERAGE=$(lcov --summary coverage/lcov.info 2>/dev/null | grep lines | sed 's/.*: \([0-9.]*\)%.*/\1/' || echo "unknown")
                log_info "Coverage: ${COVERAGE}%"
            fi
        else
            log_info "No coverage report. Run: flutter test --coverage"
        fi
    else
        log_warning "No test files found"
    fi
else
    log_warning "No test directory found"
fi
echo ""

# 7. Platform-Specific Checks
echo "7. Platform Configuration"
echo "────────────────────"

# iOS
if [ -d "ios" ]; then
    log_info "iOS configuration:"
    if [ -f "ios/Podfile.lock" ]; then
        echo "  ✓ CocoaPods configured"
    else
        echo "  ⚠️  Pods not installed. Run: cd ios && pod install"
    fi
    
    # Check for common iOS issues
    if [ -f "ios/Runner/Info.plist" ]; then
        echo "  ✓ Info.plist exists"
    fi
fi

# Android
if [ -d "android" ]; then
    log_info "Android configuration:"
    if [ -f "android/local.properties" ]; then
        echo "  ✓ local.properties configured"
    else
        echo "  ⚠️  local.properties missing (will be created on build)"
    fi
    
    # Check min SDK version
    if [ -f "android/app/build.gradle" ]; then
        MIN_SDK=$(grep "minSdkVersion" android/app/build.gradle | sed 's/.*minSdkVersion *//' | tr -d ' ')
        echo "  ℹ️  Min SDK: $MIN_SDK"
    fi
fi

# Web
if [ -d "web" ]; then
    log_info "Web configuration:"
    if [ -f "web/index.html" ]; then
        echo "  ✓ index.html exists"
    fi
fi
echo ""

# 8. Performance Checks
echo "8. Performance Checks"
echo "────────────────────"

# Check for large assets
if [ -d "assets" ]; then
    LARGE_ASSETS=$(find assets -type f -size +1M 2>/dev/null | wc -l | tr -d ' ')
    if [ "$LARGE_ASSETS" -gt 0 ]; then
        log_warning "Found $LARGE_ASSETS large assets (>1MB). Consider optimization"
    else
        log_success "No large assets found"
    fi
fi

# Check for const usage in lib
CONST_WIDGETS=$(grep -r "const.*Widget\|const.*Container\|const.*Text" lib 2>/dev/null | wc -l | tr -d ' ')
if [ "$CONST_WIDGETS" -gt 0 ]; then
    log_success "Using const widgets ($CONST_WIDGETS found)"
else
    log_warning "Consider using const constructors for better performance"
fi
echo ""

# Summary
echo "═══════════════════════════════════════"
echo "    Health Check Summary"
echo "═══════════════════════════════════════"

# Calculate health score
SCORE=0
MAX_SCORE=10

[ -f "pubspec.yaml" ] && ((SCORE++))
[ -f "pubspec.lock" ] && ((SCORE++))
[ -d "lib" ] && ((SCORE++))
[ -d "test" ] && ((SCORE++))
[ -f "analysis_options.yaml" ] && ((SCORE++))
[ "$TEST_COUNT" -gt 0 ] 2>/dev/null && ((SCORE++))
[ -f "coverage/lcov.info" ] && ((SCORE++))
echo "$DOCTOR_OUTPUT" | grep -q "No issues found" && ((SCORE++))
[ "$CONST_WIDGETS" -gt 0 ] && ((SCORE++))
[ "$LARGE_ASSETS" -eq 0 ] 2>/dev/null && ((SCORE++))

echo "Health Score: $SCORE/$MAX_SCORE"

if [ "$SCORE" -ge 8 ]; then
    log_success "Excellent Flutter project health!"
elif [ "$SCORE" -ge 6 ]; then
    log_info "Good project health with room for improvement"
else
    log_warning "Several areas need attention"
fi

echo ""
echo "Run 'flutter doctor -v' for detailed diagnostics"
echo "═══════════════════════════════════════"