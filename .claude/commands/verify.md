---
description: Run 6-phase verification loop before claiming work is done
---

Invoke the verify-work skill. Run all 6 phases in order against the current project:

1. **Build** — compile/transpile succeeds
2. **Typecheck** — type checker passes
3. **Lint** — linter passes
4. **Test** — test suite passes
5. **Security** — no secrets in code, no .env staged, check dep vulns if lockfile changed
6. **Diff review** — self-review changes, flag debug code, commented-out code, scope creep

Produce a READY or NOT READY verdict. If NOT READY, list exactly what needs fixing.
