# dotfiles log

changelog for this dotfiles repo — shell · terminal · wm · claude · setup, any
change of any kind. the dated record; newest first. current state lives in the
[README](README.md). (claude-config has its own log at `.claude/docs/CHANGELOG.md`;
this one is the repo-wide one.)

**format** — newest first · `## YYYY-MM-DD` · **bold-grouped** bullets that carry the *why* (not just
the *what*) · an optional `### why / decisions` block for roads-not-taken · and **every entry ends with a
`**commits:**` line linking its SHAs** (`github.com/Vvkmnn/dotfiles/commit/<sha>`) so the log is always
one hop from the diff. new entries follow this; the `update-dotfiles` skill enforces it.

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
  → ~/Downloads` agent auto-drains it. **why a daemon, not pbcopy:** the headless hub has no GUI
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
- **P1 is the gate:** the m4 can't push its own commits until the one-line `~/.zshenv:92` fix lands —
  the `-S "$SSH_AUTH_SOCK"` guard *passes* on macOS's valid-but-empty launchd agent, so the 1Password
  override never runs and every github push falls back to gh-HTTPS. `-n "$SSH_CONNECTION"` fixes it: 1P
  socket locally, forwarded agent under `ssh -A`. owned by the a18 (it has Touch-ID); once it lands, the m4
  pushes itself through the a18's forwarded agent.
- **claude config: no model pin + never silent-switch me.** dropped the `model` pin from
  `.claude/settings.json` — on max 20x the platform default *is* the daily driver, so no key
  (`opusplan` is a cheaper-plan lever only; a specific model rides per-project in that
  project's `.claude/settings.json`). **the load-bearing toggle: `switchModelsOnFlag: false`** —
  fable's safety classifier falls back to opus on flagged content, and this makes that a
  *pause-and-ask*, never a silent swap, so the model is never changed without a chance to fix.
  **why fleet-wide:** `settings.json` is tracked → syncs; the `/config` UI toggles
  (`externalEditorContext`, copy-on-select) land in gitignored `.claude.json` → per-machine.
  the full two-file sync model + classifier levers captured in `.claude/docs/CONFIG.md`.

**commits:** [`7f51437`](https://github.com/Vvkmnn/dotfiles/commit/7f51437c) theme+daemons · [`8d8b416`](https://github.com/Vvkmnn/dotfiles/commit/8d8b416a) rewire · [`203c821`](https://github.com/Vvkmnn/dotfiles/commit/203c821b) vsend+colours · [`d0836c0`](https://github.com/Vvkmnn/dotfiles/commit/d0836c03) palette-SGR · [`af42509`](https://github.com/Vvkmnn/dotfiles/commit/af425097) screenshot · [`5a7426e`](https://github.com/Vvkmnn/dotfiles/commit/5a7426e9) this log — plus the day's earlier fleet infra: [`64a83f0`](https://github.com/Vvkmnn/dotfiles/commit/64a83f05) tailscale-login · [`0b43b89`](https://github.com/Vvkmnn/dotfiles/commit/0b43b89c) badge · [`512d0af`](https://github.com/Vvkmnn/dotfiles/commit/512d0af0) cargo-guard · [`b664bf8`](https://github.com/Vvkmnn/dotfiles/commit/b664bf89) claude-model-policy

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

**commits:** [`cdeeb5f`](https://github.com/Vvkmnn/dotfiles/commit/cdeeb5fa) vw-tree · [`0b9f317`](https://github.com/Vvkmnn/dotfiles/commit/0b9f3177) + [`5eaf051`](https://github.com/Vvkmnn/dotfiles/commit/5eaf051f) pop-window · [`8543dff`](https://github.com/Vvkmnn/dotfiles/commit/8543dff5) ghostty · [`247a845`](https://github.com/Vvkmnn/dotfiles/commit/247a845c) vssh/vw → `.fleet` · [`6801c08`](https://github.com/Vvkmnn/dotfiles/commit/6801c084) log stood up · [`a0eb899`](https://github.com/Vvkmnn/dotfiles/commit/a0eb8993) update-dotfiles docs-first · [`58c3097`](https://github.com/Vvkmnn/dotfiles/commit/58c30972) λ palette — same day, the v-macos merge finalized: [`61109b1`](https://github.com/Vvkmnn/dotfiles/commit/61109b19) scale · [`cf6b4a6`](https://github.com/Vvkmnn/dotfiles/commit/cf6b4a63) setup s_ · [`0ca259d`](https://github.com/Vvkmnn/dotfiles/commit/0ca259dc) ssh config · [`cf11abf`](https://github.com/Vvkmnn/dotfiles/commit/cf11abf3) backup

## 2026-07-11

fleet navigation born + the pre-merge capture, on the way to unifying every mac onto `v-macos`.

- **fleet verbs `vssh`/`vremote`/`vw`/`vj`** — reach any fleet mac by its real (Tailscale MagicDNS) name;
  the seed of today's `.fleet`. **why:** one set of verbs to move between machines from anywhere.
- **capture-first, lose nothing** — rust → mise, GOPATH → `~/.go`, and atuin / borders / apple-handoff /
  settings all tracked *before* the merge, so no machine-local config was dropped when the fleet unified.

**commits:** [`d831fbe`](https://github.com/Vvkmnn/dotfiles/commit/d831fbe8) fleet nav · [`5539fc9`](https://github.com/Vvkmnn/dotfiles/commit/5539fc9f) + [`671b7fd`](https://github.com/Vvkmnn/dotfiles/commit/671b7fdd) rust→mise · [`beaece8`](https://github.com/Vvkmnn/dotfiles/commit/beaece86) GOPATH→~/.go · [`2083662`](https://github.com/Vvkmnn/dotfiles/commit/20836626) atuin · [`2a445d7`](https://github.com/Vvkmnn/dotfiles/commit/2a445d7d) + [`179bb9a`](https://github.com/Vvkmnn/dotfiles/commit/179bb9a3) borders · [`fcba9dc`](https://github.com/Vvkmnn/dotfiles/commit/fcba9dca) apple-handoff · [`2a30bb1`](https://github.com/Vvkmnn/dotfiles/commit/2a30bb16) settings capture

## 2026-07-07

the m4 joins the fleet — tmux identity + parity, and the machine-agnostic setup rails.

- **badge + full `tmux.conf` parity** on the m4 (blue pill). rust → mise, untracking 33 MB of
  committed `.cargo` binaries. `phase_gitauth` — GitHub auth via the **1Password SSH agent** + a fetch
  refspec (the auth story this whole fleet still runs on).
- setup hardened: tmux-plugin install (`TMUX_PLUGIN_MANAGER_PATH` + sentinel verify — a "succeeds while
  installing nothing" trap), post-reboot findings logged to `~/.ai`.

**commits:** [`f820d3a`](https://github.com/Vvkmnn/dotfiles/commit/f820d3a0) badge/parity · [`8136691`](https://github.com/Vvkmnn/dotfiles/commit/81366918) rust→mise, untrack .cargo · [`1cdbdcb`](https://github.com/Vvkmnn/dotfiles/commit/1cdbdcb5) 1P gitauth + refspec · [`fcd6b42`](https://github.com/Vvkmnn/dotfiles/commit/fcd6b42e) tmux-plugin harden · [`a2e1181`](https://github.com/Vvkmnn/dotfiles/commit/a2e11818) findings

## 2026-07-06

the m4 cold-start — the headless bootstrap that seeded the fleet.

- **bare-repo bootstrap** — early mise/node provisioning, git-crypt bare-repo/1P/verify fixes, no-TTY
  sudo askpass, and guarded zoxide/mise/atuin init for the pre-install window (a shell that has to start
  cleanly *before* its own tools exist). bootstrap findings (FDA restart, hooks/node) logged to `~/.ai`.

**commits:** [`442633c`](https://github.com/Vvkmnn/dotfiles/commit/442633c8) mise/node + git-crypt · [`ef5638e`](https://github.com/Vvkmnn/dotfiles/commit/ef5638e2) sudo askpass + casks · [`a790381`](https://github.com/Vvkmnn/dotfiles/commit/a790381c) guarded init · [`dacf731`](https://github.com/Vvkmnn/dotfiles/commit/dacf7314) bootstrap findings

