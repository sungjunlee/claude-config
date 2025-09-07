---
description: Python-specific performance optimization with profiling and best practices
---

# Python Performance Optimization

> **Project Override**: This Python-specific version overrides the account-level `/optimize` command
> 
> **Override Priority**: Project Level (this file) > Account Level > Built-in

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

#### Django Optimization Examples
```python
# Use select_related for foreign keys
posts = Post.objects.select_related("author").all()

# Use prefetch_related for many-to-many
posts = Post.objects.prefetch_related("tags", "comments").all()

# Combine for complex queries
posts = (Post.objects
         .select_related("author")
         .prefetch_related("tags", "comments__user")
         .filter(published=True))

# Use only() to limit fields
posts = Post.objects.only("title", "published_date").all()

# Enable query debugging
# In settings.py
DEBUG_TOOLBAR_CONFIG = {
    'SHOW_TOOLBAR_CALLBACK': lambda request: DEBUG
}
```

#### Flask Optimization Examples
```python
# Use Flask-Caching for view caching
from flask_caching import Cache

cache = Cache(config={'CACHE_TYPE': 'redis'})

@app.route('/expensive')
@cache.cached(timeout=60, key_prefix='expensive_view')
def expensive_view():
    return expensive_computation()

# Use memoization for functions
@cache.memoize(timeout=300)
def get_user_data(user_id):
    return User.query.get(user_id)

# Connection pooling with SQLAlchemy
app.config['SQLALCHEMY_POOL_SIZE'] = 10
app.config['SQLALCHEMY_POOL_RECYCLE'] = 3600
app.config['SQLALCHEMY_POOL_PRE_PING'] = True
```

Execute Python-optimized performance analysis for: $ARGUMENTS