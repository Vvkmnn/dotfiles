# ~/.claude — Claude Code Configuration

> The map of this setup: what lives where, why, and the principles that keep it lean.
> The log: [docs/CHANGELOG.md](docs/CHANGELOG.md) · Operations + how to drive it: [docs/CONFIG.md](docs/CONFIG.md)

## Architecture

| Layer | Location | What it does |
|-------|----------|--------------|
| Instructions | `CLAUDE.md` | Global rules index — thin, points into `rules/` |
| Rules | `rules/*.md` | One concept per file: explore, verify, test, teach, minimize, recover, avoid, code, orchestrate, preview, plan |
| Skills | `skills/*/SKILL.md` | 19 owner skills in 6 groups (CLAUDE/SHIP/KNOW/SYSTEM/WEB/PERSONAL) + 10 vendored (never token-edited). Retired versions: `skills/.archive/` |
| Agents | `agents/*.md` | 5 roles: architect (opus/max), code-reviewer + security-reviewer (sonnet gates), debugger (inherit), paper-researcher (background academic). Commands dispatch them explicitly |
| Hooks | `hooks/*.js` + settings.json | 9 events wired: session-start (maintenance nudge), user-prompt-submit (per-turn branch/plan/type context), pre/post-tool-use (guards + slow-op nudge), subagent telemetry, pre-compact (plan checkpoint), notification |
| Statusline | `statusline.sh` | v2: `ॐ Fᵀˣ ψ κ μ λ σ θ π $` — ॐ doubles as vim-state (orange/green/gold); header comment documents every segment. `STATUSLINE_MINIMAL=1` = early-warning-only display |
| MCP | `mcp/config.json` + `docs/CONFIG.md` (MCP section) | TBXark proxy on :9090, Bearer-auth gated. 14 active servers; 12 parked under `disabledServers` (CLI-first fleet table in CONFIG) |
| Memory | `projects/*/memory/` | Native /memory (MEMORY.md index + one fact per file) |
| Plans | `plans/*.md` | Living plan files; lifecycle in `rules/plan.md` |
| Docs | `docs/` — CHANGELOG (the log) + CONFIG (operations) | README = current state; CHANGELOG = log with reasoning (upcoming + reference + dated entries); CONFIG = Playbook + Settings + MCP + Plugins in one. Root keeps only loader-mandated CLAUDE.md + README.md |

## Governing Principles

1. **Build, don't replace** — extend our own files; steal *patterns* from the community, never artifacts. Local convention wins unless objectively broken.
2. **Condense, modularize, simplify** — structure budgets enforced weekly (CLAUDE.md ≤110 lines, rules ≤120, SKILL.md ≤400 + `references/`, agents ≤90). Every addition displaces or justifies its tokens.
3. **CLI-first, MCP-when-earned** — a server must beat the CLI/native equivalent to hold a slot (gh, tmux, osascript, yt-dlp, agent-browser, ast-grep won their fights; notion, reddit, paper_search, fred, anki etc. keep theirs).

## Maintenance

- `improve-claude` skill — 8 phases (health/audit/analyze/refresh/cleanup/evolve/parity/cloud); health runs budget + drift gates; cloud = weekly /schedule routine (all-surface sweep + benchmark list → GitHub issue)
- Synced via bare dotfiles repo (`dotfiles` alias); secrets git-crypt'd, key in 1Password. Machine bootstrap: `~/.ai/README.md`

## Model Strategy (Max 20x, July 2026)

20x is the plan; models are choices within it: **Default** (= Opus 4.8 + auto-Sonnet fallback) for daily work, **Fable 5** per-session via `/model` for the hardest long-horizon runs, effort `xhigh` when it matters. Details: `switch-claude` skill.
