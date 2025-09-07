---
description: Analyze and optimize code performance, queries, and algorithms
---

# Performance Optimization

Analyze and optimize performance for: $ARGUMENTS

## Purpose
Identify performance bottlenecks and provide actionable optimization recommendations for code, database queries, algorithms, and system architecture.

## Optimization Areas

### 1. Code Performance
- **Algorithm Complexity**: Identify O(n²) or worse algorithms
- **Memory Usage**: Detect memory leaks and excessive allocation
- **CPU Bottlenecks**: Find computation-intensive operations
- **I/O Optimization**: Improve file and network operations

### 2. Database Performance
- **Query Optimization**: Analyze slow queries and suggest improvements
- **Index Strategy**: Recommend proper indexing for performance
- **N+1 Problems**: Identify and resolve query multiplication issues
- **Connection Pooling**: Optimize database connection management

### 3. Frontend Performance
- **Bundle Size**: Analyze and reduce JavaScript bundle size
- **Render Performance**: Optimize React/Vue rendering cycles
- **Network Requests**: Minimize HTTP requests and payload size
- **Caching Strategy**: Implement effective caching mechanisms

### 4. System Architecture
- **Concurrency**: Improve parallel processing and async operations
- **Resource Utilization**: Optimize CPU, memory, and disk usage
- **Scalability**: Design for horizontal and vertical scaling
- **Load Distribution**: Balance workload across resources

## Analysis Process

### Step 1: Performance Profiling
```bash
# Analyze current performance
# - Measure execution time
# - Monitor resource usage
# - Identify bottlenecks
# - Establish baseline metrics
```

### Step 2: Code Analysis
```bash
# Review code for performance issues
# - Algorithm complexity analysis
# - Memory allocation patterns
# - Inefficient data structures
# - Redundant operations
```

### Step 3: Optimization Strategy
```bash
# Develop optimization plan
# - Prioritize high-impact improvements
# - Consider trade-offs (performance vs maintainability)
# - Plan incremental optimizations
# - Set measurable goals
```

### Step 4: Implementation
```bash
# Apply optimizations
# - Refactor critical code paths
# - Optimize data structures and algorithms
# - Implement caching where appropriate
# - Add performance monitoring
```

## Output Format

```markdown
## 🚀 Performance Analysis Report

### Current Performance
- Execution Time: X seconds
- Memory Usage: X MB
- CPU Utilization: X%
- Bottlenecks: [List identified issues]

### 🎯 Optimization Recommendations

#### High Priority (Performance Impact: High)
1. **Issue**: [Description of performance problem]
   - **Impact**: [Quantified performance cost]
   - **Solution**: [Specific optimization approach]
   - **Expected Gain**: [Estimated improvement]
   - **Implementation**: [Code changes needed]

#### Medium Priority (Performance Impact: Medium)
2. **Issue**: [Description]
   - **Solution**: [Optimization approach]
   - **Expected Gain**: [Improvement estimate]

#### Low Priority (Performance Impact: Low)
3. **Issue**: [Description]
   - **Solution**: [Minor optimization]

### 📊 Performance Metrics
- **Before**: [Baseline measurements]
- **After**: [Projected improvements]
- **ROI**: [Effort vs performance gain]

### 🔧 Implementation Plan
1. [Step-by-step optimization roadmap]
2. [Testing strategy for validations]
3. [Monitoring setup for ongoing performance tracking]
```

## Optimization Patterns

### Common Anti-patterns to Fix
- **Premature Optimization**: Focus on actual bottlenecks, not theoretical ones
- **Over-optimization**: Balance performance gains with code maintainability
- **Micro-optimizations**: Prioritize algorithmic improvements over micro-optimizations
- **Ignoring Trade-offs**: Consider memory vs speed, complexity vs performance

### Best Practices
- **Measure First**: Always profile before optimizing
- **Optimize Hot Paths**: Focus on frequently executed code
- **Cache Wisely**: Implement caching for expensive operations
- **Async Operations**: Use non-blocking operations where possible
- **Resource Pooling**: Reuse expensive resources (connections, objects)

## Usage Examples

```bash
# Optimize specific function
/optimize "slow database query in getUserPosts()"

# Optimize algorithm
/optimize "sorting algorithm in dashboard component"

# System-level optimization
/optimize "high memory usage in production"

# Frontend performance
/optimize "React component re-rendering issues"

# Full application analysis
/optimize "overall application performance bottlenecks"
```

## Integration with Other Tools

- **Profilers**: Integrate with language-specific profilers (py-spy, Node.js profiler, etc.)
- **Monitoring**: Connect with APM tools (New Relic, DataDog, etc.)
- **Load Testing**: Combine with load testing results
- **Code Review**: Link with code-reviewer for performance-focused reviews

Execute comprehensive performance analysis and optimization for: $ARGUMENTS