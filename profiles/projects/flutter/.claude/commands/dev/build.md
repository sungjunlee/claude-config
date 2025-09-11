---
name: build
description: Build Flutter app for various platforms (APK, IPA, Web, Desktop)
---

# Flutter Build

Build Flutter application for: $ARGUMENTS

## Build Strategy

### 1. Auto-Detect Target Platform
```bash
# Parse arguments or detect from project
if [[ "$ARGUMENTS" == *"ios"* ]]; then
    TARGET="ios"
elif [[ "$ARGUMENTS" == *"android"* ]] || [[ "$ARGUMENTS" == *"apk"* ]]; then
    TARGET="apk"
elif [[ "$ARGUMENTS" == *"web"* ]]; then
    TARGET="web"
elif [[ "$ARGUMENTS" == *"windows"* ]]; then
    TARGET="windows"
elif [[ "$ARGUMENTS" == *"macos"* ]]; then
    TARGET="macos"
elif [[ "$ARGUMENTS" == *"linux"* ]]; then
    TARGET="linux"
else
    # Default to APK for mobile-first development
    TARGET="apk"
fi
```

### 2. Clean Build (if needed)
```bash
# Clean if requested or if build issues detected
if [[ "$ARGUMENTS" == *"clean"* ]] || [ -f ".flutter-build-error" ]; then
    flutter clean
    flutter pub get
fi
```

### 3. Platform-Specific Builds

#### Android Builds
```bash
# Debug APK (fastest, includes debugging info)
flutter build apk --debug

# Release APK (optimized, smaller)
flutter build apk --release

# App Bundle for Play Store
flutter build appbundle --release

# Split APKs by ABI (smaller downloads)
flutter build apk --split-per-abi --release

# Specific flavor
flutter build apk --flavor production --release
```

#### iOS Builds
```bash
# iOS App (requires Mac with Xcode)
flutter build ios --release

# iOS Simulator build
flutter build ios --simulator --debug

# IPA for App Store
flutter build ipa --release

# AdHoc distribution
flutter build ios --release --export-options-plist=ios/ExportOptions.plist
```

#### Web Builds
```bash
# Web build with auto renderer
flutter build web --release

# HTML renderer (better compatibility)
flutter build web --web-renderer html --release

# CanvasKit renderer (better performance)
flutter build web --web-renderer canvaskit --release

# PWA with service worker
flutter build web --pwa-strategy offline-first --release
```

#### Desktop Builds
```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

### 4. Build Variants & Flavors

```bash
# Development flavor
flutter build apk --flavor development --target lib/main_dev.dart

# Staging flavor
flutter build apk --flavor staging --target lib/main_staging.dart

# Production flavor
flutter build apk --flavor production --target lib/main_prod.dart
```

### 5. Build Optimization

#### Size Optimization
```bash
# Enable obfuscation (hides code)
flutter build apk --obfuscate --split-debug-info=debug_info/

# Tree shaking icons (removes unused icons)
flutter build apk --tree-shake-icons --release

# Analyze app size
flutter build apk --analyze-size --release
```

#### Performance Optimization
```bash
# Profile mode (performance analysis)
flutter build apk --profile

# Enable Dart compiler optimizations
flutter build apk --release --extra-gen-snapshot-options=--optimization-level=2
```

### 6. Post-Build Actions

```bash
# Show build output location
echo "✅ Build complete!"
echo "📦 Output location:"

case $TARGET in
    apk)
        echo "  build/app/outputs/flutter-apk/app-release.apk"
        ls -lh build/app/outputs/flutter-apk/*.apk 2>/dev/null
        ;;
    ios)
        echo "  build/ios/iphoneos/Runner.app"
        ;;
    ipa)
        echo "  build/ios/ipa/*.ipa"
        ls -lh build/ios/ipa/*.ipa 2>/dev/null
        ;;
    web)
        echo "  build/web/"
        du -sh build/web/ 2>/dev/null
        ;;
    *)
        echo "  build/$TARGET/"
        ;;
esac

# Size report
if [[ -f "build/app/outputs/apk/release/app-release.apk" ]]; then
    SIZE=$(du -h build/app/outputs/apk/release/app-release.apk | cut -f1)
    echo "📏 APK Size: $SIZE"
fi
```

## Build Troubleshooting

### Common Issues & Fixes

#### Android Issues
```bash
# Gradle issues
cd android && ./gradlew clean && cd ..
flutter build apk --release

# SDK version issues
# Update android/app/build.gradle:
# minSdkVersion 21
# targetSdkVersion 33
```

#### iOS Issues
```bash
# Pod issues
cd ios && pod install --repo-update && cd ..
flutter build ios --release

# Signing issues
open ios/Runner.xcworkspace
# Configure signing in Xcode
```

#### Web Issues
```bash
# CORS issues
# Add headers to web/index.html
# Enable CORS on server

# Base href for subdirectory deployment
flutter build web --base-href /app/ --release
```

## CI/CD Build Commands

```bash
# GitHub Actions / CI build
flutter build apk --release --build-number=$BUILD_NUMBER --build-name=$VERSION

# Fastlane integration
cd ios && fastlane beta && cd ..
cd android && fastlane deploy && cd ..
```

Execute the appropriate build command based on the target platform and options.