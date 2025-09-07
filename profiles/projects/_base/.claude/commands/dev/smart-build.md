---
description: Universal build system that auto-detects project type
---

# Smart Build System

Auto-detect and build for: $ARGUMENTS

## Build System Detection

### JavaScript/TypeScript
```bash
# Next.js
if [[ -f "next.config.js" ]] || [[ -f "next.config.mjs" ]]; then
    npm run build || yarn build
    
# Vite
elif [[ -f "vite.config.js" ]] || [[ -f "vite.config.ts" ]]; then
    npm run build || yarn build
    
# Webpack
elif [[ -f "webpack.config.js" ]]; then
    npx webpack --mode production
    
# Generic npm/yarn
elif [[ -f "package.json" ]]; then
    if grep -q '"build":' package.json; then
        npm run build || yarn build
    fi
fi
```

### Python
```bash
# setuptools
if [[ -f "setup.py" ]]; then
    python setup.py build
    
# Poetry
elif [[ -f "pyproject.toml" ]] && grep -q "\[tool.poetry\]" pyproject.toml; then
    poetry build
    
# Django collectstatic
elif [[ -f "manage.py" ]]; then
    python manage.py collectstatic --noinput
fi
```

### Rust
```bash
# Release build
cargo build --release

# With all features
cargo build --release --all-features
```

### Go
```bash
# Standard build
go build ./...

# With version info
go build -ldflags="-X main.version=$(git describe --tags)" ./...
```

### Java/Kotlin
```bash
# Maven
if [[ -f "pom.xml" ]]; then
    mvn clean package
    
# Gradle
elif [[ -f "build.gradle" ]] || [[ -f "build.gradle.kts" ]]; then
    ./gradlew build
fi
```

### C#/.NET
```bash
# .NET build
if [[ -f "*.csproj" ]] || [[ -f "*.sln" ]]; then
    dotnet build --configuration Release
fi
```

### C/C++
```bash
# CMake
if [[ -f "CMakeLists.txt" ]]; then
    mkdir -p build
    cd build
    cmake ..
    make
    
# Make
elif [[ -f "Makefile" ]]; then
    make
    
# Cargo for Rust/C bindings
elif [[ -f "Cargo.toml" ]] && grep -q "crate-type.*cdylib" Cargo.toml; then
    cargo build --release
fi
```

### Docker
```bash
# Dockerfile
if [[ -f "Dockerfile" ]]; then
    docker build -t $(basename $(pwd)):latest .
    
# docker-compose
elif [[ -f "docker-compose.yml" ]] || [[ -f "docker-compose.yaml" ]]; then
    docker-compose build
fi
```

## Build Optimization

### Production Flags
- Minification enabled
- Source maps generated
- Assets optimized
- Dead code eliminated

### Development Build
For development builds, use:
- Fast refresh/HMR enabled
- Source maps inline
- No minification
- Verbose logging

### Build Cache
- Leverage incremental compilation
- Use build caches when available
- Cache dependencies

## Build Artifacts

Common output locations:
- JavaScript: `dist/`, `build/`, `.next/`
- Python: `dist/`, `build/`, `*.egg-info/`
- Rust: `target/release/`
- Go: Binary in project root or `bin/`
- Java: `target/`, `build/`
- .NET: `bin/Release/`

## Post-Build Actions

1. Run tests on built artifacts
2. Generate documentation
3. Create checksums/signatures
4. Package for distribution

Execute appropriate build process.