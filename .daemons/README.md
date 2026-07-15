# ~/.daemons — custom launchd daemon registry

First-class home (like `~/.assets/` for vendored fonts) for every **custom** launchd
agent/daemon in these dotfiles. One folder · one installer · one map.

## Map — what's built

| Label (= filename)          | What it does                                   | Lifetime / trigger                    | Domain      |
|-----------------------------|------------------------------------------------|---------------------------------------|-------------|
| `com.user.tmux`             | resident tmux server (`tmux-server.sh`)        | KeepAlive · RunAtLoad                 | tmux        |
| `com.user.tmux-save`        | tmux save-loop (every `SAVE_INTERVAL`s)        | loop                                  | tmux        |
| `com.claude.mcp-proxy`      | MCP proxy (`start-proxy.sh`)                    | KeepAlive                             | claude/mcp  |
| `com.user.taildrop-receive` | fleet Taildrop auto-receiver → `~/Downloads`   | `tailscale file get --loop`, KeepAlive| fleet/media |

Brew-managed services (yabai · skhd · sketchybar · menuanywhere) are **not** here — `brew services` owns them.

## How they install — `~/.ai/setup` → `s_services`
Each `com.*.plist.template` is **rendered** (`__HOME__` → `$HOME`) and **copied** into
`~/Library/LaunchAgents/`, then `launchctl bootout` + `bootstrap gui/$(id -u)`.
- **Copy, not symlink** — macOS Sonoma 14+ `launchd` ignores *symlinked* plists at login (verified).
- `~/Library/LaunchAgents/` is the install target — **never tracked**.
- Idempotent: re-running setup re-renders + re-bootstraps.

## Conventions
- **Filename = the launchd `Label`** (reverse-DNS `com.<owner>.<svc>`).
- **Absolute** binary paths in the plist (launchd won't expand `~`/`$HOME`); use `__HOME__` for `$HOME`.

## Add a daemon
1. Drop `com.<owner>.<svc>.plist.template` here (use `__HOME__` for `$HOME`).
2. Add a row to the map above.
3. Run `~/.ai/setup` (its `s_services` phase) — it installs it.

## Status / debug
`launchctl print gui/$(id -u)/<label>` · logs per each plist's `StandardErrorPath`.
