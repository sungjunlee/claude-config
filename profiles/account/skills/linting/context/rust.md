# Rust Linting Guide

Rust 프로젝트를 위한 Clippy 및 rustfmt 가이드입니다.

## Tool Stack

**Linting**: Clippy (built-in)
**Formatting**: rustfmt (built-in)

## Clippy (Linting)

### Basic Usage
```bash
# Run clippy
cargo clippy

# All targets (tests, examples, benches)
cargo clippy --all-targets

# All features
cargo clippy --all-features

# Workspace-wide
cargo clippy --workspace --all-targets --all-features

# Strict mode (warnings as errors)
cargo clippy -- -D warnings
```

### Auto-fix
```bash
# Fix clippy warnings
cargo clippy --fix

# Allow dirty working directory
cargo clippy --fix --allow-dirty

# Fix with backup
cargo clippy --fix --backup
```

### Lint Categories
```bash
# Pedantic lints (thorough)
cargo clippy -- -W clippy::pedantic

# Restriction lints (minimal dependencies)
cargo clippy -- -W clippy::restriction

# Performance lints
cargo clippy -- -W clippy::perf

# Suspicious code patterns
cargo clippy -- -W clippy::suspicious

# Nursery lints (experimental)
cargo clippy -- -W clippy::nursery
```

## rustfmt (Formatting)

### Basic Usage
```bash
# Format code
cargo fmt

# Check without changes
cargo fmt -- --check

# Format specific file
rustfmt src/main.rs
```

### Configuration (rustfmt.toml)
```toml
edition = "2021"
max_width = 100
tab_spaces = 4
use_small_heuristics = "Default"
imports_granularity = "Crate"
group_imports = "StdExternalCrate"
reorder_imports = true
```

## Combined Workflow

### Development
```bash
# Fix and format
cargo clippy --fix --allow-dirty && cargo fmt
```

### CI Mode
```bash
# Strict checking
cargo fmt -- --check
cargo clippy -- -D warnings
```

### Full Check
```bash
# Complete CI pipeline
cargo fmt -- --check && \
cargo clippy --all-targets --all-features -- -D warnings && \
cargo test --quiet
```

## Configuration

### clippy.toml
```toml
# Project-specific clippy settings
cognitive-complexity-threshold = 25
too-many-arguments-threshold = 10
type-complexity-threshold = 250
```

### Cargo.toml
```toml
[lints.rust]
unsafe_code = "forbid"

[lints.clippy]
all = "warn"
pedantic = "warn"
nursery = "warn"
cargo = "warn"

# Allow specific lints
missing_errors_doc = "allow"
must_use_candidate = "allow"
```

## Common Lint Groups

### Recommended for Most Projects
```toml
[lints.clippy]
all = "warn"
pedantic = "warn"
```

### Strict for Libraries
```toml
[lints.clippy]
all = "warn"
pedantic = "warn"
cargo = "warn"
missing_docs = "warn"
```

### Minimal for Prototypes
```toml
[lints.clippy]
all = "warn"
```

## Inline Lint Control

```rust
// Allow specific lint for item
#[allow(clippy::too_many_arguments)]
fn complex_function(...) {}

// Deny lint for module
#![deny(clippy::unwrap_used)]

// Expect lint (fails if lint doesn't trigger)
#[expect(clippy::needless_return)]
fn example() { return; }
```

## Common Issues

### False Positives
```rust
// Suppress with explanation
#[allow(clippy::cast_possible_truncation)]
// SAFETY: value is always within range
let x = large_value as u8;
```

### Conflicting Lints
Some pedantic lints conflict. Choose based on project needs:
```toml
[lints.clippy]
pedantic = "warn"
module_name_repetitions = "allow"  # Often noisy
```

### Performance vs Readability
```rust
// clippy::unnecessary_lazy_evaluations
// Sometimes lazy is clearer, allow when appropriate
#[allow(clippy::unnecessary_lazy_evaluations)]
let value = option.unwrap_or_else(|| compute());
```

## CI/CD Integration

```yaml
# GitHub Actions
- name: Lint
  run: |
    cargo fmt -- --check
    cargo clippy --all-targets --all-features -- -D warnings
```

## Best Practices

1. **Start with defaults**: `cargo clippy` without extra flags
2. **Add pedantic gradually**: Enable one category at a time
3. **Document suppressions**: Explain why lints are allowed
4. **CI enforcement**: Use `-D warnings` in CI
5. **Format on save**: Configure editor to run `cargo fmt`

## Performance Tips

1. Use `cargo clippy --workspace` for monorepos
2. Run clippy on changed files only in CI when possible
3. Cache cargo build artifacts between runs
