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
- "The threshold is 80%" → READ file:line first, never assume config values

### UNVERIFIED Is a Stop Sign, Not a Hedge You Can Ship
An `UNVERIFIED` / "likely" / "probably" flag means **STOP and verify** — it is NOT permission to write the claim down. **Never let a flagged-unverified or assumed claim enter a durable file** (config, docs, rules, skills, plans, commit messages). Before any factual or behavioral claim lands in a tracked file, do ONE of:
1. **Verify** it against an authoritative source (official docs, the actual code/config you can read) OR an empirical test — then write it as fact with the source; or
2. **Ask the user to verify** — when the check needs something you can't reach (their account, a paid model like Fable, a runtime/UI test, private data), give them the exact test to run and encode the answer they report. Delegating the check beats omitting; the user is a verification partner, not just an approver. You can also ask them to run a command, paste output, or make a change on your behalf; and
3. **Omit** it; or
4. Write it explicitly as an **open question to test** ("undocumented — verify before relying"), never as guidance.

Conversation may hold "unverified, needs testing." A committed file may not present a guess as fact. **Subagent / research-agent output is a LEAD, not a source** — re-verify its load-bearing claims yourself before any of it enters a file (agents fabricate: invented repos, star counts, model IDs, a phantom settings key, and mechanism behavior this session). If you can't verify and can't omit, say so out loud and stop — don't ship the guess.

> Origin (2026-07-08): an UNVERIFIED "ultrathink is a no-op on Fable" guess was written into CONFIG.md + orchestrate.md as guidance. Flagging it unverified did not make it safe — durable files demand verified fact or an explicit open question, nothing in between.

### Before Claiming Completion
From `superpowers:verification-before-completion`:
1. IDENTIFY: What command proves this claim?
2. RUN: Execute the command (fresh, complete)
3. READ: Full output, check exit code
4. VERIFY: Does output confirm the claim?
5. **TASK**: If this completes a plan item, call TaskUpdate → completed NOW
6. **SKILLS**: If you used a custom skill or discovered something non-obvious, evaluate skill evolution at end of task (invoke `improve-claude evolve` if warranted). Batch this — don't interrupt main work.
7. ONLY THEN: Make the claim

**Verification pattern:**
```bash
<command> 2>&1 | tail -15 && echo "Exit: $?"
```
*Commands: pytest, cargo build, go test, npm test, make, gcc -Wall, shellcheck*

### After Configuration Changes

**When modifying config files, the pattern is:**
1. Apply/reload the config
2. Verify it loaded without errors
3. Confirm the specific setting changed
4. Test the behavior that was broken

**Why**: Config changes can fail silently (syntax errors, ignored sections, wrong reload mechanism).

**General verification approaches:**
- Check service logs for errors after reload
- Query the running config to confirm setting applied
- Test the specific feature that depends on the config
- Look for confirmation messages or status indicators

**Don't assume reload succeeded** - prove it with specific checks relevant to that config system.

### Token Efficiency
- File:line references are cheaper than re-reading files
- Concrete snippets prevent back-and-forth clarification
- Anchored claims don't need re-verification

## Complements
- `superpowers:verification-before-completion` skill - The full verification protocol
- `tdd-workflows` plugin - Tests as verification
- `/commit` command - Verification before commit
