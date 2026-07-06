# PROMPT.md Template — Ralph autonomous loop scaffold

> Moved verbatim from SKILL.md (lines 456-577) in the 2026-07-06 restructure — the full PROMPT.md scaffold (structure, guardrails, tracking, success criteria, anti-hallucination checklist, completion promotion).

## Structure

```markdown
# Project Name - Goal

Brief description of what you're building.

## Visual Target (if UI)
ASCII mockup showing the end state - gives Claude a concrete goal.

## Key Concepts
Table mapping concepts → where they appear → implementation notes.

## Tool Usage Requirements
Explicit instructions to use available tools:
- WebSearch before implementing
- MCP servers (context7, brave-search, github)
- Subagents for parallel work
- Skills (/tdd, /commit, /code-review)

## Project Structure
Directory tree showing expected layout.

## Data Models
Key structs/types with realistic field values.

## Phased Approach
Break into phases: Setup → Structure → Implementation → Polish

## Verification Checklist
What must pass before claiming "done":
- [ ] Build passes
- [ ] Tests pass
- [ ] Linter clean
- [ ] Manual verification

## Guardrails
### NEVER Do
- Skip commits
- Hallucinate APIs
- Leave FIXME.md empty

### ALWAYS Do
- Search before implementing
- Verify with cargo build / npm test / etc.
- Update CHANGELOG.md

## Tracking Files
- CHANGELOG.md - what changed per iteration
- FIXME.md - blockers for human review

## Success Criteria (Progressive)
Level 1: Compiles
Level 2: Renders/Runs
Level 3: With data
Level 4: Animated/Interactive
Level 5: Polished
```

## Best Practices

### 1. Be Concrete, Not Abstract
```markdown
# BAD
Build a nice dashboard

# GOOD
Build a TUI with 7 panels:
- Header: portfolio total, generation, time
- Chart: equity curve with Braille markers
- Leaderboard: sortable table with sparklines
[ASCII mockup here]
```

### 2. Specify Tool Usage
```markdown
## Required Tool Usage

Before writing ANY code:
1. WebSearch for current best practices
2. mcp__context7__query-docs for library APIs
3. `gh search code` for examples (github MCP parked — gh CLI owns this)

After writing code:
1. cargo build / npm run build
2. Launch code-reviewer agent
```

### 3. Include Anti-Hallucination Measures
```markdown
## Anti-Hallucination Checklist
- [ ] Verified API with docs/search
- [ ] Found working example
- [ ] Tested compilation
- [ ] Checked for deprecation warnings
```

### 4. Define Realistic Mock Data
```markdown
## Mock Data Ranges
- Prices: NVDA $800-900, AAPL $180-200
- Returns: Elite +10-25%, Bottom -15 to -25%
- Sharpe: Elite 1.5-2.5, Bottom -0.5 to 0.5
```

### 5. Continuous Loop Instructions
```markdown
## Completion
This prompt runs INDEFINITELY. No completion promise.
Keep improving until manually stopped.
If stuck, document in FIXME.md and try different approach.
```

### 6. Git Commit Format
```markdown
## Git Commits
[ralph] <type>: <description>

Types: feat, fix, refactor, style, docs, perf
Always commit working states.
```

