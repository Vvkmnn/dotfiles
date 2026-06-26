#!/usr/bin/env bash
# ai.sh — one-command, idempotent macOS package install for the dotfiles.
#
#   bash ~/.ai/ai.sh          # full install
#   bash ~/.ai/ai.sh check    # just report what's still missing
#
# Fixes the pain points of raw `brew bundle`:
#   - ONE sudo prompt + keep-alive (no repeated passwords through Xcode's 15GB)
#   - refuses to run if another brew is active (prevents lock-contention crashes)
#   - untaps unused taps + trusts used taps (Homebrew 4.6+ tap-trust)
#   - handles the Xcode→menuanywhere ordering (2nd pass after Xcode + license)
#   - minimal clean output; safe to re-run after a crash (everything skips).

set -uo pipefail

BREWFILE="$HOME/.setup/Resources/Brewfile"

say()  { printf '\n\033[1;34m==>\033[0m \033[1m%s\033[0m\n' "$*"; }
ok()   { printf '  \033[32m✓\033[0m %s\n' "$*"; }
warn() { printf '  \033[33m⚠\033[0m %s\n' "$*"; }
die()  { printf '\n\033[31m✗ %s\033[0m\n' "$*" >&2; exit 1; }

command -v brew >/dev/null 2>&1 || eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null)"
command -v brew >/dev/null 2>&1 || die "Homebrew not found (run AI.md P2 first)"
[ -f "$BREWFILE" ] || die "Brewfile not found: $BREWFILE"

# `check` subcommand — read-only status, no install.
if [ "${1:-}" = check ]; then
  brew bundle check --file="$BREWFILE" --verbose 2>&1 | grep -iE 'needs to be|satisfied' || true
  exit 0
fi

# Guard: don't run alongside another brew (this is what caused the crashes).
if pgrep -f 'Homebrew/Homebrew/bin/brew|Library/Homebrew/brew' >/dev/null 2>&1; then
  die "another brew is running — let it finish (or kill it), then re-run this script"
fi

# 1. One sudo + keep-alive (one password for the whole run).
say "sudo — one prompt, kept alive for the whole run"
sudo -v || die "sudo is required for cask/system-extension installs"
( while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done ) &
trap 'kill %1 2>/dev/null' EXIT
ok "sudo cached + refreshing every 60s"

# 2. Taps: drop unused (silence trust warnings), trust the ones we use.
say "taps"
for t in oven-sh/bun getsentry/xcodebuildmcp; do
  brew untap "$t" >/dev/null 2>&1 && warn "untapped unused $t"
done
grep -E '^tap "' "$BREWFILE" | sed -E 's/^tap "([^"]+)".*/\1/' | while read -r t; do
  brew trust "$t" >/dev/null 2>&1 && ok "trusted $t"
done

# 3. brew bundle (Xcode ~15GB via App Store is slow + shows no progress bar).
say "brew bundle — installing (Xcode is large; App Store shows no progress, be patient)"
brew bundle install --file="$BREWFILE" || warn "first pass had failures (expected: menuanywhere needs Xcode) — fixing next"

# 4. Xcode (installed separately via `xcodes` — see SECRETS.md) → select it,
#    accept license, 2nd bundle pass so menuanywhere builds. NOTE: `xcodes` installs
#    to a VERSIONED path (e.g. Xcode-26.5.0.app), NOT Xcode.app — so glob for it.
XCODE_APP=$(ls -d /Applications/Xcode*.app 2>/dev/null | sort -V | tail -1)
if [ -n "$XCODE_APP" ]; then
  say "Xcode present ($(basename "$XCODE_APP")) → select, accept license, build menuanywhere"
  sudo xcode-select -s "$XCODE_APP/Contents/Developer" 2>/dev/null && ok "xcode-select → $(basename "$XCODE_APP")"
  sudo xcodebuild -license accept 2>/dev/null && ok "Xcode license accepted" || warn "license accept skipped"
  brew bundle install --file="$BREWFILE" || warn "second pass still has failures (see verify)"
else
  warn "Xcode not installed. To install headless (Apple ID from 1Password):"
  warn '  XCODES_USERNAME=op://Personal/Apple/username XCODES_PASSWORD=op://Personal/Apple/password op run -- xcodes install --latest'
  warn "then re-run ai.sh to build menuanywhere (skhd/sketchybar/etc. already work without it)."
fi

# 5. Start the window-manager stack as login services (idempotent; no sudo —
#    basic yabai, no scripting-addition). They only fully work once you grant
#    the TCC permissions in step 6.
say "window manager services"
command -v yabai >/dev/null 2>&1 && { yabai --start-service 2>/dev/null; ok "yabai service"; }
command -v skhd  >/dev/null 2>&1 && { skhd  --start-service 2>/dev/null; ok "skhd service"; }
for svc in sketchybar borders menuanywhere; do
  command -v "$svc" >/dev/null 2>&1 && { brew services start "$svc" >/dev/null 2>&1; ok "$svc service"; }
done
# tmux plugins via tpm (config loads without them, but features need them)
if [ -x "$HOME/.config/tmux/plugins/tpm/bin/install_plugins" ]; then
  "$HOME/.config/tmux/plugins/tpm/bin/install_plugins" >/dev/null 2>&1 && ok "tmux plugins (tpm)"
fi

# 6. Manual gate — TCC permissions (macOS won't let a script grant these).
#    Open the panes; add the listed apps. One trip, then they all work.
say "GATE: grant permissions (one System Settings trip — can't be scripted)"
warn "Privacy & Security → Accessibility:  add yabai, skhd, Karabiner-Elements"
warn "Privacy & Security → Input Monitoring: add skhd, Karabiner-Elements (karabiner_grabber)"
warn "Privacy & Security → (approve) system extensions: Karabiner, Mullvad, AdGuard"
open 'x-apple.systempreferences:com.apple.settings.PrivacySecurity?Privacy_Accessibility' 2>/dev/null
open 'x-apple.systempreferences:com.apple.settings.PrivacySecurity?Privacy_ListenEvent' 2>/dev/null

# 7. Verify.
say "verify"
if brew bundle check --file="$BREWFILE" >/dev/null 2>&1; then
  ok "all Brewfile entries installed"
else
  warn "still missing:"
  brew bundle check --file="$BREWFILE" --verbose 2>&1 | grep -iE 'needs to be' | sed 's/^/      /'
fi
echo
ok "done. If yabai/skhd don't respond yet, grant the permissions above, then: yabai --restart-service && skhd --restart-service"
