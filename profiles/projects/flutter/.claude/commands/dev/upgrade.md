---
name: upgrade
description: Upgrade Flutter SDK and project dependencies
---

# Flutter Upgrade

Upgrade Flutter and dependencies: $ARGUMENTS

## Upgrade Strategy

### 1. Flutter SDK Upgrade
```bash
echo "🚀 Upgrading Flutter SDK..."

# Check current version
echo "Current version:"
flutter --version | head -n 1

# Upgrade Flutter
flutter upgrade

# Force upgrade if needed
if [[ "$ARGUMENTS" == *"force"* ]]; then
    flutter upgrade --force
fi

# Verify new version
echo "New version:"
flutter --version | head -n 1
```

### 2. Dependencies Upgrade

#### Check Outdated Packages
```bash
echo "📦 Checking outdated packages..."

# Show outdated packages
flutter pub outdated

# Show dependency tree
if [[ "$ARGUMENTS" == *"tree"* ]]; then
    flutter pub deps
fi
```

#### Upgrade Dependencies
```bash
# Upgrade to latest compatible versions (respects pubspec.yaml constraints)
flutter pub upgrade

# Upgrade to latest versions (may break compatibility)
if [[ "$ARGUMENTS" == *"major"* ]]; then
    echo "⚠️  Upgrading to latest major versions..."
    flutter pub upgrade --major-versions
fi

# Upgrade specific package
if [[ "$ARGUMENTS" == *"package:"* ]]; then
    PACKAGE=$(echo "$ARGUMENTS" | sed 's/.*package:\([^ ]*\).*/\1/')
    flutter pub upgrade $PACKAGE
fi
```

### 3. Null Safety Migration
```bash
# Check null safety status
dart pub outdated --mode=null-safety

# Migrate to null safety if needed
if [[ "$ARGUMENTS" == *"null-safety"* ]]; then
    dart migrate
fi
```

### 4. Platform-Specific Updates

#### iOS Updates
```bash
if [ -d "ios" ]; then
    echo "🍎 Updating iOS dependencies..."
    cd ios
    pod update
    pod repo update
    cd ..
fi
```

#### Android Updates
```bash
if [ -d "android" ]; then
    echo "🤖 Checking Android updates..."
    cd android
    
    # Update Gradle wrapper if needed
    if [[ "$ARGUMENTS" == *"gradle"* ]]; then
        ./gradlew wrapper --gradle-version=latest
    fi
    
    cd ..
fi
```

### 5. Breaking Changes Check
```bash
echo "⚠️  Checking for breaking changes..."

# Run analyzer to detect issues
flutter analyze

# Run tests to verify functionality
if [ -d "test" ]; then
    echo "Running tests..."
    flutter test || echo "⚠️  Some tests failed after upgrade"
fi
```

### 6. Code Generation Update
```bash
# Regenerate code if using code generation
if grep -q "build_runner" pubspec.yaml; then
    echo "🔧 Regenerating code..."
    flutter pub run build_runner build --delete-conflicting-outputs
fi
```

### 7. Clean Build After Upgrade
```bash
if [[ "$ARGUMENTS" == *"clean"* ]]; then
    echo "🧹 Performing clean build..."
    flutter clean
    flutter pub get
    
    if [ -d "ios" ]; then
        cd ios && pod install && cd ..
    fi
fi
```

## Upgrade Report
```bash
echo ""
echo "════════════════════════════════════════"
echo "         Upgrade Summary"
echo "════════════════════════════════════════"

# Flutter version
flutter --version | head -n 1

# Count of outdated packages
OUTDATED=$(flutter pub outdated 2>/dev/null | grep -c "^[a-z]" || echo "0")
echo "Outdated packages: $OUTDATED"

# Dart SDK version
echo "Dart SDK: $(dart --version 2>&1 | cut -d' ' -f4)"

# Migration status
if dart pub outdated --mode=null-safety 2>&1 | grep -q "fully migrated"; then
    echo "Null safety: ✅ Fully migrated"
else
    echo "Null safety: ⚠️  Not fully migrated"
fi

echo "════════════════════════════════════════"
echo ""
echo "Next steps:"
echo "1. Review breaking changes in CHANGELOG"
echo "2. Run 'flutter test' to verify functionality"
echo "3. Test on all target platforms"
```

Execute appropriate upgrade operations.