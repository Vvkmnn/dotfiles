# Test with Purpose

## Problem

Untested code breaks. Unscoped work drifts. Unsecured code leaks.

## Rule

Gate all work with appropriate tests, security checks, and scope verification.

### Testing Strategy

**When to use TDD (test-first):**

- Bug fixes (write failing test that reproduces bug FIRST)
- New features with clear requirements
- Refactoring (tests prove behavior unchanged)

**When TDD is overkill:**

- Exploratory prototyping
- One-off scripts
- Pure documentation changes

**TDD pattern (adapt to your framework):**
```python
# 1. RED - Write failing test first
def test_feature():
    assert feature(input) == expected

# 2. GREEN - Minimal code to pass
def feature(x):
    return expected

# 3. REFACTOR - Improve without changing behavior
```
*Frameworks: pytest, cargo test, go test, npm test, make test, busted (lua)*

**Testing layers:**
| Layer | Tests | When Required |
|-------|-------|---------------|
| Unit | Individual functions | Always for business logic |
| Integration | Component interactions | APIs, database access |
| E2E | Full user flows | Critical paths before deploy |

### Security Gates

**Before every commit (`/commit` already checks some):**

- [ ] No secrets in code (API keys, tokens, passwords)
- [ ] No `.env` files staged
- [ ] No credentials in logs or error messages

**Before PR:**

- [ ] Input validation at system boundaries
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (output encoding)
- [ ] Auth/authz on all protected endpoints

**Before deploy:**

- [ ] Dependencies scanned for vulnerabilities
- [ ] No debug code or console.logs in production paths
- [ ] Error messages don't leak internal details

### Scope Verification

**Before marking complete, verify:**

1. Re-read the original request
2. List what was asked for
3. List what was delivered
4. Confirm: delivered ⊆ asked (subset, not superset)
5. Clear documentation that is compliant and human-readable

**Scope creep red flags:**

- "While I'm here, I'll also..."
- "This would be better if..."
- "I noticed this other thing..."
- Adding features not requested
- Refactoring unrelated code

### Test Quality

**Good tests are:**

- Independent (no shared state)
- Deterministic (same result every run)
- Fast (seconds, not minutes)
- Descriptive (test name explains what/why)

**Avoid:**

- Testing mock behavior instead of real code
- Test-only methods in production code
- Mocking without understanding what you're mocking

## Complements

- `tdd-workflows@claude-code-workflows` - TDD mechanics
- `superpowers:test-driven-development` skill - Red-green-refactor
- `superpowers:testing-anti-patterns` skill - What to avoid
- `security-guidance@claude-code-plugins` - Security patterns
- `security-scanning@claude-code-workflows` - Automated scanning
- `/commit` command - Pre-commit security checks
