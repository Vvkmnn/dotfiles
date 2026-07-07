# CONFIG — Operations, Settings, Fleet & Usage

> The single operational reference: how to drive the setup (Playbook), every settings key triaged (Settings), the MCP fleet (MCP), and the plugin catalog (Plugins). Current-state map: [README](../README.md) · logs: [CHANGELOG](CHANGELOG.md).

---

## Playbook — How to Drive This Setup

> For the human, not for Claude. Companion: [README.md](../README.md) (what exists) · [CHANGELOG.md](CHANGELOG.md) (why + what is next).

### Model & Effort (Max 20x)

Your default is **Default** (no model key): Opus 4.8 daily, auto-softens to Sonnet at the Opus rate limit instead of stopping. Reach for the rest deliberately:

| Move | When |
|------|------|
| `/model fable` | Hardest long-horizon runs: overnight goals, gnarliest debugging, huge refactors. ~2× Opus quota burn — spend it like it costs double, because it does |
| `/effort xhigh` | The hardest 10% of work on any model. `/effort low` for chores/renames |
| `/fast` | Opus sessions only (not Fable): same model, faster output — great for interactive back-and-forth |
| `/model` per session | Never re-pin settings.json — session-scoped choices keep Default the baseline |

**Fable rhythm**: give it goal-first, single-message specs (what + constraints + how to verify), not step lists — over-prescription measurably degrades it. Minutes-long turns are normal; that's thinking, not hanging. Check in via iOS Remote Control instead of hovering.

### Statusline Legend (your scoreboard)

`ॐ Fᵀˣ ψ 36%¹ᴹ κ 94% μ 52% λ 38% 28% σ 2.2h 5.7h θ 4.2h¹·³ 1.4d π main +45 $ 484`

| Glyph | Reads as | Act when |
|-------|----------|----------|
| `ॐ` color | vim state: orange insert (typing = resting) · green normal/escaped · gold visual | (replaces -- INSERT --) |
| `F/O/S/H` + `ᵀ ᴹ ˣ ⁺ ⁻` | model, thinking, effort | wrong model for the task? `/model` |
| `ψ %` (`¹ᴹ` = 1M session) | context used | >60% orange: wrap up or `/compact Focus on X` |
| `κ %` | cache-hit efficiency | orange <70: cache breaking — early-context edits or >1h gaps. Cache reads DON'T count against rate limits (subscription sessions get 1-hour TTL) — κ is a quota multiplier |
| `μ %` | weekly budget variance | red negative: overspent pace · gray >5: surplus, spend more |
| `λ % %` | 5h / 7d quota used | red = near cap; Default will soften to Sonnet |
| `θ h/d` + superscript | runway + pace ratio | red superscript >1.2: current pace exhausts quota before reset |
| `$` | API-equivalent value extracted (dim) | higher = more out of the flat rate. It's a score, not a bill |
| `¢` (orange, appears only when >0) | REAL usage-credit spend | post-2026-07-08 Fable sessions burn credits — this is actual money; refreshed by the usage-API fallback, carried forward between refreshes |

`STATUSLINE_MINIMAL=1` flips to early-warning display (segments appear only when actionable).

### Skills — reach-for map (19 owner skills)

| Situation | Say / use |
|-----------|-----------|
| Weekly maintenance, drift check, "Claude feels off" | `improve-claude` (phases: health/audit/analyze/refresh/cleanup/evolve/parity/cloud) |
| Switch pricing mode or project model | `switch-claude` |
| Research anything (tech or academic) | `research-topics` — routes to parallel agents or paper databases |
| Commit time | `craft-commit` (owns commits) → `draft-github` (PRs) |
| Pre-commit verification | `verify-work` |
| Fork/branch this conversation | `branch-claude` |
| Web perf/audit/automation | `inspect-web` |
| Isolated TUI testing | `isolate-tmux` |
| New machine | `setup-dotfiles`; syncing → `update-dotfiles` |
| Autonomous overnight loop | `ralph-docker` (sandbox only) |

### Agents — when to dispatch (5 custom)

`/review` (code-reviewer), `/security` (security-reviewer), `/architect` — all now genuinely dispatch in the background with fresh context. The `debugger` agent fires when a bug survives your first fix attempt — fresh eyes beat self-critique. `paper-researcher` runs behind research-topics' academic mode. Deeper passes: CE reviewer fleet, trailofbits skills.

Subagents run in the **background by default** — keep working; results arrive. Agent teams: only for adversarial/competing-hypothesis debugging (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`).

### CLIs Claude now prefers (and you can too)

- `sg -p 'useEffect($FN, [])' --lang tsx` — syntax-aware search (ast-grep); add `-r` to rewrite structurally
- `agent-browser open <url>` → `snapshot` → `click @e1` → `close` — headless browsing at ~300 tokens/page
- `gh`, `yt-dlp`, `osascript`, `tmux` — replaced their MCPs outright (see the MCP section below)

### Quota Craft (20x)

- One pool across Code / claude.ai / iOS / Cowork — `/usage` when anything feels throttled
- **Cache reads don't count against rate limits**, and subscription sessions auto-request a 1-HOUR cache TTL — κ is your cheapest quota multiplier: keep sessions warm (<1h gaps), don't edit early context mid-task, batch related asks into one session
- Explore subagents pinned to haiku by our override; custom agents route sonnet/opus — the config stretches quota, don't fight it
- `μ` gray surplus late in the week = leave nothing on the table: queue the big refactor or a worktree fleet

### Fable Economics (from 2026-07-08 Fable draws usage credits, not included limits)

| Path | Mechanism | When |
|------|-----------|------|
| Daily driver | Default (no model key) = Opus 4.8 + auto-Sonnet fallback, included in Max | Always — Opus 4.8 matches Fable's 1M/128K at half the token weight |
| Fable occasionally | `/model fable` on subscription → draws **usage credits** (top up in account settings; no key juggling) | Hardest long-horizon runs Opus 4.8 xhigh can't crack |
| Fable via API | Set `ANTHROPIC_API_KEY` → API billing takes precedence over subscription (`/status` shows the route); unset to return | Only if credit pricing loses to API for your pattern; $10/$50 per MTok = exactly 2× Opus |

**$-stretching for paid Fable sessions (ranked):**
1. Cache discipline — reads bill at 0.1× input; stable prefixes + warm session cut real cost most
2. Scope hard — one goal, context pre-gathered on subscription first, zero exploratory reads on the paid clock
3. Subagents stay on subscription/cheap models — never let a Fable session fan out to Fable children
4. `/effort` deliberately — don't stack max on tasks high handles
5. Keep prompts 200K-sized unless the task truly needs the 1M window

### Weekly Rhythm

1. **Sunday 3am** (once you run `/schedule` → "Run the improve-claude skill, cloud phase"): audit runs on Anthropic infra → mechanical fixes arrive as a PR (`claude/weekly-audit-*`), judgment calls as an issue, push notification links you to a conversable session
2. **Merging that PR is the approval** — machines just pull
3. Session-start nudges you if maintenance goes >7 days stale

### Multi-model, Workflows & Memory (researched 2026-07-06, sourced)

**Second opinions from Codex + Gemini — the free 2-model panel (`second-opinion` skill v1.3.0).** Both $0, CLI-to-CLI, no MCP/keys: **Codex** (`codex exec review`, your ChatGPT sub — primary, diff review; FOREGROUND only, 7-min timeout, NOT run_in_background = 0-byte bug) + **Gemini** (`gemini -p`, free personal-Google OAuth, 1M context — large-codebase/different-lineage; run `gemini` once to Login-with-Google, decline telemetry). Two opinions ≈ 70% of value; a 3rd rarely flips a call. Free breadth if ever wanted: `llm`+`llm-openrouter` (24 free OpenRouter models) — not installed. Grok = no free path. *Heavier paid routes, only if you outgrow free:* PAL MCP (needs OpenRouter keys). **Avoid `claude-code-router`** (bypasses Max billing). *Heavier routes, only if you outgrow that:* PAL MCP (`BeehiveInnovations/pal-mcp-server`, ex-zen-mcp) puts many models in one prompt but needs OpenRouter/provider keys = separate recurring cost, NOT covered by Max — verify the repo live before installing. **Avoid `claude-code-router` for your case**: it swaps Claude's backend to other providers, so you pay *them* (Max is bypassed) — it's for replacing Claude with cheaper models, not your goal.

**Dynamic Workflows (native, zero config)** — JS scripts orchestrating many background subagents. Reach for them on jobs too big for one conversation to coordinate (codebase audits, large migrations, multi-angle research). Trigger `ultracode` in a prompt for one task, or `/effort ultracode` for a whole session; `/deep-research <q>` is a built-in fan-out-and-verify workflow. Save a good run: `/workflows` → select → `s` → it lands in `~/.claude/workflows/`. Distinct from **subagents** (Claude decides each turn what to spawn) and **skills** (instructions Claude follows). The weekly cloud audit is a natural future saved-workflow.

**Memory** — you already run native `/memory` + MEMORY.md (auto-caps 200 lines, overflow → topic files). The one unused lever: **path-scoped rules** — `.claude/rules/<name>.md` with `paths:` frontmatter loads only when matching files open, cutting context noise on big projects (e.g. an api rule scoped to `src/api/**`). Audit accrued memory with `/memory` periodically. (claude.ai memory does NOT sync to Code — separate systems.)

**Cross-surface ritual (Remote Control is on)** — queue reviews/tests at the desk → approve from phone/couch; heavy-code in the terminal → light edits in browser → quick approvals on iOS, all synced. For a long/overnight run: start an isolated `--worktree` session + Remote Control, monitor from anywhere, main branch untouched. One live session per machine at a time.

---

## Settings — Every-Key Adoption Plan

> Every user-relevant settings.json key, triaged: what we use, what we adopt, what waits for a trigger, what's genuinely N/A — with reasoning. Maintained by `improve-claude` audit phase (new keys each release get triaged here). Principle: minimize governs code quality, NOT feature adoption — unknown features get evaluated on merit.

### Active (in use)

| Key | Value | Why |
|-----|-------|-----|
| `permissions` | tiered allow/ask/deny | Oversight backbone |
| `hooks` | 9 events | session-start, prompt-submit, tool guards, telemetry, pre-compact, notification |
| `statusLine` | script + `refreshInterval: 30` + `hideVimModeIndicator` | v2 line; live clocks; ॐ replaces INSERT banner |
| `enabledPlugins` | 27 | Plugins section below |
| `sandbox` | enabled | Command isolation |
| `attribution` | empty commit/pr | No attribution noise |
| `alwaysThinkingEnabled` | true | Thinking on (Fable: always-on regardless) |
| `editorMode` | vim | With ॐ statusline indicator |
| `tui` | fullscreen | Flicker-free renderer |
| `voiceEnabled` | true | Hold-to-talk |
| `cleanupPeriodDays` | 77 | Transcript retention |
| `includeGitInstructions` | true | Native commit/PR guidance |
| `inputNeededNotifEnabled` `agentPushNotifEnabled` | true | iOS push when waiting / proactive |
| `terminalProgressBarEnabled` | true | OSC 9;4 in Ghostty tab |
| `showTurnDuration` | true | "Cooked for Nm" — calibrates Fable rhythm |
| `model` | **deliberately absent** | = Default: Opus 4.8 + auto-Sonnet fallback; Fable per-session |

### Adopt when trigger fires

| Key | Trigger | Note |
|-----|---------|------|
| `worktree.symlinkDirectories` | First worktree fleet | node_modules symlinks save GBs |
| `worktree.baseRef: head` | Fleet on feature branches | Default `fresh` fine until then |
| `teammateMode: tmux` | First agent-teams session | Teams as tmux panes — native fit |
| `subagentStatusLine` | Fleet visibility need | Small script: name + elapsed |
| `sshConfigs` | vbookneo remote work | `claude ssh vbookneo` |
| `remote.defaultEnvironmentId` | Cloud envs standardize | |
| `skillOverrides` | A vendored skill gets noisy | `name-only` / `off` per skill |
| `enabledMcpjsonServers` | First team repo with .mcp.json | |
| `pluginConfigs` | Plugin needs user config | |
| `otelHeadersHelper` | OTel backlog item lands | With CLAUDE_CODE_ENABLE_TELEMETRY |
| `fallbackModel` | Pinned-model automation (crons) | Default already falls back |
| `autoUpdatesChannel: stable` | If a `latest` release ever burns us | Currently latest = fine |

### Evaluate (real trade-offs — decide deliberately)

| Key | Trade-off |
|-----|-----------|
| `autoUploadSessions` | Watch any session from iOS (cross-surface goal) vs uploading everything — privacy call |
| `autoDreamEnabled` + `autoMemoryEnabled` | Background memory consolidation vs gladiator's reflector role — settle in consolidation item |
| `switchModelsOnFlag` | Fable safety-flag → auto-switch keeps flow vs knowing it happened; server-side fallbacks may supersede |
| `showThinkingSummaries` | See Fable's summarized reasoning vs transcript noise |
| `remoteControlAtStartup` | Always steerable from phone vs bridge overhead per session |
| `showClearContextOnPlanAccept` | Fresh context per plan vs losing exploration context |
| `askUserQuestionTimeout` | Auto-continue stalled questions (60s/5m/10m) vs surprise partial answers |
| `preferredNotifChannel: ghostty` | Explicit channel vs auto detection (test if auto misbehaves) |
| `showMessageTimestamps` | Metrics love vs visual clutter |
| `autoMode` custom rules | Tune the auto-permission classifier once auto mode gets real use |
| `defaultView` / `viewMode` | chat vs transcript default — taste |
| `skillListing*` budgets | Raise if skill descriptions get truncated (18 skills: not yet) |
| `theme` daltonized variants | If diff colors still fight Kanagawa after minimum-contrast |
| `spinnerVerbs` / `spinnerTipsOverride` | Pure fun — a rainy-day customization |
| `breakReminder` / `quietHours` | Wellness nudges — user's call entirely |
| `env` block | Move .profile privacy vars (DISABLE_TELEMETRY etc.) here for dotfiles-synced, launch-independent env |

### Deliberately skipped (decided, with reasoning)

| Key | Why |
|-----|-----|
| `autoCompactWindow` / PCT override | Would gut 1M-context sessions (CHANGELOG entry) |
| `effortLevel` (persisted) | Session `/effort` beats a sticky global — effort is per-task |
| `fastMode` (persisted) | `/fast` per-session; `fastModePerSessionOptIn` if it ever sticks wrongly |
| `disableClaudeAiConnectors` | Keep Gmail/Calendar/Drive connectors available for cross-surface |
| `enableAllProjectMcpServers` | Blanket trust — against oversight model |
| `claudeMdExcludes` / `disableBundledSkills` / `disableAllHooks` | Removing capability we use |
| `includeCoAuthoredBy` | Deprecated — `attribution` covers it |
| `verbose` / `syntaxHighlightingDisabled` / `prefersReducedMotion` / `axScreenReader` | Defaults correct for this human |
| Enterprise/policy keys (`policyHelper`, `availableModels`, `strict*`, `allowed*`, `force*`, `claudeMd`, `pluginTrustMessage`, `companyAnnouncements`, `sshConfigs`-as-policy, `modelOverrides`) | Solo operator — no managed environment |
| `apiKeyHelper` / AWS/GCP auth | Subscription auth, not API keys |
| `@internal` keys (`totalTokensReminder`, `awaySummaryEnabled`, `doneMeansMerged`, `precomputeCompactionEnabled`) | Unsupported surface — revisit if documented |

### Structural surfaces (beyond settings.json)

| Element | Status |
|---------|--------|
| `workflows/` | ADOPTED — native Dynamic Workflows dir (was our biggest structural gap) |
| `agents/explore.md` override | ADOPTED — pins built-in Explore to haiku for cheap scans |
| `output-styles/` | Evaluate-lite — 1-2 presets max; overlaps CLAUDE.md tone |
| AGENTS.md / CLAUDE.local.md / VERSION / scripts/ / templates/ / HANDOFF.md | Covered by existing equivalents (CLAUDE.md, settings.local.json, improve-claude, mcp/bin+hooks, plans+skills, docs/PAST) |

---

## MCP — Server Inventory & Fleet

> Fleet: 26 → 14 active; 12 parked under `disabledServers` (see fleet table below)
> Config: `~/.claude/mcp/config.json` (proxy server definitions; `disabledServers` key = parked entries, TBXark ignores unknown keys)
> Endpoints: `~/.claude.json` (Claude Code HTTP connections)
> Credentials backup: `~/.claude/mcp/credentials.txt` (gitignored)
> Logs: `~/.claude/mcp/proxy-error.log` (access logging OFF since 2026-07-06 — `logEnabled:false`; gitignored)

### Architecture

All servers run through `mcp-proxy` gateway on `localhost:9090`. Each server is an npm/uvx package spawned as a stdio subprocess. Claude Code connects to `http://localhost:9090/<server>/mcp`.

**Auth (since 2026-07-06):** the proxy requires `Authorization: Bearer <token>` (`mcpProxy.options.authTokens` in config.json; matching header on each `~/.claude.json` entry — both files hold the token, both are protected: git-crypt / gitignored). Unauthenticated requests get 401 — other local processes can no longer use the credentialed servers. Re-adding a server: `claude mcp add <name> http://localhost:9090/<name>/mcp --transport http -s user --header "Authorization: Bearer <token from config.json>"` (positionals BEFORE flags — flag-first silently fails with "missing required argument").

**Restart proxy:** `launchctl kickstart -k gui/$(id -u)/com.claude.mcp-proxy`
(never `pkill … &` — that bypasses the LaunchAgent's port-cleanup wrapper and orphans the KeepAlive)

**After config changes:** Restart proxy AND restart Claude Code (tools load at session start).

**Machine-2 bootstrap (runtime trio):** the proxy needs three pieces beyond the git-crypt'd config:
1. Binary: `~/.claude/mcp/bin/mcp-proxy` (7.4MB arm64, not tracked) — get via `go install github.com/TBXark/mcp-proxy@latest` then copy from `$GOPATH/bin`, or download the release binary from github.com/TBXark/mcp-proxy
2. Wrapper: `mcp/bin/start-proxy.sh` ($HOME-relative since 2026-07-06 — port-cleanup + exec)
3. LaunchAgent: install from the tracked template — `sed "s|__HOME__|$HOME|g" ~/.claude/mcp/com.claude.mcp-proxy.plist.template > ~/Library/LaunchAgents/com.claude.mcp-proxy.plist && launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.claude.mcp-proxy.plist`
Then: git-crypt unlock (config.json), `claude /login`, re-add the 14 Claude-side entries with the Bearer header (see Auth above).

### Fleet Decision (2026-07-06, CLI-first)

12 servers parked — entries preserved verbatim under `disabledServers` in config.json; restore = move the entry back to `mcpServers`, re-add the Claude-side endpoint (`claude mcp add --transport http <name> http://localhost:9090/<name>/mcp -s user`), kickstart proxy.

| Parked | Replaced by |
|--------|-------------|
| railway, supabase | dead (placeholder tokens); `supabase` CLI if ever needed |
| google_drive | unused since Apr 4; claude.ai Drive connector on desktop |
| sequential_thinking | Fable/Opus think natively |
| memory | native /memory + MEMORY.md |
| fetch, duckduckgo | built-in WebFetch / WebSearch |
| chrome_devtools | claude-in-chrome (interactive) + `agent-browser` CLI (headless) + `npx lighthouse` (audits) |
| tmux | `tmux` via Bash |
| applescript | `osascript` via Bash |
| yt_dlp | `yt-dlp` CLI (youtube MCP stays for API metadata/transcripts) |
| github | `gh` CLI (authed; craft-commit/draft-github already use it) |

#### Previous Architecture (before 2026-02-01)

All MCP servers were proxied through code-mode UTCP (`@utcp/code-mode-mcp`). Config lived in `~/.utcp_config.json` (git-crypt encrypted). Backup of that era: `~/.claude/mcp/mcp.json.bak` (git-crypt encrypted, 36 servers). Native MCP with mcp-proxy replaced UTCP for better performance (+8.6% accuracy, 85% token reduction via lazy loading). Lost features: `call_tool_chain`, `register_manual`, `search_tools`. `~/.utcp_config.json` kept as reference. See the Historical Appendix below for the code-mode rationale and the native-MCP bug analysis that justified that era.

### Active Servers (14: anki, apify, brave_search, firecrawl, fred, hackernews, magic_ui, notion, paper_search, reddit, rss, stackoverflow, twitter, youtube — tables below predate the 2026-07-06 park and include parked servers)

#### Search & Social
| Server | Package | Auth | Notes |
|--------|---------|------|-------|
| reddit | `reddit-mcp-server` | OAuth client_id + secret | 60-100 req/min. Creds from reddit.com/prefs/apps |
| twitter | `@practicaltools/twitter-mcp-server` | Apify token (shared) | 11 tools via Apify scraping. Free ~50k results/month |
| hackernews | `@devabdultech/hn-mcp-server` | None | |
| stackoverflow | `@notalk-tech/stackoverflow-mcp` | None | 300 req/day |
| duckduckgo | `duckduckgo-mcp-server` | None | Fallback search |

#### Web & Content
| Server | Package | Auth | Notes |
|--------|---------|------|-------|
| brave_search | `@brave/brave-search-mcp-server` | API key | Free: 1 req/sec |
| fetch | `mcp-fetch-server` | None | URL -> markdown, unlimited |
| firecrawl | `firecrawl-mcp` | API key | JS-rendered pages. 500 one-time free credits |
| rss | `@iflow-mcp/rss-reader-server` | None | |

#### Research
| Server | Package | Auth | Notes |
|--------|---------|------|-------|
| paper_search | `paper-search-mcp` (uvx) | None (optional keys for higher rate limits) | 22+ sources: arXiv, PubMed, Google Scholar, Semantic Scholar, Crossref, OpenAlex, SSRN, bioRxiv, dblp, CORE, Europe PMC, and more. Replaces standalone arxiv. 817 stars, 95% reliability |
| fred | `fred-mcp-server` | FRED API key (free) | 800k+ Federal Reserve economic time series. GDP, inflation, employment, rates |

#### Media
| Server | Package | Auth | Notes |
|--------|---------|------|-------|
| youtube | `@kirbah/mcp-youtube` | YouTube Data API v3 key | Search, transcripts, trending. 10k units/day free |
| yt_dlp | `@kevinwatt/yt-dlp-mcp` | None | Download transcripts/metadata. Complements youtube |

#### Productivity
| Server | Package | Auth | Notes |
|--------|---------|------|-------|
| notion | `@notionhq/notion-mcp-server` | Integration token | |
| google_drive | `@piotr-agier/google-drive-mcp` | OAuth tokens | ~/.config/google-drive-mcp/ |
| github | `@modelcontextprotocol/server-github` | PAT | Also via gh CLI |
| memory | `@modelcontextprotocol/server-memory` | None | Knowledge graph |

#### System & Automation
| Server | Package | Auth | Notes |
|--------|---------|------|-------|
| tmux | `tmux-mcp` | None | |
| applescript | `@peakmojo/applescript-mcp` | None | macOS automation |
| chrome_devtools | `chrome-devtools-mcp` | None | |
| apify | `@apify/actors-mcp-server` | API token | Shared token with twitter server |

#### AI & Dev Tools
| Server | Package | Auth | Notes |
|--------|---------|------|-------|
| sequential_thinking | `@modelcontextprotocol/server-sequential-thinking` | None | |
| magic_ui | `@magicuidesign/mcp` | None | |
| anki | `@ankimcp/anki-mcp-server` | None | Needs Anki desktop running |

#### Unconfigured (2 servers — need API keys to activate)

| Server | What's Needed |
|--------|---------------|
| supabase | Access token + project ref from supabase.com dashboard |
| railway | API token from railway.app/account/tokens |

#### Retired (available if needed)

| Server | Package | Notes |
|--------|---------|-------|
| arxiv | `arxiv-mcp-server` (uvx) | Replaced by paper_search which includes arXiv + 20 more sources. Re-add with: `"arxiv": {"command": "uvx", "args": ["arxiv-mcp-server", "--storage-path", "/Users/v/.arxiv-papers"]}` |

### Changes Log

#### 2026-06-28
- Consolidated top-level `~/.claude/MCP.md` (code-mode era doc) into this file as Historical Appendix
- Added Plugin status section recording orphaned-marketplace state on vBook

#### 2026-03-18
- Added `paper-search-mcp` (22+ academic sources in one server, replaces standalone arxiv)
- Added `fred-mcp-server` (Federal Reserve economic data, 800k+ time series)
- Retired standalone `arxiv` (now covered by paper_search)
- Created `study-claude` skill + `study-researcher` agent for research workflows

#### 2026-03-17
- Reddit: `reddit-mcp-buddy` -> `reddit-mcp-server` (old package blocked by Reddit API changes)
- Twitter: `agent-twitter-client-mcp` -> `@practicaltools/twitter-mcp-server` (cookie/credential auth broken, switched to Apify)
- YouTube: Added `@kirbah/mcp-youtube` (new)
- Firecrawl: API key configured
- Apify: API key configured

#### 2026-02-01
- Migrated from code-mode UTCP proxy to native MCP with mcp-proxy gateway

### Troubleshooting

- **404 from proxy**: Server crashed on startup. Check proxy-error.log for "Connecting" loops
- **Stuck "Connecting"**: Kill all proxy processes, restart fresh. Stale state causes this
- **Tools missing in Claude Code**: Restart Claude Code after proxy changes
- **Twitter auth issues**: Now uses Apify, no direct Twitter auth needed
- **Reddit 403**: Uses OAuth now, not unauthenticated scraping

### Plugin status

Two Claude Code plugins are installed on vBook but their marketplaces have **gone orphaned** (the local cache under `~/.claude/plugins/marketplaces/<name>/` no longer has a `git remote` to read from, and neither marketplace is listed in `~/.claude/plugins/known_marketplaces.json`):

| Plugin | Marketplace alias | Source on vBook | How to recover |
|--------|-------------------|-----------------|----------------|
| `everything-claude-code` | `everything-claude-code` | Cache gone, no trace | Best-effort: search GitHub for `everything-claude-code` marketplace.json |
| `ralph-wiggum` | `claude-code-plugins` | Cache gone | Likely the same set as `anthropics/claude-plugins-official` (every plugin appears with both `@claude-code-plugins` and `@claude-plugins-official` suffixes in installed_plugins.json — this is the old registry name). `ralph-wiggum` not in the official one, so the old `claude-code-plugins` marketplace was a different repo — owner will need to remember/look it up. |

vNeo is at parity except for these two. Re-adding them requires `claude plugin marketplace add <repo>` for each, then `claude plugin install <plugin>@<marketplace>`.

**Owner exclusion:** `claude-mem@thedotmack` should NOT be installed on vNeo even though `thedotmack` is in the registry.

### Appendix: Historical — code-mode era (2026-02 and earlier)

Preserved for context. This was the architecture before the migration to native MCP via mcp-proxy.

#### Why code-mode existed

Native MCP had a parameter-serialization bug for any tool whose JSON Schema used `$ref` pointing to a `oneOf` union:

| Tool | Parameter | Schema Type | Native MCP |
|------|-----------|-------------|------------|
| `notion.post-page` | `parent` | `$ref` → `oneOf` union | ❌ Stringified the object |
| `notion.query-data-source` | `filter` | inline object | ✅ Worked |
| `notion.patch-page` | `properties` | inline object | ✅ Worked |

**Root cause**: Claude Code serialized `$ref → oneOf` parameters to a JSON string instead of passing the object. Symptom:
```
body.parent should be an object... instead was `"{\"database_id\": \"2c8b6eb0-...\"`
```

**code-mode workaround**: pass parameters through TypeScript's type system instead of relying on JSON-schema interpretation. The `@utcp/code-mode-mcp` wrapper sat in front of every native MCP server.

#### code-mode configuration (historical)

```json
// ~/.claude.json (era 2026-01)
{
  "mcpServers": {
    "code-mode": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@utcp/code-mode-mcp"],
      "env": {
        "UTCP_CONFIG_FILE": "/Users/v/.utcp_config.json"
      }
    }
  }
}
```

#### Trade-off table

| Aspect | Native MCP | code-mode |
|--------|------------|-----------|
| Context on idle | Lower (lazy-load) | Higher (+0.9k) |
| Heavy server usage | Tool defs load | Single tool call |
| Parameter handling | Buggy for $ref/oneOf | Reliable |
| Debugging | Direct errors | TypeScript stack |

#### code-mode usage syntax (no longer active)

```typescript
// Top-level await not supported — wrap in async IIFE
(async () => {
  const result = await notion.API_post_page({
    parent: { database_id: "..." },
    properties: { "Job": { title: [{ text: { content: "Example Job" } }] } }
  });
  console.log(JSON.stringify(result, null, 2));
})();
```

`mcp__code-mode__list_tools` listed servers; `mcp__code-mode__tool_info("server.tool")` printed the interface; `mcp__code-mode__call_tool_chain` executed the TypeScript.

#### Why we moved off

Native MCP via mcp-proxy got the bug fixed upstream and benchmarked +8.6% accuracy / 85% token reduction (lazy tool loading). Cost: lost `call_tool_chain`, `register_manual`, `search_tools`. The full `~/.utcp_config.json` is preserved as reference, encrypted via git-crypt.

#### Docs
- https://github.com/universal-tool-calling-protocol/code-mode
- https://www.utcp.io/

---

## Plugins — Disabled Catalog & Re-enable Guide

> Disabled-plugin catalog with re-enable guidance. Optimization plan: `groovy-pondering-flamingo.md`
> Re-enable globally: set `true` in `~/.claude/settings.json` under `enabledPlugins`
> Re-enable per-project: add to `<project>/.claude/settings.json`:
> ```json
> { "enabledPlugins": { "plugin-name@marketplace": true } }
> ```

### Why Disabled

63 plugins injected 15k+ tokens of agent descriptions per session (~7% of 200k context). Direct JSONL search across 794 sessions confirmed 36 plugins had zero actual skill/agent invocations. Context pollution degrades output — clean 30% context outperforms polluted 60%.

### Trail of Bits Security Suite (15 plugins)

Zero invocations across all sessions. Specialized for security audits not in current workflow.

**Re-enable when:** Starting a security-focused project, doing penetration testing, writing detection rules, auditing cryptographic code, or reviewing code for vulnerabilities.

| Plugin | What It Does | Best For |
|--------|-------------|----------|
| `audit-context-building@trailofbits` | Per-function security analysis with deep architectural context | Security code audits — invoke `audit-context` skill |
| `static-analysis@trailofbits` | CodeQL + Semgrep scanning with SARIF parsing | SAST scanning pipelines |
| `semgrep-rule-creator@trailofbits` | Custom Semgrep rule authoring with test-driven flow | Writing detection rules |
| `semgrep-rule-variant-creator@trailofbits` | Port Semgrep rules across languages | Multi-language codebases |
| `variant-analysis@trailofbits` | Find similar vulnerabilities across codebase | After finding one vuln, find all variants |
| `insecure-defaults@trailofbits` | Detect fail-open / insecure default configurations | Config review, hardening |
| `property-based-testing@trailofbits` | Hypothesis/QuickCheck property-based testing | Fuzzing, edge case discovery |
| `testing-handbook-skills@trailofbits` | LibFuzzer, AFL++, cargo-fuzz, OSS-Fuzz, harness writing | Fuzz testing infrastructure |
| `constant-time-analysis@trailofbits` | Timing side-channel detection | Cryptographic implementations |
| `differential-review@trailofbits` | Security-focused diff review | Security-sensitive PRs |
| `sharp-edges@trailofbits` | Error-prone API / dangerous pattern detection | API safety review |
| `spec-to-code-compliance@trailofbits` | Verify code implements spec exactly | Protocol/standard compliance |
| `dwarf-expert@trailofbits` | DWARF binary debug info analysis | Binary reverse engineering |
| `yara-authoring@trailofbits` | YARA malware detection rule authoring | Malware research |
| `ask-questions-if-underspecified@trailofbits` | Clarify requirements before implementing | Redundant with CLAUDE.md rules |

### Redundant Plugins (7 plugins) — Better version kept

| Disabled | Kept Instead | Why Redundant |
|----------|-------------|---------------|
| `error-debugging@claude-code-workflows` | `debugging-toolkit` | Same `debugger` agent. debugging-toolkit adds `dx-optimizer`. error-debugging's unique `error-detective` (log correlation) is niche. |
| `unit-testing@claude-code-workflows` | `tdd-workflows` | 3rd copy of `debugger` agent. tdd-workflows has `tdd-orchestrator` (red-green-refactor discipline). |
| `code-review@claude-plugins-official` | `compound-engineering` (ce-review) | ce-review provides domain-specialist reviewers. code-review has unique `gh pr comment` integration — **re-enable if doing heavy PR review work**. |
| `feature-dev@claude-plugins-official` | `compound-engineering` (ce-plan) | ce-plan provides document-driven planning. feature-dev is more interactive but never invoked. |
| `security-guidance@claude-plugins-official` | `security-scanning` (if re-enabled) | Passive security hook, but zero invocations. Trail of Bits suite is more thorough if security work needed. |
| `repomix-commands@repomix` | `repomix-mcp` | MCP server provides same tools directly. Commands are user-facing wrappers — `pack-remote`/`pack-local` skills. |
| `repomix-explorer@repomix` | `repomix-mcp` | MCP server's `read_repomix_output`/`grep_repomix_output` cover this. Explorer adds analysis agents. |

**Re-enable repomix-commands when:** You want `/pack-remote` and `/pack-local` slash commands for convenience.
**Re-enable code-review when:** Doing frequent PR reviews and want `gh pr comment` integration.

### Zero-Usage Workflow Plugins (14 plugins)

Zero skill invocations across 794 sessions. High-quality plugins for workflows not currently active.

#### Infrastructure & Backend
**Re-enable when:** Building backend services, setting up CI/CD, designing databases, or deploying to cloud.

| Plugin | Skills/Agents | Best For |
|--------|--------------|----------|
| `backend-development@claude-code-workflows` | API design, microservices, event sourcing, CQRS, GraphQL, Temporal, saga orchestration | Backend service architecture |
| `cicd-automation@claude-code-workflows` | GitHub Actions templates, GitLab CI, Terraform, Kubernetes, secrets management | CI/CD pipeline setup |
| `database-design@claude-code-workflows` | PostgreSQL schema design, SQL optimization | Database schema work |
| `deployment-validation@claude-code-workflows` | Cloud architecture validation, deployment checks | Pre-deploy verification |

#### Code Quality & Review
**Re-enable when:** Doing comprehensive PR reviews, large refactors, or quality audits.

| Plugin | Skills/Agents | Best For |
|--------|--------------|----------|
| `pr-review-toolkit@claude-plugins-official` | **6 agents (~33KB)**: silent-failure-hunter, type-design-analyzer, pr-test-analyzer, comment-analyzer, code-reviewer, code-simplifier | Thorough PR reviews (biggest single token cost) |
| `code-refactoring@claude-code-workflows` | Legacy modernizer, code reviewer agents | Large-scale refactoring |
| `quality-tools@cc-skills` | Multi-agent profiling, schema validation, dead-code detection, pre-ship review | Quality audits before release |
| `security-scanning@claude-code-workflows` | security-auditor + threat-modeling-expert agents | Active security scanning |

#### Language-Specific (Advanced)
**Re-enable when:** Doing systems programming in Rust/Go/C or need advanced language patterns beyond what python-development and javascript-typescript provide.

| Plugin | Skills/Agents | Best For |
|--------|--------------|----------|
| `systems-programming@claude-code-workflows` | Rust async, Go concurrency, C memory safety | Rust/Go/C projects |

#### Specialized Tools
**Re-enable when:** Building Agent SDK apps, generating documents, managing dotfiles with chezmoi, or building frontend UIs.

| Plugin | Skills/Agents | Best For |
|--------|--------------|----------|
| `agent-sdk-dev@claude-plugins-official` | Agent SDK app scaffolding + verification (TS + Python) | Claude Agent SDK development |
| `frontend-design@claude-plugins-official` | Production UI with Tailwind, accessibility, responsive design | Frontend/UI projects |
| `doc-tools@cc-skills` | LaTeX builds, Pandoc PDF generation, ASCII diagrams, academic PDF conversion | Document generation, academic work |
| `dotfiles-tools@cc-skills` | Chezmoi sync, drift checking workflows | Chezmoi-based dotfile management (you have `update-dotfiles` skill already) |

#### Already Disabled (kept disabled)

| Plugin | Why |
|--------|-----|
| `cc_chrome_devtools_mcp_skill` | Replaced by claude-in-chrome MCP |
| `github@claude-plugins-official` | Use gh CLI directly |
| `superpowers@claude-plugins-official` | Duplicate of marketplace version |
| `interface-design@interface-design` | Zero usage, niche |

### Kept Plugins (27 plugins)

| Category | Plugins | Why Kept |
|----------|---------|----------|
| Core (5) | superpowers, superpowers-dev-for-cc, elements-of-style, compound-engineering, explanatory-output-style | Foundational skills, plan mode, Context7 MCP |
| Workflow (7) | commit-commands, git-pr-workflows, tdd-workflows, debugging-toolkit, plugin-dev, shell-scripting, ralph-loop | Daily tools confirmed by JSONL session search |
| Language (2) | python-development, javascript-typescript | Active Python/TS work. orchestrate.md updated with invoke triggers |
| Quality (1) | code-simplifier | 2 sessions confirmed usage. Operates on code (complements elements-of-style for prose) |
| MCP (1) | repomix-mcp | Direct MCP server access (tools, not just skills) |
| LSP (5) | typescript, pyright, rust-analyzer, lua, swift | Near-zero cost — no agent descriptions injected |
| Emporium (6) | praetorian, orator, gladiator, historian, oracle, vigil | Custom tools, low overhead |

### Result

63 enabled -> 27 enabled. ~10k tokens saved per session from agent descriptions.

---

## claude.ai Profile (canonical mirror)

The single source for parity check S1 — paste this into **claude.ai → Settings → Profile → "personal preferences"** (all surfaces inherit: web, desktop, iOS). Hybrid persona (OpenAI advisor rigor + CLAUDE.md engineering directness), scaled to stakes. Loads every message, so it's kept <400 words; when it drifts from CLAUDE.md's tone, edit HERE then re-paste. Memory preference is a claude.ai *setting*, not part of this text.

> Be a brutally honest advisor, collaborator, and internal auditor — optimize for truth, clarity, and leverage, not comfort. Treat me as a high-potential founder/engineer with blind spots: interrogate assumptions, argue from first principles + evidence, surface trade-offs. Assume competence; skip the basics; no filler, hedging, praise openers, or emojis.
>
> Match effort to stakes. Simple asks get a direct answer, done. For real decisions or non-obvious claims, give me: (1) the answer, (2) why, (3) options with trade-offs, (4) risks/assumptions, (5) next step + how I'll know it worked. On consequential calls also add: confidence /10 (and why not 10), the strongest objection to your view and your reply to it, and one non-obvious way you might be wrong.
>
> When you're <90% sure, or a claim is time-sensitive or niche, browse and cite 2–4 credible sources; if you can't browse, say so and date-bound the claim. Never fabricate, fake data, or pretend to know — say "I don't know," what would change your answer, and how you'd verify. Success is solving the real problem, not sounding helpful.
>
> Technical: show key math with units and re-check the digits; prefer tables when clearer. Code should run from a single paste with minimal deps, a brief usage example, and noted edge/security cases. When context is missing, ask the one highest-leverage question instead of guessing.

*Future option: move the 5-part output structure into a claude.ai **Style** (purpose-built for formatting), leaving this Profile for persona only.*
