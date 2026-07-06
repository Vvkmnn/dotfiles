---
name: verify-work
description: Run before claiming work is done. Use when the user says "verify this works", "check before commit", "run checks", "quality gate", "is this ready", or before any commit/PR. 6-phase quality gate that checks build, types, lint, tests, security, and diff review. Produces READY or NOT READY verdict. Use after implementing features, fixing bugs, or before commits.
version: 1.1.0
---

# Verification Loop

6-phase quality gate. Run all phases in order. Stop at first failure unless user says to continue.

## Phase 1: Build

Compile or transpile the project. Language-specific:

```bash
# Detect and run the appropriate build command
# TypeScript: npx tsc --noEmit
# Rust: cargo build
# Go: go build ./...
# Python: python -m py_compile <changed files>
# C/C++: make or cmake --build
```

Exit criteria: zero errors. Warnings are noted but don't block.

## Phase 2: Typecheck

Run the type checker if the project has one:

```bash
# TypeScript: npx tsc --noEmit (may overlap with build)
# Python: pyright or mypy on changed files
# Rust: cargo check (included in build)
```

Exit criteria: zero type errors.

## Phase 3: Lint

Run the project linter:

```bash
# TypeScript/JS: npx eslint <changed files>
# Python: ruff check <changed files>
# Rust: cargo clippy
# Go: golangci-lint run
# Shell: shellcheck <changed files>
```

Exit criteria: zero errors. Warnings are noted.

## Phase 4: Test

Run the test suite:

```bash
# Detect test runner from project config
# npm test / pytest / cargo test / go test ./...
```

Exit criteria: all tests pass. Note any skipped tests.

## Phase 5: Security Scan

Quick security checks on changed files:

```bash
# Check for secrets
grep -rn "password\|secret\|api_key\|token" --include="*.ts" --include="*.py" --include="*.js" <changed files> | grep -v "test\|spec\|mock\|\.d\.ts"

# Check for .env files staged
git diff --cached --name-only | grep -i "\.env"

# Check deps if lockfile changed
# npm audit / pip audit / cargo audit
```

Exit criteria: no secrets in code, no .env staged, no critical dep vulns.

## Phase 6: Diff Review

Self-review the changes:

```bash
git diff --stat
git diff
```

Check:
- Does each change serve the original request?
- Any debug code left in? (console.log, print, debugger)
- Any commented-out code without explanation?
- Any files changed that shouldn't have been?

## Verdict

After all 6 phases, produce:

```
READY — all 6 phases passed
```
or
```
NOT READY — [list specific failures with phase number]
```

If NOT READY, list exactly what needs fixing before re-running.
