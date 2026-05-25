# dotfiles-ai — the 19-phase runbook

> **Read [AI.md](./AI.md) first** if you don't know what this file is.
> AI.md is the primer; this file is the runbook Claude executes.

> Owner environment bootstrap for a Mac. Reusable across machines —
> workstation (owner accounts: `v` on laptop/mini admin/Studio admin) and
> server (`eve` daemon user on mini/Studio).
> Calls existing `~/.setup/*.sh` scripts where they're non-interactive.
> State markers at `~/.setup/dotfiles-ai/state/` (gitignored).
> Visual layer in `~/.setup/dotfiles-ai/ui.sh` (Tokyo Night, face glyphs, box drawing).

## How to use

| Command | Action |
|---|---|
| `/dotfiles-ai` | First call: dry-run (plan + verify probes only). Type `go` to execute. |
| `/dotfiles-ai resume` | Re-runs only steps whose marker is missing or whose verify-block SHA changed. |
| `/dotfiles-ai doctor` | Run every verify probe. Report drift. No changes. |
| `/dotfiles-ai reset <key>` | Delete one marker so that step re-runs next time. |
| `DOTFILES_AI_SOUND=0 /dotfiles-ai` | Silence milestone sounds. |

## Profile detection — by user role

```bash
# Profile is determined by who the account is FOR, not what hardware it
# runs on. Owner accounts (v, vivek, etc.) get the full workstation
# stack regardless of machine. The dedicated daemon user `eve` gets
# the lean server profile.
#
# Override with: export DOTFILES_AI_PROFILE=server  (or workstation)

if [ -z "$DOTFILES_AI_PROFILE" ]; then
  case "$USER" in
    eve)         DOTFILES_AI_PROFILE=server      ;;  # daemon host on mini/Studio
    *)           DOTFILES_AI_PROFILE=workstation  ;;  # owner: laptop, mini admin, Studio admin
  esac
fi
export DOTFILES_AI_PROFILE
```

**Why user-based**: the mini admin account (`v`) is screen-shared into ~90% of the time — needs window management, sketchybar, karabiner, the works. Mini's `eve` user runs daemons (Matrix, bot, router) — no GUI, lean install. Hardware is irrelevant; user role decides.

## State paths

```
~/.setup/dotfiles-ai/state/<step-key>.done    timestamp + SHA of verify block
~/.setup/dotfiles-ai/state/manifest.txt       rollup, grep-friendly
~/.setup/dotfiles-ai/state/warnings.log       skipped-with-warning entries
```

All gitignored. `dotfiles config status.showUntrackedFiles no` already suppresses listing.

---

## Phase 0 — Preflight (read-only, fails fast)

### P0.1 Hardware spec
```bash
verify:
  test "$(uname -m)" = "arm64" || die "Not Apple Silicon"
  test "$(sysctl -n hw.memsize)" -ge 17179869184 || die "RAM < 16 GB"
  test "$(df -k / | awk 'NR==2 {print $4}')" -ge 209715200 || die "Free disk < 200 GB"
```

### P0.2 macOS version
```bash
verify:
  ver=$(sw_vers -productVersion)
  # sort -CV checks non-decreasing order. Threshold first, $ver second,
  # so "26.0\n26.3\n" is ascending → passes for any macOS ≥ 26.0.
  printf '26.0\n%s\n' "$ver" | sort -CV || die "macOS < 26 — runbook is Tahoe-targeted"
```

### P0.3 iCloud signed in + Apple ID match (server profile only)
```bash
verify:
  this_id=$(defaults read MobileMeAccounts Accounts 2>/dev/null \
            | awk -F'"' '/AccountID/ {print $2; exit}')
  test -n "$this_id" || die "Not signed into iCloud"
  if [ "$DOTFILES_AI_PROFILE" = "server" ]; then
    # Fetch primary Mac's AccountID via tailnet for comparison
    primary=$(tailscale status 2>/dev/null \
              | awk '/MacBook|iMac/ {print $2; exit}')
    if [ -n "$primary" ]; then
      remote_id=$(ssh "$primary" "defaults read MobileMeAccounts Accounts 2>/dev/null \
                                  | awk -F\\\" '/AccountID/ {print \$2; exit}'")
      [ "$this_id" = "$remote_id" ] || warn "Apple ID mismatch: this=$this_id primary=$remote_id"
    fi
  fi
on-fail:
  open 'x-apple.systempreferences:com.apple.systempreferences.AppleIDSettings'
  Sign out, then sign back in with the SAME Apple ID as the primary Mac.
```

### P0.4 Network audit (informational)
```bash
verify:
  default_if=$(route -n get default | awk '/interface:/ {print $2}')
  ether_up=$(ifconfig en0 2>/dev/null | grep -c 'status: active')
  wifi_up=$(ifconfig en1 2>/dev/null | grep -c 'status: active')
  ether_inet=$(ifconfig en0 2>/dev/null | grep -c 'inet ')
  wifi_inet=$(ifconfig en1 2>/dev/null | grep -c 'inet ')
  if [ "$DOTFILES_AI_PROFILE" = "server" ] && [ "$ether_up" -eq 1 ] && [ "$wifi_up" -eq 1 ]; then
    warn "Server profile + Ethernet + Wi-Fi both up — Phase 3 will disable Wi-Fi"
  fi
  adapters=$(networksetup -listallhardwareports | grep -c 'Ethernet Adapter')
  [ "$adapters" -gt 0 ] && echo "$adapters adapter interface(s) detected — likely a dock; left alone"
```

### P0.5 System extensions inventory
```bash
verify:
  count=$(systemextensionsctl list 2>&1 | awk '/^[[:space:]]*\*/ {n++} END {print n+0}')
  echo "$count pre-existing system extensions"
  systemextensionsctl list 2>&1 | grep -q 'io.tailscale' \
    && warn "Pre-existing Tailscale extension — confirm not orphaned App Store install (tailscale#17891)"
```

### P0.6 Live ~/.claude state to preserve
```bash
verify:
  if [ -d "$HOME/.claude" ]; then
    echo "Claude state present — Phase 5 preserves projects/sessions/session-env via .backup/"
  fi
```

### P0.7 git-crypt key availability
```
mode: manual-gate
instructions:
  The dotfiles repo encrypts ~/.claude.json + 3 other files via git-crypt.
  Per ~/.github/README.md, the key lives in TWO places:
    1. ~/Documents/key on owner's primary Mac
    2. 1Password vault entry
  
  Bootstrap needs the key local before checkout. Either:
    A. AirDrop ~/Documents/key from primary Mac to this Mac's Downloads
    B. Open 1Password, save key contents to ~/Documents/key here
  
  Open Finder for path A:
    open ~/Downloads
  
  Type 'done' when the key is at ~/Downloads/key OR ~/Documents/key.

verify:
  test -f "$HOME/Downloads/key" -o -f "$HOME/Documents/key" \
    || die "git-crypt key missing"
```

---

## Phase 1 — Hostname sanity

```bash
verify:
  cn=$(scutil --get ComputerName)
  ln=$(scutil --get LocalHostName)
  [ "$cn" = "$ln" ] || warn "ComputerName/LocalHostName mismatch ($cn vs $ln)"
  case "$cn" in vMini*|vBook*|vStudio*) ;; *) warn "Unconventional name: $cn" ;; esac
```

## Phase 2 — Foundations: Xcode CLT, Homebrew, baseline tools

```bash
action:
  xcode-select --install 2>/dev/null || true
  until xcode-select -p >/dev/null 2>&1; do sleep 5; done
  
  if ! command -v brew >/dev/null; then
    NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  brew install git git-crypt jq

verify:
  command -v brew && command -v git-crypt && command -v jq
```

## Phase 3 — Network priority (server profile — Wi-Fi stays available)

> Server profile prefers Ethernet but keeps Wi-Fi as fallback so the mini
> stays reachable through network changes, cable unplugs, or ISP swaps.
> Let the machine decide based on what's connected.

```bash
condition: $DOTFILES_AI_PROFILE = server
action:
  # Prefer Ethernet when wired; keep Wi-Fi enabled for fallback.
  if ifconfig en0 2>/dev/null | grep -q 'status: active'; then
    # Move Ethernet above Wi-Fi in service order. Idempotent — no-op
    # if already ordered correctly.
    networksetup -ordernetworkservices "Ethernet" "Wi-Fi" 2>/dev/null || true
    echo "Ethernet prioritized; Wi-Fi kept as fallback"
  else
    echo "No Ethernet active; Wi-Fi remains default"
  fi

verify:
  # Default route must exist via some en* interface.
  route -n get default 2>/dev/null | awk '/interface:/ {print $2}' \
    | grep -qE '^en[0-9]+$' || warn "No default route via en*"
```

If Wi-Fi is on a separate subnet from Ethernet (audit found en1 on
192.168.11.0/24 vs en0 on 192.168.4.0/22 — likely a guest VLAN or
different SSID), Tailscale MagicDNS doesn't care: both interfaces reach
the tailnet. Owner can swap SSIDs via System Settings → Wi-Fi later if
they want both NICs on the same subnet.

## Phase 4 — Clone dotfiles bare repo

```bash
action:
  # First-boot clone uses HTTPS because the ed25519 SSH key isn't
  # generated until P15. P15 rewrites the remote to SSH after keygen.
  if [ ! -d "$HOME/.dotfiles" ]; then
    if ! git clone --bare git@github.com:Vvkmnn/dotfiles.git "$HOME/.dotfiles" 2>/dev/null; then
      git clone --bare https://github.com/Vvkmnn/dotfiles.git "$HOME/.dotfiles"
    fi
  fi
  
  dotfiles() { /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"; }
  export -f dotfiles
  
  # Server profile forks from v-macos-macbook (closest parity);
  # later, rebase periodically onto v-macos shared base.
  base=v-macos-macbook
  case "$DOTFILES_AI_PROFILE" in
    workstation) machine=v-macos-macbook ;;
    server)      machine=v-macos-mini ;;   # rename per hostname for studio
  esac
  
  # First-pass checkout — capture conflicts to .backup/
  if ! dotfiles checkout "$base" 2>&1 | tee /tmp/dotfiles-checkout.log; then
    mkdir -p "$HOME/.backup"
    awk '/^\s+\./ {print $1}' /tmp/dotfiles-checkout.log | while read f; do
      mv "$HOME/$f" "$HOME/.backup/$f" 2>/dev/null || true
    done
    dotfiles checkout "$base"
  fi
  dotfiles config status.showUntrackedFiles no
  
  # Fork to machine-specific branch
  [ "$machine" != "$base" ] && dotfiles checkout -B "$machine" || true

verify:
  test -n "$(dotfiles branch --show-current)"
```

## Phase 5 — Restore live ~/.claude state if backed up

```bash
action:
  for d in projects sessions session-env shell-snapshots backups cache; do
    if [ -d "$HOME/.backup/.claude/$d" ]; then
      rm -rf "$HOME/.claude/$d" 2>/dev/null || true
      mv "$HOME/.backup/.claude/$d" "$HOME/.claude/$d"
    fi
  done

verify:
  test -d "$HOME/.claude"
```

## Phase 6 — Submodules

```bash
action:
  dotfiles submodule update --init --recursive --jobs 4

verify:
  test -f "$HOME/.config/nvim/init.lua"
```

## Phase 7 — git-crypt unlock

```bash
action:
  key=""
  [ -f "$HOME/Downloads/key" ] && key="$HOME/Downloads/key"
  [ -f "$HOME/Documents/key" ] && key="$HOME/Documents/key"
  test -n "$key" || die "git-crypt key vanished between P0.7 and P7"
  ( cd "$HOME" && git-crypt unlock "$key" )

verify:
  head -1 "$HOME/.claude.json" 2>/dev/null | grep -qv 'GITCRYPT' \
    || die "git-crypt unlock failed"

on-success:
  [ -f "$HOME/Downloads/key" ] && rm -P "$HOME/Downloads/key"
```

## Phase 8 — Brewfile (profile-conditional)

```bash
action:
  case "$DOTFILES_AI_PROFILE" in
    workstation)
      brew bundle install --file="$HOME/.setup/Resources/Brewfile"
      ;;
    server)
      brew bundle install --file="$HOME/.setup/Resources/Brewfile.server"
      ;;
  esac

verify:
  command -v claude && command -v tmux && command -v op && command -v mosh
  test -d /Applications/Tailscale.app
```

## Phase 9 — Install launchagents (existing sed __HOME__ loop)

```bash
action:
  for f in "$HOME/.config/launchagents/"*.plist; do
    [ -e "$f" ] || continue
    base=$(basename "$f")
    out="$HOME/Library/LaunchAgents/$base"
    mkdir -p "$HOME/Library/LaunchAgents"
    sed "s|__HOME__|$HOME|g" "$f" > "$out"
    launchctl bootstrap "gui/$(id -u)" "$out" 2>/dev/null || true
  done

verify:
  launchctl print "gui/$(id -u)/com.user.tmux" >/dev/null
  launchctl print "gui/$(id -u)/com.claude.mcp-proxy" >/dev/null
```

## Phase 10 — Wait for iCloud sync to settle

```
mode: manual-gate
instructions:
  iCloud silently reverts ~10 lines of macos.sh (Finder icon view, Mail
  threading, Safari URL display) if applied before sync settles. Wait
  2-3 min after iCloud sign-in.
  
  open 'x-apple.systempreferences:com.apple.systempreferences.AppleIDSettings'
  
  Type 'done' when iCloud panel shows no spinners and expected apps say "Synced".

verify:
  true   # owner-confirmed; no programmatic probe
```

## Phase 11 — Apply ~/.setup/macos.sh (existing script)

```bash
action:
  # The existing macos.sh is mostly non-interactive `defaults write` calls.
  # We invoke it directly. Audit flagged dead lines (111, 659-662, 706,
  # 721-724, 757-775, 778-803) — those will silently no-op, harmless.
  # On server profile, third-party app sections become no-ops too.
  bash "$HOME/.setup/macos.sh" 2>&1 | tail -20
  echo "macos.sh applied. Some changes need a logout to take full effect."

verify:
  # `defaults read` exits non-zero on unset keys. Coerce to a sentinel
  # so we can distinguish "macos.sh not run yet" (unset) from
  # "macos.sh ran but key wrong" (set to wrong value).
  test "$(defaults read NSGlobalDomain AppleShowAllExtensions 2>/dev/null || echo unset)" = "1"
  test "$(defaults read com.apple.dock autohide 2>/dev/null || echo unset)" = "1"
```

## Phase 12 — pmset never-sleep (server profile only) [admin-gate]

```bash
condition: $DOTFILES_AI_PROFILE = server
gate: admin   # requires sudo password
action:
  # Pre-cache sudo timestamp so the pmset call doesn't block mid-phase.
  # On a fresh login, prompt once interactively; subsequent sudo within
  # the timestamp_timeout window (default 5 min) is non-interactive.
  sudo -v || die "sudo required for pmset — owner must authenticate"
  
  sudo pmset -a sleep 0 disksleep 0 displaysleep 30 \
              womp 1 powernap 1 networkoversleep 1 tcpkeepalive 1 \
              standby 0 autorestart 1 hibernatemode 0

verify:
  pmset -g custom | grep -E '^[[:space:]]*sleep[[:space:]]+0' >/dev/null
  pmset -g custom | grep -E '^[[:space:]]*womp[[:space:]]+1' >/dev/null
  pmset -g custom | grep -E '^[[:space:]]*autorestart[[:space:]]+1' >/dev/null
```

## Phase 13 — TCC checklist (manual-gate, single batched System Settings trip)

```
mode: manual-gate
instructions:
  Single trip. Open each pane via the deeplinks below. Add Terminal.app
  (and Ghostty.app if on workstation) to each:
  
  ACCESSIBILITY:
    open 'x-apple.systempreferences:com.apple.settings.PrivacySecurity?Privacy_Accessibility'
  
  FULL DISK ACCESS:
    open 'x-apple.systempreferences:com.apple.settings.PrivacySecurity?Privacy_AllFiles'
  
  LOCAL NETWORK:
    open 'x-apple.systempreferences:com.apple.settings.PrivacySecurity?Privacy_LocalNetwork'
  
  Workstation-only — SCREEN RECORDING:
    open 'x-apple.systempreferences:com.apple.settings.PrivacySecurity?Privacy_ScreenCapture'
  
  iPhone notification sent. Type 'done' when complete.

verify:
  sqlite3 "$HOME/Library/Application Support/com.apple.TCC/TCC.db" \
    "select 1 from access limit 1" >/dev/null 2>&1 \
    || warn "FDA not granted to Terminal — re-verify in Settings"
```

## Phase 14 — Tailscale install + OAuth + SSH

```
mode: manual-gate
instructions:
  Tailscale is in the Brewfile. Sign in (browser flow), then enable SSH.
  
    open -a Tailscale
  
  Menu bar → Log In → sign in with Apple ID (same as iCloud).
  Wait for the menu bar to show "Logged in".
  Then in Terminal:
  
    sudo tailscale up --ssh
  
  Tailscale SSH lets tailnet identity authenticate SSH; OpenSSH stays
  enabled as on-LAN fallback. Type 'done'.

verify:
  tailscale status >/dev/null 2>&1 || die "Tailscale not signed in"
  test -n "$(tailscale ip -4 2>/dev/null)" || die "No Tailscale IP"
```

## Phase 15 — Per-device ed25519 key + 1Password registry

```bash
action:
  mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
  host=$(scutil --get LocalHostName | tr A-Z a-z)
  keyfile="$HOME/.ssh/id_ed25519_${host}"
  [ -f "$keyfile" ] || ssh-keygen -t ed25519 -C "${host}@$(date +%Y%m%d)" -N "" -f "$keyfile"
  
  touch "$HOME/.ssh/authorized_keys" && chmod 600 "$HOME/.ssh/authorized_keys"
  
  if command -v op >/dev/null && op account list 2>/dev/null | grep -q .; then
    # Store this host's pubkey in 1Password (canonical item name)
    op item create --vault Private --category 'SSH Key' \
      --title "Mac SSH key — ${host}" \
      "public_key=$(cat ${keyfile}.pub)" 2>/dev/null \
      || op item edit "Mac SSH key — ${host}" \
        "public_key=$(cat ${keyfile}.pub)"
    
    # Fetch peer pubkeys + add to authorized_keys
    for peer in vbookair vminim4 vstudio iphone15pm; do
      [ "$peer" = "$host" ] && continue
      pk=$(op item get "Mac SSH key — ${peer}" --field public_key 2>/dev/null)
      [ -n "$pk" ] && ! grep -qF "$pk" "$HOME/.ssh/authorized_keys" \
        && echo "$pk" >> "$HOME/.ssh/authorized_keys"
    done
  fi
  
  # 1Password SSH agent line
  grep -q '1password.*agent.sock' "$HOME/.ssh/config" 2>/dev/null || cat >> "$HOME/.ssh/config" <<'EOF'

Host *
  IdentityAgent ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
EOF

  # Rewrite dotfiles remote to SSH (P4 may have used HTTPS as bootstrap
  # fallback before this key existed). Idempotent — no-op if already SSH.
  if [ -d "$HOME/.dotfiles" ]; then
    current_url=$(/usr/bin/git --git-dir="$HOME/.dotfiles" remote get-url origin 2>/dev/null || echo "")
    case "$current_url" in
      https://*) /usr/bin/git --git-dir="$HOME/.dotfiles" \
          remote set-url origin git@github.com:Vvkmnn/dotfiles.git ;;
    esac
  fi

verify:
  test -f "$HOME/.ssh/id_ed25519_$(scutil --get LocalHostName | tr A-Z a-z)"
  grep -q '1password' "$HOME/.ssh/config"
  # dotfiles remote is SSH (either set originally or rewritten above)
  /usr/bin/git --git-dir="$HOME/.dotfiles" remote get-url origin | grep -q '^git@github.com:'
```

## Phase 16 — Remote Login ON (both profiles)

```
mode: manual-gate
instructions:
  Enable Remote Login (sshd) so the other Macs and iPhone can ssh in.
  
    open 'x-apple.systempreferences:com.apple.settings.PrivacySecurity?Privacy_Sharing'
  
  System Settings → General → Sharing → Remote Login ON.
  "Allow full disk access for remote users" is your call (more
  convenient, slight blast radius increase).
  
  Type 'done'.

verify:
  systemsetup -getremotelogin 2>/dev/null | grep -q "On" \
    || die "Remote Login still off"
```

## Phase 17 — Workstation extras: yabai SA + sketchybar (workstation only)

```bash
condition: $DOTFILES_AI_PROFILE = workstation
action:
  yabai_bin=$(command -v yabai)
  [ -n "$yabai_bin" ] && {
    echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 "$yabai_bin" | awk '{print $1}') $yabai_bin --load-sa" \
      | sudo tee /etc/sudoers.d/yabai >/dev/null
    sudo yabai --install-sa
    yabai --start-service
  }
  command -v skhd >/dev/null && skhd --start-service
  brew services start FelixKratz/formulae/sketchybar 2>/dev/null || true

verify:
  pgrep -x yabai >/dev/null && pgrep -x skhd >/dev/null
```

Server profile skips this phase entirely — `yabai/skhd/sketchybar/karabiner` are not in `Brewfile.server`.

## Phase 17.5 — Native Continuity (Tahoe 26 / iOS 26 additions)

> Mostly iPhone-side single toggles. Owner can pre-complete in parallel
> with bootstrap execution. Pre-flight surfaces which gates are still
> pending; this phase is mostly verification + one-time pairs.

### P17.5.1 Handoff toggle (both Macs)
```
mode: manual-gate
instructions:
  open 'x-apple.systempreferences:com.apple.preference.general'
  General → AirDrop & Handoff → "Allow Handoff between this Mac
  and your iCloud devices" ON
verify:
  pgrep -x useractivityd >/dev/null
```

### P17.5.2 iMessage / SMS forwarding (iPhone-side)
```
mode: manual-gate
instructions:
  iPhone → Settings → Messages → Text Message Forwarding →
  toggle this Mac ON. Code appears on Mac; type on iPhone.
verify:
  # iPhone-side toggle. Owner-confirmed; no reliable Mac probe.
```

### P17.5.3 Phone calls relay (NEW Tahoe, iPhone-side)
```
mode: manual-gate
instructions:
  iPhone → Settings → Phone → Calls on Other Devices →
  toggle this Mac ON. Cellular calls ring on Mac via Phone.app.
  Hold Assist + Call Screening included.
verify:
  test -d "/System/Applications/Phone.app"
```

### P17.5.4 Continuity Camera (iPhone as webcam)
```
mode: manual-gate
instructions:
  iPhone → Settings → General → AirPlay & Continuity →
  Continuity Camera ON. Tahoe addition: Magnifier mode for whiteboards.
verify:
  # iPhone-side. Owner-confirmed via Camera picker in FaceTime/Zoom.
```

### P17.5.5 iPhone Mirroring one-time pair
```
mode: manual-gate (one-time per Mac)
action:
  open -a "iPhone Mirroring"
  # Approve on iPhone-side prompt. After pair: Spotlight on Mac
  # indexes iPhone apps (Tahoe-new).
verify:
  # No reliable Mac-side probe for pair status — only checks the app
  # is installed. Pair state lives in keychain + iPhone-side approval.
  # Owner confirms pairing by opening the app and seeing the phone screen.
  test -d "/System/Applications/iPhone Mirroring.app"
```

### P17.5.6 Notes markdown (NEW Tahoe)
```
mode: auto
action:
  defaults write com.apple.Notes EnableMarkdown -bool true 2>/dev/null || true
verify:
  defaults read com.apple.Notes EnableMarkdown 2>/dev/null | grep -q '1' \
    || warn "Notes markdown not enabled (optional)"
```

### P17.5.7 Apple Intelligence opt-in (~7 GB model)
```
mode: manual-gate
instructions:
  open 'x-apple.systempreferences:com.apple.AppleIntelligence-Settings.extension'
  Toggle ON. ~7 GB model downloads in background (15-30 min).
  Required for: Notes call transcription, Reminders auto-categorize,
  Writing Tools, Image Playground. Private Cloud Compute fallback
  for heavy queries (Apple Silicon servers, data not stored).
  Skip if cloud fallback uncomfortable.
verify:
  defaults read com.apple.AppleIntelligence Enabled 2>/dev/null | grep -q '1' \
    || warn "Apple Intelligence not opted-in (optional)"
```

### P17.5.8 AirDrop verify (Tahoe regression test)
```
mode: info + manual-verify
instructions:
  AirDrop broken in 26.0–26.2 with VPN/security tools active
  (Mullvad daemon is a known culprit on the laptop; the mini
  has no Mullvad — skip the disable step there).
  Test: send small file laptop ↔ mini ↔ iPhone (all 3 pairs).
  If any pair fails AND Mullvad is installed: disable temporarily, re-test.
  Probe whether Mullvad is present:
    systemextensionsctl list 2>/dev/null | grep -qi mullvad && echo "Mullvad present" || echo "no Mullvad"
  If still fails: Network → Firewall → off, re-test.
```

### P17.5.9 Shortcuts Mac automations (NEW Tahoe, info-only)
```
note:
  Tahoe 26 added Mac-side automation triggers: folder changes,
  drive connect, app launch/quit, battery level, Wi-Fi connect.
  Open Shortcuts.app → Automation tab. Apple Intelligence
  actions available inside flows. Awareness only; no required setup.
```

## Known Tahoe regressions (NOT auto-fixed)

- **AirPlay 2 / CoreAudio** broken through 26.2 — Apple Music handoff
  drops after sleep. Defer audio-handoff config until 26.3+ patch.
- **AirDrop** unreliable with VPN/security tools — see P17.5.8.
- **yabai SA** flaky on 26.1/26.2 — use `asmvik/yabai` HEAD per P17.
- **csrutil status** reports `unknown` on Tahoe even when configured —
  verify SIP via `yabai --load-sa` exit code, not `csrutil`.

## Phase 18 — Doctor (verify suite)

`/dotfiles-ai doctor` runs all of these. Exit 0 (all green) / 1 (warnings) / 2 (failures). One probe per line.

```
- hw            arm64 + RAM ≥ 16 GB + disk ≥ 200 GB free
- macos         ≥ 26.0
- apple-id      MobileMeAccounts AccountID populated
- same-id       (server) AccountID matches primary Mac's
- network       exactly one default route
- wifi-off      (server) en1 power is Off
- tailscale     `tailscale ip -4` returns 100.x.x.x
- tailscale-ssh `tailscale debug capability ssh` succeeds
- magic-dns     tailnet contains this host's name
- sshd          (after P16) sshd LaunchDaemon is loaded
- mosh          `command -v mosh-server` succeeds
- tmux-svc      com.user.tmux LaunchAgent is loaded
- mcp-svc       com.claude.mcp-proxy LaunchAgent is loaded
- claude-cli    `claude --version` returns
- claude-tmux   tmux session 'claude' exists with claude PID
- dotfiles      `dotfiles status` clean (modulo intentional WIP)
- git-crypt     ~/.claude.json head ≠ 'GITCRYPT'
- pmset         (server) sleep=0, womp=1, autorestart=1
- icloud-drv    ~/Library/Mobile Documents/com~apple~CloudDocs exists
- tcc-fda       Terminal can read TCC.db
- workstation   (workstation) yabai+skhd+sketchybar PIDs alive
- handoff       useractivityd PID alive (Handoff toggle in AirDrop & Handoff pref)
- time-sync     sntp offset < 5s from time.apple.com
- imessage-fwd  (manual-confirmed; SMS rows in ~/Library/Messages/chat.db)
- phone-relay   /System/Applications/Phone.app exists (Tahoe-new native)
- cont-cam      (iPhone-side; FaceTime camera picker lists iPhone)
- iphone-mirror /System/Applications/iPhone\ Mirroring.app exists + paired
- apple-intel   `defaults read com.apple.AppleIntelligence Enabled` == 1 (optional)
- notes-md      `defaults read com.apple.Notes EnableMarkdown` == 1
- airdrop       send-file probe to laptop+iPhone succeeds (Tahoe regression test)
- mullvad-iso   if airdrop fails AND mullvad-daemon running, suspect VPN extension
```

Output uses `~/.setup/dotfiles-ai/ui.sh`'s `ui_doctor_line` per check.

## Phase 19 — Celebration card

If all green, the skill prints (via `ui_celebration`):

```
  ┌─ [$_$]  This machine is your machine.
  │
  │   profile    server (Mac mini)
  │   hostname   vMiniM4
  │   tailnet    vminim4.tail-XXXX.ts.net
  │   reachable  ssh v@vminim4 (LAN + Tailscale)  ·  mosh v@vminim4 (iPhone-friendly)
  │
  │      ╭──────────────────────────────╮
  │      │  N auto steps         ✓      │
  │      │  M manual gates       ✓      │
  │      │  XX packages          ✓      │
  │      │  YYY files synced     ✓      │
  │      │  ZZ min ZZ sec               │
  │      ╰──────────────────────────────╯
  │
  │   Try now:
  │     ssh mini → tmux attach -t claude
  │     /dotfiles-ai doctor → re-verify any time
  │
  └──   Welcome home.
```

## Phase 20+ — iPhone access (deferred)

When ready: Blink Shell from App Store ($20), Tailscale from App Store (free), generate ed25519 in Blink (Settings → Keys), AirDrop pubkey to a Mac, add as "Mac SSH key — iphone15pm" in 1Password. Subsequent Macs auto-pull and authorize.

Trigger: `/dotfiles-ai phone` (skill stub TBD).

---

## Resume + debug semantics

- **Resume from interruption** — re-running `/dotfiles-ai` reads the manifest, skips done steps.
- **Edit a step's verify block** — SHA changes, marker invalidates, step re-runs.
- **Single-step rerun** — `/dotfiles-ai reset <key>` then `/dotfiles-ai`.
- **Drift check** — `/dotfiles-ai doctor` anytime, no changes.
- **Warnings** — `~/.setup/dotfiles-ai/state/warnings.log` accumulates skip-with-warning entries; final card surfaces count.

## What this runbook does NOT do

- Touch existing WIP in `~/.dotfiles` (only commits files explicitly added).
- Modify `~/.setup/setup.sh` or other interactive scripts.
- Install or configure the `eve` standard user account on the mini.
- Set up iPhone access (Phase 20+ deferred).
- Disable en5/en6/en7 (dock adapters — left alone unless owner says otherwise).
- Touch SIP state (stays enabled — yabai ~80% functionality plus iOS apps work).

## What this runbook DOES reuse from existing dotfiles

- `~/.setup/Resources/Brewfile` (workstation profile)
- `~/.setup/macos.sh` (defaults, both profiles)
- `~/.config/launchagents/*.plist` (sed `__HOME__` loop)
- `~/.config/tmux/claude-session-restore.sh` + tmux-resurrect machinery (carries via dotfiles checkout)
- `~/.config/tmux/claude-idle-checker.sh` (carries)
- The bare-repo checkout pattern + conflict-resolver one-liner from `~/.github/README.md`

## Hand-off

This file is the source of truth. The skill at `~/.claude/skills/dotfiles-ai/SKILL.md` orchestrates phases. The visual layer at `~/.setup/dotfiles-ai/ui.sh` produces the box-drawn output. `~/.setup/Resources/Brewfile.server` defines the server profile's package set.

When invoked on a fresh Mac with Claude Code installed:
1. Owner clones dotfiles bare repo (or skill does it as Phase 4)
2. Owner says `/dotfiles-ai` to mini Claude
3. Skill reads this file, executes phase-by-phase, pauses at the 4 manual gates
4. Doctor verifies; celebration card prints
5. Owner walks away
