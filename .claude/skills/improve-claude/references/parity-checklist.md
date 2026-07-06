# Parity Phase — Fleet & Surface Checklist

Researched 2026-07-05 (official docs, high confidence unless flagged). One-time items set once per machine/account; recurring items drift and need periodic re-checks.

## Fleet (multi-machine Claude Code)

| # | Check | Type |
|---|-------|------|
| F1 | Dotfiles uncommitted count <10; last commit recent | Recurring |
| F2 | mcp-proxy runtime trio present: `mcp/bin/mcp-proxy` (arm64 binary), `mcp/bin/start-proxy.sh` ($HOME paths), `~/Library/LaunchAgents/com.claude.mcp-proxy.plist` — tracked template in mcp/ | Per machine |
| F3 | Proxy running: `pgrep -fl mcp-proxy`; restart via `launchctl kickstart -k gui/$(id -u)/com.claude.mcp-proxy` | Recurring |
| F4 | git-crypt unlocked (mcp/config.json readable as JSON, not GITCRYPT blob) — key via 1Password `Personal/Dotfiles/dotfiles.key` | Per machine |
| F5 | Plugins rebuilt from known_marketplaces.json + enabledPlugins; skill submodules initialized (`git submodule update --init`) | Per machine |
| F6 | `claude /login` completed (`.claude.json` oauth is machine-local, never synced) | Per machine |
| F7 | settings.local.json holds ONLY machine-specific bits (permissions, local paths) | Recurring |

## Surfaces (Claude app iOS / macOS desktop / claude.ai web)

| # | Check | Surface | Type |
|---|-------|---------|------|
| S1 | claude.ai Profile matches the canonical mirror in docs/CONFIG.md ("claude.ai Profile" section — the single source; NO auto-sync, re-paste after edits there) | claude.ai | Recurring |
| S2 | Reusable behaviors encoded as Skills enabled on claude.ai (the ONLY bridge — they auto-load into cloud Code sessions) | claude.ai→cloud | Recurring |
| S3 | Privacy toggle set intentionally (Settings→Privacy→"Improve Claude": affects retention 30d vs ~5y; wrong compliance config disables Remote Control) | Account | One-time |
| S4 | GitHub linked for web/teleport: `/web-setup` or GitHub App | Account + per Mac | One-time |
| S5 | Remote Control default on (`/config`) — sessions steerable from iOS | Per Mac | One-time |
| S6 | iOS app signed in, push notifications enabled (`/config` push toggles) | iOS | One-time |
| S7 | Desktop Dispatch paired with phone (Cowork tab) | Per Mac | One-time |
| S8 | Desktop connectors pruned to used set (Settings→Connectors); after adding desktop MCPs run `claude mcp add-from-claude-desktop` | Desktop | Recurring |
| S9 | Model default per surface matches intent (they're independent) | All | After model changes |
| S10 | Quota awareness: ONE shared Max 20x pool across Code/chat/Cowork/Design — `/usage` + Desktop ring | All | Recurring |
| S11 | Project `.claude/` carries what cloud sessions need (cloud sees only committed config, never ~/.claude) | Repos | Recurring |
| S12 | Teleport prerequisites when needed: clean tree, branch pushed, same account | Per repo | Situational |
| S13 | Google connectors (Gmail/Calendar/Drive) — first-party OAuth: connect ONCE on claude.ai (covers web+desktop), authenticate per-Mac in Claude Code (`/mcp` → OAuth; separate from mcp-proxy fleet). Read/search/draft only, never sends | Account + per Mac | One-time |

## Facts that shape the checks (verified against official docs)

- claude.ai memory ≠ Code memory: no sync, by design; updates ~24h, excludes Projects chats
- Cloud sessions clone from GitHub, not local disk — push before `--cloud`
- `--teleport` pulls cloud→local; local→web push is Desktop-only ("Continue in")
- Remote Control requires Claude Code v2.1.51+; push notifications v2.1.110+
