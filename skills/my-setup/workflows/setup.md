# Setup Workflow

개발 환경 설정 워크플로우입니다.

## 실행 단계

### 1. 환경 분석
```bash
# 프로젝트 타입 감지
ls package.json pyproject.toml Cargo.toml go.mod 2>/dev/null

# 기존 설정 확인
ls .gitignore .gitleaks.toml .pre-commit-config.yaml 2>/dev/null
```

### 2. Gitleaks 설정
```bash
# pre-commit 설치 확인
pip install pre-commit || pipx install pre-commit

# gitleaks hook 추가
cat >> .pre-commit-config.yaml << 'EOF'
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.0
    hooks:
      - id: gitleaks
EOF

# hook 설치
pre-commit install
```

### 3. Gitignore 강화
```bash
# 기존 .gitignore에 추가
cat >> .gitignore << 'EOF'

# Security - Secrets
.env
.env.*
!.env.example
*.pem
*.key
credentials.json
secrets.yaml

# IDE
.idea/
.vscode/
*.swp
*.swo

# Build artifacts
dist/
build/
*.egg-info/
node_modules/
target/
EOF
```

### 4. 검증
```bash
# gitleaks 테스트
pre-commit run gitleaks --all-files

# gitignore 확인
git status --ignored
```

## 선택적 설정

### Custom Gitleaks Rules
`context/gitleaks.md` 참조

### Language-specific Patterns
`context/gitignore-patterns.md` 참조

## 출력 예시

```
✓ Pre-commit installed
✓ Gitleaks hook added
✓ Gitignore updated (12 patterns added)
✓ Verification passed

Setup complete! Run 'pre-commit run --all-files' to verify.
```
