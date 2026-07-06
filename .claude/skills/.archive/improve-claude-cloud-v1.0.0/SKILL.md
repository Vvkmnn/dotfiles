---
name: improve-claude-cloud
author: Vvkmnn
description: >
  Weekly cloud routine covering ALL Claude incarnations: Claude Code CLI, claude.ai app,
  iOS, macOS desktop, API, and model lineup. Runs the automatable subset of improve-claude
  (health drift-gates + audit) against the dotfiles clone, checks every Claude surface for
  updates, maintains a 7+ benchmark list of best-in-class setups, and reports via GitHub
  issue + push notification. For local/interactive maintenance phases, use improve-claude.
version: 1.0.0
---

# Improve Claude — Cloud Routine

Runs weekly on Anthropic infra via `/schedule` (`0 3 * * 0`, Sunday 3am). Cloud sessions are ephemeral: clone the dotfiles repo (it contains ~/.claude config; git-crypt files stay encrypted — work with the tracked plaintext files only), do read-only analysis, report out. NEVER modifies config from the cloud — findings land as a GitHub issue the user applies locally via improve-claude.

## Weekly Workflow

1. **Clone + health subset**: run improve-claude's budget sweep + drift gates against the clone (line budgets, stale model names, dead skill refs, `> Updated:` marker ages, PAST.md entry age)
2. **Product updates sweep** — every surface:
   - Claude Code: CHANGELOG since last run (new features/deprecations affecting our config)
   - claude.ai app: release notes / feature announcements (memory, Projects, Skills changes)
   - iOS + macOS desktop: app updates worth enabling
   - API/models: new models, pricing changes, deprecations (affects switch-claude tables + statusline)
3. **Benchmark list refresh**: check each entry below for updates (last-push date, new patterns); hunt ONE new candidate per run; propose add/drop to keep list ≥7 and current
4. **Cross-surface harmony**: flag drift candidates from the parity checklist's recurring items (S1 instructions mirror, S2 skills bridge, S9 model defaults, S11 repo configs)
5. **Report**: GitHub issue tagged `claude-maintenance` — sections: Drift gates | Product updates | Benchmark changes | Harmony flags | Proposed actions (each one-line + effort estimate). Then PushNotification: "Weekly Claude audit: N items"

## Benchmark List (≥7 at all times; update last-checked each run)

| # | Setup | URL | Best-in-class for | Checked |
|---|-------|-----|-------------------|---------|
| 1 | fcakyon/claude-codex-settings | github.com/fcakyon/claude-codex-settings | All-around config, precompact priorities, telemetry hooks | 2026-07-04 |
| 2 | affaan-m/ECC | github.com/affaan-m/everything-claude-code | Broadest pattern library; reference not wholesale | 2026-07-04 |
| 3 | jarrodwatts/claude-code-config | github.com/jarrodwatts/claude-code-config | Path-scoped rules, persistent planning files | 2026-07-04 |
| 4 | brianlovin/claude-config | github.com/brianlovin/claude-config | Install hygiene, synced-vs-local drift reporter | 2026-07-04 |
| 5 | VoltAgent/awesome-claude-code-subagents | github.com/VoltAgent/awesome-claude-code-subagents | Model-routing-by-role reference (catalog, not install) | 2026-07-06 |
| 6 | wshobson/agents | github.com/wshobson/agents | Largest agent/workflow set (catalog, not install) | 2026-07-06 |
| 7 | hesreallyhim/awesome-claude-code | github.com/hesreallyhim/awesome-claude-code | Discovery hub — track what's new | 2026-07-04 |
| 8 | Karpathy methodology | github.com/karpathy/autoresearch | Agentic engineering: human as oversight, program.md | 2026-07-04 |
| 9 | elder-plinius/CL4R1T4S | github.com/elder-plinius/CL4R1T4S | Frontier-tool system-prompt patterns (coding directives) | 2026-07-05 |
| 10 | ciembor/agent-rules-books | github.com/ciembor/agent-rules-books | SE-book wisdom distilled to agent rules | 2026-07-05 |
| 11 | google/eng-practices | github.com/google/eng-practices | Code-review standard: code health, small CLs | 2026-07-05 |

Tooling watched (patterns only, never installed): Owloops/claude-powerline + ccusage (statusline/budget segment ideas), AIRIS gateway (lazy HOT/COLD spawn), Claude Squad (worktree fleets), anthropics/skills (first-party skills land here first).

## Boundaries

- Read-only toward config: cloud NEVER edits; all changes proposed in the issue for local application
- No secrets: git-crypt files remain encrypted in the clone; never attempt to decrypt or request keys
- If the dotfiles repo or GitHub is unreachable: report what was skipped — never fabricate findings
- Issue hygiene: one issue per run; close superseded prior issues with a pointer

## Setup (one-time, done locally)

1. `/schedule` → weekly cron `0 3 * * 0`, prompt: "Run the improve-claude-cloud skill workflow"
2. Requires: GitHub repo access to the dotfiles remote, issue-create permission, PushNotification
3. Verify first run manually before trusting the schedule

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-07-06 | Initial. Companion to improve-claude v2.1 (runs its automatable subset in the cloud); benchmark list seeded from 5 research passes |
