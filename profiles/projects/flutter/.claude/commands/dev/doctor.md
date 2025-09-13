---
name: doctor
description: Run Flutter doctor to check development environment
---

# Flutter Doctor

Check Flutter development environment: $ARGUMENTS

## Doctor Execution

### 1. Basic Check
```bash
# Run Flutter doctor
flutter doctor

# Verbose output with more details
flutter doctor -v

# Check for specific platforms
flutter doctor --android-licenses  # Accept Android licenses
```

### 2. Platform-Specific Checks

#### Android
```bash
# Check Android setup
flutter doctor --android-licenses
flutter config --android-sdk /path/to/sdk
flutter config --android-studio-dir /path/to/studio
```

#### iOS (macOS only)
```bash
# Check iOS setup
flutter doctor --ios
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

#### Web
```bash
# Enable web support if not enabled
flutter config --enable-web
flutter doctor
```

### 3. Fix Common Issues

```bash
# Missing command line tools
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    xcode-select --install
    brew install --cask android-studio
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    sudo apt-get install lib32stdc++6
fi

# Accept Android licenses
flutter doctor --android-licenses

# Clear Flutter cache if issues persist
flutter clean
rm -rf ~/flutter/bin/cache
flutter doctor
```

### 4. Environment Validation

```bash
# Check Flutter channel
flutter channel

# Switch to stable if needed
flutter channel stable
flutter upgrade

# Verify installation
echo "Flutter version: $(flutter --version | head -n 1)"
echo "Dart version: $(dart --version)"
echo "Path: $(which flutter)"
```

Execute Flutter doctor diagnostics.