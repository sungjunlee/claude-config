# Tests

claude-config 테스트 스위트.

## 요구사항

### Python 테스트
```bash
pip install pytest pytest-mock
```

### Shell 테스트 (bats-core)
```bash
# macOS
brew install bats-core

# Linux
git clone https://github.com/bats-core/bats-core.git
cd bats-core && sudo ./install.sh /usr/local
```

## 실행

### 전체 테스트
```bash
./tests/run_tests.sh
```

### Python 테스트만
```bash
pytest tests/ -v
```

### Shell 테스트만
```bash
bats tests/install/*.bats tests/hooks/*.bats
```

### 특정 테스트
```bash
# Python
pytest tests/hooks/test_audit_logger.py -v

# Shell
bats tests/install/test_install.bats
```

## 테스트 구조

```
tests/
├── README.md
├── run_tests.sh           # 전체 테스트 실행
├── conftest.py            # pytest 설정
├── install/
│   └── test_install.bats  # install.sh 통합 테스트
├── hooks/
│   ├── test_audit_logger.py
│   ├── test_post_edit.py
│   └── test_shell_hooks.bats
└── fixtures/
    └── sample_input.json  # 테스트용 입력 데이터
```

## CI/CD

GitHub Actions에서 자동 실행:

```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      - run: pip install pytest pytest-mock
      - run: sudo npm install -g bats
      - run: ./tests/run_tests.sh
```
