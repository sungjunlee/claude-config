---
name: clean
description: Clean Flutter project build artifacts and caches
---

# Flutter Clean

Clean Flutter project: $ARGUMENTS

## Cleaning Strategy

### 1. Basic Clean
```bash
# Standard Flutter clean
flutter clean

# Get dependencies after clean
flutter pub get
```

### 2. Deep Clean (All Artifacts)
```bash
echo "🧹 Starting deep clean..."

# Flutter clean
flutter clean

# Remove iOS artifacts
rm -rf ios/Pods
rm -rf ios/.symlinks
rm -rf ios/Flutter/Flutter.framework
rm -rf ios/Flutter/Flutter.podspec
rm -rf ios/Podfile.lock

# Remove Android artifacts  
rm -rf android/.gradle
rm -rf android/app/build
rm -rf android/build
find android -name "*.iml" -delete

# Remove common artifacts
rm -rf .dart_tool
rm -rf .packages
rm -rf .flutter-plugins
rm -rf .flutter-plugins-dependencies
rm -rf build/
rm -rf .idea/

# Remove pubspec.lock for fresh dependencies
if [[ "$ARGUMENTS" == *"deps"* ]]; then
    rm -f pubspec.lock
    echo "Removed pubspec.lock"
fi

echo "✅ Deep clean complete"
```

### 3. Platform-Specific Clean

#### iOS Clean
```bash
if [ -d "ios" ]; then
    echo "🍎 Cleaning iOS..."
    cd ios
    pod deintegrate
    pod cache clean --all
    rm -rf ~/Library/Developer/Xcode/DerivedData
    cd ..
fi
```

#### Android Clean
```bash
if [ -d "android" ]; then
    echo "🤖 Cleaning Android..."
    cd android
    ./gradlew clean
    ./gradlew cleanBuildCache
    cd ..
fi
```

#### Web Clean
```bash
if [ -d "web" ]; then
    echo "🌐 Cleaning Web..."
    rm -rf build/web
fi
```

### 4. Cache Clean
```bash
# Clean pub cache (use with caution)
if [[ "$ARGUMENTS" == *"cache"* ]]; then
    echo "🗑️ Cleaning pub cache..."
    flutter pub cache clean
    dart pub cache clean
fi

# Clean Flutter cache
if [[ "$ARGUMENTS" == *"flutter-cache"* ]]; then
    echo "🗑️ Cleaning Flutter cache..."
    rm -rf ~/flutter/bin/cache
    flutter doctor  # Rebuilds cache
fi
```

### 5. Restore Dependencies
```bash
echo "📦 Restoring dependencies..."

# Get Flutter packages
flutter pub get

# iOS dependencies
if [ -d "ios" ]; then
    cd ios && pod install && cd ..
fi

# Run code generation if needed
if grep -q "build_runner" pubspec.yaml; then
    echo "🔧 Running code generation..."
    flutter pub run build_runner build --delete-conflicting-outputs
fi

echo "✅ Project cleaned and restored"
```

### 6. Verification
```bash
# Verify clean was successful
echo ""
echo "📊 Clean Summary:"
[ ! -d "build" ] && echo "✓ build/ removed" || echo "✗ build/ still exists"
[ ! -d ".dart_tool" ] && echo "✓ .dart_tool/ removed" || echo "✗ .dart_tool/ still exists"
[ ! -d "ios/Pods" ] && echo "✓ iOS Pods removed" || echo "✗ iOS Pods still exist"
[ ! -d "android/.gradle" ] && echo "✓ Android gradle removed" || echo "✗ Android gradle still exists"
```

Execute appropriate cleaning based on arguments.