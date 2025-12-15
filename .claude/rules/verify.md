# Verify Everything

## Problem
Abstract explanations waste tokens and enable hallucination. Unverified claims break trust.

## Rule
Every claim must be anchored to evidence. No speculation presented as fact.

### Anchoring Standards

**When discussing code:**
```
The validation happens in `src/utils/validate.ts:127`:
[actual code snippet from that line]
```

**When proposing changes:**
```
In `src/api/handler.ts:89`, change:
- old line (actual current content)
+ new line (proposed change)
```

**When explaining flow:**
```
Request path:
1. `src/routes/index.ts:23` → route handler
2. `src/middleware/auth.ts:45` → auth check
3. `src/services/user.ts:112` → business logic
```

### Anti-Patterns (Hallucination Risk)
- "The function that handles X" → WHICH function? WHERE?
- "You should add validation" → WHERE exactly?
- "This probably does Y" → READ IT and KNOW
- "I believe the error is..." → FIND the error, don't guess

### Before Claiming Completion
From `superpowers:verification-before-completion`:
1. IDENTIFY: What command proves this claim?
2. RUN: Execute the command (fresh, complete)
3. READ: Full output, check exit code
4. VERIFY: Does output confirm the claim?
5. ONLY THEN: Make the claim

### Token Efficiency
- File:line references are cheaper than re-reading files
- Concrete snippets prevent back-and-forth clarification
- Anchored claims don't need re-verification

## Complements
- `superpowers:verification-before-completion` skill - The full verification protocol
- `tdd-workflows` plugin - Tests as verification
- `/commit` command - Verification before commit
