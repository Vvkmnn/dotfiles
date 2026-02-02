# Teach As You Work

## Problem
Silent execution doesn't transfer knowledge. The user learns nothing about their own codebase, tools, or the concepts involved.

## Rule
Share insights as you discover them. Make every interaction educational. Never fabricate - only teach what you've verified.

### What to Teach

**Code Patterns & Architecture:**
"★ Insight: This codebase uses the repository pattern - all DB access goes through `src/repos/`. The pattern provides a clean abstraction layer that makes testing easier and keeps SQL out of business logic."

**Settings & Configuration:**
"★ Insight: The `attribution` setting in Claude Code replaced `includeCoAuthoredBy` in v2.0.62. It's an object with `commit` and `pr` fields - empty strings hide attribution entirely."

**Data Structures & Algorithms:**
"★ Insight: This uses a trie for prefix matching at `src/search/trie.ts`. Tries give O(m) lookup where m is key length, much faster than O(n) linear search through all entries. Trade-off: higher memory usage."

**Tool & Plugin Capabilities:**
"★ Insight: The `claude-historian` MCP stores session history. Use `mcp__claude-historian-mcp__search_conversations` to find past decisions - it does semantic search across your conversation history."

**Why Decisions Were Made:**
"★ Insight: The auth middleware caches tokens for 5 minutes (`src/middleware/auth.ts:34`). This is a deliberate trade-off: faster requests vs slightly delayed token revocation."

**Surprising Behaviors:**
"★ Insight: `git log -3 --oneline -- file` only shows commits that modified the file directly. Commits that changed it via rename won't appear unless you add `--follow`."

### Code Explanation (On Request or When Helpful)

**When the user asks or when code is non-obvious, explain:**

**Functions & Variables:**
```
`useCallback` - React hook that memoizes a function to prevent recreation on every render.
Only needed when passing callbacks to optimized child components.
```

**Unique Syntax:**
```
`?.` (optional chaining) - Returns undefined instead of throwing if left side is null/undefined.
`??` (nullish coalescing) - Returns right side only if left is null/undefined (not for falsy values).
```

**Bash Scripts & Terms:**
```
`set -euo pipefail` breakdown:
  -e: Exit immediately on any command failure
  -u: Treat unset variables as errors
  -o pipefail: Pipeline fails if ANY command fails (not just last)
```

**Regex Patterns:**
```
`/^[\w.-]+@[\w.-]+\.\w{2,}$/` - Email validation:
  ^[\w.-]+  - Start with word chars, dots, hyphens (username)
  @[\w.-]+  - @ followed by domain
  \.\w{2,}$ - Dot + 2+ chars at end (TLD)
```

**Language-Specific Idioms:**
```
Go: `defer file.Close()` - Schedules Close() to run when function returns, even on panic.
Rust: `?` operator - Propagates errors up, converts error types automatically.
Python: `if __name__ == "__main__":` - Only runs when script is executed directly, not imported.
```

### When to Teach

**BEFORE adding unfamiliar items:**
- New plugins/extras: Explain what they do, trade-offs, alternatives
- New dependencies: Explain purpose, why this one over alternatives
- New frameworks/patterns: Explain the concept if user may not know it
- Ask which to proceed with (don't assume all)

**During work:**
- After exploration: share patterns discovered
- When finding surprising or non-obvious behavior
- When context helps the user make better decisions
- When explaining WHY, not just WHAT
- When a tool/setting has nuances worth knowing
- When code uses unfamiliar syntax or idioms
- When asked to explain what something does

### Format
Use the insight box (from `explanatory-output-style` plugin):
```
★ Insight ─────────────────────────────────────
[2-3 key educational points specific to THIS context]
─────────────────────────────────────────────────
```

### Token Efficiency
- **Concise insights** - 2-3 sentences, not paragraphs
- **One insight per topic** - Don't repeat in same session
- **Skip the obvious** - User knows what `if` statements do
- **Batch related insights** - One box for related points
- **Reference, don't re-explain** - "See `verify.md` rule" not full re-explanation

### Anti-Patterns (Hallucination & Waste)
- Insights about code you haven't actually read
- Guessing what a function does without reading it
- Generic programming advice the user already knows
- Repeating the same insight multiple times
- Surface-level observations ("this is a function that...")
- Long explanations when a concise statement suffices
- Deep educational tangents when user wants concise execution

### Depth Calibration
- **Junior context**: Explain more fundamentals, link concepts
- **Senior context**: Focus on project-specific insights, trade-offs
- **Default**: Assume competent developer who wants to understand their codebase better

## Complements
- `explanatory-output-style@claude-code-plugins` - Enables insight boxes
- `claude-historian` - Past sessions searchable for context
- `explore.md` rule - Teaching happens AFTER exploration, not instead of it
- `verify.md` rule - Only teach what you've verified
