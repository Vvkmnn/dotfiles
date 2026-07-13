---
name: ssh-fleet
version: 1.0.0
description: Operate the owner's personal 3-Mac fleet (vMiniM4 hub + vBookAirM3 + vBookNeo) from any machine — read/write tmux sessions on any reachable box, hand a task to another machine's Claude, inspect what's running, and route heavy work to the mini — all over Tailscale + mosh with 1Password auth. Use when the user asks to reach/inspect/drive another fleet machine, offload work to the mini, message another Claude ("tell the mini's Claude to…"), see what's running across machines, or wake/keep a machine available.
---

# Fleet Control

Shared cross-AI policy lives in `~/.ai/fleet.md`; this skill is Claude's thin
operational adapter.

Drive the owner's 3-Mac fleet from whichever machine you're on. **Identical dotfiles everywhere** (parity via a bare git repo), a **Tailscale** mesh, and **1Password shared-key** auth — so the same commands and the same tmux/nvim behave identically on every box, and **only the owner's own devices can reach anything** (Tailscale is the gate; nothing is exposed publicly).

## Topology — roles matter for routing

| host (MagicDNS) | machine       | chip    | role |
|-----------------|---------------|---------|------|
| `vminim4`       | Mac mini      | M4      | always-on **HUB** · heaviest · plugged in → send heavy/long/parallel work HERE |
| `vbookairm3`    | MacBook Air   | M3      | fanless laptop · sometimes-on |
| `vbookneoa18`   | MacBook (Neo) | A18 Pro | lightest laptop · sometimes-on |

A machine only answers **while awake**. Laptops sleep on lid-close/battery — a mosh session freezes and **resumes on wake** (tmux persists server-side, nothing lost). To keep one reliably reachable, the owner runs `vwatch` on it.

## Reach commands (defined in ~/.functions on every machine)

- `vssh <host>` — mosh into that machine's tmux in a fresh Ghostty window (interactive, for the human)
- `vremote <host>` — screen-share (VNC) in
- `vwatch` — keep THIS machine awake + a live power/agents dashboard
- `_fleet_host <name>` — resolves bare name (Tailscale MagicDNS) → `<name>.local` (Bonjour); **returns non-zero if unreachable** — use it to fail fast

## ALWAYS check reachability first — never hang

```bash
tailscale ping -c1 <host> >/dev/null 2>&1 || { echo "<host> unreachable — asleep/offline"; }
# or: _fleet_host <host> >/dev/null || echo "unreachable"
```
A sleeping laptop won't answer; report it, don't spawn a dead window or block.

## Read a remote machine's tmux (non-interactive — this is how YOU inspect it)

Over ssh (rides Tailscale + the 1P key, so it's silent once approved):
```bash
# what's running on <host>?
ssh <host> 'tmux list-windows -a -F "#{session_name}:#{window_index} #{window_name} #{pane_current_command} #{@agent_status}"'
# read a specific window/pane
ssh <host> 'tmux capture-pane -p -t <session>:<window>'            # current screen
ssh <host> 'tmux capture-pane -p -S -200 -t <session>:<window>'    # last 200 lines of scrollback
```
`@agent_status` is reserved but is not currently wired by a shared hook. Treat
`pane_current_command` plus `capture-pane` output as truth; an empty status does
not mean the AI is idle.

## Write to / run on a remote machine's tmux

```bash
# type a command + Enter into a window
ssh <host> 'tmux send-keys -t <session>:<window> "the command here" Enter'
# spin up a window to run heavy work on the mini
ssh vminim4 'tmux new-window -n build -c ~/proj "make -j"'
```

## AI → AI (hand a task to another machine)

Every machine runs Claude with `remoteControlAtStartup: true`. To delegate to the mini's Claude FROM another machine, send-keys into its Claude window:
```bash
# 1. find the Claude window on the target
ssh vminim4 'tmux list-windows -a -F "#{session_name}:#{window_index} #{window_name}" | grep -i claude'
# 2. send it a prompt (arrives as input at that Claude's prompt)
ssh vminim4 'tmux send-keys -t <claude-window> "Please run the heavy build and summarize the result" Enter'
# 3. read its reply later
ssh vminim4 'tmux capture-pane -p -S -100 -t <claude-window>'
```
The same pattern works for a Codex TUI window. This is how "tell the mini's AI to
do X from Neo" works—nothing new is exposed; tmux is driven over the same
authenticated link.

## Route work by machine weight

- **Heavy / long / parallel** (builds, big compiles, data jobs, anything that should keep running) → **`vminim4`** (M4, plugged in, never sleeps).
- **Light / interactive / on-the-move** → the laptop you're on.
- To offload: open a window on the target and run there, or hand it to that machine's Claude (above), then poll the pane for the result.

## Non-negotiable rules

1. **Reachability check before every remote op** — a sleeping laptop won't answer. Report it; don't hang.
2. **Auth = 1Password over Tailscale.** Nothing is manually keyed; only the owner's tailnet devices qualify. **Never drop/hardcode SSH keys** — the machine self-qualifies from the vault via `setup remote`.
3. **Parity:** tmux/nvim/commands are byte-identical everywhere — what works locally works remotely.
4. **Power stays hands-off** — the owner keeps machines awake on demand with `vwatch`, gracefully per device. Don't force never-sleep.
5. **mosh persists server-side** — a dropped link resumes on wake; the tmux session is never lost.

## Related

- `isolate-tmux` — local tmux session isolation; this skill is its cross-machine counterpart.
- `setup-dotfiles` / `update-dotfiles` — the byte-identical-dotfiles parity that makes "works locally = works remotely" true. If a remote machine behaves differently, it's a sync gap — resolve there first.
- `second-opinion` — the fleet's Claude→Claude handoff is a heavier cousin: delegate to another machine's Claude when the work needs *that* box (the mini's power), not just a fresh model.
