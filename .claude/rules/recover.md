# Recover and Escalate

## Problem
Silent failures waste time. Unclear boundaries cause mistakes. Getting stuck without escalating burns context.

## Rule
Know when to retry, when to escalate, and what requires approval. Never silently fail or guess when stuck.

### Boundaries (Three-Tier System)

**Always safe (no approval needed):**
- Read any file, search any pattern
- Run tests, linters, type-checkers
- Git status, log, diff (read-only)
- Fetch documentation, changelogs

**Ask first (get explicit approval):**
- Architectural decisions affecting multiple files
- Adding/removing dependencies
- Deleting files or public APIs
- Git commits, pushes, merges
- Changes to settings.json or hooks

**Never do (refuse even if asked):**
- Push --force to main/master
- Commit secrets, credentials, .env files
- Skip verification hooks (--no-verify)
- Delete without backup strategy

### Error Recovery

**When tools fail:**
| Failure | Retry | Escalate |
|---------|-------|----------|
| Glob/Grep returns 0 | Bash fallback (see avoid.md) | If bash also fails |
| MCP tool timeout | Once with longer timeout | After 2nd failure |
| WebFetch blocked | Try raw.githubusercontent.com | Report to user |
| Bash command fails | Check error message | If unclear |

**Pattern for retry:**
1. Read the error message completely
2. Understand why it failed
3. Fix the cause, don't just retry blindly
4. After 2 failures, escalate

### Context Management

**When context gets polluted:**
- After 2+ corrections on same issue → `/clear` and restart with better prompt
- Between unrelated tasks → `/clear` to reset
- Context >50% used → consider Explore subagent for investigation
- Long exploration → delegate to subagent, get summary back

### When Stuck

**Recognize stuck:**
- Trying same approach 3+ times
- Don't understand why something fails
- Missing information to proceed
- Multiple valid approaches, unsure which

**Escalate protocol:**
1. **State clearly:** "I'm stuck on X because Y"
2. **Share what's tried:** List approaches attempted
3. **Propose options:** "We could try A, B, or C"
4. **Ask for direction:** Don't guess, don't spin

**Never:**
- Pretend to know when you don't
- Make up information
- Continue hoping it works
- Hide failures in verbose output

### Recovery Checklist

Before claiming "done" after any error:
- [ ] Root cause identified (not just symptoms)
- [ ] Fix verified with fresh run
- [ ] No new errors introduced
- [ ] User informed of what happened

## Complements
- `verify.md` - Evidence before claims
- `explore.md` - Investigate before acting
- `superpowers:systematic-debugging` - When truly stuck
