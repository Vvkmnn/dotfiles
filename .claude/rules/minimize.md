# Minimize and Beautify

## Problem
Over-engineered code is hard to read, test, and maintain. Complex solutions hide bugs.

## Rule
Write the minimum code needed, but make it beautiful. Iterate in small steps.

### The Minimalism Principles

**Do only what's asked:**
- Implement the request, not what you think would be "better"
- No bonus features, no opportunistic refactoring
- No "while I'm here" improvements

**Edit, don't create:**
- Prefer modifying existing files over creating new ones
- Extend existing patterns rather than inventing new ones
- Comment out old code with explanations (preserve context and reasoning)

**Simplest solution that works:**
- Fewer files > more files
- Fewer abstractions > more abstractions
- Inline code > premature extraction
- Three similar lines > a premature helper function

**Right-sized models:**
- Haiku for deterministic, can't-fail tasks (CI/CD, file reads, structured data extraction, simple MCP calls)
- Sonnet for general work (default, handles most complexity)
- Opus for complex reasoning (planning, architecture, novel problem-solving)

When launching subagents: `model: "haiku"` for straightforward execution tasks

### The Beauty Principles

**Readable code:**
- Names that explain intent (`getUserById` not `fetch`)
- Consistent formatting matching the codebase
- Logical grouping and ordering
- White space that aids scanning

**Elegant code:**
- One clear purpose per function
- Obvious flow (no clever tricks)
- Symmetry in structure
- Patterns that repeat predictably

**Verifiable code:**
- Easy to trace inputs to outputs
- State changes are explicit
- Side effects are obvious
- Testable without complex setup

### The Iteration Principles

**Small steps:**
- One logical change at a time
- Commit frequently at stable points
- Validate each step before continuing
- Easier to review, easier to revert

**Build incrementally:**
```
✅ Step 1: Add function stub → verify compiles
✅ Step 2: Implement happy path → verify works
✅ Step 3: Add error handling → verify handles edge cases
✅ Step 4: Add tests → verify passes

❌ Write everything at once → hope it works
```

**Validate as you go:**
- Run tests after each meaningful change
- Check linter/compiler frequently
- Don't accumulate changes before verifying

**Dry run before acting:**
- Explain what you're about to do and what will happen
- For MCP/database calls: describe the operation, expected effect, any side effects
- Show preview/diff when possible
- Ask for approval on destructive or irreversible operations
- One change at a time, not batched surprises
- Then execute after confirmation

### Code Quality Checklist

Before considering code complete:
- [ ] Does it do ONLY what was asked?
- [ ] Could it be simpler?
- [ ] Is it easy to read?
- [ ] Is it easy to test?
- [ ] Does it match existing patterns?
- [ ] Would a new developer understand it?
- [ ] Removed code commented out with brief explanation?

### Anti-Patterns

| Don't | Do |
|-------|-----|
| Add features "for later" | Add when needed |
| Create abstraction for one use | Inline until pattern emerges |
| Delete code without explanation | Comment out with reason why removed |
| Add docstrings to unchanged code | Leave it alone |
| Clever one-liners | Clear multi-line |
| Big bang changes | Incremental steps |

## Complements
- `elements-of-style@superpowers-marketplace` - Writing clarity
- `pr-review-toolkit@claude-code-plugins` - Code review catches complexity
- `test.md` rule - Scope verification prevents creep
