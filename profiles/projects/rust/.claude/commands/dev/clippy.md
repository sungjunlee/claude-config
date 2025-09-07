---
description: Rust linting with clippy and formatting
---

# Rust Code Quality

Run clippy and rustfmt for: $ARGUMENTS

## Linting with Clippy

### Standard Linting
```bash
# Run clippy
cargo clippy

# With all targets (tests, examples, benches)
cargo clippy --all-targets

# With all features
cargo clippy --all-features

# Strict mode (warnings as errors)
cargo clippy -- -D warnings
```

### Common Clippy Lints

```bash
# Pedantic lints for thorough checking
cargo clippy -- -W clippy::pedantic

# Restrict lints for minimal dependencies
cargo clippy -- -W clippy::restriction

# Performance lints
cargo clippy -- -W clippy::perf

# Suspicious code patterns
cargo clippy -- -W clippy::suspicious
```

## Formatting with rustfmt

```bash
# Format code
cargo fmt

# Check formatting without changes
cargo fmt -- --check

# Format with specific config
cargo fmt -- --config imports_granularity=Crate
```

## Auto-fix Common Issues

```bash
# Fix clippy warnings automatically
cargo clippy --fix

# Fix with backup
cargo clippy --fix --backup

# Fix and allow dirty working directory
cargo clippy --fix --allow-dirty
```

## CI-Ready Commands

```bash
# Full check suitable for CI
cargo fmt -- --check && \
cargo clippy -- -D warnings && \
cargo test --quiet
```

## Configuration

Check for `.clippy.toml` or `clippy.toml` for project-specific rules.
Check for `rustfmt.toml` or `.rustfmt.toml` for formatting rules.

Execute appropriate linting and formatting.