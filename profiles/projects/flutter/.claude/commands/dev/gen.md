---
description: Run code generation for Flutter (build_runner, freezed, json_annotation)
---

# Flutter Code Generation

Generate code for: $ARGUMENTS

## Code Generation Strategy

### 1. Detect Generation Needs
```bash
# Check for code generation dependencies
if grep -q "build_runner" pubspec.yaml; then
    echo "✓ build_runner detected"
fi

if grep -q "freezed" pubspec.yaml; then
    echo "✓ freezed detected - will generate immutable models"
fi

if grep -q "json_serializable" pubspec.yaml; then
    echo "✓ json_serializable detected - will generate JSON serialization"
fi

if grep -q "injectable" pubspec.yaml; then
    echo "✓ injectable detected - will generate dependency injection"
fi

if grep -q "auto_route" pubspec.yaml; then
    echo "✓ auto_route detected - will generate navigation"
fi

if grep -q "hive_generator" pubspec.yaml; then
    echo "✓ hive_generator detected - will generate database adapters"
fi

if grep -q "retrofit_generator" pubspec.yaml; then
    echo "✓ retrofit_generator detected - will generate API clients"
fi
```

### 2. Main Generation Commands

#### One-time Generation
```bash
# Generate code once
dart run build_runner build

# Force regeneration (delete existing)
dart run build_runner build --delete-conflicting-outputs
```

#### Watch Mode (Auto-regenerate)
```bash
# Watch for changes and regenerate
dart run build_runner watch

# Watch with conflict resolution
dart run build_runner watch --delete-conflicting-outputs
```

### 3. Specific Generators

#### Freezed (Immutable Models)
```dart
// Example model requiring generation
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    @Default(0) int age,
  }) = _User;
  
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

```bash
# Generate freezed models
dart run build_runner build --delete-conflicting-outputs
```

#### JSON Serialization
```dart
// Example JSON model
import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  final String id;
  final String name;
  final double price;
  
  Product({required this.id, required this.name, required this.price});
  
  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}
```

```bash
# Generate JSON serialization
dart run build_runner build
```

#### Injectable (Dependency Injection)
```dart
// Example injectable service
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@singleton
class AuthService {
  Future<bool> login(String email, String password) async {
    // Implementation
  }
}

@module
abstract class AppModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}
```

```bash
# Generate dependency injection
dart run build_runner build
```

#### Auto Route (Navigation)
```dart
// Example route configuration
import 'package:auto_route/auto_route.dart';

@MaterialAutoRouter(
  routes: <AutoRoute>[
    AutoRoute(page: HomePage, initial: true),
    AutoRoute(page: LoginPage),
    AutoRoute(page: ProfilePage),
  ],
)
class $AppRouter {}
```

```bash
# Generate navigation
dart run build_runner build
```

### 4. Localization Generation

#### Flutter Intl
```bash
# Generate localization files
flutter pub global activate intl_utils
flutter pub global run intl_utils:generate

# Or with flutter_gen
flutter gen-l10n
```

#### Easy Localization
```bash
# Generate translation keys
dart run easy_localization:generate -S assets/translations -f keys -o locale_keys.g.dart
```

### 5. Asset Generation

#### Flutter Gen
```bash
# Generate type-safe asset references
dart run build_runner build # flutter_gen uses build_runner
```

Configuration in `pubspec.yaml`:
```yaml
flutter_gen:
  output: lib/gen/
  integrations:
    flutter_svg: true
    flare_flutter: true
    rive: true
    lottie: true
```

### 6. Clean & Rebuild

```bash
# Clean generated files
dart run build_runner clean

# Full clean and regenerate
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### 7. Optimization & Troubleshooting

#### Performance Tips
```bash
# Use build filters for faster generation
dart run build_runner build --build-filter="lib/models/*.dart"

# Low resource mode (reduces memory usage, may be slower)
dart run build_runner build --low-resources-mode
```

#### Common Issues & Fixes
```bash
# Fix version conflicts
flutter pub upgrade
dart run build_runner build --delete-conflicting-outputs

# Fix analyzer issues
dart analyze
dart run build_runner clean
dart run build_runner build

# Fix import issues
dart fix --apply
dart run build_runner build
```

## Generation Configuration

### build.yaml Example
```yaml
targets:
  $default:
    builders:
      json_serializable:
        options:
          explicit_to_json: true
          include_if_null: false
      freezed:
        options:
          union: true
          union_value: true
```

## Validation

```bash
# Verify generated files
find lib -name "*.g.dart" -o -name "*.freezed.dart" | wc -l
echo "Generated files count: $(find lib -name '*.g.dart' -o -name '*.freezed.dart' | wc -l)"

# Check for missing generations
grep -r "part '" lib/ | grep -E "\.(g|freezed|injectable)\.dart" | while read line; do
  file=$(echo $line | cut -d: -f1)
  part=$(echo $line | sed "s/.*part '\(.*\)'.*/\1/")
  dir=$(dirname $file)
  if [ ! -f "$dir/$part" ]; then
    echo "⚠️  Missing: $dir/$part"
  fi
done
```

Execute the appropriate code generation based on project configuration.