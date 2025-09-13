---
name: publish
description: Publish Flutter package to pub.dev or app to stores
---

# Flutter Publish

Publish Flutter package/app: $ARGUMENTS

## Publishing Strategy

### 1. Package Publishing (pub.dev)

#### Pre-publish Checks
```bash
if [ -f "pubspec.yaml" ] && grep -q "publish_to:" pubspec.yaml; then
    echo "📦 Preparing package for publishing..."
    
    # Analyze package
    flutter pub publish --dry-run
    
    # Check package score
    dart pub global activate pana
    pana --no-warning
fi
```

#### Validate Package
```bash
# Check format
dart format --set-exit-if-changed lib test

# Run tests
flutter test

# Check documentation
if [ ! -f "README.md" ]; then
    echo "⚠️  Missing README.md"
fi

if [ ! -f "CHANGELOG.md" ]; then
    echo "⚠️  Missing CHANGELOG.md"
fi

if [ ! -f "LICENSE" ]; then
    echo "⚠️  Missing LICENSE file"
fi

# Verify example if package
if [ -d "example" ]; then
    cd example
    flutter pub get
    flutter analyze
    cd ..
fi
```

#### Publish to pub.dev
```bash
# Dry run first
flutter pub publish --dry-run

if [[ "$ARGUMENTS" == *"confirm"* ]]; then
    # Actual publish
    flutter pub publish --force
    
    echo "✅ Package published to pub.dev"
    echo "View at: https://pub.dev/packages/YOUR_PACKAGE_NAME"
fi
```

### 2. App Store Publishing

#### iOS App Store
```bash
if [[ "$ARGUMENTS" == *"ios"* ]] || [[ "$ARGUMENTS" == *"appstore"* ]]; then
    echo "🍎 Preparing iOS release..."
    
    # Build iOS release
    flutter build ios --release
    
    # Archive for App Store
    cd ios
    xcodebuild -workspace Runner.xcworkspace \
               -scheme Runner \
               -sdk iphoneos \
               -configuration Release \
               -archivePath build/Runner.xcarchive \
               archive
    
    # Export IPA
    xcodebuild -exportArchive \
               -archivePath build/Runner.xcarchive \
               -exportOptionsPlist ExportOptions.plist \
               -exportPath build/ios-release
    
    cd ..
    
    echo "📱 IPA created at: ios/build/ios-release/"
    echo "Upload via:"
    echo "  1. Xcode → Window → Organizer"
    echo "  2. Transporter app"
    echo "  3. altool command line"
fi
```

#### Google Play Store
```bash
if [[ "$ARGUMENTS" == *"android"* ]] || [[ "$ARGUMENTS" == *"playstore"* ]]; then
    echo "🤖 Preparing Android release..."
    
    # Build app bundle
    flutter build appbundle --release
    
    # Or build APK
    if [[ "$ARGUMENTS" == *"apk"* ]]; then
        flutter build apk --release --split-per-abi
    fi
    
    echo "📱 App Bundle created at: build/app/outputs/bundle/release/"
    echo "Upload via:"
    echo "  1. Google Play Console"
    echo "  2. fastlane supply"
    echo "  3. gradle play publisher plugin"
fi
```

#### Web Publishing
```bash
if [[ "$ARGUMENTS" == *"web"* ]]; then
    echo "🌐 Building web release..."
    
    # Build optimized web
    flutter build web --release --web-renderer canvaskit
    
    # Optional: Build with specific base href
    if [[ "$ARGUMENTS" == *"base-href:"* ]]; then
        BASE_HREF=$(echo "$ARGUMENTS" | sed 's/.*base-href:\([^ ]*\).*/\1/')
        flutter build web --release --base-href "$BASE_HREF"
    fi
    
    echo "🌐 Web build created at: build/web/"
    echo "Deploy to:"
    echo "  1. Firebase Hosting: firebase deploy"
    echo "  2. Netlify: netlify deploy --prod"
    echo "  3. Vercel: vercel --prod"
fi
```

### 3. Version Management

```bash
# Bump version before publishing
if [[ "$ARGUMENTS" == *"bump"* ]]; then
    # Get current version
    CURRENT_VERSION=$(grep "version:" pubspec.yaml | sed 's/version: //')
    echo "Current version: $CURRENT_VERSION"
    
    # Increment version
    if [[ "$ARGUMENTS" == *"major"* ]]; then
        # Bump major version
        echo "Bumping major version..."
    elif [[ "$ARGUMENTS" == *"minor"* ]]; then
        # Bump minor version
        echo "Bumping minor version..."
    elif [[ "$ARGUMENTS" == *"patch"* ]]; then
        # Bump patch version
        echo "Bumping patch version..."
    fi
    
    # Update changelog
    echo "Remember to update CHANGELOG.md"
fi
```

### 4. CI/CD Publishing

#### GitHub Release
```bash
if [[ "$ARGUMENTS" == *"github"* ]]; then
    # Create GitHub release
    VERSION=$(grep "version:" pubspec.yaml | sed 's/version: //')
    
    gh release create "v$VERSION" \
        --title "Release v$VERSION" \
        --notes "See CHANGELOG.md for details" \
        build/app/outputs/apk/release/*.apk \
        build/app/outputs/bundle/release/*.aab
fi
```

#### Fastlane Integration
```bash
if [ -f "fastlane/Fastfile" ]; then
    echo "📱 Using Fastlane..."
    
    if [[ "$ARGUMENTS" == *"ios"* ]]; then
        fastlane ios release
    fi
    
    if [[ "$ARGUMENTS" == *"android"* ]]; then
        fastlane android deploy
    fi
fi
```

## Publishing Checklist

```bash
echo ""
echo "📋 Publishing Checklist:"
echo "──────────────────────"

# Common checks
[ -f "README.md" ] && echo "✅ README.md" || echo "❌ README.md"
[ -f "CHANGELOG.md" ] && echo "✅ CHANGELOG.md" || echo "❌ CHANGELOG.md"
[ -f "LICENSE" ] && echo "✅ LICENSE" || echo "❌ LICENSE"

# Tests passing
flutter test &>/dev/null && echo "✅ Tests passing" || echo "❌ Tests failing"

# No analysis issues
flutter analyze &>/dev/null && echo "✅ No analysis issues" || echo "❌ Analysis issues found"

# Version updated
echo "📌 Version: $(grep "version:" pubspec.yaml | sed 's/version: //')"

echo ""
echo "Ready to publish? Use:"
echo "  Package: flutter pub publish"
echo "  iOS: flutter build ios --release"
echo "  Android: flutter build appbundle --release"
echo "  Web: flutter build web --release"
```

Execute appropriate publishing workflow.