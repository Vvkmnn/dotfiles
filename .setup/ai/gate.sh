#!/usr/bin/env bash
# ai/gate.sh — manual-gate orchestration helper for dotfiles-ai.
#
# DRYs up the 7 [GATE] phases in AI.md. Each gate has the same shape:
#   1. Probe verify; if already passes, skip the whole interaction
#   2. Open the System Settings deeplink
#   3. Send iPhone notification via osascript
#   4. Print the box (sources ai/ux.sh)
#   5. Loop on user input: done re-runs verify; skip warns; abort exits
#
# Usage:
#   . ~/.setup/ai/gate.sh                       # also sources ai/ux.sh
#   ai_gate <name> <deeplink> <verify_cmd> [help_line...]
#
# Returns: 0 (done), 1 (skipped), 2 (aborted by owner)
#
# Examples:
#   ai_gate "TCC Accessibility" \
#     'x-apple.systempreferences:com.apple.settings.PrivacySecurity?Privacy_Accessibility' \
#     'sqlite3 "$HOME/Library/Application Support/com.apple.TCC/TCC.db" "select 1 from access limit 1" >/dev/null' \
#     "Add Terminal.app (and Ghostty.app on workstation) to the list"
#
#   ai_gate "Tailscale OAuth" \
#     "" \
#     'tailscale status >/dev/null 2>&1 && [ -n "$(tailscale ip -4 2>/dev/null)" ]' \
#     "Menu bar → Log In → Apple ID, then: sudo tailscale up --ssh"

# Source visual layer (relative path so this works from any CWD).
_gate_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./ux.sh
. "$_gate_dir/ux.sh"

# Owner iPhone number for Messages-based notifications.
# Override: export AI_GATE_IPHONE='+1...'  (E.164 format)
: "${AI_GATE_IPHONE:=}"

# Send iPhone notification. Tries Messages first (if AI_GATE_IPHONE set),
# falls back to local notification center. Non-blocking.
_gate_notify() {
  local title="${1:?}"
  if [ -n "$AI_GATE_IPHONE" ]; then
    osascript >/dev/null 2>&1 <<EOF &
tell application "Messages"
  send "dotfiles-ai paused: $title" to buddy "$AI_GATE_IPHONE"
end tell
EOF
  fi
  osascript -e "display notification \"$title\" with title \"dotfiles-ai\" sound name \"Glass\"" 2>/dev/null &
}

# ai_gate <name> <deeplink> <verify_cmd> [help_lines...]
ai_gate() {
  local name="${1:?}" deeplink="${2:-}" verify="${3:?}"
  shift 3

  # 1. Pre-check — silent skip if verify already passes (idempotent re-runs).
  if eval "$verify" >/dev/null 2>&1; then
    ui_step ok "$name (already satisfied)"
    return 0
  fi

  # 2-4. Open deeplink, notify, print box.
  local color="$UI_C_ORANGE" face
  face=$(_ui_face)
  printf '\n  \033[%sm┌─ %s\033[0m  \033[1;%sm⏸ %s\033[0m\n' "$color" "$face" "$color" "$name"
  printf '  \033[%sm│\033[0m\n' "$color"
  local line
  for line in "$@"; do
    printf '  \033[%sm│\033[0m      %s\n' "$color" "$line"
  done
  if [ -n "$deeplink" ]; then
    printf '  \033[%sm│\033[0m\n' "$color"
    printf '  \033[%sm│\033[0m      \033[%sm%s\033[0m\n' "$color" "$UI_C_CYAN" "$deeplink"
    open "$deeplink" 2>/dev/null &
  fi
  printf '  \033[%sm│\033[0m\n' "$color"
  printf '  \033[%sm└──\033[0m  type \033[1mdone\033[0m to verify · \033[1mskip\033[0m · \033[1mabort\033[0m\n' "$color"
  _gate_notify "$name"

  # 5. Owner input loop.
  local ans
  while :; do
    printf '\n  > '
    read -r ans
    case "$ans" in
      done)
        if eval "$verify" >/dev/null 2>&1; then
          ui_step ok "$name verified"
          return 0
        else
          ui_step fail "verify still failing — try again or skip"
        fi
        ;;
      skip)
        ui_step warn "$name skipped"
        return 1
        ;;
      abort)
        ui_step fail "$name aborted — re-run AI.md to resume"
        return 2
        ;;
      *)
        printf '  (type: done | skip | abort)\n'
        ;;
    esac
  done
}
