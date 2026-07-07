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
  misses. Three zero-cost models available (Codex + Gemini primary, qwen-coder via OpenRouter as optional 3rd lens). Offer it at commit/push time even if unprompted.
version: 1.4.0
---

# Second Opinion — Codex + Gemini panel

Independent cross-checks from genuinely different models with zero shared context, both **$0** (no API keys, no new billing):
- **Codex** (`codex exec`, primary) — OpenAI, on the owner's existing Codex/ChatGPT subscription. Best for **code review of a diff**.
- **Gemini** (`gemini -p`, free personal-Google OAuth, 1000/day, **1M context**) — Google's model, a *different* lineage from Codex/Claude. Best for **large-codebase reasoning** Codex can't hold, or a genuine third lineage on a decision.

Two independent opinions ≈ 70% of the value; a third rarely flips a call. So: **Codex by default; add Gemini when the codebase is large or you want a second, non-OpenAI lineage.** Don't fan out to both on trivial asks.

## When to reach for it

- **Before a commit or push** on anything non-trivial — offer it: "Want Codex's take before we commit?"
- **On risky surface** (auth, billing, migrations, concurrency, shared state, data loss, public APIs) — strongly suggest it.
- **When the user signals doubt** ("is this right?", "am I missing something?", "another opinion").
- **When you're uncertain yourself** — a fresh context beats self-critique.
- Skip it for trivial edits, renames, or when the user says "just do it."

## How to run

**CRITICAL — run in the FOREGROUND with a long timeout.** `codex exec` runs a full reasoning turn (2–5 min). Two verified gotchas:
- Bash's DEFAULT 2-min timeout WILL kill it (the v1.0.0 bug) → pass an extended Bash `timeout` of **420000 ms (7 min)** on the call.
- **Do NOT use `run_in_background: true`** — verified 2026-07-07 that a backgrounded `codex exec` writes a **0-byte output file** (its output only materializes on the foreground path). Run it foreground and let the extended timeout hold; the turn blocks but returns real output.

Add `--skip-git-repo-check` when not inside a git repo (freeform questions from any cwd).

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

### Gemini path (free, 1M context, different lineage)

Same foreground + long-timeout discipline. `gemini -p` is headless; prefix `GEMINI_TELEMETRY_ENABLED=false` (telemetry is on by default). Reach for Gemini when the input is large (whole files/repo — its 1M window) or you want a non-OpenAI second lineage on a decision.

```bash
# Freeform decision second opinion
GEMINI_TELEMETRY_ENABLED=false gemini -p "Blunt technical second opinion, <250 words: <the question>."

# Review a diff (or a large chunk of code piped in — 1M context)
git diff | GEMINI_TELEMETRY_ENABLED=false gemini -p "Second opinion — <focus>. Blunt; real problems only, skip nits."
```

If Gemini errors with an auth message, it isn't logged in yet — tell the owner to run `gemini` once and pick **Login with Google** (free personal-account tier, no API key). Do not fall back to a paid `GEMINI_API_KEY` path.

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
- Gemini CLI installed 2026-07-07 (`@google/gemini-cli` v0.49).
- **Third lens (free, installed 2026-07-07):** `llm` v0.31 + `llm-openrouter` 0.6 → `qwen/qwen3-coder:free` (480B coding specialist, $0). One-time: `llm keys set openrouter` (free key at openrouter.ai/keys, no card for `:free` models). Invoke:
  ```bash
  git diff | llm -m openrouter/qwen/qwen3-coder:free "Second opinion — <focus>. Blunt, real problems only."
  ```
  Use only when you genuinely want a third read (rarely — a 3rd opinion seldom flips a call); free-tier rate-limited. GLM has NO free path ($18/mo Lite exists but only worth it as a cheap *driver*, never as a 3rd opinion). Grok: no free path.
