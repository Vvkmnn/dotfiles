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
  misses. Codex (primary, free) + a full OpenRouter panel — best model of each provider via ONE key (nemotron/qwen free by default; gpt-5.5-pro/gemini-3/grok flagships on prepaid credits). Fan out to several and synthesize. Offer it at commit/push time even if unprompted.
version: 2.0.0
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

## The model panel — best of each provider, all $0-marginal on subs already held

Principle: **maximize what the owner already pays for; never buy per-token what a subscription covers.** Three engines:
- **Claude** — the harness (this session). We ARE this; not in the panel.
- **OpenAI → codex-sub** — `codex exec --model gpt-5.5` uses the owner's ChatGPT **Plus** subscription (flat-rate, $0 marginal). This is THE OpenAI lens. **Do NOT route OpenAI through OpenRouter** (`openai/*` there is per-token = paying twice).
- **Everyone else → OpenRouter `llm`** — one key, async-safe, fleet-synced. Free models need no balance; non-OpenAI *flagships* are "later, when he funds credits" (no sub for them yet).

| Provider | How | Tier |
|---|---|---|
| OpenAI | `codex exec --model gpt-5.5` (Plus sub) | **primary, $0, on now** |
| NVIDIA | `openrouter/nvidia/nemotron-3-ultra-550b-a55b:free` | **free — default** |
| Alibaba | `openrouter/qwen/qwen3-coder:free` | **free — default** (code) |
| Google | `openrouter/google/gemini-3.1-pro-preview` | later (~$0.03/q, needs credits) |
| xAI | `openrouter/x-ai/grok-4.3` | later (~$0.008/q, needs credits) |
| DeepSeek | `openrouter/deepseek/deepseek-v4-pro` | optional (~$0.003/q) |

**Today's complete $0 panel = codex-sub (OpenAI) + free OpenRouter (nemotron/qwen). No OpenRouter credits needed.** The paid rows 403 "Key limit exceeded" until the owner funds credits + raises the key cap (a one-time owner action at openrouter.ai/credits) — reserve them for when he wants Gemini/Grok specifically. IDs verified live 2026-07-08; they rotate — the weekly cloud audit re-checks them.

**Fan-out (parallel, then synthesize)** — fire codex (OpenAI) + free OpenRouter at once. Use `codex -o` for a CLEAN answer (plain `>` captures 43KB of TUI trace — verified 2026-07-08):
```bash
Q="Second opinion — <focus>. Blunt, real problems only, <150 words."
codex exec --skip-git-repo-check -o /tmp/op_codex.txt "$Q" >/dev/null 2>&1 &   # OpenAI, Plus sub, clean via -o
for m in nvidia/nemotron-3-ultra-550b-a55b:free qwen/qwen3-coder:free; do
  llm -m "openrouter/$m" "$Q" > "/tmp/op_${m//\//_}.txt" 2>&1 &
done; wait; for f in /tmp/op_*.txt; do echo "── $f"; cat "$f"; done; rm -f /tmp/op_*.txt
```
`codex exec` via `&` inside a FOREGROUND Bash call works (verified); the #19945/#20919 hang only bites `run_in_background` (whole call detached). codex + llm concurrently = two subs at once.

**RELIABILITY & PRIVACY (dogfooded 2026-07-08 — the honest truth GPT-5.5 flagged):** treating "$0 marginal" as a reliable substrate is the trap. **codex-sub is the ONE dependable lens** (but flat-rate ≠ unlimited — Plus throttles). **Free OpenRouter models are BEST-EFFORT** — in a real run BOTH nemotron + qwen 429'd at once; expect 1-2 of N to fail, note them, don't retry the same one. **PRIVACY: never send proprietary/sensitive code to free third-party models** (nemotron/qwen/etc. — unknown retention). And **synthesize, don't vote-count** — weigh the reasoning, a 2-1 "majority" of weaker models doesn't beat one strong dissent.
Then **synthesize** as with Codex: agreements · real dissents (with your judgment) · net call. A model that 403s (no credits) or 429s (free throttle) → note it and move on; never fabricate a verdict.

**COST GUARDRAIL — default is $0, never auto-spend.** Use ONLY: **Codex** (`codex exec`, the owner's ChatGPT/Codex *subscription* via the local CLI — costs no usage credits, no API billing) + **free OpenRouter models** (`:free`). **NEVER fire a paid flagship** (`gpt-5.5-pro`, `gemini-3.1-pro`, `grok-4.3`) unless the owner EXPLICITLY asks for it AND has funded OpenRouter credits (until then they 403). These are shell-outs — they spend **no Claude/Anthropic usage credits** either. A full flagship fan-out is ~$0.10–0.20; the default free path is $0.

## Related

- `craft-commit` — reach for this before the commit step on non-trivial changes.
- `verify-work` — mechanical verification (tests/lint); this is the *judgment* cross-check. Do both on risky work.
- The full model panel is above ("The model panel"). Notes: skip `openai/gpt-oss-120b:free` (OpenAI-lineage, echoes Codex); on **429** (free-tier throttle) switch models, don't retry — free models on the same upstream provider (e.g. "Venice") throttle together, others sail through; on **403** the paid key needs credits + a raised spend-cap. Gemini CLI installed but its free OAuth is dead (2026-06-18) — reach Gemini via `openrouter/google/gemini-3.1-pro-preview` instead.
  - Free model IDs rotate — if one 404s, refresh: `curl -s openrouter.ai/api/v1/models | jq -r '.data[].id|select(endswith(":free"))'`.
