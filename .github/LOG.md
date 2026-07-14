# dotfiles log

changelog for this dotfiles repo — shell · terminal · wm · claude · setup, any
change of any kind. the dated record; newest first. current state lives in the
[README](README.md). (claude-config has its own log at `.claude/docs/CHANGELOG.md`;
this one is the repo-wide one.)

## 2026-07-14

post-merge, opening the "seamless fleet" layer — sit at any mac, work on/from any other. a long
research session grounded every choice; the load-bearing ones carry their *why* below, because the
reasoning is the part that's expensive to rediscover.

- **theme → one `~/.theme` file + `~/.config/theme/` assets.** the palette was already centralized
  (`~/.theme/palette.sh`, sourced by `.shell`) but as a *folder* in `$HOME`, which the owner didn't
  want — home stays clean. so the assets moved to `~/.config/theme/` and `~/.theme` became a first-class
  *entrypoint file* that defines the palette and sources the per-tool shell bits: the whole theme is one
  home-level file that *uses* the config folder. **why the SGR forms:** `.fleet`'s verbs print colour
  with ANSI truecolor escapes (`\e[38;2;r;g;bm`) but `palette.sh` held hex only — so it now derives
  `$KANAGAWA_*_SGR` from the hex (single source, one `_sgr` helper). **why `CUSTOM_DIM`:** `.fleet`'s dim
  grey `#72747c` isn't a real Kanagawa Wave colour, so it's namespaced `CUSTOM_*` — the `KANAGAWA_*` set
  stays canonical and the fleet look is preserved exactly.
- **`~/.daemons/` — a first-class launchd registry, like `~/.assets`.** custom daemons had been
  proliferating (tmux, tmux-save, mcp-proxy, now a Taildrop receiver) and scattered across `~/.config/tmux`
  and `~/.claude/mcp`. researched how well-run dotfiles handle this: one central folder of reverse-DNS
  `*.plist.template`s + a script that renders + `launchctl bootstrap`s them. **the load-bearing finding:**
  macOS Sonoma 14+ `launchd` *ignores symlinked plists at login*, so copy-and-render (which `~/.ai/setup`
  already does) isn't a preference, it's the only correct approach — validated our mechanism. all four
  templates centralized + a `README.md` map (a manifest is above the norm; most repos let the folder be
  the registry); `s_services` globs the one folder.
- **`com.user.taildrop-receive`.** `vsend` drops a file into a peer's Taildrop *inbox*, but on macOS it
  then sits there until `tailscale file get` runs — not seamless. a KeepAlive `tailscale file get --loop
  → ~/Downloads` agent auto-drains it. **why a daemon, not pbcopy:** the headless mini has no GUI
  pasteboard, so it must receive via the filesystem — Taildrop needs no GUI.
- **`vsend <file> [host]`.** the felt pain: you can't paste a screenshot/file into a Claude running on
  *another* machine over an ssh/mosh terminal — image bytes can't cross a text pty. so send the *file*
  (Taildrop) and reference its path. `vsend` is the verb; no host → the existing `_fleet_menu` fzf picker.
- **screenshot resize 700 → 1568.** the capture→resize→clipboard flow shrank to 700px. research: Claude
  only downscales above **1568px** (2576 on Opus 4.8), and image token cost is ~w·h/750 — so 700 threw
  away text legibility for no real token saving. 1568 keeps dense text readable and still dodges the
  downscale. also dropped the `terminal-notifier` dep for a backgrounded native `osascript` notification.

### why / decisions worth keeping
- **transport (not yet built):** mosh stays the daily `vj` until the ssh+tmux swap lands, because the one
  thing that forced the whole re-think is that **mosh can't forward the 1Password agent** — no Touch-ID
  git-push from a remote session. ssh+tmux can, at the cost of a reconnect wrapper; tmux makes the old
  "ssh SIGHUP kills my session" objection obsolete (verified — the pane's children belong to the tmux
  server daemon, not the ssh pty).
- **screenshot context-routing deferred on purpose (speed):** detecting local/vj/vr *in* the capture
  script means an `osascript` window-title read on every shot (~150ms) — too slow, and the owner flagged
  it. the fast design: the `vj` wrapper sets a Karabiner variable and passes the target as an arg, so
  there's zero per-shot probe. built the fast base now; routing rides P3 + a GUI machine to test.
- **P1 is the gate:** the mini can't push its own commits until the one-line `~/.zshenv:92` fix lands —
  the `-S "$SSH_AUTH_SOCK"` guard *passes* on macOS's valid-but-empty launchd agent, so the 1Password
  override never runs and every github push falls back to gh-HTTPS. `-n "$SSH_CONNECTION"` fixes it: 1P
  socket locally, forwarded agent under `ssh -A`. owned by Neo (it has Touch-ID); once it lands, the mini
  pushes itself through Neo's forwarded agent.

## 2026-07-13

- **vw tree — borderless vitals.** one filled identity pill per machine (self gold,
  peer signature hue) carrying power-shape · name · chip; vitals after it are plain
  text — dim labels, health-tinted numbers, `·` separators — so nothing opaque floats
  over a translucent terminal. this machine is framed with gold `▶ … ◀` triangles
  instead of a word label.
- **pop-window (`⌥⏎`) — no orphan or frozen leftovers.** popping a tmux window into
  its own session + a fresh ghostty now closes only the clients the move strands: a
  sole-window source whose client got relocated (the fleet runs `detach-on-destroy
  off`, so a dead session switches its client onto another rather than exiting), or a
  throwaway `vw` picker view (`destroy-unattached on`). a normal multi-window source is
  left intact — its surviving client drops to the nearest window on the **left** and
  any copy-mode is cancelled, so it never lands frozen (`[0/N]`).
- **ghostty `super+enter=ignore`** — stops `cmd+enter` doubling the `⌥⏎` pop.
- **fleet verbs collapsed to `vj·vw·vr·vd`.** the old `~/.functions` set — `vssh` (→`vj`),
  `vwatch` (→`vw`), `vremote` (→`vr`), `vdebug` (→`vd`), `coffee` (engine folded into
  `vw`) — is deprecated and commented out, each with a pointer to its `~/.fleet`
  successor. `.fleet` is self-contained and sourced after `.functions`, so it fully
  supersedes the old block.
- **this log** — stood up `~/.github/LOG.md` as the repo-wide dotfiles changelog.

### notes

- reading a tmux client's current session: use `list-clients` / `#{client_session}`,
  not `display-message -c <tty> '#{session_name}'` — the latter resolves against the
  current target, not the client, and lies.
- `▶`/`◀` assume single-width rendering in ghostty; if the self row's vitals shift a
  column relative to the peers, swap for a narrower glyph.
