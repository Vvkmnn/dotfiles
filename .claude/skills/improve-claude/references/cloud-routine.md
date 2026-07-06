# Cloud Phase — Weekly Remote Routine

Runbook for `improve-claude cloud` (was standalone improve-claude-cloud v1.0.0 — merged 2026-07-06 per no-3-word-skills rule; original archived).

Runs weekly on Anthropic infra via `/schedule` (`0 3 * * 0`, Sunday 3am). Cloud sessions are ephemeral: clone the dotfiles repo (it contains ~/.claude config; git-crypt files stay encrypted — work with the tracked plaintext files only), do read-only analysis, report out. NEVER modifies config from the cloud — findings land as a GitHub issue the user applies locally via improve-claude.

## Weekly Workflow

1. **Clone + health subset**: run improve-claude's budget sweep + drift gates against the clone (line budgets, stale model names, dead skill refs, `> Updated:` marker ages, CHANGELOG entry age)
2. **Product updates sweep** — every surface:
   - Claude Code: CHANGELOG since last run (new features/deprecations affecting our config)
   - claude.ai app: release notes / feature announcements (memory, Projects, Skills changes)
   - iOS + macOS desktop: app updates worth enabling
   - API/models: new models, pricing changes, deprecations (affects switch-claude tables + statusline)
3. **Benchmark list refresh**: check each entry below for updates (last-push date, new patterns); hunt ONE new candidate per run; propose add/drop to keep list ≥7 and current
4. **Cross-surface harmony**: flag drift candidates from the parity checklist's recurring items (S1 instructions mirror, S2 skills bridge, S9 model defaults, S11 repo configs)
5. **Report — Claude-native loop (2026-07-06 design)**:
   - **Mechanical fixes** (stale refs, budget breaches, doc markers): push a branch `claude/weekly-audit-YYYYMMDD` with the actual diffs + open a PR (NEVER touch main). Applying = user merges + machines pull. Cloud never edits any machine directly — it edits a branch; the merge IS the approval.
   - **Judgment items** (adopt/skip decisions, benchmark changes, harmony flags): GitHub issue tagged `claude-maintenance` — sections: Drift gates | Product updates | Benchmark changes | Harmony flags | Proposed actions (one-line + effort each).
   - **Delivery in Claude, via Claude**: PushNotification "Weekly Claude audit: N items (PR #X)" — and the run itself stays in the claude.ai session list: open it from iOS/desktop and talk to it ("explain finding 3", "amend the PR") — it still holds repo + analysis context.

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

1. `/schedule` → weekly cron `0 3 * * 0`, prompt: "Run the improve-claude skill, cloud phase (references/cloud-routine.md)"
2. Requires: GitHub repo access to the dotfiles remote, branch-push + PR + issue permissions, PushNotification
3. Verify first run manually before trusting the schedule

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-07-06 | Initial. Companion to improve-claude v2.1 (runs its automatable subset in the cloud); benchmark list seeded from 5 research passes |
