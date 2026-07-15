# CHANGELOG — The Log

> One living document: what's coming (Upcoming), what's parked for a trigger (Reference), and the dated record of everything tried, considered-but-not-tried, and found — newest first. Superseded decisions stay verbatim: the reasoning is the value. Current state: [README](../README.md) · operations: [CONFIG.md](CONFIG.md).

## Upcoming

- **Telemetry check-in (~2026-08-14, ~1mo)** — verify `telemetry-*.jsonl` is still growing on every fleet host, run the `analyze-usage` skill on a real month of data (does per-session cost + `session_name`/`why` read well?), and add monthly gzip rotation if any host's ledger > ~20 MB. Also confirm the τ heartbeat still blinks. The weekly `improve-claude` cloud routine reviews this Upcoming list, so it surfaces on its own — no separate cron. Built 2026-07-14 (see entry below).
- **Statusline next iteration** (from Reddit research 2026-07-06): block/weekly reset countdown clocks, tokens-until-autocompact, cacheTimer (5-min prompt-cache TTL warning) — real gaps, deferred from v2 to keep the line calm
- **Playwright CLI** (`@playwright/cli`) — named fallback if a task defeats agent-browser (cross-browser, video, tracing); install the day it's needed, not before
- **OTel telemetry** (`CLAUDE_CODE_ENABLE_TELEMETRY=1`) — blind spot for fleet/overnight runs; ColeMurray/claude-code-otel dashboard optional
- **anthropics/skills marketplace** — first-party skills land there first (canvas-design fills a real visual gap)
- **claude-code-ship-gate** — would upgrade verify-work from advisory to enforcing pre-push gate; evaluate against consolidation direction first
- **Deregister `interface-design` marketplace** — repo 404s (verified 2026-07-05); autoUpdate silently no-ops. Reference entry below kept for the record
- **~/.ai TODO** (deferred 2026-07-06, was out of scope): phase_claude in ~/.ai/setup (launchctl bootstrap proxy, skill submodules, plugin verify, /login gate) + phase_doctor probes (claude/statusline/port-9090); fold agent-browser + ast-grep into package list
- **eve/claude-emporium statusline** — TODO note pending in that project's README (Fable → F glyph; see ~/.claude/statusline.sh reference implementation)
- **Noted, not adopted** (2026-07-05 paradigm scan): Claude Squad orchestrator (if manual worktrees outgrow), agentmemory/claude-mem (conflicts with native-first memory), lazy-senior-dev token-diet output style (cheap experiment)
- **Unverified plugin leads** (2026-07-06 discovery sweep degraded by rate limits — agent admitted synthesizing; star counts/repos NOT verified, do not install without checking): hivemind (trace→skill generation), context-compression-lite, mcp-memory-augmented. Verify existence + adoption before considering
- **¢ statusline field-shape verification** — after the first real credit spend (post 07-08 Fable session), check `jq '.extra_usage' ~/.claude/status/rate_limit.json` against the defensive field list in statusline.sh `_parse_rate_json`; adjust if the real key differs
- **apple-gtd restructure** — 439 lines, only owner skill over the ≤425 budget (verification sweep 2026-07-06); same move-to-references/ pattern as the other four
- ~~**Voice**~~ **RESOLVED 2026-07-06 — native /voice WORKING.** Root cause was double: skhd globally intercepted ⌥K (`.skhdrc:106` yabai focus-north, unused — released with annotation) AND the live tmux server predated the `extended-keys on` config (applied live; hold-to-talk needs key-release forwarding). Diagnostic that cracked it: `/bin/cat -v` printing nothing = chord swallowed upstream of every app. SuperWhisper fallback stays documented (one license = unlimited devices, lifetime ~$249.99 reverify) but not needed. Fleet note: vbookneo's tmux server needs the same live `set -s extended-keys on` or a restart after config sync

## Reference (enable when needed)

### Legacy (from ~/.claude.old)

Location: `~/.claude/legacy/`

Contains old commands and hooks from July 2025 setup:
- `commands/`: backup, check, commit, install, learn, plan, pull, sync, test
- `hooks/`: notification.js, post-tool-use.js, pre-commit-validation.js, pre-compact.js, pre-tool-use.js, stop.js, subagent-stop.js
- `CLAUDE.old.md`: Previous CLAUDE.md format
- `MCP.md`: Old MCP documentation

Review when time permits - may contain useful patterns to integrate into current plugin-based setup.

### Dora (Code Navigation, per-project)

Fast symbol lookup, dependency tracing, reference finding. Set up when exploring a codebase extensively.

```bash
cd ~/project
dora init                    # Creates .dora/
# Edit .dora/config.json with language indexer (see below)
dora index                   # Build initial index
```

**Indexer config** (`.dora/config.json`):

| Language | Config |
|----------|--------|
| TypeScript/JS | `{"commands": {"index": "scip-typescript index --output .dora/index.scip"}}` |
| Python | `{"commands": {"index": "scip-python index --output .dora/index.scip"}}` |
| Rust | `{"commands": {"index": "rust-analyzer scip . --output .dora/index.scip"}}` |
| Lua | `{"commands": {"index": "scip-lua index --output .dora/index.scip"}}` |

**Usage**: `dora symbol <name>`, `dora refs <symbol>`, `dora deps <path>`, `dora map`

**Re-index after significant changes**: `dora index`

### Interface Design (Dammyjay93)

> Annotation 2026-07-06: repo 404s (ecosystem audit 2026-07-05) — deregistration is in Backlog. Entry kept for the record.

Design system consistency for UI work.

```bash
claude plugin marketplace add Dammyjay93/interface-design
claude plugin install interface-design@Dammyjay93
```

### Snyk MCP (Security Scanning)

> Annotation 2026-07-06: the snippet below targets `~/.utcp_config.json` — the code-mode era config (retired 2026-02-01, see Historical). If adopting Snyk today: add to `~/.claude/mcp/config.json` `mcpServers`, then register via `claude mcp add <name> <url> --transport http -s user --header "Authorization: Bearer <token>"` (see the MCP section of CONFIG.md). Snippet kept for the record.

Local vulnerability scanning. Requires Snyk account and API token.

1. Get token: https://app.snyk.io/account
2. Add to `~/.utcp_config.json` (code-mode):

```json
{
  "mcpServers": {
    "snyk": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-snyk"],
      "env": {
        "SNYK_TOKEN": "<your-token>"
      }
    }
  }
}
```

### External Services (Enable When Needed)

These require accounts/API keys:

| Plugin | Purpose | Setup |
|--------|---------|-------|
| sentry@claude-plugins-official | Error monitoring | Sentry API token |
| vercel@claude-plugins-official | Deployment | Vercel account |
| slack@claude-plugins-official | Team comms | Slack app token |
| figma@claude-plugins-official | Design-to-code | Figma API token |
| stripe@claude-plugins-official | Payments | Stripe API keys |
| huggingface-skills | AI models | HF token |

### Domain-Specific (Enable Per Project)

| Plugin | Use Case |
|--------|----------|
| llm-application-dev | LangGraph, RAG, vector search |
| observability-monitoring | Prometheus, Grafana |
| data-engineering | ETL, dbt, Airflow |
| c4-architecture | Architecture diagrams |

### Trail of Bits Security Research (2026-02-02)

Marketplace added but plugins not installed. Specialized for security research (not typical app security).

```bash
/plugin marketplace add trailofbits/skills  # Already done
```

**Available plugins** (install when doing security research):
- `static-analysis` - CodeQL + Semgrep bindings
- `variant-analysis` - Find code similar to known vulns
- `constant-time-analysis` - Crypto timing side-channels
- `property-based-testing` - Hypothesis-style fuzzing
- `yara-authoring` - Malware detection rules
- `dwarf-expert` - Binary/debug info analysis
- `burpsuite-project-parser` - Web pentesting workflow
- `building-secure-contracts` - Solidity/smart contracts

**Note:** Repo may not follow Claude Code plugin format. Check structure if install fails.

### Additional claude-code-workflows Plugins (2026-02-02)

> Annotation 2026-07-06: `debugging-toolkit` and `git-pr-workflows` have since been installed and are active — rows kept, marked.

Already have: security-scanning, cicd-automation, database-design, python-development, javascript-typescript, systems-programming, backend-development, tdd-workflows, unit-testing.

**Install when needed:**

| Plugin | Use Case |
|--------|----------|
| `debugging-toolkit` | Systematic debugging agents (installed since) |
| `error-debugging` | Error pattern analysis |
| `git-pr-workflows` | PR creation/review workflows (installed since) |
| `code-refactoring` | Structured refactoring |

```bash
/plugin install debugging-toolkit@claude-code-workflows   # done
/plugin install error-debugging@claude-code-workflows
/plugin install git-pr-workflows@claude-code-workflows    # done
/plugin install code-refactoring@claude-code-workflows
```

### Cost Tracking (When Needed)

```bash
npm install -g ccusage
ccusage  # Shows cost breakdown per session/project
```

Only relevant for API usage, not subscription. (The statusline `$` segment covers the API-equivalent view since 2026-07-06.)

## Settings & Plugins

> Adopt-when triggers, evaluate queues, and the disabled-plugin catalog live in [CONFIG.md](CONFIG.md) (Settings + Plugins sections) — they're configuration reference, not backlog.

---

## Current State (as of 2026-07-06)

- **Model**: no `model` key = Default (Opus 4.8 + auto-Sonnet fallback on Max 20x); Fable 5 per-session via `/model`
- **MCP**: TBXark proxy on :9090, Bearer-auth gated, 14 active / 12 parked (`disabledServers` in mcp/config.json)
- **Skills**: 19 owner (6 groups) + 10 vendored; retired versions in `skills/.archive/`
- **Agents**: 5 (architect, code-reviewer, security-reviewer, debugger, paper-researcher) — commands dispatch explicitly
- **Hooks**: 9 events wired; statusline v2 (`ॐ` vim-state anchor, κ/$ segments, λ clamp)
- **Plugins**: 27 enabled (see `docs/CONFIG.md` Plugins section)
- **Maintenance**: `improve-claude` (8 phases incl. weekly cloud routine via /schedule; budgets encoded)

---

## 2026-07-14: Local telemetry ledger — recycle the probe, save 110%

**Built.** `~/.claude/status/telemetry.jsonl` — append-only JSONL usage history, one flat row per fresh haiku probe (~2–3 min; idle adds nothing, deduped by `_fetched_at`). **Zero extra API calls:** recycles the probe's rate-limit headers + this render's stdin, both of which were being discarded. **Self-contained** — carries Anthropic's own `total_cost_usd`/token/line numbers straight from stdin, so **no ccusage dependency, no transcript re-parse** (learned from ccusage's transcript approach, deliberately didn't adopt it — self-containment + Anthropic's own numbers beat a LiteLLM estimate). Gitignored (`status/`), secret-free.

- **New headers harvested** (same ping, `statusline.sh` `_refresh_rate_limit`): `unified-5h/7d-status` + `-representative-claim`, written into `rate_limit.json` and each ledger row. Verified via a raw OAuth header capture (CodexBar #1894): the `unified` family exposes **no absolute limit/remaining header** — allowance changes can only be *inferred* from `utilization ÷ cost`, which is the whole reason to log utilization live.
- **Schema** (`v:1`, RAW/unbiased — owner: "no bias, raw true data for perfect future analytics"): thin envelope `{v, ts, host}` + `rl` (the whole `rate_limit.json`) + `in` (the whole statusline stdin payload verbatim — vim, transcript_path, cost, context_window, everything). Nothing dropped/flattened/renamed at capture; flatten at read time. Reverted an earlier curated-flat-scalar shape (that curation was itself bias). Full detail in CONFIG.md → Telemetry ledger.
- **τ heartbeat** — dim = armed, gold when the rate sample is fresh (~every 2min). Keyed to freshness (`rate_content_age < 40`), NOT to "this render appended" — the ledger is shared across sessions, so an append-flag would only ever fire in whichever session won the race; freshness is true in every session at once.
- **Cross-fleet + encrypted (same day, pm):** per-host files `telemetry-<host>.jsonl` + a `host` field in every row → the ledgers sync via the dotfiles repo with **no merge conflicts** (each machine owns its file); aggregate the fleet by globbing `telemetry-*.jsonl`. **git-crypt-encrypted at rest** (`.gitattributes: .claude/status/telemetry-*.jsonl`), un-ignored from `status/*`; runtime caches (`rate_limit.json`/`weekly_activity.json`) stay gitignored. Owner wanted a private, real, cross-everything history.
- **Zero-latency gate:** `_append_telemetry` bails on `rate_content_age < 40` — ~80% of renders are one integer test, no subprocess (owner constraint: no impact on perf/cost/latency).
- **What/why** (topic per session) = derived on demand from transcripts joined by `sid` — no live capture, zero runtime cost. A report/skill that surfaces it is the deferred pass.
- **Deferred** (plan `plans/the-stautsline-seems-like-starry-karp.md`): analysis/report (7×24 hour×day heatmap, per-project/model leaderboard, burn-rate + reset ETA, cache-hit trend, limit-drift detector, what/why topics) + a report skill wired into improve-claude/switch-claude; monthly rotation+gzip when the files grow (~30–50 MB/yr each).
- Partially closes the **OTel "blind spot"** Upcoming item for the local/solo case — OTel's collector+Prometheus+Grafana stack is overkill; this is the lean local answer. OTel stays parked for fleet aggregation.

## 2026-07-11: Auto-compaction retune — the 07-09 experiment over-corrected

Owner: *"compacting way too often, really annoying."* The 07-09 experiment (below) set `CLAUDE_CODE_AUTO_COMPACT_WINDOW=400000` + `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=70` in `settings.json` env → compaction at ~70%×400K ≈ **280K = ~28% of the real 1M Opus window**. On heavy `~/.claude` sessions the baseline (system prompt + skills + plan + memory) leaves a tiny runway before 280K → constant compaction.

**The experiment answered its question — and revealed the value was wrong.** It was flagged *"does settings.json `env` get honored despite #63186?"* Answer: **yes, honored** (if ignored, compaction would fire near 1M and there'd be no complaint). But the value **over-corrected** — swung from the old "carry 1M forever" mistake straight to "compact at 28%", the opposite failure. Two facts reframe it: (1) both vars are **UNDOCUMENTED** — verified absent from `code.claude.com/docs/costs` this session; steering compaction with two magic internal numbers is version-fragile. (2) On a flat Max-20x sub, carrying context is **~$0** (cache reads don't count vs rate limits, 1h TTL) — "compact early to save resources" optimizes a cost the owner isn't billed while paying real ones (summary rot + wall-clock + annoyance). The genuine lever was always **`/clear` at task boundaries**, not auto-compaction tuning.

**Decision — REMOVE the hack.** Deleted the `settings.json` env block + the `.profile` commented fallback. Auto-compaction reverts to native (fires only near ~1M); `/clear` + manual `/compact` are the levers. No magic numbers, no undocumented-knob dependency. Verify (owner, fresh session): statusline `ψ`/context% should no longer compact near ~280K — only near ~1M or not at all in a normal session.

## 2026-07-11: Second-opinion audit — fact-corrections to this session's "verified" claims

A full-scope re-verification of the decisions made this session (owner: "more subagent research and second opinions on everything fable did"). The audit engine had to **pivot**: `codex exec` HANGS in this environment — 3 foreground attempts (xhigh, high, a trivial "reply OK" probe) all produced zero output with a wedged process left behind, refuting the second-opinion skill's "foreground is the reliable path" claim; the free OpenRouter `llm` panel was resource-exhausted (429). The engine that worked: **fresh-context Claude subagents + primary-source re-verification**. Four durable "verified" claims were corrected against `platform.claude.com/docs/en/model-config` and `.../api/rate-limits`:

- **`effortLevel` is a real settings key, NOT a phantom.** Doc: *"Settings: set `effortLevel` to low/medium/high/xhigh in your settings file"* (`max`/`ultracode` session-only). This session had marked "effortLevel=phantom" VERIFIED and used it to justify the statusline change. The statusline behavior is still correct (its stdin payload carries live `.effort.level`, not the settings key) — only the *justification* was wrong. Fixed CONFIG.md:25, statusline.sh comment, switch-claude version-note. (Supersedes the "phantom effort key" phrasing in the 2026-07-06 entry below — the bug was real, the diagnosis wasn't.)
- **effort frontmatter works on skills AND subagents** (doc), not "agents only" — and NOT on commands (that's model frontmatter). Fixed CONFIG.md:25, health-checks.md.
- **ultrathink / ultracode are documented** (resolves the standing "UNDOCUMENTED — verify first" hedge, audit #6). `ultrathink`: per-turn keyword, adds an in-context instruction, API effort unchanged, model-agnostic. `ultracode`: session-only setting sending `xhigh` + dynamic-workflow orchestration, v2.1.203+. Fixed CONFIG.md:26, orchestrate.md:42.
- **"Cache reads don't count against rate limits" is TRUE and now SOURCED** — the audit's own subagent flagged it "unsourced/soften," but the rate-limits doc's "Cache-aware ITPM" section confirms it for every model we use (only retired Haiku 3.5 counts them). Added the missing nuance: cache **writes** (`cache_creation_input_tokens`) DO count, so breaking a stable prefix isn't free. Sharpened CONFIG.md:84. *(Lesson: a subagent's "NOT FOUND" is a lead to re-check, not a verdict — verify.md catches false negatives too.)*

**Held up (Fable was right):** subagent-model precedence, autocompact mechanics (the 07-09 fix), Fable $10/$50 + always-on thinking, 1h cache TTL on subs. **Still pending:** the 6-cluster full audit (config/rules/skills/hooks/docs) via subagents; second-opinion skill fix; settings.json `opusplan`/`opus` reconcile.

## 2026-07-09: Proactive auto-compaction — reversing the "protect 1M" mistake

Reverses the 2026-07-06 decision to skip `CLAUDE_CODE_AUTO_COMPACT_WINDOW` / `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`. That call ("would gut 1M sessions") was the root cause of the ~2-day, no-`/clear`, ~1M-context-every-turn session — it optimized retention over efficiency. Codex/GPT-5.5 second opinion, blunt: *"a 1M window is an emergency reserve, not a cruising altitude."*

**Verified (official env-vars doc + gh #31806/#52390/#63186/#70477):** local Opus 4.8 (1M) auto-compacts ONLY near the ~1M limit by default — there was never a window to protect; proactive compaction had to be turned ON. `PCT_OVERRIDE` alone is a no-op without `WINDOW` also set (#52390); override can only LOWER (#31806); and settings.json `env` may be ignored for these vars — some reports say they must be shell-exported (#63186).

**The fix:** `CLAUDE_CODE_AUTO_COMPACT_WINDOW=400000` + `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=70` → compaction at ~70% of 400K ≈ **280K instead of ~1M**. Pair with `/clear` discipline.

**ACTIVE EXPERIMENT (owner watching):** set in **settings.json `env` first** to test whether that path is honored despite #63186. `.profile` has a commented fallback: if compaction still only fires near 1M in a fresh session, shell-export the two vars there instead. Test = a NEW session (env loads at launch), then watch statusline `ψ` for compaction near ~28% (280K) rather than ~1M.

> **RESOLVED / SUPERSEDED 2026-07-11:** experiment concluded — settings.json `env` IS honored (#63186 didn't bite), but 280K over-corrected (too frequent on 1M; owner: "compacting way too often"). Both vars REMOVED; reverted to native auto-compaction + `/clear` discipline. See the 2026-07-11 "Auto-compaction retune" entry above.

## 2026-07-06: Deep Upgrade — catalog restructure, subagent v2, MCP fleet, statusline v2

The largest single-day overhaul (plan: `plans/enchanted-pondering-taco.md`, 27/42 items). Decisions at ADR level:

- **Skill catalog 25→19** in 6 named groups; merges: 5 maintenance skills → `improve-claude` (7 phases incl. new parity phase for fleet + iOS/macOS/web), research-agents + study-claude → `research-topics`, configure-project → `switch-claude` v2. Six renames to strict `<verb>-<noun>` (verify-work, isolate-tmux, craft-commit, setup-dotfiles, inspect-web; agent study-researcher → paper-researcher). Originals archived with versions in `skills/.archive/`.
- **Subagent system v2** — root cause of shelf-ware roster was WIRING (0 dispatches ever vs Explore's 254): commands now explicitly dispatch via Agent tool; added `debugger` agent; orchestrate.md corrected (3 stale claims) + async-delegation + model/effort routing. Architect reverted to read-only (advisory contract beat the day-old Write/Edit grant).
- **MCP fleet 26→14 (CLI-first)** — 12 parked reversibly after log-mining + per-server user decisions: dead (railway, supabase, google_drive), native-covered (sequential_thinking, memory, fetch, duckduckgo, chrome_devtools), CLI-covered (tmux, applescript, yt_dlp, github→gh). Proxy hardened: `authTokens` Bearer gate (401 verified), `logEnabled:false` + 89MB access-log truncated, restart docs corrected to `launchctl kickstart`.
- **New CLIs**: `agent-browser` (research-verified best-in-class, 200-400 tok/page) + `ast-grep`. Playwright CLI = named fallback, not installed.
- **Statusline v2** — F glyph, live effort/thinking superscripts, λ clamped ≤100 (fixes 103% + negative-runway ⁻⁰·¹ bugs), κ cache-hit, ¹ᴹ window marker, $ value far-right, ॐ = vim-state anchor (orange/green/gold; pairs with `hideVimModeIndicator` — our issue #16788 shipped). `STATUSLINE_MINIMAL=1` = early-warning display.
- **Hooks 5→9 events**: user-prompt-submit (per-turn branch/plan/type), subagent telemetry (stderr-only); session-start reads `.last-maintenance`.
- **Model strategy**: 20x is the PLAN, models are choices within it — no "fable mode". Default daily; Fable special cases. `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` deliberately SKIPPED (would gut 1M-context sessions).
- **Docs**: README.md created (architecture map + 3 principles); this file restructured (was category-grouped with duplicate headers → single timeline); custom docs consolidated to 4 files (README + PAST + FUTURE + MCP — PLAYBOOK/SETTINGS/PLUGINS content absorbed, files retired).
- **Settings every-key triage** (doctrine: minimize governs code quality, NOT feature adoption): 4 adopted same-day (statusLine.refreshInterval 30, inputNeededNotifEnabled, terminalProgressBarEnabled, showTurnDuration); deliberately SKIPPED with reasoning — autoCompactWindow/PCT-override (guts 1M sessions), persisted effortLevel + fastMode (session-scoped /effort //fast beat sticky globals), disableClaudeAiConnectors (keep cross-surface connectors), enableAllProjectMcpServers (blanket trust), enterprise/policy + @internal keys (solo operator / unsupported). Adopt-when + evaluate queues live in CONFIG.md Settings section.
- **Structural gaps closed** (benchmark scan: only 3 real gaps in our layout): `workflows/` created (native Dynamic Workflows), `agents/explore.md` (name-shadows built-in Explore to pin scans to haiku — the name is the mechanism), output-styles judged overlap with CLAUDE.md tone (skipped). Everything else community setups carry, we cover with named equivalents.

**Tried**: everything above, plus — agent `<example>` blocks as raw frontmatter XML (broke YAML, deregistered 3 agents; fixed via block-scalar) · CronCreate for the weekly routine (session-only — wrong tool; /schedule is the real one) · early-warning statusline hiding as default (reverted to show-everything per preference; kept as `STATUSLINE_MINIMAL` opt-in).

**Considered, deliberately NOT tried (and why)**: VoltAgent-style JSON agent protocols (team-pipeline overkill; Fable degrades on over-prescription) · community chief-agent orchestration charter (Fable delegates well when told simply; stole only return-contracts) · Playwright CLI install (named fallback for the day agent-browser loses a fight) · output-styles/ presets (overlap CLAUDE.md tone) · autocompact override at 70% (would gut 1M sessions) · agent teams as default review (fragile, no /resume; competing-hypothesis debugging only) · test-writer agent (skills cover it) · per-topic docs layout (consolidated to CHANGELOG+CONFIG instead) · claude-mem/agentmemory (native-first memory won).

**Might try** (queued in Upcoming + CONFIG Settings queues): statusline reset-countdown / tokens-to-compact / cacheTimer segments · OTel telemetry · anthropics/skills marketplace · ship-gate enforcing verify · autoDream + autoUploadSessions · worktree fleet keys + teammateMode:tmux · Fable-via-usage-credits workflow after 2026-07-08 (first paid session calibrates the $-stretching playbook).

**Scorecard (before → after, structure not line-deletion — keep-doctrine means nothing was destroyed):**

| Surface | Before | After |
|---|---|---|
| Owner skills | 25 (3 commit paths, trigger collisions, 5-way maintenance sprawl) | 19 in 6 groups, 9 versioned archives |
| Agents | 4, zero dispatches ever, broken frontmatter | 6 (5 professions + Explore-haiku override), wired to dispatch, memory/effort/skills routed |
| MCP servers | 26 open on :9090, 92MB log firehose | 14 active behind Bearer auth, parks reversible, log silent |
| Hooks | 5 events | 9 events (+per-turn context, subagent telemetry) |
| Custom docs | 7 scattered files w/ duplicate headers + stale claims | 3: README (state) + CHANGELOG (log) + CONFIG (ops) |
| Plugins | 27 | 24 (3 native-covered retired; emporium untouched + improvement notes filed) |
| Oversized skills | 4 over budget (1409 max) | All ≤422 decision-layer, content verbatim in references/ |
| CLIs | — | +agent-browser (verified best-in-class), +ast-grep |
| Statusline | 3 bugs (phantom effort key, λ>100%, negative runway), no Fable | v2: fixed math, vim-anchor ॐ, κ/¹ᴹ/$/¢ segments |
| Disk | 89MB log + 17 debris files | reclaimed |

**Verification (same day, spent the last included-Fable on it):** two fresh-context audit agents swept the full change set; the author session cross-checked both. Real catches, fixed: improve-claude Phase 8 runbook section had silently failed to land (a mid-session Edit error — re-applied, order verified 1-8); owner-skill count is 19 not 18 (corrected in three docs); budgets recalibrated to post-doctrine reality (CLAUDE.md ≤160, owner skills ≤425, vendored exempt); apple-gtd queued as the one remaining over-budget owner skill. Auditor false alarms, rejected with evidence: "0 active MCP servers" (config holds 14, proxy 200 — mis-query), "28 plugins" (24 true, counted disabled keys), "paper-researcher YAML broken" (2 delimiters, registered), statusline "accepts malformed JSON" (fail-open is the design), stale-ref hits in plans/CHANGELOG/memory (historical records keep era-true paths by doctrine). Lesson recorded: verify the verifiers — fresh eyes catch author blindness AND generate their own.

**Restore**: everything is in dotfiles git history + `skills/.archive/`; MCP parks reverse per the CONFIG.md fleet table.

---

## 2026-03-17: MCP Server Fixes and Additions

**Changes:**
- **Reddit**: Switched from `reddit-mcp-buddy` (blocked by Reddit API changes) to `reddit-mcp-server` with OAuth credentials (client_id + client_secret from reddit.com/prefs/apps)
- **Twitter/X**: Switched from `agent-twitter-client-mcp` (cookie/credential auth both broken) to `@practicaltools/twitter-mcp-server` via Apify. Uses existing Apify token — free tier covers ~50k searches/month
- **YouTube**: Added `@kirbah/mcp-youtube` with YouTube Data API v3 key. Complements yt_dlp (search vs transcript extraction)
- **Firecrawl**: Added API key (free tier, 500 credits one-time)
- **Apify**: Added API key (free tier, $5/month credits)
- **Supabase/Railway**: Left with placeholder keys (not currently used)

**Architecture:** All MCP servers route through `mcp-proxy` gateway on localhost:9090. Config: `~/.claude/mcp/config.json`. Claude Code connects via `~/.claude.json` HTTP entries.

**Reference:** `~/.claude/mcp/MCP.md` — full server inventory
**Credentials backup:** `~/.claude/mcp/credentials.txt`

**To restore old Twitter:** See credentials.txt for cookie and credential auth configs. Cookie auth works but expires frequently. Credential auth returns error 34 on new accounts.

---

## 2026-03-17: Max 20x Optimization (63 → 27 plugins)

**Previous:** 63 plugins enabled, model unset, git instructions on
**Current:** 27 plugins enabled, model: "opus", includeGitInstructions: false, filesystem Read denies added

**Changes applied:**
- Disabled 36 plugins (15 Trail of Bits, 7 redundant, 14 zero-usage workflow)
- Added `model: "opus"` (fixes switch-claude 20x detection)
- Added `includeGitInstructions: false` (~2k token savings, covered by commit-commands plugin)
- Added Read denies for `~/.ssh/*`, `~/.aws/*`, `~/.env*`, `~/.gnupg/*`
- Updated `orchestrate.md` with Language Skills invoke triggers
- Kept ralph-loop (6 sessions/5 projects confirmed), code-simplifier (2 sessions confirmed)
- Kept python-development, javascript-typescript (fixed root cause of non-invocation in orchestrate.md)

**Evidence:** Direct JSONL search across 794 session files (historian search has gaps — zero results doesn't mean zero usage).

**Reference:** `~/.claude/analysis/PLUGINS_DISABLED.md` — full catalog with re-enable guidance
**Plan:** `plans/groovy-pondering-flamingo.md`

**To restore:** Backup not needed — set any plugin back to `true` in settings.json. See PLUGINS_DISABLED.md for what each does.

---

## 2026-02-02: Best-in-Class Claude Code Setup Comparison

**Sources analyzed:**
- Reddit r/ClaudeAI (V4 guide, 25 tips, 6-month retrospective posts)
- GitHub awesome-claude-skills, VoltAgent, Trail of Bits, obra/superpowers
- Dev blogs, Hacker News, Medium articles on Claude Code optimization

**Current setup vs community best practices:**

| Feature | Our Setup | Community Best | Status |
|---------|-----------|----------------|--------|
| `mcpToolSearch: "always"` | ✓ | ✓ 85% context reduction | Done |
| Custom keybindings | ✓ 7 shortcuts | ✓ V4 feature | Done |
| Comprehensive hooks | ✓ 5 types | ✓ Core workflow | Done |
| superpowers plugin | ✓ | ✓ 27.9k stars | Done |
| continuous-learning-v2 | ✓ | More advanced than Claudeception | Done |
| claude-historian MCP | ✓ | ✓ Session memory | Done |
| Privacy env vars | ✓ Added | ✓ | Done |

**New additions (2026-02-02):**
- Added to `~/.profile`:
  ```sh
  export CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1
  export DISABLE_TELEMETRY=1
  export DISABLE_ERROR_REPORTING=1
  ```

**Evaluated but skipped:**

| Tool | Reason Skipped |
|------|----------------|
| claude-mem | Already tried, RAM issues (see 2025-12-26 entry) |
| SuperClaude Framework | Heavy overlap with superpowers |
| Claude-Flow | Overkill unless doing swarm orchestration |
| ccusage | Optional cost tracking, install later if needed |
| Maestro | Only if running 5+ parallel sessions |

**Key community insights:**
- Boris (Claude Code creator) runs "surprisingly vanilla" setup
- Plugin stacking burns ~8k tokens on tool definitions before first prompt
- Skill hot-reload (v2.1+): Skills in `~/.claude/skills/` auto-reload
- Custom compaction: `/compact Focus on X` tells Claude what to preserve
- `context: fork` in skill frontmatter for isolated sub-agent context

**Resources discovered:**
- [SkillsMP](https://skillsmp.com/) - 71K+ community skills
- [skills.sh](https://skills.sh) - Skill browser
- [Trail of Bits](https://github.com/trailofbits/skills) - 23 security plugins
- [ccusage](https://ccusage.com/) - Cost tracking CLI
- [AgentDepot](https://agentdepot.dev) - Searchable skills/plugins directory

**Conclusion:** Setup already top-tier. Main gaps were privacy vars (now added).

---

## 2026-02-01: Migrated from code-mode to native MCP

**Previous:** All MCP servers proxied through code-mode UTCP (`@utcp/code-mode-mcp`)
**Current:** Native MCP servers in `~/.claude.json` (git-crypt encrypted)

**Reason:** Native MCP Tool Search provides better performance
- 85% token reduction with lazy loading (10K threshold)
- +8.6% accuracy improvement on Opus 4.5
- No reconnection bugs ([Issue #20684](https://github.com/anthropics/claude-code/issues/20684))
- Simpler architecture (one less MCP server layer)

**Lost features:**
- `call_tool_chain` - TypeScript tool chaining in single execution
- `register_manual` - Dynamic server registration without restart
- `search_tools` - Manual tool search (replaced by native tool search)

**Preserved:**
- `~/.utcp_config.json` kept as reference (git-crypt encrypted)
- Backup at `~/.claude/backups/.claude.json.20260201-pre-native-mcp`

**To rollback:**
```bash
cp ~/.claude/backups/.claude.json.20260201-pre-native-mcp ~/.claude.json
# Restart Claude Code
```

**Sources:**
- [Anthropic Tool Search Docs](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-search-tool)
- [MCP Tool Search Guide](https://www.atcyrus.com/stories/mcp-tool-search-claude-code-context-pollution-guide)

---

## 2026-01-30: code-mode vs Native MCP analysis (decision reversed 2026-02-01)

> Moved here from FUTURE.md's Historical section during doc consolidation — superseded decisions live in PAST. The "keep code-mode" call below was reversed two days later (see 2026-02-01 entry above). Trade-off table kept verbatim: it remains a good template for aggregator decisions.

**State then:** 21 MCP servers aggregated via code-mode (`~/.utcp_config.json`); Node 22 wrapper required (`~/.claude/wrappers/npx-node22`, isolated-vm@5.x vs Node 24); upstream PR #28 pending.

| Factor | code-mode | Native Claude Code MCP |
|--------|-----------|------------------------|
| Token efficiency | 98.7% (TypeScript code execution) | 85% (MCP Tool Search) |
| Process overhead | 1 aggregated process | N separate processes |
| Failure isolation | Single point of failure | Independent per server |
| Multi-tool workflows | Excellent (chain calls in one execution) | Each call is separate round-trip |
| Maintenance | Node version workarounds | None |
| Setup complexity | One config file | Multiple config entries |

**Decision then:** keep code-mode (98.7% vs 85% savings; cleaner multi-step chains; wrapper working). Failing servers noted: claude_senator, 1mcpserver, openapi, cclsp. Periodic checks defined: `npm view @utcp/code-mode peerDependencies.isolated-vm` (drop wrapper at ^6), /mcp connection status. Reconsider triggers: maintenance burden, native improvements, server-count drop, fewer multi-tool workflows. Hybrid fallback sketched (notion/github/google_drive dual-registered).

---

## 2026-01-08: Removed archived Apple MCPs

**Removed:**
- `apple-core` → `bunx apple-mcp@latest` (supermemoryai/apple-mcp)
- `apple-mail` → `apple-mail-mcp`

**Reason:** Consolidation and maintenance status
- `supermemoryai/apple-mcp` was archived January 1, 2026 (read-only, no updates)
- Both MCPs were timing out on operations
- `apple-mail` was redundant - AppleScript MCP already handles Mail
- AppleScript MCP (`@peakmojo/applescript-mcp`) covers all apps:
  - Reminders (list, create with priority, due dates)
  - Notes (full CRUD, folders)
  - Calendar (events, date ranges)
  - Mail (search, send, organize)
  - Messages, Contacts, Maps

**Current setup:**
- Single MCP: `@peakmojo/applescript-mcp` (parked 2026-07-06 — `osascript` via Bash covers it)
- Skill file: `~/.claude/skills/apple-tools.md` (AppleScript templates)

**Active alternatives if needed:**
- Reminders + Calendar: [FradSer/mcp-server-apple-events](https://github.com/FradSer/mcp-server-apple-events) (Swift-compiled, v1.0.1)
- Notes: [henilcalagiya/mcp-apple-notes](https://github.com/henilcalagiya/mcp-apple-notes) (Full CRUD, v0.1.0)
- Mail: [s-morgan-jeffries/apple-mail-mcp](https://github.com/s-morgan-jeffries/apple-mail-mcp) (Python)

**To restore archived MCPs (not recommended):**
```json
{
  "name": "apple-core",
  "call_template_type": "mcp",
  "config": {
    "mcpServers": {
      "apple-mcp": {
        "command": "bunx",
        "args": ["--no-cache", "apple-mcp@latest"],
        "transport": "stdio"
      }
    }
  }
}
```

---

## 2025-12-26: Changed from `opusplan` to `default`

**Previous:** `"model": "opusplan"`
**Current:** `"model": "default"`

**Reason:** Token optimization
- opusplan forces Opus for all planning sessions
- With default mode set to "plan", every session was using Opus
- Result: 1.1B cache read tokens on Opus vs 671M on Sonnet
- Savings: ~40% reduction in per-token cost

**To switch back to Opus for planning:**
```json
"model": "opusplan"
```

**Other model options (as of late 2025):**
- `"default"` - Use system default (currently Sonnet 4.5)
- `"sonnet"` - Always use Sonnet 4.5
- `"opus"` - Always use Opus 4.5
- `"haiku"` - Always use Haiku 4.5
- `"opusplan"` - Use Opus for plan mode, default for execute mode

---

## 2025-12-26: Disabled claude-mem

**Changed:** `"claude-mem@thedotmack": false`

**Reason:** Massive token overhead
- Plugin size: 14MB
- Cache cost: ~42,000 tokens per session
- 78% of total plugin bloat
- Represents 42k of 54k total cache tokens

**What claude-mem does:**
- Semantic search across past Claude Code sessions
- Cross-session memory ("did we solve this before?")
- Stores observations in SQLite database

**Alternatives:**
- Built-in `~/.claude/stats-cache.json` for usage tracking
- Session transcripts in `~/.claude/projects/*/` for history
- claude-historian-mcp (lighter weight MCP server alternative)

**To re-enable when needed:**
```json
"claude-mem@thedotmack": true
```

---

## 2025-12-26: Pre-optimization baseline snapshot

Backup: `~/.claude/settings.json.backup-20251226`

**Stats:**
- 33 enabled plugins
- ~54k cache tokens per session
- Model: opusplan
- Daily Opus usage: 200-400k tokens

**Expected post-optimization:**
- 32 enabled plugins
- ~12k cache tokens per session
- Model: default (Sonnet)
- Daily Opus usage: 60-120k tokens (when manually switched to Opus)

**Savings: ~78% reduction in cache overhead, ~70% reduction in overall token usage**
