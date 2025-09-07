---
description: Comprehensive Rust testing with cargo test
---

# Rust Testing

Run cargo tests for: $ARGUMENTS

## Test Execution

### Basic Testing
```bash
# Run all tests
cargo test

# Run with output
cargo test -- --nocapture

# Run specific test
cargo test test_name

# Run tests in specific module
cargo test module_name::
```

### Test Categories
```bash
# Unit tests only
cargo test --lib

# Integration tests only
cargo test --test '*'

# Doc tests only
cargo test --doc

# Benchmark tests
cargo test --benches

# All targets
cargo test --all-targets
```

## Feature Combinations

```bash
# Test with all features
cargo test --all-features

# Test with no default features  
cargo test --no-default-features

# Test with specific features
cargo test --features "feature1 feature2"

# Test all feature combinations (requires cargo-all-features)
cargo install cargo-all-features
cargo test-all-features
```

## Test Filtering

```bash
# Run ignored tests
cargo test -- --ignored

# Run all tests including ignored
cargo test -- --include-ignored

# Run tests matching pattern
cargo test -- pattern

# Run exact test
cargo test -- --exact test_name
```

## Parallel vs Sequential

```bash
# Run tests in parallel (default)
cargo test

# Run tests sequentially
cargo test -- --test-threads=1

# Run with specific thread count
cargo test -- --test-threads=4
```

## Coverage with Tarpaulin

```bash
# Install tarpaulin
cargo install cargo-tarpaulin

# Generate coverage
cargo tarpaulin

# With HTML output
cargo tarpaulin --out Html

# Exclude files
cargo tarpaulin --exclude-files "**/tests/*"

# Coverage threshold
cargo tarpaulin --fail-under 80
```

## Property Testing with Proptest

```rust
#[cfg(test)]
mod tests {
    use proptest::prelude::*;
    
    proptest! {
        #[test]
        fn test_property(x: i32, y: i32) {
            assert_eq!(x + y, y + x);
        }
    }
}
```

## Test Organization

1. Unit tests in `src/` files with `#[cfg(test)]`
2. Integration tests in `tests/` directory
3. Doc tests in documentation comments
4. Benchmarks in `benches/` directory
5. Examples in `examples/` directory

Execute appropriate test strategy.