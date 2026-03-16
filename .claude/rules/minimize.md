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

**No disk artifacts for state:**
- No tmpfiles, lockfiles, cooldown files, or PID files for internal state
- Keep state in code, variables, or process environment — not on disk
- If state must persist across processes, use existing mechanisms (git, env vars, CLI flags)
- Every file on disk is a cleanup liability

### The Iteration Principles

**Small steps:**
- One logical change at a time
- Commit frequently at stable points
- Validate each step before continuing
- Easier to review, easier to revert

**Commit messages match the repo:**
- Run `git log --oneline -10` before every commit — match the existing format exactly
- Single-line history → single-line message (NO body, NO bullets)
- Multi-line history → multi-line message matching that style
- Match casing, scope conventions, and level of detail
- Never default to verbose; let the repo's history dictate

**Build incrementally:**
```
Step 1: Add function stub → verify compiles
Step 2: Implement happy path → verify works
Step 3: Add error handling → verify handles edge cases
Step 4: Add tests → verify passes

BAD: Write everything at once → hope it works
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

### Documentation for Future Work

**Add comments that answer:**
- What does this do? (one-line purpose for functions/classes)
- Why this approach? (decisions, trade-offs, alternatives rejected)
- What broke before? (comment out failed code with explanation)
- What else depends on this? (cross-file references with file:line)
- What are the edge cases? (race conditions, timing, quirks)

**Format:**
- LSP-friendly docstrings for functions/classes (helps tooling)
- Inline comments for non-obvious logic
- Section headers for major blocks (like yabai/sketchybar example)
- Never create separate doc files (README per module, DESIGN.md, etc.)

### Code Quality Checklist

Before considering code complete:
- [ ] Does it do ONLY what was asked?
- [ ] Could it be simpler?
- [ ] Is it easy to read?
- [ ] Is it easy to test?
- [ ] Does it match existing patterns?
- [ ] Would a new developer understand it?
- [ ] Removed code commented out with brief explanation?
- [ ] Added comments explaining what, why, decisions, edge cases?
- [ ] Immutable patterns used (spread `{ ...obj, key }` not mutation)
- [ ] Functions small (<50 lines)
- [ ] Files focused (<800 lines, 200-400 typical)
- [ ] No deep nesting (>4 levels)
- [ ] No console.log in production code

### Branch-Scope Refactoring

When refactoring on a feature branch, auto-detect scope from git:
```bash
git diff main...HEAD --name-only  # Files changed since branching
git diff main...HEAD              # All changes since branching
git log main..HEAD --oneline      # Commits since branching
```

Prioritize refactoring by ROI:
- **Immediate**: Code being actively modified in this branch
- **Future**: Code likely to change soon based on roadmap
- **Team**: Code that confuses multiple developers
- **Maintenance**: Code with frequent bugs

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
