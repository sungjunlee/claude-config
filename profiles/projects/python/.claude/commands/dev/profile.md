---
description: Profile Python code performance
---

# Profile Python Performance

Profile performance for: $ARGUMENTS

## Profiling Strategies

### 1. CPU Profiling with cProfile
```bash
# Profile script
python -m cProfile -s cumtime $ARGUMENTS

# Save profile data
python -m cProfile -o profile.prof $ARGUMENTS

# Analyze saved profile
python -m pstats profile.prof
```

### 2. Line Profiler
```bash
# Install line_profiler
pip install line_profiler

# Add @profile decorator to functions
# Run with kernprof
kernprof -l -v $ARGUMENTS
```

### 3. Memory Profiling
```bash
# Install memory_profiler
pip install memory_profiler

# Add @profile decorator
# Run with memory profiling
python -m memory_profiler $ARGUMENTS

# Monitor memory over time
mprof run $ARGUMENTS
mprof plot
```

## Profiling Tools

### py-spy (Sampling Profiler)
```bash
# Install py-spy
pip install py-spy

# Profile running process
py-spy record -o profile.svg --pid $PID

# Profile script
py-spy record -o profile.svg -- python $ARGUMENTS

# Top-like interface
py-spy top --pid $PID
```

### Scalene (AI-powered profiler)
```bash
# Install scalene
pip install scalene

# Profile with Scalene
scalene $ARGUMENTS

# Profile specific functions
scalene --profile-only 'module.function' $ARGUMENTS
```

## Performance Analysis

### Identify Bottlenecks
1. Look for functions with high cumulative time
2. Check for high call counts
3. Identify memory allocation hotspots
4. Find I/O blocking operations

### Common Optimizations

#### Algorithm Optimization
```python
# Before: O(n²)
for i in items:
    if i in large_list:  # O(n) lookup
        process(i)

# After: O(n)
large_set = set(large_list)  # O(1) lookup
for i in items:
    if i in large_set:
        process(i)
```

#### Memory Optimization
```python
# Use generators for large datasets
def read_large_file(file):
    for line in file:  # Generator, not loading all
        yield process(line)

# Use slots for classes
class Point:
    __slots__ = ['x', 'y']  # Less memory
```

#### Caching
```python
from functools import lru_cache

@lru_cache(maxsize=128)
def expensive_function(n):
    # Cached results
    return complex_calculation(n)
```

## Async Performance

### Profile Async Code
```python
import asyncio
import cProfile

def profile_async():
    cProfile.run('asyncio.run(main())')

# Or use aiomonitor
pip install aiomonitor
python -m aiomonitor $ARGUMENTS
```

## Visualization

### Generate Flame Graphs
```bash
# Using py-spy
py-spy record -o profile.svg -d 30 -- python $ARGUMENTS

# Using snakeviz
pip install snakeviz
python -m cProfile -o profile.prof $ARGUMENTS
snakeviz profile.prof
```

### Generate Call Graphs
```bash
# Using gprof2dot
pip install gprof2dot
python -m cProfile -o profile.prof $ARGUMENTS
gprof2dot -f pstats profile.prof | dot -Tsvg -o profile.svg
```

## Benchmarking

### Using timeit
```python
import timeit

# Benchmark small code
time = timeit.timeit('sum(range(100))', number=10000)

# Benchmark functions
time = timeit.timeit(lambda: function(), number=1000)
```

### Using pytest-benchmark
```python
def test_performance(benchmark):
    result = benchmark(function_to_test)
    assert result == expected
```

## Output Format

When reporting performance:
1. Top 10 time-consuming functions
2. Memory usage patterns
3. Identified bottlenecks
4. Optimization recommendations
5. Before/after comparisons