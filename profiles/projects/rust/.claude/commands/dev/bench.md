---
description: Rust benchmarking with cargo bench and criterion
---

# Rust Benchmarking

Run benchmarks for: $ARGUMENTS

## Benchmark Tools

### Built-in Cargo Bench
```bash
# Run all benchmarks
cargo bench

# Run specific benchmark
cargo bench bench_name

# With specific features
cargo bench --features feature_name

# Save baseline
cargo bench -- --save-baseline before
```

### Criterion.rs Benchmarks
```bash
# Run criterion benchmarks
cargo bench --bench my_benchmark

# Compare with baseline
cargo bench -- --baseline main

# Quick benchmark (fewer samples)
cargo bench -- --quick

# Generate HTML report
cargo bench -- --output-format bencher
```

## Performance Profiling

### Using flamegraph
```bash
# Install flamegraph
cargo install flamegraph

# Generate flamegraph
cargo flamegraph --bench my_benchmark

# Profile specific test
cargo flamegraph --test my_test
```

### Using perf (Linux)
```bash
# Record performance data
perf record cargo bench
perf report

# With call graph
perf record -g cargo bench
```

## Memory Profiling

```bash
# Using valgrind (Linux)
cargo build --release
valgrind --tool=massif ./target/release/my_app

# Using heaptrack (Linux)
heaptrack ./target/release/my_app
heaptrack_gui heaptrack.my_app.*.gz

# macOS alternatives (Instruments)
# instruments -t "Time Profiler" ./target/release/my_app
# instruments -t "Allocations" ./target/release/my_app
```

## Optimization Workflow

1. **Establish Baseline**
   ```bash
   cargo bench -- --save-baseline master
   ```

2. **Make Changes**
   - Implement optimizations
   - Focus on hot paths

3. **Compare Results**
   ```bash
   cargo bench -- --baseline master
   ```

4. **Profile if Needed**
   ```bash
   cargo flamegraph --bench critical_path
   ```

## Common Optimizations

- Use `#[inline]` for small hot functions
- Prefer iterators over explicit loops
- Use `SmallVec` for small collections
- Consider `Arc<str>` vs `String` for shared data
- Profile before optimizing

Execute appropriate benchmark strategy.