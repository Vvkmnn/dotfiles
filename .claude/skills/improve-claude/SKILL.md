---
name: improve-claude
author: Vvkmnn
description: >
  Use after Claude Code updates, for weekly maintenance, when user expresses frustration
  ("still not working", retry loops), when plugins misbehave or hooks act stale, when
  ~/.claude feels cluttered, after major tasks worth learning from, or when checking
  multi-machine parity and Claude iOS/macOS/web surface alignment. Eight phases:
  health, audit, analyze, refresh, cleanup, evolve, parity, cloud — run one, several,
  or all. The cloud phase is the weekly remote routine (Anthropic infra via /schedule,
  reports by GitHub issue).
version: 2.2.0
argument-hint: "[health|audit|analyze|refresh|cleanup|evolve|parity|cloud|all]"
---

# Improve Claude — Unified Maintenance

One skill, eight phases. Argument `$ARGUMENTS` selects phases (default: `health` + whatever the trigger suggests; `all` runs everything in order). Merged 2026-07-06 from upgrade-claude, improve-claude v1, refresh-claude, cleanup-claude, evolve-skill + improve-claude-cloud (originals in `skills/.archive/`).

| Phase | Job | Interactive? | Effort |
|-------|-----|-------------|--------|
| 1 health | Validate config + enforce structure budgets (drift detection) | No | low |
| 2 audit | CHANGELOG + community best practices since last check | No | medium |
| 3 analyze | Conversation retrospective: frustration, retries, gaps | Semi | high |
| 4 refresh | Plugin cache flush + marketplace sync | Yes | low |
| 5 cleanup | Tiered artifact cleanup with per-path approval | Yes | low |
| 6 evolve | Extract session learnings into skills | Yes | high |
| 7 parity | Multi-machine fleet + iOS/macOS/web surface alignment | Semi | medium |
| 8 cloud | Weekly remote routine: all-surface sweep + benchmark list → GitHub issue | No (scheduled) | medium |

After any phase that changed files: update `~/.claude/.last-maintenance` (ISO timestamp) and add a CHANGELOG.md entry for structural changes.

---

## Phase 1: health

Fast, non-interactive, zero network. Run every invocation.

```bash
claude --version && echo "last maintenance: $(cat ~/.claude/.last-maintenance 2>/dev/null || echo never)"
jq . ~/.claude/settings.json > /dev/null && echo "settings.json OK"
for h in ~/.claude/hooks/*.js; do node --check "$h" || echo "SYNTAX ERROR: $h"; done
bash -n ~/.claude/statusline.sh && echo "statusline OK"
```

**Structure budgets (drift gates — flag any breach):**

| File class | Budget | Check |
|---|---|---|
| CLAUDE.md | ≤160 lines (recalibrated with the rules budget — same evidence) | `wc -l ~/.claude/CLAUDE.md` |
| Each rule | ≤200 lines (recalibrated 2026-07-06: trim cancelled by redundancy research — failure-derived tables stay; cache makes rule-loading quota-free) | `wc -l ~/.claude/rules/*.md` |
| Each OWNER SKILL.md | ≤425 lines (overflow → references/). VENDORED are exempt and never token-edited: docx, pdf, pptx, xlsx, mcp-builder, webapp-testing, vercel-*, web-design-guidelines, impeccable, claude-praetorian | `wc -l ~/.claude/skills/*/SKILL.md` minus vendored |
| Each agent | ≤90 lines | `wc -l ~/.claude/agents/*.md` |

**Reference-integrity checks (the drift that bit us in July 2026):**
- Stale model names: `grep -rnE "opus[- ]?4[.-][0-6]|sonnet[- ]?4[.-][0-5]" ~/.claude/CLAUDE.md ~/.claude/rules ~/.claude/skills/*/SKILL.md ~/.claude/agents | grep -v .archive` — should be empty
- Dead skill refs: every skill name mentioned in CLAUDE.md/rules/commands must exist in `ls ~/.claude/skills`
- `mcp__*` tool names cited in rules/skills spot-checked against live tool list (ToolSearch)
- CHANGELOG staleness: last entry >30 days old → flag
- Doc markers: files with `> Updated:` headers older than 90 days → flag

Modularity rules (enforced by review, not script): one concept per rule file; SKILL.md = decision logic, references/ = runbooks; vendored skills (docx/pdf/pptx/xlsx/mcp-builder/webapp-testing/vercel-*/impeccable/praetorian) never token-edited.

Full validation snippets: `references/health-checks.md`.

## Phase 2: audit

What changed since `.last-maintenance`, and what should we adopt?

1. Fetch CHANGELOG: `https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md` — extract versions since last check: new settings, hook events, frontmatter fields, deprecations, features worth enabling
2. Check the benchmark sources (11-entry table w/ last-checked dates in `references/cloud-routine.md`); spot-check 2-3 for new patterns
3. Verify our config against findings: new feature we should turn on? deprecated key we still set?
4. Output: prioritized adopt/skip list with one-line rationale each; HIGH items get proposed diffs

Never auto-apply — every change is proposed with a diff and approved individually.

## Phase 3: analyze

Conversation retrospective — what did the user experience?

Primary source (historian MCP):
```
mcp__plugin_claude-historian_historian__search_conversations
  query: "still not OR still doesn't OR think more carefully OR stop trying"   # frustration
  query: "restarted claude OR restart OR again"                                 # retry loops
```
Fallback: parse `~/.claude/projects/<project>/<sessionId>.jsonl` directly (turn counts, token spikes, user-message extraction).

Look for: frustration phrases, same-approach retries (≥3 = escalation failure), context waste (rereading files, redundant searches), tool-approval friction (repeated asks for the same pattern → allowlist candidate), skills that SHOULD have fired but didn't (trigger gap), skills that fired wrongly (greedy description).

Output per finding: evidence (quote/session), root cause, proposed fix (CLAUDE.md/rule/skill/permission edit), priority. Present as a table; apply approved items.

## Phase 4: refresh

Plugin cache flush — needed because auto-update is broken end-to-end for third-party marketplaces (GitHub #10265, #26744: autoUpdate not defaulted; #14061, #17361: cache keyed by version + pointer never updated → stale code runs forever).

1. Pull all marketplace repos: `git -C ~/.claude/plugins/marketplaces/<name> pull --ff-only` (loop)
2. Staleness check: installed version in `installed_plugins.json` vs latest in cache — report STALE list
3. Flush (targeted preferred): `rm -rf ~/.claude/plugins/cache/<marketplace>/` — ask which; full flush is the nuclear option
4. Verify autoUpdate: `jq 'to_entries[] | "\(.key): \(.value.autoUpdate // false)"' ~/.claude/plugins/known_marketplaces.json` — all true
5. Restart session for rebuilt cache; verify with `ls ~/.claude/plugins/cache/<m>/<plugin>/` → only latest version

## Phase 5: cleanup

Tiered, per-path user approval on EVERY deletion (rm rule). Sizes first, delete second.

```bash
du -sh ~/.claude/ && du -sh ~/.claude/*/ 2>/dev/null | sort -hr | head -10
```

| Tier | What | Examples |
|------|------|----------|
| 1 Safe (regenerates) | caches + session debris | debug/, shell-snapshots/, paste-cache/, telemetry/1p_failed_*, stale session-env/ |
| 2 Orphaned | leftovers nothing reads | security_warnings_state_*.json, *.bak*, old *.log, .DS_Store, stale dot-state files |
| 3 Archive-not-delete | old content with possible value | legacy/, superseded configs → `.archive/` or `archive/YYYY-MM/` |

**Never touch**: .claude.json, settings.json, settings.local.json, CLAUDE.md, rules/, skills/, hooks/ (active), commands/, agents/, mcp/config.json, recent backups/, plans/ with pending items. Full directory/file reference tables: `references/cleanup-tables.md`.

Verify after: `du -sh ~/.claude/` + essential-config ls + new session starts clean.

## Phase 6: evolve

Extract learnings into skills. Two modes:

**Improve existing** — after using an owner skill that had missing steps/stale instructions/new edge cases: propose surgical Edits (never rewrites), bump version (patch=wording, minor=new scenario, major=restructure), user approves.

**Extract new** — only when ALL four quality gates pass:
- **Reusable** (helps future tasks) · **Non-trivial** (required discovery) · **Specific** (exact triggers describable) · **Verified** (actually worked)

Before creating: `grep -ri "keyword" ~/.claude/skills/ --include=SKILL.md -l` — decision matrix: same trigger+fix → update existing (minor bump); same trigger different cause → new + See-also links; partial overlap → new subsection; nothing related → new skill (verb-noun name, "Use when..." description with concrete triggers, never workflow summaries).

Anti-patterns: over-extraction (mundane solutions don't need preserving), vague descriptions, unverified solutions, duplicating official docs, interrupting main work (batch evolution at task END).

Retrospective mode ("what did we learn?"): scan session → list candidates with justification → extract top 1-3 → report.

## Phase 7: parity

Two halves — fleet (other Macs) and surfaces (iOS/macOS app/web). Full checklist: `references/parity-checklist.md`.

**Fleet (multi-machine):**
```bash
git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" status --short | wc -l   # uncommitted drift
git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" log --oneline -1        # last sync point
ls ~/.claude/mcp/bin/mcp-proxy ~/Library/LaunchAgents/com.claude.mcp-proxy.plist 2>/dev/null  # runtime trio present?
pgrep -fl mcp-proxy | head -1
```
- Uncommitted pile ≥10 → prompt `/update-dotfiles`; other-machine staleness → prompt pull + `/setup-dotfiles` drift check
- The mcp-proxy runtime trio (binary, start-proxy.sh, LaunchAgent) is the known parity break — verify tracked copies exist and MCP.md documents acquisition
- Plugin parity: `known_marketplaces.json` + `enabledPlugins` are the sync contract; caches rebuild per-machine

**Surfaces (Claude app iOS / macOS / web) — facts to check against:**
- claude.ai memory does NOT sync to Code; the only bridge is Skills enabled on claude.ai (auto-load into cloud sessions)
- "Instructions for Claude" (claude.ai Settings→Profile) drifts from CLAUDE.md — no auto-sync; walk the user through re-mirroring the tone/preference subset when CLAUDE.md changed materially
- iOS: push notifications on (`/config` → push toggles), Remote Control paired (`/remote-control`, v2.1.51+) for monitoring long runs
- macOS desktop: connectors pruned to used set (Settings→Connectors), Dispatch paired, `claude mcp add-from-claude-desktop` run after adding desktop-side MCPs
- Model defaults are PER SURFACE — verify each matches intent after model changes
- Quota is ONE shared 20x pool across Code/chat/Cowork/Design — check `/usage` if any surface feels throttled
- Cloud/web sessions see only COMMITTED repo config — project .claude/ must carry what cloud runs need

Interactive items (account toggles, app settings) are walked through WITH the user — never assume state that lives outside this machine.

## Phase 8: cloud

The weekly remote routine — runs on Anthropic infra via `/schedule` (`0 3 * * 0`), NOT locally. Clones the dotfiles repo, runs the automatable subset (health drift-gates + audit) read-only, sweeps ALL Claude surfaces for updates, refreshes the benchmark list, then reports Claude-natively: mechanical fixes as a PR on `claude/weekly-audit-*` (merge = approval, machines pull), judgment items as a tagged issue, push notification links to the still-conversable run. NEVER edits config from the cloud. Full runbook + benchmark list + boundaries: `references/cloud-routine.md`.

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.0.0 | 2026-07-06 | Merged 5 skills (upgrade 1.1.0, improve 1.0.0, refresh 1.1.0, cleanup 1.0.0, evolve-skill 1.0.0) into 6 phases; added structure budgets + drift gates to health; refreshed audit sources to 2.1.20x era; runbooks → references/ |
