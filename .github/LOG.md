# dotfiles log

changelog for this dotfiles repo — shell · terminal · wm · claude · setup, any
change of any kind. the dated record; newest first. current state lives in the
[README](README.md). (claude-config has its own log at `.claude/docs/CHANGELOG.md`;
this one is the repo-wide one.)

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
- **this log** — stood up `~/.github/LOG.md` as the repo-wide dotfiles changelog.

### notes

- reading a tmux client's current session: use `list-clients` / `#{client_session}`,
  not `display-message -c <tty> '#{session_name}'` — the latter resolves against the
  current target, not the client, and lies.
- `▶`/`◀` assume single-width rendering in ghostty; if the self row's vitals shift a
  column relative to the peers, swap for a narrower glyph.
