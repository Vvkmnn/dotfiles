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
