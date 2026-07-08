---
name: switch-claude
author: Vvkmnn
description: Use when switching Claude Code usage modes ("switch to pro/5x/20x mode", "conserve tokens", "full power"), OR managing models ("switch to fable/opus/sonnet", "use opus for this project", "set project model", "clear project model"). Modes = pricing plans; fable/opus/sonnet/haiku are model choices WITHIN a plan — there is no "fable mode". Global modes write ~/.claude/settings.json; project overrides write .claude/settings.local.json. Always shows a diff and confirms before writing any settings file.
version: 2.0.0
---

# Claude Model & Usage Modes

Two scopes, one skill. Argument: `$ARGUMENTS`.
- **Global mode** (`pro` | `5x` | `20x`) → `~/.claude/settings.json`
- **Project override** (`project <model>` | `project show` | `project clear`) → `./.claude/settings.local.json`

**Never write a settings file without showing the diff and getting confirmation.**

## Step 1: Research First (global mode switches only)

Run in parallel before applying:
1. `WebSearch`: "Claude Code token optimization best practices <current year>"
2. `WebSearch`: "Claude Code model effort subagent configuration <current year>"

Fold any NEW strategies into the tips output.

## Step 2: Detect Current State

```bash
jq '{model: .model, thinking: .alwaysThinkingEnabled, effort_env: (.env.CLAUDE_CODE_EFFORT_LEVEL // "unset (model default)"), subagent: (.env.CLAUDE_CODE_SUBAGENT_MODEL // "not set")}' ~/.claude/settings.json
```

| Detected | Mode |
|---|---|
| `fable`/`opus`/`sonnet` main model, thinking on, no conservation env | **20x** (any full-power model counts) |
| `model: "opusplan"` + effort medium + haiku subagents | **5x** |
| `model: "opusplan"` + effort low + haiku subagents | **pro** |
| Anything else | **Custom** — report it |

## Step 3: Apply Global Mode

### `pro` — maximum conservation ($20/mo)
```bash
jq '.model = "opusplan" | .alwaysThinkingEnabled = false | .env = (.env // {}) | .env.CLAUDE_CODE_EFFORT_LEVEL = "low" | .env.CLAUDE_CODE_SUBAGENT_MODEL = "haiku"' ~/.claude/settings.json
```
Tips: `/clear` between EVERY task; `/compact` at 50%; one task per session; `@file` refs over full reads; no subagents unless essential; sessions timed to 5h resets; quota shared with claude.ai.

### `5x` — max ROI
```bash
jq '.model = "opusplan" | .alwaysThinkingEnabled = false | .env = (.env // {}) | .env.CLAUDE_CODE_EFFORT_LEVEL = "medium" | .env.CLAUDE_CODE_SUBAGENT_MODEL = "haiku"' ~/.claude/settings.json
```
Tips: subagents for exploration; `/clear` between unrelated tasks; avoid agent teams; `/effort` bump for hard problems only.

### `20x` — full power (current plan). 20x is the PLAN, not a model.
```bash
# Optional model argument: /switch-claude 20x [opus|fable|sonnet] — default keeps current model
jq --arg m "$MODEL_CHOICE" '(if $m != "" then .model = $m else . end) | .alwaysThinkingEnabled = true | (if .env then .env |= (del(.CLAUDE_CODE_SUBAGENT_MODEL) | del(.CLAUDE_CODE_EFFORT_LEVEL)) else . end)' ~/.claude/settings.json
```
Model choice WITHIN 20x:
| Model | Reach for it when | Notes |
|---|---|---|
| `opus` (4.8) | **Daily default** — complex work, planning, review | `/fast` capable; best quota-per-quality; same 1M/128K as Fable |
| `fable` | **Special cases** — hardest long-horizon runs Opus xhigh can't crack | Thinking always-on. Since 2026-07-08: draws **usage credits**, not included limits (top up in account settings). Via API instead: set ANTHROPIC_API_KEY (takes precedence over subscription; `/status` shows route; $10/$50 = 2× Opus). $-stretching playbook: docs/CONFIG.md Fable Economics |
| `sonnet` (5) | High-volume grunt work, big mechanical sweeps | Near-Opus on agentic coding since Sonnet 5 |

Quota fact worth exploiting: cache reads don't count against rate limits, and subscription sessions get a 1-hour cache TTL — warm sessions stretch every tier.

Universal on 20x regardless of model: thinking on, effort default high (`/effort xhigh` for the hardest work), subagents auto-route down-tier (Explore caps at Opus), agent teams for competing-hypothesis debugging only (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`), watch statusline λ/μ/θ for quota pacing — optimize tokens-into-results, not $.

**Per-session `/model` switch (runtime — writes NOTHING).** `/model fable|opus|sonnet` changes just the live session; this skill's modes above write persistent settings. When you switch mid-session, the dials cascade per the **[Model Operating Matrix](../../docs/CONFIG.md)** (Claude re-dials proactively — see `orchestrate.md` AUTO-RE-DIAL): **effort** is the live tuning knob (`/effort` low/high/xhigh, model-relative); **subagent model** is chosen per-dispatch (never the `CLAUDE_CODE_SUBAGENT_MODEL` env — it's a blunt override that clobbers your per-agent frontmatter pins); thinking just inherits (no per-subagent dial, Fable always-on). Fable = credits since 07-08, so a session on Fable is a deliberate spend.

Apply pattern for every jq: write to `"$(mktemp)"`, validate `jq .`, show diff vs original, confirm with user, then move into place. Restart session for model changes.

## Step 4: Project Overrides (absorbed from configure-project)

Hierarchy: project local (`.claude/settings.local.json`) → project shared (`.claude/settings.json`) → user global.

- **`project <model>`** ("use opus for this project"): `mkdir -p .claude`; read existing settings.local.json (preserve all fields); set `"model"`; valid: `fable`, `opus`, `sonnet`, `haiku`, `opusplan`, `default`, or full IDs. Write with 2-space indent. Auto-gitignored by Claude Code.
- **`project show`**: report `"model"` from `.claude/settings.local.json`, or "using global default".
- **`project clear`**: remove `"model"` field, preserve others; delete the file if it becomes `{}`.

## Reference: Models (July 2026)

| Alias | Resolves to | $/MTok in→out | Best for |
|-------|-------------|--------------|----------|
| `fable` | Fable 5 (1M ctx default) | $10 → $50 | Hardest reasoning, long-horizon agentic; thinking always-on |
| `opus` | Opus 4.8 (1M) | $5 → $25 | Complex reasoning; `/fast` capable |
| `sonnet` | Sonnet 5 (1M) | $3 → $15 | Daily coding; near-Opus on agentic work |
| `haiku` | Haiku 4.5 (200K) | $1 → $5 | Deterministic search, summaries |
| `opusplan` | Opus plans + Sonnet executes | mixed | Conservation hybrid (pro/5x) |

`opusplan[1m]` keeps 1M context in plan mode. Prompt caching ≈90% discount, automatic.

## Reference: Effort (`low`→`max`)

| Level | Use |
|-------|-----|
| `low` | Chores, renames, lookups |
| `medium` | Cost-sensitive routine work |
| `high` | Default — most work |
| `xhigh` | Hardest coding/agentic (Fable/Opus 4.8 sweet spot) |
| `max` | Correctness over cost, latency-insensitive |

Set per-session with `/effort`; per-agent/skill via `effort:` frontmatter; hooks see `$CLAUDE_EFFORT`.

## Reference: Context Conservation

`/clear` between tasks (biggest saver) · `/compact Focus on [topic]` at ~50% · `@file` refs over full reads · subagents for exploration (separate context) · `/context` + `/usage` to monitor · stay out of the last 20%.

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.0.0 | 2026-07-06 | Fable 5 era rewrite (models/pricing/effort tables); absorbed configure-project (project overrides); replaced phantom `effortLevel` settings key with env.CLAUDE_CODE_EFFORT_LEVEL; enabled auto-invocation with confirm-before-write |
| 1.x | 2026-03 | Opus 4.6-era modes (archived in git history) |
