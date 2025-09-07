---
description: Python-specific performance optimization with profiling and best practices
---

# Python Performance Optimization

Analyze and optimize Python performance for: $ARGUMENTS

## Python-Specific Optimization

This is a **Python project override** of the general optimize command.

### Python Profiling Tools
- **cProfile**: Built-in deterministic profiler
- **py-spy**: Sampling profiler for production
- **memory_profiler**: Memory usage profiling
- **line_profiler**: Line-by-line timing

### Python-Specific Optimizations

#### 1. Algorithm and Data Structures
- Use built-in functions (map, filter, list comprehensions)
- Choose appropriate data structures (set vs list for membership)
- Leverage collections module (Counter, defaultdict, deque)

#### 2. Memory Optimization
- Use generators instead of lists for large datasets
- Implement __slots__ for memory-efficient classes
- Use memory_profiler to track memory usage
- Consider numpy arrays for numerical data

#### 3. I/O Optimization
- Use asyncio for concurrent I/O operations
- Implement connection pooling for databases
- Use buffered I/O operations
- Consider multiprocessing for CPU-bound tasks

### Quick Analysis Commands

```python
# Profile with cProfile
python -m cProfile -s cumtime your_script.py

# Memory profiling
pip install memory_profiler
@profile
def your_function():
    pass

# Line profiling  
pip install line_profiler
@profile
def your_function():
    pass
kernprof -l -v your_script.py
```

### Django/Flask Specific
- Use database query optimization (select_related, prefetch_related)
- Implement proper caching (Redis, Memcached)
- Use django-debug-toolbar for analysis
- Optimize template rendering

Execute Python-optimized performance analysis for: $ARGUMENTS