# Plan

Switch to Opus for comprehensive planning, append to CLAUDE.md, then execute with Sonnet.

## Usage

```
/plan [feature/task description]
```

## Process

### 1. Model Switch
- Automatically switch to Opus for deep analysis
- Leverage maximum reasoning capability

### 2. Comprehensive Analysis
- Break down requirements
- Consider multiple approaches
- Analyze trade-offs
- Identify edge cases

### 3. Plan Creation
- Document all decisions
- Create actionable steps
- Define success criteria
- Note potential risks

### 4. Storage
- Append to appropriate CLAUDE.md
- Preserve for future reference
- Enable cross-session continuity

### 5. Execution Mode
- Switch back to Sonnet
- Follow plan systematically

## Output Format

```markdown
## Plan: [Feature] - [YYYY-MM-DD]

### Requirements
- Core needs analysis
- Constraints and scale
- Security/performance targets

### Approaches
1. **Fast**: Quick implementation
   - Pros/Cons
   - Complexity: O(n)
   
2. **Scalable**: Production-ready
   - Pros/Cons
   - Complexity: O(log n)

3. **Optimized**: Performance-focused
   - Pros/Cons
   - Complexity: O(1)

### Recommendation
[Approach X] because [reasoning]

### Steps
- [ ] Step 1: Specific action
- [ ] Step 2: Next action
- [ ] Step 3: Continue...

### Success Criteria
- Tests: X% coverage
- Perf: P99 < Xms
- Security: OWASP compliant

### Risks
- Risk → Mitigation
```

## Example

```
User: /plan rate limiter for 1M requests/second

Claude: Switching to Opus for comprehensive planning...

## Plan: Rate Limiter - 2025-07-06

### Requirements
- Handle 1M requests/second
- Per-user rate limiting
- Minimal latency impact
- Distributed system support

### Approaches
1. **Fast**: In-memory token bucket
   - Pros: Simple, fast
   - Cons: Not distributed
   - Complexity: O(1)

2. **Scalable**: Redis sliding window
   - Pros: Distributed, accurate
   - Cons: Network overhead
   - Complexity: O(log n)

3. **Optimized**: Hybrid local/remote
   - Pros: Fast + distributed
   - Cons: Complex sync
   - Complexity: O(1) local

### Recommendation
Approach 2 (Redis) for accurate distributed limiting

[Plan appended to CLAUDE.md]
Switching back to Sonnet for implementation...
```

## Best Practices

- Use for features with multiple approaches
- Review plan before implementation
- Update CLAUDE.md as requirements evolve
- Check off completed steps
- Keep plans concise but complete