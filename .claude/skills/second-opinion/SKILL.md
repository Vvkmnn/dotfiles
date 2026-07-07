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
  misses. Free models: Codex (primary) + OpenRouter panel (qwen/nemotron/llama, non-aligned lineages); Gemini optional after Google killed its free OAuth 2026-06-18. Offer it at commit/push time even if unprompted.
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
- **Do NOT use `run_in_background: true`** — a detached `codex exec` HANGS then dies (exit 144), never producing output. Root cause is upstream, not ours: codex #19945 (silent 0-byte stdout when detached from TTY, regression since v0.124) + #20919 (hangs on stdin reads in non-TTY). **`-o/--output-last-message FILE` does NOT rescue it** — the process hangs *before* writing the file (verified 2026-07-08, don't re-test this). Run FOREGROUND with the long timeout; that's the only reliable path until codex ships the fix (watch v0.143+).

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

### Gemini path (OPTIONAL — free OAuth was killed 2026-06-18)

⚠️ Google **deprecated free "Login with Google" for individuals on 2026-06-18** (Gemini CLI → Antigravity migration). The only remaining $0 path is a **Google AI Studio free-tier API key** (rate-limited, shared quota, Google actively squeezing it): create at aistudio.google.com/apikey, then `export GEMINI_API_KEY=...`. Do NOT install Antigravity just for a second opinion (it's a full IDE suite), and do NOT pay. If the free key is flaky, **skip Gemini** — Codex + the OpenRouter panel below cover the need without Google.

`gemini -p` is headless (1M context — good for whole-repo review). Prefix `GEMINI_TELEMETRY_ENABLED=false`:
```bash
git diff | GEMINI_TELEMETRY_ENABLED=false gemini -p "Second opinion — <focus>. Blunt; real problems only, skip nits."
```
If it errors with an auth message, the free key isn't set — tell the owner; do not fall back to paid billing.

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
- **Third lens (free, installed 2026-07-07):** `llm` v0.31 + `llm-openrouter` 0.6. One-time: `llm keys set openrouter` (free key at openrouter.ai/keys, no card for `:free` models). Pick by role — all $0, all distinct lineage from Codex/Gemini/Claude (verified live on the OpenRouter `:free` list, re-check periodically as free models rotate):
  - **Code/diff** → `openrouter/qwen/qwen3-coder:free` (coding specialist, 1M ctx, Alibaba)
  - **Hard reasoning/architecture** → `openrouter/nvidia/nemotron-3-ultra-550b-a55b:free` (550B, 1M ctx, NVIDIA)
  - **Fast general/quick sanity** → `openrouter/meta-llama/llama-3.3-70b-instruct:free` (proven workhorse, Meta)
  ```bash
  git diff | llm -m openrouter/qwen/qwen3-coder:free "Second opinion — <focus>. Blunt, real problems only."
  ```
  Skip `openai/gpt-oss-120b:free` — strong but OpenAI-lineage, echoes Codex. Use a 3rd lens rarely (seldom flips a call). GLM has NO free path ($18/mo Lite is a cheap *driver*, not worth it as a 3rd opinion). Grok: no free path.
  - **On 429 (free-tier throttle), just try another model** — verified 2026-07-08: qwen + llama share upstream provider "Venice" (throttle together); nemotron is on a separate provider and sails through. Provider-diversity is why the 3-model panel stays available. Don't retry the same 429'd model — switch.
  - Free model IDs rotate — if one 404s, refresh: `curl -s openrouter.ai/api/v1/models | jq -r '.data[].id|select(endswith(":free"))'`.
