# Performance Analysis

Analyze and optimize code performance, identifying bottlenecks and suggesting improvements.

## Usage

```
/perf [target]
```

## Process

### 1. Performance Profiling
- Identify slow functions and algorithms
- Find N+1 query problems
- Detect memory leaks
- Analyze time complexity
- Review space complexity

### 2. Bottleneck Analysis
- Database query optimization
- Network request batching
- Caching opportunities
- Unnecessary computations
- Inefficient data structures

### 3. Optimization Strategy
- Algorithm improvements
- Data structure selection
- Lazy loading implementation
- Parallel processing opportunities
- Resource pooling

### 4. Benchmarking
- Measure current performance
- Set performance targets
- Create reproducible benchmarks
- Document improvements

## Output Format

```markdown
## Performance Analysis Report

### Current Metrics
- Response time: P50/P95/P99
- Memory usage: Average/Peak
- CPU usage: Average/Peak

### Bottlenecks Identified
1. **[Component]**: Impact and description
2. **[Component]**: Impact and description

### Optimization Recommendations
- [ ] Optimization 1: Expected improvement
- [ ] Optimization 2: Expected improvement

### Implementation Priority
1. Quick wins (high impact, low effort)
2. Major improvements (high impact, high effort)
3. Nice to have (low impact)
```

## Example

```
User: /perf api endpoints

Claude: Analyzing API endpoint performance...

## Performance Analysis Report

### Current Metrics
- Response time: P50: 250ms, P95: 800ms, P99: 2.1s
- Memory usage: Average: 512MB, Peak: 1.2GB
- CPU usage: Average: 45%, Peak: 89%

### Bottlenecks Identified
1. **getUserPosts()**: 600ms - Fetches posts one by one
2. **processImages()**: 400ms - No caching, processes on every request
3. **searchProducts()**: 1.2s - Full table scan on 1M records

### Optimization Recommendations
- [ ] Batch getUserPosts queries: 600ms → 50ms (92% improvement)
- [ ] Add Redis caching for images: 400ms → 10ms (97% improvement)
- [ ] Add database index on product.name: 1.2s → 80ms (93% improvement)

[continues...]
```