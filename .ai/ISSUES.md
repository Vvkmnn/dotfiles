# ISSUES.md — dotfiles-setup post-mortem & error log

Lives in `~/.ai/` — the modernized agent-facing setup home. `.setup/` is left
as-is (legacy package/defaults scripts). Captured while bootstrapping **vBookNeo**
(8GB MacBook, macOS 26) on 2026-06-25 so the next machine goes clean. The
"what broke and why" log.

## Restart-readiness snapshot — 2026-06-26 (READ FIRST if resuming vBookNeo)

vBookNeo is set up + pushed; **one normal restart pending.** State for a fresh Claude:

**Done + committed (origin `v-macos-macbook`, HEAD `7c66f46e`):**
- `~/.ai/setup` = the self-contained one command (inline package list + curated macOS defaults). `.ai/` = `setup` + `README.md` + `ISSUES.md` only (`ai.sh`/`SECRETS.md` removed → folded into README).
- Routing: `~/.claude/CLAUDE.md` ("Machine Setup → macOS") + the `dotfiles-setup` skill both point at `~/.ai/setup`. New machine = point Claude → it finds `.ai/`, no handoff.
- Packages installed (jq/pngpaste/contexts + full set); `font-sf-pro` dropped (plugins use SFMono now).
- Fonts: **SFMono Nerd Font** (vendored `.otf`, `.assets/fonts`, git-crypt) + **Symbols Nerd Font Mono** (cask `font-symbols-only-nerd-font`) installed.
- Curated macOS defaults applied via `setup macos` (menu-bar+dock autohide, finder, fast key-repeat, Stage-Manager-off…). One failed: `com.apple.universalaccess reduceTransparency` → set via System Settings → Accessibility → Display.
- sketchybar `network_boxes.sh`/`clock_analog.sh` switched SF Pro → SFMono Nerd Font.
- BatFi license stored in 1Password (Personal → "BatFi", Software License).

**Check after the restart:**
- **`?` glyphs** — fonts are installed; the restart rebuilds CoreText's fallback cache, which should clear them. If they PERSIST → the cask's Symbols Nerd Font Mono differs from the laptop's exact `NFM.ttf` → `cp ~/.assets/fonts/NFM.ttf ~/Library/Fonts/ && brew services restart sketchybar`.
- Menu-bar autohide needs the re-login to fully take.

**yabai — VERIFIED (2026-06): scripting addition is BROKEN on macOS 26 Tahoe.** `space --focus`/`--destroy` fail even with SIP off; disabling SIP gains nothing (GitHub #2634/2656/2675/2707/2730). → **Basic yabai only — NO scripting-addition, NO SIP-disable, ONE restart (not Recovery).** Space-switching = native Ctrl+←/→. CAVEAT: if `.skhdrc` binds spaces to `yabai -m space --focus`, those hotkeys won't fire on Tahoe → rebind to native Ctrl+arrow (the fleet default for Tahoe).

**The restart = one normal restart** (Apple → Restart). Owner checklist: `?` cleared · menu-bar autohides · yabai/skhd/sketchybar auto-started · space-switch via Ctrl+arrows · approve any Mullvad/AdGuard system-extension prompt.

## TL;DR — the core failure

The bootstrap machinery (`AI.md` + `dotfiles-setup` skill + `ai/` helpers)
**already existed**, but it got **bypassed and hand-rolled** instead of run.
Four root causes:

1. **Planned from a fossil.** First exploration found the **iCloud copy**
   (`~/Library/Mobile Documents/.../Documents/dev/dotfiles`) whose remote refs
   were **13 months stale (April 2025)** — from before `AI.md`/the skill existed.
   So the whole system was invisible; an elaborate from-scratch plan reinvented it.
   → **Rule: always `git fetch` / fresh-clone from origin before reasoning. Never
   a local/iCloud cached ref.** (Now noted in AI.md P0.)
2. **Clutter hid the entry point.** `.setup/` has **36 legacy per-tool scripts**
   plus a deprecated **`setup.sh`** that *looks* like the entry. The real brain
   (`AI.md`) doesn't stand out. → archive legacy; loud "start here" header.
3. **Treated `AI.md` as docs, not as the program.** Even after finding it, the
   phases were hand-rolled (raw `brew bundle`, clipboard gates) instead of
   executed via `ai_gate` / an install step.
4. **Ran installs headless.** Background/sandboxed `brew bundle` has no TTY →
   every sudo cask + App Store app failed. The gates assume an **interactive
   terminal**; that contract wasn't honored.

## Bugs / gaps found in the repo & runbook

- **git-crypt key source** — AI.md P0/P7 said "AirDrop from laptop"; it's actually
  in **1Password → Personal → "Dotfiles" (document) → `dotfiles.key`**. [FIXED in AI.md]
- **macos.sh date** — AI.md caption says "Oct 31 2025"; real last-edit is
  **2025-12-17**. [TODO: fix caption]
- **Untrusted taps** — Homebrew 4.6+ refuses formulae from untrusted third-party
  taps; `brew bundle` aborts on the first (`oven-sh/bun`). AI.md P8 has no
  `brew trust` step. Fix: `brew trust koekeishiya/formulae felixkratz/formulae
  crissnb/dynamicisland acsandmann/tap supabase/tap joachimbrindeau/ccusage-monitor
  epk/epk`. [TODO: add to runbook / ai.sh]
- **Parallel-download lock contention** — Homebrew 5.1.0 parallelises `brew
  bundle`; shared deps (pkgconf/go/cmake) lock-collide → `uv`/`lf`/`bat`/`tmux`
  failed on first pass, fixed by a re-run. [NOTE: re-run is the mop-up]
- **sudo casks** — `karabiner-elements`, `mullvad-vpn` install **system
  extensions** → require sudo; fail headless. [TODO: interactive + sudo keep-alive]
- **mas** — `mas account` subcommand removed; `mas install` needs a signed-in App
  Store **and** the app in purchase history; also hit sudo. Apps: AdGuard, Keynote,
  Pages, Xcode. [NOTE: owner runs in terminal / App Store GUI fallback]
- **menuanywhere** — builds from source; needs **full Xcode** + `xcodebuild
  -license accept`. [NOTE: re-enabled Xcode for it]
- **Brewfile rename** — cask `tailscale` → **`tailscale-app`**. [TODO: rename in Brewfile]
- **Brewfile gaps** — `uv` and `tailscale` were **missing entirely** despite being
  used/needed. [FIXED: added]
- **bun / xcodebuildmcp** — bun has **no homebrew-core formula** (oven-sh tap only)
  → dropped, use `mise use -g bun`. xcodebuildmcp needs Xcode. [FIXED: commented]
- **Hooks need node** — P4 deploys `.claude/hooks/*.js` which run via `node`, but
  node (via mise) isn't installed until P8 → "node: command not found" noise until
  then. Ordering issue. [NOTE: non-blocking; resolves after mise/node]
- **lazygit residue** — aliases lingered in `.alias`/`.shell` after lazygit was
  dropped. [FIXED: commented out]
- **iCloud repo** — `~/.../Documents/dev/dotfiles` corrupted by iCloud
  (`refs/remotes/origin/master 2`), stale since April 2025. [owner handling]

## Agent mistakes (mine)

1. Planned against the stale iCloud copy; reinvented existing machinery.
2. Hand-rolled phases instead of executing `AI.md` via its helpers.
3. Ran `brew bundle` headless → sudo failures; should have handed one interactive
   command from the start (sudo keep-alive pattern).
4. Made a scratch clone `~/dev/dotfiles` (extra artifact; bare `~/.dotfiles` is canonical).
5. Never used `ux.sh` — built UX assumptions instead of using what existed.

## Fixed & pushed this session (branch v-macos-macbook)

- Curated Brewfile: ~140 → ~70 active; unused commented **inline** with reasons; +`uv` +`tailscale`.
- lazygit aliases commented out.
- AI.md: registered `vbookneo` (P15 peer), fetch-fresh P0 note, git-crypt-via-1Password (P0/P7/gates).

## Uncommitted (to batch-commit at end)

- Brewfile: bun→mise, xcodebuildmcp commented, Xcode re-enabled, menuanywhere note.
- This NOTES.md.

## TODO — next-machine fixes

- [ ] AI.md P8: add `brew trust <taps>` + `sudo -v` keep-alive + "run in an
      interactive terminal" contract.
- [ ] Brewfile: `tailscale` → `tailscale-app`.
- [ ] Loud **"FOR THE AGENT: execute, don't improvise; fetch fresh first"** header
      atop AI.md + SKILL.md, with this failure list.
- [ ] Consolidate `ai/{ux,gate,doctor}.sh` → single **`ai.sh`**; move the 36 legacy
      per-tool scripts (incl. deprecated `setup.sh`) into `Archive/`.
- [ ] Fix AI.md macos.sh date caption.
- [ ] Run `doctor.sh` (P18) to verify once interactive installs finish.
- [ ] `ai.sh` §4: detect Xcode at versioned path `/Applications/Xcode-*.app`
      (`xcodes` installs `Xcode-26.5.0.app`, NOT `Xcode.app`) — current
      `[ -d /Applications/Xcode.app ]` misses it; use a glob or `xcodes select`.

## Live-setup findings — 2026-06-26 (the real vBookNeo run)

- **mas-cli is the wrong tool on modern macOS.** `mas install` forces a fresh sudo
  prompt per app (keep-alive can't suppress it), loops, and Apple blocks headless
  App Store installs. → All `mas` apps pulled from the auto path: Keynote/Pages
  **skipped** (MAS-only, optional), AdGuard → **`cask "adguard"`**, Xcode →
  **`xcodes`**. (`brew "mas"` kept only for `mas list`/`upgrade`.)
- **Xcode via `xcodes`** works, with caveats: (1) Apple ID fed from the 1Password
  `Apple` item via `op run` (no secret on disk/env); (2) a **2FA code is still
  required** (Apple policy — codes expire ~30s, enter the freshest, arrow-keys
  corrupt the prompt); (3) installs to a **versioned path**
  `/Applications/Xcode-26.5.0.app`, not `Xcode.app`; (4) the final step needs
  **sudo** (`xcodes` prompts `macOS User Password:`) — if mistyped, Xcode is
  installed but unfinished → run `sudo xcode-select -s <path>/Contents/Developer
  && sudo xcodebuild -license accept && sudo xcodebuild -runFirstLaunch`.
- **`xcodebuild -runFirstLaunch` CoreSimulator error is HARMLESS for us.** It fails
  loading `IDESimulatorFoundation` (iOS Simulator; CoreSimulator.framework missing),
  but macOS builds are fine — `xcodebuild -version` + macOS SDK work, and
  `menuanywhere` built in ~19s right after. Ignore the wall of dyld error.
- **brew tap trust churns.** When a third-party tap is untapped/re-tapped (or
  cleaned), its trust **resets** → `brew bundle` "Refusing to load formula from
  untrusted tap" even though the binary is already installed. Fix: `brew trust
  <tap>` again. This is why `ai.sh` trusts taps **before every bundle** — running
  raw `brew bundle` (bypassing ai.sh) re-broke `yabai`/`skhd`. **Use `ai.sh`,
  not raw `brew bundle`.**
- **Apple passkeys can't live in 1Password** (Apple restricts Apple-ID passkeys to
  iCloud Keychain), and CLI tools can't use passkeys anyway → Apple ID is stored as
  a 1Password **Login item** (email + password); `xcodes` uses it + a 2FA code.
- **`adguard` cask needs sudo** (network system-extension) → owner runs it in a
  terminal; can't be done headless.
- **`node: command not found` in Claude hooks = PATH, not missing node.** node IS
  installed (`/opt/homebrew/bin/node`, plus mise `node@24`). The error happens
  because the running Claude was launched from a shell *before* the dotfiles PATH
  (brew + mise) existed, and hooks run via `/bin/sh` with a stripped PATH. **Fix:
  relaunch Claude from a fresh terminal — `.shell` (`mise activate`, line 188)
  + brew shellenv put node on PATH → hooks work.** This is one of the things the
  one restart cleans up. Robust fix (TODO): make hook commands PATH-independent
  (absolute node path, or set PATH inside the hook) so it never recurs from a bare
  shell or a too-early launch.
- **sketchybar `?` boxes = missing `sketchybar-app-font.ttf`.** sketchybar needs a
  SEPARATE font for app-icon glyphs (your SFMono Nerd Font is fine for everything
  else). Not in the Brewfile → app icons render as `?`. Fix (now in ai.sh TODO):
  `curl -fsSL https://github.com/kvndrsslr/sketchybar-app-font/releases/latest/download/sketchybar-app-font.ttf
  -o ~/Library/Fonts/sketchybar-app-font.ttf && sketchybar --reload`. Also reload
  sketchybar AFTER fonts install (it started before them).
- **tmux tpm**: tmux.conf HAS a self-healing clone+install snippet, but it only fires
  on an interactive tmux launch (hadn't happened) → plugins were absent. ai.sh now
  runs `install_plugins` as belt-and-suspenders. (9 plugins now installed.)
- **`macos.sh` (P11) was never run** → no system defaults applied (menu-bar autohide,
  Finder/Dock/keyboard). It's the laptop's **Dec-2025 snapshot (816 lines)** and
  **lacks `_HIHideMenuBar`** (menu-bar autohide) entirely. Set it manually now
  (`defaults write NSGlobalDomain _HIHideMenuBar -bool true`). macos.sh options:
  (a) run as-is for the bulk of defaults [16GB-era, does `killall Dock/Finder`];
  (b) curate/modernize it like we did the Brewfile (add menu-autohide etc.);
  (c) regenerate from the laptop's live `defaults` (needs Tailscale, Phase 2).
- **Menu bar AND Dock not auto-hiding** — both are symptoms of `macos.sh` (P11)
  never running. Dock autohide (`com.apple.dock autohide -bool true`) IS in
  macos.sh; menu-bar autohide (`NSGlobalDomain _HIHideMenuBar -bool true`) is
  NOT. Setting `_HIHideMenuBar` via `defaults write` alone did NOT visibly apply
  (needs the System Settings → Menu Bar → "Automatically hide and show" = Always,
  or a re-login). Resolution: the refreshed `macos.sh` must set BOTH dock autohide
  and `_HIHideMenuBar`, then run P11 → both hide. Until then, set both in
  System Settings (Desktop & Dock → "Automatically hide and show the Dock";
  Menu Bar → "Automatically hide and show the menu bar" = Always).
- **skhd TCC staleness**: on a future `brew upgrade skhd`, hotkeys may stop (TCC
  cdHash changes) → `tccutil reset ListenEvent com.koekeishiya.skhd && skhd --restart-service`.

## Research validation (2026 best-practice check)

Our approach was confirmed correct by web research:
- **Basic yabai (no scripting-addition, no SIP-disable) + manual TCC is the right
  Tahoe default** — yabai-SA is broken on macOS 26 and won't be fixed without Apple.
- **`xcodes` + `op run` for headless Xcode** = best practice (2FA unavoidable).
- **`brew bundle` + `brew trust` for taps** (Homebrew 6.0 tap-trust) = correct.
- **1Password as single secrets source** (SSH agent + git-crypt doc + Apple login,
  `op run` per-command) = sound; minor: `op run` env vars are readable by the user's
  own processes (fine for a personal machine).
- **`ai.sh` + CLAUDE.md/AGENTS.md entry** = sound structure; optional hardening:
  `sudo -k` on exit; consider reusing `.setup/ai/doctor.sh` probes for `ai.sh check`.

## ai.sh TODO (close the remaining automation gaps)

- [ ] Install `sketchybar-app-font.ttf` (curl) in the services step + reload sketchybar.
- [ ] Apply menu-bar autohide + run/curate `macos.sh` (P11) as a phase.
- [ ] Reuse `.setup/ai/doctor.sh` probes for `ai.sh check`; reuse `ai_gate` for the TCC gate.
- **`.ai/` layout now:** `README.md` (charter/mission), `SECRETS.md` (1Password
  manifest — SSH key, git-crypt key, Apple ID), `ai.sh` (toolkit/installer with
  sudo keep-alive + tap-trust + brew bundle + Xcode/menuanywhere), `ISSUES.md`.

## Install state on vBookNeo (snapshot)

- **Done:** Homebrew · gh + GitHub SSH (1Password agent) · 1Password app/CLI/agent ·
  git-crypt unlock · ~94 formulae + casks · dotfiles deployed (`$HOME` on
  `v-macos-macbook`) · nvim submodule · **karabiner-elements · mullvad-vpn ·
  tailscale-app** · **Xcode 26.5 (via xcodes) + license + menuanywhere built** ·
  taps re-trusted.
- **Pending (owner-run, interactive):** **`adguard` cask** (sudo / system-extension —
  the ONLY brew item left; run `bash ~/.ai/ai.sh` in a terminal, it'll prompt once).
- **Dropped:** mas apps — Keynote/Pages skipped (MAS-only); AdGuard moved to cask.
- **Not started (later phases):** P9 LaunchAgents · P11 macos.sh · P11.5 Fast User
  Switching · P13 TCC perms (yabai/skhd/karabiner) · P14 Tailscale login · P15
  per-host key · P16 Remote Login · P17 yabai SA (SIP — skipped, Tahoe-flaky) ·
  P18 doctor.

## Live-setup findings — 2026-06-27 (vBookNeo: sketchybar · shell · sound)

- **sketchybar metrics need macmon AND a compiled bar-daemon.** `helpers/bar-daemon.swift`
  spawns `/opt/homebrew/bin/macmon pipe` (~line 917) and is the ONLY writer of
  `/tmp/sketchybar_cache`; the binary is gitignored → must be `swiftc`-compiled per machine.
  Missing either = blank cpu/gpu/temp/memory/power. Fixed inline: `brew "macmon"` + a
  `swiftc` compile step in `phase_services`. macmon needs no sudo.
- **Reduce Transparency is a TCC gate, not a scriptable default.** `defaults write
  com.apple.universalaccess reduceTransparency` is SILENTLY REFUSED on Tahoe (the old line
  did nothing). Toggle manually (Accessibility ▸ Display) — the supported way to a
  solid/"filled" menu bar. Now a self-verifying gate in `phase_macos` + `phase_gate`.
- **mise tools configured but never installed.** `~/.config/mise/config.toml` pins
  python=3.13 · node=lts · cmake + `python.uv_venv_auto=true`, but `mise install` was never
  run → no python3 shim → stale `zsh-autoswitch-virtualenv` plugin warned every shell init
  → broke p10k instant prompt. Fix: `mise install` step in `phase_packages`; removed the
  plugin + `AUTOSWITCH_DEFAULT_PYTHON` from `.shell`. Python/venvs via mise+uv now.
- **Stale uv standalone env line in `.profile`.** `. "$HOME/.local/bin/env"` (uv
  standalone-installer artifact) errored every shell because uv is brew-managed. Guarded:
  `[ -f ... ] && . ...`. (`.zprofile` is a symlink → `.profile`; one real file.)
- **Cask drift + tailscale rename.** Added `1password-cli`/`steam`/`openemu`; renamed
  deprecated cask `tailscale` → `tailscale-app`. Cask manifest now matches installed. Do
  NOT add `node`/`tailscale` formulae (mise owns node; cask ships tailscale CLI).
- **Notification sound: vProfile, not defaults.** Not scriptable on Tahoe (ncprefs dead;
  per-app `PreviewType` is iOS-only). Solution = `~/.ai/vProfile.mobileconfig`
  (`com.apple.notificationsettings`, `SoundsEnabled=false` per app, banners kept = visual
  only). macOS `allowmanualinstall=true` → installs without MDM (one approval = a gate).
  "Show previews → Never" is a separate manual gate. KEEP volume-change feedback (wanted).
  Verified silent. vProfile = superset of fleet apps (inert entries for absent apps).
- **mas still not worth it.** The 2 MAS apps are cask-redundant (1Password-for-Safari ships
  in the `1password` cask; AdGuard Mini = `adguard` cask). Stay 100% cask = the manifest.

## Live-setup findings — 2026-07-06 (vMiniM4: fossil runbook + no-TTY sudo)

- **The exact TL;DR failure repeated, on a different machine.** Found
  `~/.setup/dotfiles-ai.md` (696L) + `~/.setup/dotfiles-ai/ui.sh` (178L) already
  sitting on vMiniM4 — untracked, invented by an earlier session, reinventing
  `AI.md`/`ux.sh` from scratch (same Tokyo Night palette + face-glyph roster) down
  to referencing a `~/.claude/skills/dotfiles-ai/SKILL.md` that never existed. Cost
  most of a session before the real checkout surfaced `.ai/`/`AI.md`/`dotfiles-setup`
  and the duplication became obvious. Deleted both fossil files. **The rule isn't
  sticking from prose alone** — consider making the `dotfiles-setup` skill's
  activation step actively grep for untracked `.setup/*ai*`-looking files and flag
  them before any bootstrap plan gets drafted, rather than relying on a Claude
  session to remember to check.
- **Claude Code's Bash tool has no TTY at all, ever — `need_sudo()` didn't handle
  this.** `sudo -v` (no `-A`) fails outright with "a terminal is required... or
  configure an askpass helper" when invoked via Claude's tool-calls, even though a
  real Terminal.app session works fine. Also confirmed this machine's sudo
  (1.9.17p2) requires `-A` EXPLICITLY for askpass — it does not silently fall back
  to `SUDO_ASKPASS`/`sudo.conf` just because stdin isn't a tty (contradicts some
  generic sudo docs/blog claims — verify empirically per-machine, don't trust
  secondhand sudo behavior claims). Fixed: `need_sudo()` now checks `[ -t 0 ]`; if
  false, writes a tiny `osascript display dialog ... with hidden answer` helper to
  a mktemp file and calls `sudo -A` with `SUDO_ASKPASS` pointed at it —
  self-contained, cleaned up after. **Gotcha inside the gotcha:** AppleScript's
  `display dialog` does NOT support a `subtitle` clause (that's `display
  notification` only) — including one is a silent syntax error (`-2740`) that looks
  exactly like flaky window-server attachment. Cost real time misdiagnosing "flaky
  GUI" before finding the actual cause.
- **A stray `/etc/sudo.conf`** (`Path askpass /Users/v/.local/bin/macos-askpass.sh`)
  is dangling on vMiniM4 from an earlier iteration of this fix — the file it points
  to no longer exists. Harmless (only consulted if `SUDO_ASKPASS` env is unset,
  which `need_sudo()` never allows now) but should be `sudo rm /etc/sudo.conf`'d
  next time someone's at the console with sudo already primed.
- **Claude Code's Bash tool pins its own PATH regardless of dotfiles/profile
  exports.** `export PATH=...` in `.zshenv`/`.minimal` has zero effect on what
  Claude's tool-calls resolve — confirmed empirically (a brand-new
  `HOMEBREW_PREFIX` export took effect immediately in the same file/session; the
  `PATH` export never did). Only `~/.local/bin` is on the tool's fixed PATH.
  Practical implication: any freshly-`brew install`ed binary a Claude session needs
  to call directly needs a symlink into `~/.local/bin` — Homebrew auto-symlinked
  `git`/`git-crypt`/`jq` there this run (unclear why/whether reliable), but `brew`
  itself did not and needed a manual `ln -sf /opt/homebrew/bin/brew ~/.local/bin/`.
  Worth a `phase_packages` note or a `doctor.sh` probe if this bites again.
- **Real profile convention is by `$USER`, not hardware model** (`AI.md`'s table:
  `eve → server`, everyone else incl. mini-admin `v` → `workstation` — "Mini admin
  (v) gets workstation — screen-shared 90% of the time, needs full UX"). Flagging
  because the (now-deleted) fossil runbook assumed hardware-based profile (Mac mini
  ⇒ server for `v`), which would have put the wrong Brewfile/services on this
  machine. Not yet acted on — vMiniM4's `v` should get the `workstation` Brewfile,
  not `server`, whenever packages are installed.
- **P13's Full Disk Access grant requires quitting + reopening Terminal.app to take
  effect — and Claude Code was itself launched from inside that Terminal.** Granting
  FDA (needed here so `op` can read 1Password's desktop-integration bridge file in
  its Group Container — CLI sign-in + "Integrate with 1Password CLI" alone weren't
  enough, still got `operation not permitted` reading
  `.../2BUA8C4S2C.com.1password/.../settings.json` after both) triggers macOS's
  standard "quit and reopen" prompt. Since the Claude Code session's whole process
  tree roots at that Terminal window (`launchd → Terminal.app → zsh → claude →
  zsh`), restarting Terminal kills the in-progress session. **Sequencing implication
  for future bootstraps: do P13 (or at least the Full Disk Access pane) BEFORE
  starting a long Claude-driven run that depends on `op`, not mid-run** — or expect
  a session restart and make sure state (tasks, plan file) is written to disk first
  so the next session can resume cleanly.
- **Safety hooks silently DOWN + shell error-spam during the P4→P8 window (FIXED in
  the standard setup).** Deploying the dotfiles at P4 activates
  `.claude/settings.json`'s hooks — which run via `node`
  (`~/.local/share/mise/shims/node`) — and `.shell` (mise/zoxide/atuin init). But
  node/mise/etc. aren't provisioned until the P8 Brewfile. Result on a fresh machine:
  every tool call logged `PreToolUse:Bash hook error … node: command not found` and,
  because Claude Code treats a missing-interpreter hook as **non-blocking**, the
  guardrail was **bypassed** — exactly while a bootstrap agent runs privileged
  commands. Plus every shell init spewed `command not found: zoxide/mise/atuin`.
  Nuance: on THIS machine zoxide/mise/atuin were actually already brew-installed —
  the `.shell` errors were a PATH-timing issue in the snapshot shell; only `node`
  was genuinely absent (mise had never run `mise install`). Two-part fix, both baked
  into the standard flow so no future machine hits it:
  1. **`.shell`** — `command -v`-guard the `zoxide`/`mise`/`atuin` `eval "$(… init)"`
     lines (atuin's block wrapped in `if command -v atuin; then … fi` so `^R` stays
     on fzf-history-widget when atuin is absent). Degrades silently, any transient gap.
  2. **`~/.setup/AI.md`** — added `mise` to the P2 `brew install` line, and a new
     **P6.5 "Provision language runtimes (mise)"** (`mise install` + `mise reshim` +
     a `node --version` verify) right after the mise config lands at P4/P6 — so node
     exists before the hooks matter, closing the window to ~2 commands (P5+P6) instead
     of the whole Brewfile. `node = "lts"` currently resolves to v24.
  Applied live on vMiniM4 (mise install → node v24.18.0, python 3.13.14, cmake 4.3.3;
  hook re-verified running). Edits to `.shell` + `AI.md` uncommitted pending owner review.
  Possible follow-up: make the hook wrapper itself **fail-closed** (deny) rather than
  non-blocking when its interpreter is missing — a missing-node hook currently means
  "no guardrail," which is the least-safe default.
- **AI.md P7 (git-crypt unlock) had 3 latent bugs — all FIXED.** Hit live on vMiniM4:
  1. `op ... --out-file "$(mktemp)"` fails: mktemp pre-creates the file, so `op` wants
     to confirm the overwrite and aborts `cannot prompt for confirmation` in a no-TTY
     shell. The old `2>/dev/null` swallowed it, leaving a 0-byte file → the `[ -s ]`
     check fell through to a false "FATAL: key not found." → Added `--force`, dropped
     the stderr suppression.
  2. `cd ~ && git-crypt unlock` fails `not a git repository` — the dotfiles are a BARE
     repo at `~/.dotfiles`, so from `$HOME` there's no `.git`. → Must run with
     `GIT_DIR="$HOME/.dotfiles" GIT_WORK_TREE="$HOME" git-crypt unlock`. Also: unlock
     needs a clean tree; if the bootstrap made WIP edits first (this session did:
     askpass/hooks/shell fixes), `dotfiles stash` before + `dotfiles stash pop` after.
  3. Verify probed `~/.claude.json` (`head -1 | grep -qv GITCRYPT`) — but `.claude.json`
     is NOT git-crypt-tracked on this branch (`.gitattributes` lists it, but `git
     ls-files` shows it's uncommitted; it's Claude Code's live plaintext file). So the
     check passed vacuously whether unlock worked or not. → Verify via an actually-tracked
     encrypted file: `head -c1 ~/.claude/mcp/config.json | grep -q '{'`.
  The "temp key" is NOT a second key — it's the owner's own 1Password key pulled to a
  `mktemp` (0600), used, and `rm -P`-shredded immediately (never left on disk). Set that
  actually decrypts: `.utcp_config.json`, `.claude/mcp/config.json`, `.claude/mcp/mcp.json.bak`,
  `.assets/fonts/**`. Applied live on vMiniM4; edits uncommitted pending review.
- **`~/.ai/setup packages`: 8 of ~75 deps failed first pass in a no-TTY (Claude-driven)
  run — remediation plan below.** Three distinct causes:
  1. **`fd`, `lf` — transient brew parallel-lock collisions** (`process has already locked
     /opt/homebrew/Cellar/cmake` / `…/go`): two concurrent installs wanted the same dep.
     Recovered live with a plain `brew install fd lf` (no sudo). **FIX (systemic):** add an
     **unconditional final `brew bundle` mop-up pass** at the end of `phase_packages`
     (idempotent — skips installed, re-tries only the transient losers). Today the 2nd
     bundle pass only runs if Xcode is present, so lock-transients slip through.
  2. **`mullvad-vpn`, `adguard`, `karabiner-elements`, `tailscale-app` — sudo `.pkg` casks**
     (`installer -pkg … exited with 1: sudo: a password is required`). ROOT CAUSE:
     `need_sudo()` primes one credential, but in a no-TTY run (a) it expires after the
     5-min sudo timeout during the long formulae install, and (b) the keep-alive subshell's
     `sudo -n true` can't refresh it (no-TTY ticket scoping). By the time brew reaches the
     casks, sudo is dead. **FIX (systemic, two layers):** (a) in `phase_packages`, install
     the known pkg-casks **first, right after `need_sudo`** (fresh window); (b) after the
     bundle, verify that known set and, if any are missing **and** `[ ! -t 0 ]`, print the
     exact `brew install --cask <missing>` one-liner + "run in a real terminal" — never a
     silent buried failure. Also recommend, for a fully-hands-off install, running
     `~/.ai/setup packages` in a real Terminal (TTY → need_sudo's keep-alive works as
     designed, as it did on Neo). **IMMEDIATE (vMiniM4):** owner runs
     `brew install --cask mullvad-vpn adguard karabiner-elements tailscale-app` in a terminal.
     (NB: layer-(a) auto-fix is UNVERIFIED for no-TTY — a live test of "fresh prime →
     brew child sudo" was declined; layer-(b) surfacing is the guaranteed-correct part.)
  3. **`menuanywhere` — source build, needs full Xcode** (`unsatisfied requirement failed
     this build`; `swiftc` from CLT is enough for the sketchybar bar-daemon but NOT for
     menuanywhere). Not a bug — the intended flow is `~/.ai/setup xcode` (one Apple 2FA)
     then re-run packages. **IMMEDIATE (vMiniM4):** pending the xcode phase.
  Recovered live: `fd`, `lf`, `ccusage-monitor` (3/8). Still pending: the 4 sudo casks
  (owner terminal) + `menuanywhere` (Xcode). Systemic `phase_packages` edits: TODO
  (uncommitted branch), tracked here so they land with the other end-of-session fixes.
  **DECISIVE follow-up (settles the "front-load via askpass" idea):** Claude CANNOT run
  `sudo` at all — `.claude/settings.json` deny list has `Bash(sudo *)` (line ~456), so
  any direct `sudo`/`brew install --cask <pkg-cask>` from the Bash tool is HARD-BLOCKED
  by policy ("sudo commands require manual execution"). This is the guardrail working
  (and it only came online once node/hooks were fixed earlier today). Implications:
  (1) the phase_packages "front-load pkg-casks right after need_sudo" auto-fix ONLY
  helps when the WHOLE `~/.ai/setup packages` runs in a REAL TERMINAL (owner-driven) —
  there `need_sudo`'s TTY sudo works as designed (as on Neo). (2) In a Claude-driven run,
  sudo only executes when buried inside a script launched by a non-sudo command (e.g.
  `nohup ~/.ai/setup packages`), and even then the no-TTY credential doesn't reach brew's
  child `sudo installer`. So the RELIABLE rule is: **sudo `.pkg` casks are always
  owner-run in a terminal; the phase_packages "surface the exact command" fallback (layer
  b) is the real fix, front-loading (layer a) is a bonus only for terminal runs.** Don't
  chase askpass for Claude-driven direct sudo again — it's policy-denied by design.
- **Xcode / menuanywhere — `xcodes` 2FA friction; App Store GUI was the pragmatic one-off.**
  `~/.ai/setup xcode` (→ `xcodes install --latest` with Apple creds from 1Password via
  `op run`) failed twice on the 2FA step — the 6-digit code expired (~30s window) before
  entry. `menuanywhere` needs a FULL `Xcode.app` (CLT's `swiftc` is NOT enough:
  "A full installation of Xcode.app 12.0 is required"). Resolution: installed Xcode from
  the **App Store GUI** (the mini's existing iCloud session skipped 2FA), then
  `brew install acsandmann/tap/menuanywhere` built fine (`xcode-select` already pointed at
  Xcode.app). Research (2026): `xcodes` IS the fleet CLI tool and **caches the Apple session
  in the keychain → 2FA is one-time per machine, headless after**; `mas install 497799835`
  works only after a one-time App Store GUI sign-in; `xcodeinstall` (sebsto) is the
  headless/EC2-oriented fork. Fleet guidance: expect ONE 2FA for `xcodes` per machine (type
  the freshest code fast, or `sms`); App Store GUI is the low-friction fallback when present.
  No CLI path avoids Apple's first-auth 2FA entirely.
- **doctor false-positive "packages incomplete" — FIXED.** `phase_doctor`'s
  `brew bundle check` reported yabai/skhd as "needs to be installed or updated" even though
  both are installed AND running — because `brew bundle check` can't verify a formula's
  outdated-status when its tap isn't *formula-trusted*, and treats "can't check" as
  "missing." The tap-level `brew trust` in `phase_packages` isn't enough for the per-formula
  outdated check. Fix: also run `brew trust --formula koekeishiya/formulae/yabai
  koekeishiya/formulae/skhd` (applied live → doctor now all-green). Added to `phase_packages`
  so fresh machines don't get the spurious warning. (uncommitted, with the borders/askpass work.)

## Post-reboot findings — 2026-07-07 (vMiniM4: tmux plugins · Karabiner · coverage-gap audit)

- **tmux "looks vanilla" — plugins never installed (FIXED).** The config
  (`~/.config/tmux/tmux.conf`, 45 KB) DID load (verified: live server had `mouse on`,
  `status-position top`, `prefix C-a` — all custom values; OMZ `tmux.extra.conf` chains to
  it via `source-file $ZSH_TMUX_CONFIG`). But `~/.config/tmux/plugins/` held ONLY `tpm` —
  all ~19 `@plugin`s (incl. the `minimal-tmux-status` theme, battery, wifi, resurrect,
  continuum) were missing → bare status bar. ROOT CAUSE: `phase_services` ran
  `tpm/bin/install_plugins` **without `TMUX_PLUGIN_MANAGER_PATH`**, so tpm targeted the
  default `~/.tmux/plugins/` (wrong path) and installed nothing — and the blanket
  `>/dev/null 2>&1 && ok` reported success anyway. Fix (live): 
  `TMUX_PLUGIN_MANAGER_PATH="$HOME/.config/tmux/plugins/" .../tpm/bin/install_plugins`
  → all 8 active plugins cloned; `tmux source-file` reloaded → themed. **Fleet fix
  (phase_services):** export the env var + verify a SENTINEL plugin
  (`minimal-tmux-status`) actually landed (warn, don't silently ok) + build `tmux-thumbs`
  (Rust plugin, no vendored binary) when cargo exists. Gotcha for debugging: the OMZ tmux
  shell wrapper `_zsh_tmux_plugin_run` shadows `tmux` in non-interactive shells — use the
  full `/opt/homebrew/bin/tmux` binary for diagnostics.
- **Karabiner remaps don't apply over Screen Sharing — INHERENT, not a bug.** Karabiner is
  fully healthy on the mini (DriverKit VirtualHIDDevice `[activated enabled]`, services up,
  20 KB config). It remaps events from *physical HID devices*; keystrokes arriving via
  Screen Sharing are **synthetic events injected by the screen-sharing agent** and never
  pass a physical HID device, so Karabiner's driver can't see them. What applies over the
  wire is the **parent (typing) machine's** Karabiner. → No mini-side fix; put the desired
  remaps on the machine you share *from* (Air/Neo — the fleet dotfiles already carry
  `.config/karabiner/`). Verify: a remap works on the mini's own keyboard but follows the
  parent's config over the share. (Also noted in `.config/karabiner/KARABINER.md`.)
- **Coverage-gap audit — `~/.ai/setup` skips AI.md's daemon/remote-access phases.** The
  skill runs packages·fonts·services·macos·gate·doctor (workstation UX) but NOT AI.md
  P9/P12/P14/P15/P16 — so a machine bootstrapped purely via `dotfiles-setup` is not
  always-on or fleet-SSH-wired. On vMiniM4:
  - **pmset — CRITICAL & unaddressed:** `sleep 1` (sleeps ~1 min idle) → drops SSH/
    screen-share; `womp 1` wake-on-LAN won't reliably wake for those. P12 (server
    never-sleep) never ran (`v` = workstation). Needs `sudo pmset -a sleep 0 disksleep 0
    displaysleep 0`; reconsider `autorestart 1` under FileVault (unattended reboot → locked
    out). **#1 risk for a remote mini.**
  - **LaunchAgents (P9) not installed:** `com.user.tmux`, `com.claude.mcp-proxy` absent
    (only brew service plists). MCP works via plugins; the persistent-tmux agent is missing.
  - **Per-device SSH key (P15) not generated:** no `~/.ssh/id_ed25519_vminim4`, not in
    1Password → fleet key-based SSH mesh not wired.
  - Remote Login (P16) — already ON (sshd listening). Mullvad/AdGuard sysext — pending
    first launch. Tailscale (P14) — deferred to the other machine.
  **Process fix:** add a `~/.ai/setup server` phase (P9/P12/P15, and P16 verify) for
  mini/Studio/`eve` server use, OR make the skill+AI.md explicit that a headless mini needs
  the access phases — "run the skill" currently ≠ "remotely reachable + always-on."
- **tmux-thumbs removed (unused) + rust moved to mise (2026-07-07).** tmux-thumbs was the
  only tmux plugin needing a Rust compile, and owner doesn't use it → commented its
  `@plugin`/`@thumbs-key`/`unbind t` in `~/.config/tmux/tmux.conf`, dropped the build block
  from `phase_services`, removed the plugin dir via `tpm/bin/clean_plugins`.
- **Rust was a tracked-binary one-off — now mise-managed.** Discovered `~/.cargo/bin/*`
  (14 rust binaries: cargo, rustc, rustup, rust-analyzer, clippy, rustfmt, …) **plus
  `.cargo/env` are COMMITTED into the dotfiles repo** — 15 files, **33 MB** of
  arch-specific binaries. They check out on every machine but are dead (no `~/.rustup`
  toolchain is tracked), which is why `cargo` existed but `rustup default` was never set.
  Fix: added `rust = "stable"` to `~/.config/mise/config.toml` (mise `core:rust` → rustup
  under the hood); `mise install` (already in P6.5/phase_packages) now provisions
  rustc/cargo (verified 1.96.1 via mise shim) alongside node/python/cmake — consistent,
  reproducible, no manual `rustup default`. **CLEANUP PENDING (owner decision):** untrack
  the 15 `.cargo/*` files (`dotfiles rm --cached .cargo/bin/* .cargo/env`) + gitignore
  `.cargo/`, so the repo stops shipping 33 MB of dead binaries and mise owns rust cleanly.
  `mise install` warned to remove the stale `~/.cargo/bin` copies so rustup can manage them.
  Also: `.shell:189` still sources `~/.cargo/env` (rustup env) — harmless with mise (mise
  activate wins PATH order) but can be dropped once `.cargo` is untracked.
- **GitHub push auth was never set up by `~/.ai/setup` → first push blocked (FIXED).** The
  P4 clone is **anonymous HTTPS** (public repo, read-only — no creds), so nothing surfaced
  until we tried to **push back** tonight: `git push` failed `could not read Username for
  'https://github.com': Device not configured` (HTTPS wants a password, no `gh` login, no
  cached credential, no TTY to prompt). ROOT CAUSE: push auth lives in **AI.md P15**
  (per-device SSH key + 1Password SSH agent), one of the access phases `~/.ai/setup` never
  runs — same coverage gap logged above. The fleet DESIGN is right (1Password serves
  `1password_25519` via its SSH agent — no tokens), it just wasn't wired by the skill.
  FIX (applied live + folded into the skill so no machine hits this again):
  1. `~/.ssh/config` → `Host * / IdentityAgent ~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock`.
  2. dotfiles remote HTTPS → SSH (`git@github.com:Vvkmnn/dotfiles.git`) — HTTPS is fine for
     the anon clone, but push needs the agent.
  3. `remote.origin.fetch = +refs/heads/*:refs/remotes/origin/*` — `git clone --bare` sets
     NO fetch refspec, so `origin/*` refs never update (this is why the other agent saw an
     empty `branch -r` and a stale local `v-macos-macbook`). Fixed on this machine + in the skill.
  4. New **`phase_gitauth`** in `~/.ai/setup` (self-contained: steps 1–3 idempotent, then
     verifies the agent is serving keys via **`ssh-add -l`** — NOT a real `ssh -T git@github.com`:
     the 1Password agent needs interactive Touch-ID approval per *signature*, so a scripted
     `ssh -T` either "agent refused operation" (BatchMode) or **hangs** on the GUI prompt;
     listing keys needs no approval. If the socket/keys are absent it relays the ONE manual
     gate — **1Password ▸ Settings ▸ Developer ▸ "Use the SSH agent"** — which a script can't
     flip). Wired into `all` (after `macos`, before `gate`) + dispatch + usage.
  Verified live: agent serves `1password_25519`, `ssh -T git@github.com` → "Hi Vvkmnn!",
  `push origin v-macos-mini` succeeded over SSH (Touch-ID, no token). The only per-machine
  manual step remaining is the 1Password agent toggle — call it out when deferring P15 so
  the owner isn't surprised at first push.
## Fleet dotfiles unification + git-auth gotchas — 2026-07-11 (vBookNeo/Neo)

Captured while surfacing Neo's work for the fleet union (mini is the unifier, builds on
`v-macos`; Neo manages its own `v-macos-neo`). The "what bit us and the fix" log.

- **Bare repo shipped NO fetch refspec → `origin/<branch>` refs LIED.** `git --git-dir` bare
  clones can lack `remote.origin.fetch`, so cached `origin/*` never updates and divergence math
  is wrong. Fix: `git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'` then
  `fetch`. Until then trust `gh api repos/Vvkmnn/dotfiles/git/refs/heads` (or `ls-remote`) for
  real tips — never `origin/<branch>`.
- **1Password SSH agent locked = every SSH git op fails, and `ls-remote` HANGS.** `~/.ssh/config`
  `Host * IdentityAgent …/1password/t/agent.sock` routes all keys through 1Password; when the app
  is locked (e.g. driving Neo remotely over mosh from the Air — no GUI to unlock it) signing
  fails ("communication with agent failed") and `ls-remote` blocks until timeout. No plain
  `~/.ssh/*.pub` fallback exists. **Workaround that works — push/fetch over HTTPS via gh:**
  `git -c credential.helper='!gh auth git-credential' -c remote.origin.pushurl=https://github.com/Vvkmnn/dotfiles.git push origin <branch>`
  (one-shot; nothing persisted; gh is keyring-authed with `repo` scope). A future plain `push`
  reverts to SSH and fails again until 1Password is unlocked on the machine itself.
- **zsh does NOT word-split unquoted vars.** `DG="git --git-dir=…"; $DG status` fails with "no
  such file or directory" (whole string treated as one command). Use a function
  `D(){ /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"; }` or export
  `GIT_DIR`/`GIT_WORK_TREE` and call plain `git`.
- **borders turned OFF fleet-wide.** Commented out (NOT deleted) in `~/.ai/setup` — install
  line, service-start loop, doctor health-check — with a short why-note; `.config/borders/
  bordersrc` kept tracked so revival is a one-line uncomment. Neo runtime: LaunchAgent unloaded
  + process killed. CAVEAT: `brew services stop borders` is REFUSED (untrusted tap) — use
  `launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.borders.plist`; the plist persists so
  borders may relaunch at login → `brew uninstall borders` removes binary + plist for good.
  mini had already dropped borders (`5e4d0e5b`); the union carries none.
- **Fleet union state.** origin/v-macos is STALE (`07dff110`); the real consolidation lives on
  `v-macos-neo` (~159 commits ahead — Neo was de-facto integrator). Union merge flags:
  `settings.json` = 3-way keep-both (our plugin roster + voice AND fleet hooks/perms/model);
  `.functions` = dedupe vs macbook's fleet-SSH commits; DROP the cargo-artifacts +
  marketplace-timestamp commits. `known_marketplaces.json` churns its `lastUpdated` timestamps
  constantly — leave it uncommitted (noise).
