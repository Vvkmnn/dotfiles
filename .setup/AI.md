# AI.md — Mac bootstrap runbook

> One file. Take a fresh Mac to owner-environment-parity. Claude reads this top
> to bottom, executes each phase, pauses at manual gates, sends an iPhone
> notification when input is needed. Re-run any time — every step is idempotent.

## What this is

`AI.md` is both the primer and the executable runbook. The Claude skill at
`~/.claude/skills/dotfiles-setup/SKILL.md` triggers on phrases like "Bootstrap this
Mac" / "Set up this Mac" / "Match the laptop" / `/dotfiles-setup`. The skill reads
this file and walks through the phases. There is no separate state tracker —
each script is idempotent (brew bundle skips installed, `defaults write` no-ops
on matched values, `git clone` exits if the dir exists). Interrupted halfway?
Re-run; safe steps skip automatically.

## TL;DR

```bash
# 1. Clone the bare repo (HTTPS first-boot; SSH after P15 keygen)
git clone --bare https://github.com/Vvkmnn/dotfiles.git ~/.dotfiles
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
dotfiles config --local status.showUntrackedFiles no

# 2. Trigger the skill
"Bootstrap this Mac"   # to Claude Code session
```

That's it. Claude does the rest, pausing at gates.

---

## Profiles — by user role, not hardware

```bash
case "$USER" in
  eve) DOTFILES_AI_PROFILE=server      ;;  # daemon host (mini, Studio)
  *)   DOTFILES_AI_PROFILE=workstation ;;  # owner: laptop, mini admin, Studio admin
esac
export DOTFILES_AI_PROFILE
# Override: export DOTFILES_AI_PROFILE=server before invoking
```

| Profile | Brewfile | Includes |
|---|---|---|
| `workstation` | `Resources/Brewfile` (~80 brew + casks) | yabai, skhd, sketchybar, karabiner, full GUI stack |
| `server` | `Resources/Brewfile.server` (~12 brew + 4 cask) | git, tmux, nvim, mosh, mise, uv, go, Tailscale, 1Password, Claude — no window manager |

Mini admin (`v`) gets workstation — screen-shared 90% of the time, needs full UX.
Mini eve (`eve`) gets server — daemons only.

---

## Bootstrap phases

Phases run in this order. Manual gates marked **[GATE]**. Profile-specific marked **[server]** or **[workstation]**.

### P0 — Preflight (read-only)

```bash
# Hardware
test "$(uname -m)" = "arm64"
test "$(sysctl -n hw.memsize)" -ge 17179869184      # ≥ 16 GB
test "$(df -k / | awk 'NR==2 {print $4}')" -ge 209715200   # ≥ 200 GB free

# macOS ≥ 26 (Tahoe-targeted runbook)
ver=$(sw_vers -productVersion)
printf '26.0\n%s\n' "$ver" | sort -CV   # ascending: threshold first

# iCloud signed in
defaults read MobileMeAccounts Accounts 2>/dev/null | grep -q AccountID

# [GATE if missing] git-crypt key
test -f ~/Downloads/key -o -f ~/Documents/key
# If absent: prompt owner to AirDrop from laptop ~/Documents/key

# Preserve ~/.claude live state if a previous install exists
mkdir -p ~/.backup
for d in projects sessions session-env shell-snapshots backups cache; do
  [ -d ~/.claude/$d ] && cp -R ~/.claude/$d ~/.backup/.claude/$d
done
```

### P1 — Hostname

```bash
host=vminim4    # or vbookair / vstudio
sudo scutil --set HostName    "$host"
sudo scutil --set LocalHostName "$host"
sudo scutil --set ComputerName  "$host"
```

### P2 — Xcode CLT + Homebrew + baseline

```bash
xcode-select --install 2>/dev/null || true
until xcode-select -p >/dev/null 2>&1; do sleep 5; done

if ! command -v brew >/dev/null; then
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
brew install git git-crypt jq
```

### P3 — Network priority **[server]**

```bash
# Prefer Ethernet, keep Wi-Fi as fallback. Idempotent.
if ifconfig en0 2>/dev/null | grep -q 'status: active'; then
  networksetup -ordernetworkservices "Ethernet" "Wi-Fi" 2>/dev/null || true
fi
```

### P4 — Clone dotfiles bare repo

```bash
# HTTPS fallback because ed25519 key isn't generated until P15.
if [ ! -d ~/.dotfiles ]; then
  git clone --bare git@github.com:Vvkmnn/dotfiles.git ~/.dotfiles 2>/dev/null \
    || git clone --bare https://github.com/Vvkmnn/dotfiles.git ~/.dotfiles
fi
dotfiles() { /usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME "$@"; }
export -f dotfiles

# Conflict-resolver: move existing files to ~/.backup, retry
base=v-macos-macbook
if ! dotfiles checkout "$base" 2>&1 | tee /tmp/co.log; then
  mkdir -p ~/.backup
  awk '/^\s+\./ {print $1}' /tmp/co.log | while read f; do
    mv ~/$f ~/.backup/$f 2>/dev/null || true
  done
  dotfiles checkout "$base"
fi
dotfiles config status.showUntrackedFiles no

# Fork to host-specific branch (per convention v-macos-<host>)
case "$DOTFILES_AI_PROFILE" in
  workstation) machine=v-macos-macbook ;;  # or v-macos-studio etc
  server)      machine=v-macos-mini ;;
esac
[ "$machine" != "$base" ] && dotfiles checkout -B "$machine"
```

### P5 — Restore ~/.claude state

```bash
for d in projects sessions session-env shell-snapshots backups cache; do
  [ -d ~/.backup/.claude/$d ] && {
    rm -rf ~/.claude/$d 2>/dev/null
    mv ~/.backup/.claude/$d ~/.claude/$d
  }
done
```

### P6 — Submodules (nvim config)

```bash
dotfiles submodule update --init --recursive --jobs 4
```

### P7 — git-crypt unlock

```bash
key=""
[ -f ~/Downloads/key ] && key=~/Downloads/key
[ -f ~/Documents/key ] && key=~/Documents/key
test -n "$key" || { echo "FATAL: key vanished" >&2; exit 1; }
cd ~ && git-crypt unlock "$key"
head -1 ~/.claude.json | grep -qv 'GITCRYPT'  # verify
[ -f ~/Downloads/key ] && rm -P ~/Downloads/key
```

### P8 — Brewfile (profile-conditional)

```bash
case "$DOTFILES_AI_PROFILE" in
  workstation) brew bundle install --file=~/.setup/Resources/Brewfile ;;
  server)      brew bundle install --file=~/.setup/Resources/Brewfile.server ;;
esac
```

### P9 — LaunchAgents

```bash
mkdir -p ~/Library/LaunchAgents
for f in ~/.config/launchagents/*.plist; do
  [ -e "$f" ] || continue
  out=~/Library/LaunchAgents/$(basename "$f")
  sed "s|__HOME__|$HOME|g" "$f" > "$out"
  launchctl bootstrap "gui/$(id -u)" "$out" 2>/dev/null || true
done
```

### P10 — iCloud sync settle **[GATE]**

```bash
# iCloud silently reverts ~10 macos.sh lines if applied too early.
# Open the Apple ID pane; wait until no spinners + "Synced" on key apps.
open 'x-apple.systempreferences:com.apple.systempreferences.AppleIDSettings'
# Owner types "done"
```

### P11 — Apply macos.sh (existing 816-line defaults script)

> **Caution**: macos.sh dates from Oct 31 2025 and captures the laptop's state
> at that moment. Settings tweaked since via System Settings clicks are NOT
> captured here. Audit confirms it does **not** touch Screen Sharing, SSH, or
> networking services — but it does `killall Dock Finder SystemUIServer` at
> the end, causing a brief UI blink during screen sharing (VNC connection
> survives). Opt out with `DOTFILES_AI_SKIP_MACOSSH=1` if you want to apply
> manually later.

```bash
# Snapshot critical services BEFORE — confirm we don't break access
sharing_before=$(sudo launchctl print system/com.apple.screensharing >/dev/null 2>&1 && echo on || echo off)
ssh_before=$(systemsetup -getremotelogin 2>/dev/null | grep -q On && echo on || echo off)

if [ "${DOTFILES_AI_SKIP_MACOSSH:-0}" = "1" ]; then
  echo "P11 skipped via DOTFILES_AI_SKIP_MACOSSH=1 — apply manually later: bash ~/.setup/macos.sh"
else
  bash ~/.setup/macos.sh 2>&1 | tail -20
fi

# Verify critical services still up AFTER
sharing_after=$(sudo launchctl print system/com.apple.screensharing >/dev/null 2>&1 && echo on || echo off)
ssh_after=$(systemsetup -getremotelogin 2>/dev/null | grep -q On && echo on || echo off)
[ "$sharing_before" = on ] && [ "$sharing_after" != on ] && echo "WARN: Screen Sharing went down — re-enable in System Settings"
[ "$ssh_before"     = on ] && [ "$ssh_after"     != on ] && echo "WARN: Remote Login went down — re-enable in System Settings"

# Verify a couple of canonical keys landed (skip these if SKIP=1)
if [ "${DOTFILES_AI_SKIP_MACOSSH:-0}" != "1" ]; then
  test "$(defaults read NSGlobalDomain AppleShowAllExtensions 2>/dev/null || echo unset)" = "1"
  test "$(defaults read com.apple.dock autohide 2>/dev/null || echo unset)" = "1"
fi
```

**Drift catch-up (post-bootstrap)**: to bring the mini to the laptop's CURRENT state (not Oct 31 baseline), from the laptop run:

```bash
# Dump current defaults from laptop (one-time, runs ~30s)
defaults read > /tmp/laptop-defaults.txt
defaults -currentHost read > /tmp/laptop-defaults-current.txt
# scp to mini, then on mini diff against fresh dump and import deltas manually
```

A proper drift script is out of scope — the laptop's accumulated System Settings clicks are best replayed by you in the actual Settings panes you remember tweaking. macos.sh is the persistent baseline; ad-hoc clicks are owner's to remember.

### P11.5 — Fast User Switching + Screen Sharing

```bash
# System-wide: allow multiple logged-in users (Fast User Switching).
# Owner can switch between admin (v) and daemon (eve) without logging out
# — eve's daemons keep running across the switch.
sudo -v
sudo defaults write /Library/Preferences/.GlobalPreferences MultipleSessionEnabled -bool true

# Menu bar item via Control Center (Tahoe-modern path).
defaults write com.apple.controlcenter "NSStatusItem Visible UserSwitcher" -bool true

# Legacy fallback (older defaults key, still respected on Tahoe):
# 0=hidden 1=name 2=initials 3=icon
defaults -currentHost write -globalDomain userMenuExtraStyle -int 2

# Restart Control Center so the menu bar item appears.
killall ControlCenter 2>/dev/null || true

# Screen Sharing service (idempotent — no-op if already on).
# Owner accesses admin account remotely via vnc://vminim4.local or
# vnc://vminim4 (Tailscale MagicDNS).
sudo launchctl print system/com.apple.screensharing >/dev/null 2>&1 || {
  sudo launchctl enable system/com.apple.screensharing
  sudo launchctl bootstrap system /System/Library/LaunchDaemons/com.apple.screensharing.plist
}

# skhd binding for keyboard-fast user-switch (already in tracked .skhdrc):
#   ctrl + alt - u  →  CGSession -suspend
# Reload skhd if it's already running:
skhd --reload 2>/dev/null || true

# Verify
defaults read /Library/Preferences/.GlobalPreferences MultipleSessionEnabled | grep -q 1
sudo launchctl print system/com.apple.screensharing >/dev/null 2>&1
```

Owner toggles still required in System Settings (no programmatic equivalent on Tahoe):
- **System Settings → General → Sharing → Screen Sharing**: confirm ON. "Allow access for: Administrators" is the default — when the `eve` user is later created, add `eve` here too so the owner can VNC into eve's session.
- **System Settings → Control Center → Fast User Switching**: confirm "Show in Menu Bar" if the defaults block above didn't take effect after `killall ControlCenter`.

### P12 — pmset never-sleep **[server, admin]**

```bash
sudo -v   # pre-cache password (prompts once, 5-min window)
sudo pmset -a sleep 0 disksleep 0 displaysleep 30 \
            womp 1 powernap 1 networkoversleep 1 tcpkeepalive 1 \
            standby 0 autorestart 1 hibernatemode 0
```

### P13 — TCC checklist **[GATE]**

Single batched System Settings trip. Open each pane; add **Terminal.app** (and **Ghostty.app** on workstation) to each:

```bash
open 'x-apple.systempreferences:com.apple.settings.PrivacySecurity?Privacy_Accessibility'
open 'x-apple.systempreferences:com.apple.settings.PrivacySecurity?Privacy_AllFiles'
open 'x-apple.systempreferences:com.apple.settings.PrivacySecurity?Privacy_LocalNetwork'
open 'x-apple.systempreferences:com.apple.settings.PrivacySecurity?Privacy_ScreenCapture'  # workstation only
```

### P14 — Tailscale **[GATE]**

```bash
open -a Tailscale
# Menu bar → Log In → Apple ID (same as iCloud). Wait for "Logged in".
sudo tailscale up --ssh
tailscale ip -4   # should print 100.x.x.x
```

### P15 — Per-device ed25519 + 1Password registry

```bash
mkdir -p ~/.ssh && chmod 700 ~/.ssh
host=$(scutil --get LocalHostName | tr A-Z a-z)
keyfile=~/.ssh/id_ed25519_${host}
[ -f "$keyfile" ] || ssh-keygen -t ed25519 -C "${host}@$(date +%Y%m%d)" -N "" -f "$keyfile"
touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys

# Register this host's pubkey in 1Password + pull peer pubkeys
if command -v op >/dev/null && op account list 2>/dev/null | grep -q .; then
  op item create --vault Private --category 'SSH Key' \
    --title "Mac SSH key — ${host}" \
    "public_key=$(cat ${keyfile}.pub)" 2>/dev/null \
    || op item edit "Mac SSH key — ${host}" "public_key=$(cat ${keyfile}.pub)"
  for peer in vbookair vminim4 vstudio iphone15pm; do
    [ "$peer" = "$host" ] && continue
    pk=$(op item get "Mac SSH key — ${peer}" --field public_key 2>/dev/null)
    [ -n "$pk" ] && ! grep -qF "$pk" ~/.ssh/authorized_keys \
      && echo "$pk" >> ~/.ssh/authorized_keys
  done
fi

# 1Password SSH agent line
grep -q '1password.*agent.sock' ~/.ssh/config 2>/dev/null || cat >> ~/.ssh/config <<'EOF'

Host *
  IdentityAgent ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
EOF

# Rewrite dotfiles remote to SSH if P4 used HTTPS fallback
if [ -d ~/.dotfiles ]; then
  url=$(/usr/bin/git --git-dir=~/.dotfiles remote get-url origin 2>/dev/null || echo "")
  case "$url" in
    https://*) /usr/bin/git --git-dir=~/.dotfiles \
        remote set-url origin git@github.com:Vvkmnn/dotfiles.git ;;
  esac
fi
```

### P16 — Remote Login **[GATE]**

```bash
open 'x-apple.systempreferences:com.apple.settings.PrivacySecurity?Privacy_Sharing'
# General → Sharing → Remote Login ON.
systemsetup -getremotelogin 2>/dev/null | grep -q "On"  # verify
```

### P17 — yabai SA + sketchybar **[workstation]**

```bash
yabai_bin=$(command -v yabai)
[ -n "$yabai_bin" ] && {
  echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 "$yabai_bin" | awk '{print $1}') $yabai_bin --load-sa" \
    | sudo tee /etc/sudoers.d/yabai >/dev/null
  sudo yabai --install-sa
  yabai --start-service
}
command -v skhd >/dev/null && skhd --start-service
brew services start FelixKratz/formulae/sketchybar 2>/dev/null || true
pgrep -x yabai && pgrep -x skhd   # verify
```

### P17.5 — Native Continuity (Tahoe 26 / iOS 26)

Mostly iPhone-side toggles. Owner can pre-complete in parallel with bootstrap.

| Sub | Action | Verify |
|---|---|---|
| **Handoff** | macOS: System Settings → General → AirDrop & Handoff → ON | `pgrep -x useractivityd` |
| **iMessage/SMS forwarding** | iPhone: Settings → Messages → Text Message Forwarding → this Mac ON. Type code on iPhone. | owner-confirms |
| **Phone calls relay** | iPhone: Settings → Phone → Calls on Other Devices → this Mac ON | `test -d /System/Applications/Phone.app` |
| **Continuity Camera** | iPhone: Settings → General → AirPlay & Continuity → Continuity Camera ON | owner-confirms (FaceTime camera picker) |
| **iPhone Mirroring pair** | `open -a "iPhone Mirroring"` → approve on iPhone | owner-confirms |
| **Notes markdown (new)** | `defaults write com.apple.Notes EnableMarkdown -bool true` | automatic |
| **Apple Intelligence (~7 GB)** | `open 'x-apple.systempreferences:com.apple.AppleIntelligence-Settings.extension'` → toggle ON | optional |
| **AirDrop test** | Send file laptop ↔ mini ↔ iPhone (regression test) | owner-verifies |
| **Shortcuts automations** | Awareness only — Tahoe added Mac triggers (folder/drive/app/battery/Wi-Fi) | n/a |

### P18 — Doctor (verify suite)

Run any time. Idempotent. Exit 0 (clean) / 1 (warnings) / 2 (failures).

```bash
bash ~/.setup/ai/doctor.sh           # run all probes
bash ~/.setup/ai/doctor.sh tailscale  # filter to one
```

`doctor.sh` covers: hardware, macOS version, Apple ID, network, Tailscale, launchd services (tmux, mcp-proxy), Claude CLI, dotfiles remote, git-crypt unlock state, profile-specific (yabai/skhd/sketchybar OR pmset), Continuity (Handoff, Phone, iPhone Mirroring, Notes markdown), TCC FDA. ~25 probes total. See the script for the full list.

### P19 — Celebration

```
┌─ [$_$]  This machine is your machine.
│
│   profile    workstation | server
│   hostname   vminim4
│   tailnet    vminim4.tail-XXXX.ts.net
│   reachable  ssh v@vminim4 (LAN + Tailscale)  ·  mosh v@vminim4 (iPhone)
│
│   Try now:
│     ssh mini → tmux attach -t claude
│     re-run AI.md any time to drift-check
│
└──   Welcome home.
```

### P20+ — iPhone access (deferred)

Blink Shell ($20) + Tailscale (free) from App Store. Generate ed25519 in Blink → AirDrop pubkey to a Mac → register in 1Password as `Mac SSH key — iphone15pm`. Future Macs auto-pull and authorize via P15.

---

## Manual gates summary

| Phase | Gate | What you do |
|---|---|---|
| P0.7 | git-crypt key transfer | AirDrop laptop's `~/Documents/key` to mini's `~/Downloads/key` |
| P10 | iCloud sync settle | Wait 2-3 min after iCloud sign-in until panel shows "Synced" |
| P12 | sudo password | Type once at first sudo prompt (5-min window covers subsequent) |
| P13 | TCC checklist | Add Terminal.app (+ Ghostty.app workstation) to 3-4 panes |
| P14 | Tailscale OAuth | Menu bar → Log In → Apple ID, then `sudo tailscale up --ssh` |
| P16 | Remote Login | System Settings → Sharing → Remote Login ON |
| P17.5 | Continuity sub-gates | iPhone-side toggles (see table) |

iPhone notifications fire at each gate via `osascript -e 'tell app "Messages" ...'` to the owner's iPhone 15 PM number.

---

## Idempotency model

No state markers. Every step is safe to re-run because:

- `brew bundle` — queries installed packages, skips matches
- `defaults write` — no-op if value matches
- `git clone` — exits if directory exists
- `ssh-keygen -f X` — refuses to overwrite (won't clobber)
- `pmset -a` — sets values; matches are no-ops
- `op item create || op item edit` — handles "already exists"
- `launchctl bootstrap` — `|| true` swallows "already loaded"
- `git-crypt unlock` — refuses to re-unlock (harmless if files already plain)
- `xcode-select --install` — exits if already installed

Re-run `AI.md` after any change, after `dotfiles pull`, after a crash. Safe.

---

## Known Tahoe 26 regressions (NOT auto-fixed)

- **AirPlay 2 / CoreAudio**: handoff drops after sleep through 26.2. Defer audio config until 26.3+.
- **AirDrop**: unreliable with VPN/security tools active. Check `systemextensionsctl list | grep -qi mullvad`; disable temporarily if present (mini has none).
- **yabai SA**: flaky on 26.1/26.2. Use `asmvik/yabai` HEAD (already in Brewfile).
- **`csrutil status`**: reports `unknown` on Tahoe even when configured. Verify SIP via `yabai --load-sa` exit code instead.

---

## What this runbook does NOT do

- Touch existing WIP in `~/.dotfiles` (only commits explicitly added files)
- Install or configure the `eve` standard user account (separate flow)
- Set up iPhone access (Phase 20+, deferred)
- Disable phantom en5/en6/en7 dock adapter interfaces
- Touch SIP state (stays enabled — preserves iOS app support)
- Install direct-download apps that aren't in Homebrew / MAS (see below)

## Manual installs (not in any package manager)

Apps the owner uses on the laptop that have no Homebrew/MAS path. Re-install
manually on each new Mac via the listed source:

| App | Source | Purpose |
|---|---|---|
| **BatFi** | Direct download (batfi.app) | Battery health menubar (workstation only; useless on always-plugged-in mini) |
| **iDrift** | App Store or direct | Menu bar tweaks |
| **iKontroller** | Direct download | Controller mapping helper |
| **Cartesian** | Direct download | Menu bar layout |
| **FluidNoti** | Direct download | Notification UI replacement |
| **superwhisper** | superwhisper.com | Local Whisper STT, paid one-time |
| **Keynote/Pages Creator Studio** | Direct download | Apple iWork extensions |
| **Whisky** / **Wine Crossover** | brew cask `whisky` + `wine-crossover` ✓ | Game compatibility (tracked) |
| **Steam games** (`~/Applications/*.app`) | Steam | Owner re-downloads as desired |

Mini may not need most of these — most are workstation/laptop ergonomic
helpers (BatFi makes no sense on a desktop; FluidNoti is a personal
preference). Decide per-app on each new Mac.

## Brewfile audit (May 2026)

Drift-check: which leaves/casks on the laptop are NOT in Brewfile.

```bash
# Run on laptop to surface any new drift:
brew leaves | sort > /tmp/leaves.txt
comm -23 /tmp/leaves.txt \
  <(grep '^brew ' ~/.setup/Resources/Brewfile | sed -E 's/^brew "([^"]+)".*/\1/' | sort)

brew list --cask | sort > /tmp/casks.txt
comm -23 /tmp/casks.txt \
  <(grep '^cask ' ~/.setup/Resources/Brewfile | sed -E 's/^cask "([^"]+)".*/\1/' | sort)
```

Anything that shows up is a new gap to add to Brewfile.

## Legacy ~/.setup/ scripts (kept, not invoked by AI.md)

~/.setup/ contains ~30 single-purpose install scripts from the pre-AI era
(`alacritty.sh`, `bot.sh`, `brave.sh`, etc.). They are **not invoked by
the AI bootstrap** — only `Brewfile`, `Brewfile.server`, and `macos.sh`
are. The legacy scripts are kept as reference / standalone manual runs:

```bash
bash ~/.setup/fonts.sh    # Nerd Fonts install (also covered by Brewfile cask "font-*")
bash ~/.setup/git.sh      # git-specific tweaks
bash ~/.setup/web.sh      # web-related apps
# ...etc
```

Run them ad-hoc if AI.md doesn't cover a specific tool. Don't run
`~/.setup/setup.sh` (the old interactive runner) on a new Mac — it
predates Tahoe 26 and has not been audited.

---

## File map

```
~/.setup/
├── AI.md                    ← this file (runbook)
├── ai/
│   ├── ux.sh                ← Tokyo Night palette, box drawing, faces, celebration
│   ├── gate.sh              ← manual-gate orchestration (DRYs the 7 [GATE] phases)
│   └── doctor.sh            ← standalone verify suite (P18); exits 0/1/2
├── Resources/
│   ├── Brewfile             ← workstation profile
│   └── Brewfile.server      ← server profile (eve user)
├── brew.sh                  ← legacy wrapper (still runnable standalone)
├── fonts.sh                 ← Nerd Fonts install
├── macos.sh                 ← 816-line defaults script (invoked by P11)
└── README.md                ← original pre-AI runbook (still works manually)

~/.claude/skills/dotfiles-setup/
└── SKILL.md                 ← trigger phrases; references this file
```

## When to edit what

| Want to change | Edit |
|---|---|
| Add/remove a phase | This file |
| Profile detection logic | This file § "Profiles" |
| Trigger phrases | `~/.claude/skills/dotfiles-setup/SKILL.md` |
| Workstation package list | `~/.setup/Resources/Brewfile` |
| Server package list | `~/.setup/Resources/Brewfile.server` |
| `defaults write` calls | `~/.setup/macos.sh` (called by P11) |
| Visual primitives (palette, faces, boxes) | `~/.setup/ai/ux.sh` |
| Manual-gate UX flow | `~/.setup/ai/gate.sh` |
| Doctor probes (add / remove / filter) | `~/.setup/ai/doctor.sh` |
| Re-run after a phase edit | Just invoke again — scripts are idempotent |

---

## Hand-off contract

1. Owner clones dotfiles or skill does it as P4
2. Owner says "Bootstrap this Mac" / `/dotfiles-setup` to a Claude Code session
3. Claude reads this file, executes top to bottom, pauses at the 7 manual gates
4. Doctor verifies; celebration card prints
5. Owner walks away
