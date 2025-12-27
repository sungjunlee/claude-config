# Rust Testing Guide

Rust 프로젝트를 위한 cargo test 기반 테스트 가이드입니다.

## Test Framework

**Built-in**: `cargo test`
**Coverage**: `cargo-tarpaulin`
**Property Testing**: `proptest`, `quickcheck`
**Benchmarks**: `criterion`

## Basic Commands

### Test Execution
```bash
# Run all tests
cargo test

# With output (show println!)
cargo test -- --nocapture

# Specific test
cargo test test_name

# Tests in module
cargo test module_name::

# Exact match
cargo test -- --exact test_name
```

### Test Categories
```bash
# Unit tests only
cargo test --lib

# Integration tests only
cargo test --test '*'

# Doc tests only
cargo test --doc

# Benchmarks
cargo test --benches

# All targets
cargo test --all-targets
```

## Feature Testing

```bash
# All features
cargo test --all-features

# No default features
cargo test --no-default-features

# Specific features
cargo test --features "feature1 feature2"

# All feature combinations (requires cargo-all-features)
cargo install cargo-all-features
cargo test-all-features
```

## Test Filtering

```bash
# Run ignored tests
cargo test -- --ignored

# All including ignored
cargo test -- --include-ignored

# Pattern match
cargo test -- pattern

# Exact name
cargo test -- --exact test_name
```

## Parallel Execution

```bash
# Parallel (default)
cargo test

# Sequential
cargo test -- --test-threads=1

# Specific thread count
cargo test -- --test-threads=4
```

## Coverage with Tarpaulin

```bash
# Install
cargo install cargo-tarpaulin

# Generate coverage
cargo tarpaulin

# HTML output
cargo tarpaulin --out Html

# Exclude files
cargo tarpaulin --exclude-files "**/tests/*"

# Coverage threshold
cargo tarpaulin --fail-under 80

# With all features
cargo tarpaulin --all-features
```

## Test Organization

### Unit Tests (in source files)
```rust
// src/lib.rs or src/module.rs
pub fn add(a: i32, b: i32) -> i32 {
    a + b
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_add() {
        assert_eq!(add(2, 3), 5);
    }

    #[test]
    fn test_add_negative() {
        assert_eq!(add(-1, 1), 0);
    }
}
```

### Integration Tests
```rust
// tests/integration_test.rs
use my_crate::add;

#[test]
fn test_add_integration() {
    assert_eq!(add(2, 3), 5);
}
```

### Doc Tests
```rust
/// Adds two numbers together.
///
/// # Examples
///
/// ```
/// use my_crate::add;
/// assert_eq!(add(2, 3), 5);
/// ```
pub fn add(a: i32, b: i32) -> i32 {
    a + b
}
```

## Directory Structure

```
project/
├── src/
│   ├── lib.rs          # Unit tests with #[cfg(test)]
│   └── module.rs
├── tests/              # Integration tests
│   ├── common/
│   │   └── mod.rs      # Shared test utilities
│   └── integration.rs
├── benches/            # Benchmarks
│   └── benchmark.rs
└── examples/           # Example programs
    └── example.rs
```

## Property Testing with Proptest

```rust
#[cfg(test)]
mod tests {
    use proptest::prelude::*;

    proptest! {
        #[test]
        fn test_commutative(x: i32, y: i32) {
            prop_assert_eq!(add(x, y), add(y, x));
        }

        #[test]
        fn test_identity(x: i32) {
            prop_assert_eq!(add(x, 0), x);
        }
    }
}
```

## Async Testing

```rust
#[cfg(test)]
mod tests {
    use tokio;

    #[tokio::test]
    async fn test_async_function() {
        let result = async_function().await;
        assert_eq!(result, expected);
    }

    #[tokio::test(flavor = "multi_thread", worker_threads = 2)]
    async fn test_concurrent() {
        // Multi-threaded test
    }
}
```

## Test Attributes

```rust
#[test]
fn normal_test() {}

#[test]
#[ignore]
fn slow_test() {}

#[test]
#[should_panic]
fn panicking_test() {
    panic!("expected");
}

#[test]
#[should_panic(expected = "specific message")]
fn specific_panic() {
    panic!("specific message");
}
```

## Benchmarking with Criterion

```rust
// benches/benchmark.rs
use criterion::{black_box, criterion_group, criterion_main, Criterion};
use my_crate::fibonacci;

fn fibonacci_benchmark(c: &mut Criterion) {
    c.bench_function("fib 20", |b| {
        b.iter(|| fibonacci(black_box(20)))
    });
}

criterion_group!(benches, fibonacci_benchmark);
criterion_main!(benches);
```

```toml
# Cargo.toml
[[bench]]
name = "benchmark"
harness = false

[dev-dependencies]
criterion = "0.5"
```

## Configuration (Cargo.toml)

```toml
[package]
name = "my_crate"
version = "0.1.0"

[dev-dependencies]
proptest = "1.0"
criterion = "0.5"
tokio = { version = "1", features = ["full", "test-util"] }

[profile.test]
opt-level = 0

[profile.bench]
opt-level = 3
```

## Common Issues

### Compile Errors in Tests
```bash
# Check compilation only
cargo test --no-run

# Verbose output
cargo test --verbose
```

### Test Dependencies
```toml
# Cargo.toml - test-only dependencies
[dev-dependencies]
tempfile = "3"
mockall = "0.11"
```

### Shared Test Utilities
```rust
// tests/common/mod.rs
pub fn setup() -> TestContext {
    // Setup logic
}

// tests/integration.rs
mod common;

#[test]
fn test_with_setup() {
    let ctx = common::setup();
    // Test logic
}
```

## CI/CD Integration

```yaml
# GitHub Actions
- name: Test
  run: |
    cargo test --all-features
    cargo test --doc

- name: Coverage
  run: |
    cargo install cargo-tarpaulin
    cargo tarpaulin --out Xml
```

## Performance Tips

1. **Incremental compilation**: Tests benefit from cargo's caching
2. **Parallel by default**: `cargo test` runs in parallel
3. **Use `#[ignore]`**: For slow tests, run with `--ignored`
4. **Release tests**: `cargo test --release` for performance tests
5. **Nextest**: `cargo-nextest` for faster test execution

```bash
# Install nextest
cargo install cargo-nextest

# Run with nextest (faster)
cargo nextest run
```

## Common Patterns

### Setup/Teardown
```rust
struct TestContext {
    // resources
}

impl TestContext {
    fn new() -> Self {
        // Setup
        Self { }
    }
}

impl Drop for TestContext {
    fn drop(&mut self) {
        // Teardown
    }
}

#[test]
fn test_with_context() {
    let _ctx = TestContext::new();
    // Test - cleanup happens on drop
}
```

### Mocking with mockall
```rust
use mockall::{automock, predicate::*};

#[automock]
trait Database {
    fn get(&self, id: u32) -> Option<String>;
}

#[test]
fn test_with_mock() {
    let mut mock = MockDatabase::new();
    mock.expect_get()
        .with(eq(1))
        .returning(|_| Some("value".to_string()));

    assert_eq!(mock.get(1), Some("value".to_string()));
}
```
