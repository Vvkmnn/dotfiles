---
name: second-opinion
author: Vvkmnn
description: >
  Use PROACTIVELY (don't wait to be asked) to get an independent second opinion from Codex —
  the owner's installed CLI, drawing on his existing subscription at no extra cost. Trigger when:
  about to commit or push non-trivial changes; the user asks "is this right", "another opinion",
  "what would X think", "review this", or "am I missing something"; a change touches risky areas
  (auth, billing, migrations, concurrency, shared state, data loss, public APIs); or you're
  genuinely uncertain about your own solution. A fresh-context model catches what author-context
  misses. Offer it at commit/push time even if unprompted.
version: 1.1.0
---

# Second Opinion (Codex)

Get an independent cross-check from OpenAI Codex — a genuinely different model with zero shared context. Uses the already-installed `codex exec` (verified) on the owner's existing Codex/ChatGPT subscription: **no API key, no new billing.**

## When to reach for it

- **Before a commit or push** on anything non-trivial — offer it: "Want Codex's take before we commit?"
- **On risky surface** (auth, billing, migrations, concurrency, shared state, data loss, public APIs) — strongly suggest it.
- **When the user signals doubt** ("is this right?", "am I missing something?", "another opinion").
- **When you're uncertain yourself** — a fresh context beats self-critique.
- Skip it for trivial edits, renames, or when the user says "just do it."

## How to run

**CRITICAL — timeout:** `codex exec` runs a full Codex reasoning turn that routinely takes **2–5 minutes**. Bash's DEFAULT timeout is 2 minutes and WILL kill it (this was the v1.0.0 bug). Always either:
- pass an extended Bash `timeout` of **420000 ms (7 min)** on the call, **or**
- run it with `run_in_background: true` and poll for completion.

Never let the default timeout run it. Add `--skip-git-repo-check` when not inside a git repo (freeform questions from any cwd).

Pick the mode:

```bash
# Working changes (default) — code review of uncommitted diff
codex exec review --uncommitted

# This branch vs a base
codex exec review --base main

# Freeform second opinion on a decision/design (not a diff) — works from anywhere
codex exec --skip-git-repo-check "Blunt technical second opinion, <250 words: <the question>."

# Freeform review of a diff with a pointed focus
git diff | codex exec "Second opinion — <focus, e.g. 'auth bypass risks'>. Be blunt about real problems; skip nits."
```

Keep freeform prompts tight and word-capped (`<250 words`) — it bounds Codex's runtime and output. Runs in Codex's own sandbox; **never** pass `--dangerously-bypass-approvals-and-sandbox` or `--dangerously-bypass-hook-trust` — a read-only opinion needs no write access.

## How to use the result — synthesize, don't relay

A second opinion is a cross-check, not an oracle. After Codex responds:

1. **Agreements** — one line; where Codex confirms your read.
2. **Dissents worth acting on** — each real divergence, with YOUR judgment on whether it's correct (Codex is sometimes wrong; say so).
3. **Noise** — briefly note points you're dismissing and why, so the owner sees you weighed them.
4. **Net recommendation** — your call, now informed by two models.

If Codex errors or is unavailable, say so plainly and proceed with your own review — never fabricate its verdict.

## Related

- `craft-commit` — reach for this before the commit step on non-trivial changes.
- `verify-work` — mechanical verification (tests/lint); this is the *judgment* cross-check. Do both on risky work.
- Gemini CLI (`@google/gemini-cli`, not installed) is the noted future path for 1M-context large-codebase reviews.
