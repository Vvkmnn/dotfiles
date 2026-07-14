# dotfiles log

changelog for this dotfiles repo — shell · terminal · wm · claude · setup, any
change of any kind. the dated record; newest first. current state lives in the
[README](README.md). (claude-config has its own log at `.claude/docs/CHANGELOG.md`;
this one is the repo-wide one.)

## 2026-07-14

- **theme → single `~/.theme` entrypoint + `~/.config/theme/`.** promoted the theme to a first-class
  `~/.theme` file (defines the palette, sources the per-tool shell bits) that *uses* the moved
  `~/.config/theme/` asset folder; `palette.sh` gains ANSI-SGR forms (`$KANAGAWA_*_SGR`) + a `CUSTOM_DIM`
  for the one off-Kanagawa grey; `.fleet`'s 5 hardcoded truecolor decls now reference the shared vars.
- **`~/.daemons/` — custom launchd registry.** first-class folder (like `~/.assets`) holding every
  hand-authored daemon template centrally (tmux · tmux-save · mcp-proxy · new taildrop-receive) + a
  README map; `~/.ai/setup` (`s_services`) globs the one folder. copy-not-symlink is correct — Sonoma
  14+ launchd ignores symlinked plists at login.
- **`com.user.taildrop-receive`** — KeepAlive `tailscale file get --loop` agent so Taildrop'd files
  auto-land in `~/Downloads` (works headless — the mini receives via this, not pbcopy).
- **`vsend <file> [host]`** — new fleet verb: Taildrop a file to a machine's `~/Downloads` (no-host →
  fzf picker). hand local context to another machine's Claude — files cross a text terminal, images can't.
- **screenshot resize 700 → 1568.** `smart-screenshot-resize.sh` sizes to 1568px (keeps dense text
  legible AND under Claude's downscale threshold; 700 was too small); native `osascript` notification
  replaces the `terminal-notifier` dep.

### notes
- pending (need a GUI machine + P1): the screenshot vj/vr context-routing (kept OUT of the hot path —
  a Karabiner var the `vj` wrapper sets passes the target as an arg, no per-shot osascript title-read),
  and the P1 auth fix (`~/.zshenv:92` `-S` guard → `-n "$SSH_CONNECTION"`: 1P socket used locally, the
  forwarded agent under `ssh -A`). the mini can't push until P1 lands.

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
