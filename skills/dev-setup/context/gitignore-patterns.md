# Gitignore Patterns Collection

## 필수 보안 패턴

```gitignore
# Environment files
.env
.env.*
!.env.example
!.env.template

# Credentials
credentials.json
service-account*.json
*.pem
*.key
*.p12
*.pfx

# Secrets
secrets.yaml
secrets.yml
.secrets/
```

## IDE 패턴

```gitignore
# JetBrains
.idea/
*.iml

# VS Code
.vscode/
!.vscode/settings.json
!.vscode/extensions.json

# Vim
*.swp
*.swo
*~

# macOS
.DS_Store
```

## Node.js

```gitignore
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.npm
.pnpm-debug.log*

# Build
dist/
build/
.next/
out/

# Cache
.cache/
.parcel-cache/
```

## Python

```gitignore
__pycache__/
*.py[cod]
*$py.class
*.so

# Virtual environments
.venv/
venv/
ENV/
.python-version

# Build
dist/
build/
*.egg-info/
.eggs/

# Cache
.pytest_cache/
.mypy_cache/
.ruff_cache/
```

## Go

```gitignore
# Binary
*.exe
*.exe~
*.dll
*.so
*.dylib

# Build
/bin/
/vendor/

# Go workspace
go.work
go.work.sum
```

## Rust

```gitignore
/target/
Cargo.lock  # For libraries
*.rs.bk
```

## Java/Kotlin

```gitignore
# Build
target/
build/
out/

# Gradle
.gradle/
gradle-app.setting
!gradle-wrapper.jar

# Maven
pom.xml.tag
pom.xml.releaseBackup
```

## 공통 빌드/캐시

```gitignore
# Logs
*.log
logs/

# Temporary
tmp/
temp/
*.tmp

# Coverage
coverage/
.nyc_output/
htmlcov/

# Documentation build
docs/_build/
site/
```

## 사용법

```bash
# 패턴 추가
cat >> .gitignore << 'EOF'
# Paste patterns here
EOF

# 캐시된 파일 제거
git rm -r --cached .
git add .
git commit -m "chore: update gitignore"
```
