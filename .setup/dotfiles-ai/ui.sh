#!/usr/bin/env bash
# dotfiles-ai/ui.sh — visual primitives for the bootstrap.
#
# Tokyo Night palette + face-glyph roster + box drawing.
# Sourced by both the skill orchestrator and the runbook's bash blocks.
# Source: ~/.config/tmux/claude-session-restore.sh:67-71 (same palette).
#
# Usage:
#   . ~/.setup/dotfiles-ai/ui.sh
#   ui_header "dotfiles-ai" "v0.1"
#   ui_phase_start "P4" "Clone dotfiles bare repo"
#   ui_step ok   "branch v-macos-mini forked from v-macos-macbook"
#   ui_step warn "1 conflict: ~/.zshrc → ~/.backup/"
#   ui_step fail "checkout failed: $err"
#   ui_gate_pause "TCC checklist" "x-apple.systempreferences:com.apple..."
#   ui_celebration  # reads stats from ~/.setup/dotfiles-ai/state/last-run.json
#
# Set DOTFILES_AI_SOUND=0 to silence the milestone sounds (Glass/Pop/Hero).

# --- Palette (Tokyo Night, 24-bit ANSI) -----------------------------------
UI_C_BLUE='38;2;122;162;247'
UI_C_PURPLE='38;2;187;154;247'
UI_C_CYAN='38;2;125;207;255'
UI_C_GREEN='38;2;158;206;106'
UI_C_ORANGE='38;2;224;175;104'
UI_C_RED='38;2;247;118;142'
UI_C_DIM='38;2;86;95;137'
UI_C_FG='38;2;192;202;245'

UI_COLORS=("$UI_C_BLUE" "$UI_C_PURPLE" "$UI_C_CYAN" "$UI_C_GREEN" "$UI_C_ORANGE" "$UI_C_RED")

# --- Face roster ----------------------------------------------------------
UI_FACES=(
  '[¬_¬]' '[^_^]' '[-_-]' '[o_o]' '[>_<]' '[T_T]'
  '[u_u]' '[n_n]' '[x_x]' '[~_~]' '[$_$]' '[+_+]' '[v_v]'
)

# --- Internals ------------------------------------------------------------
_ui_face() { echo "${UI_FACES[$((RANDOM % ${#UI_FACES[@]}))]}"; }
_ui_color() { echo "${UI_COLORS[$((RANDOM % ${#UI_COLORS[@]}))]}"; }

_ui_sound() {
  [ "${DOTFILES_AI_SOUND:-1}" = "0" ] && return 0
  local sound="${1:-Glass}"
  afplay "/System/Library/Sounds/${sound}.aiff" 2>/dev/null &
}

_ui_box() {
  local color="$1"; shift
  local line
  for line in "$@"; do
    printf '\033[%sm│\033[0m %s\n' "$color" "$line"
  done
}

# --- Public API -----------------------------------------------------------

# ui_header <title> <subtitle>
ui_header() {
  local title="${1:-dotfiles-ai}" sub="${2:-}"
  local face=$(_ui_face) color=$(_ui_color)
  printf '\n'
  printf '  \033[%sm┌─ %s\033[0m  \033[1;%sm%s\033[0m\n' "$color" "$face" "$color" "$title"
  printf '  \033[%sm│\033[0m\n' "$color"
  [ -n "$sub" ] && printf '  \033[%sm│\033[0m      \033[%sm%s\033[0m\n' "$color" "$UI_C_DIM" "$sub"
  printf '  \033[%sm│\033[0m\n' "$color"
}

# ui_phase_start <id> <title> [subtitle]
ui_phase_start() {
  local id="${1:?}" title="${2:?}" sub="${3:-}"
  local face=$(_ui_face) color=$(_ui_color)
  printf '\n  \033[%sm┌─ %s\033[0m  \033[1;%sm%s\033[0m  \033[%sm· %s\033[0m\n' \
    "$color" "$face" "$color" "$id" "$UI_C_DIM" "$title"
  [ -n "$sub" ] && printf '  \033[%sm│\033[0m      \033[%sm%s\033[0m\n' "$color" "$UI_C_DIM" "$sub"
  _ui_sound Glass
}

# ui_step <ok|warn|fail|info> <text>
ui_step() {
  local kind="${1:?}" text="${2:?}"
  case "$kind" in
    ok)   printf '  \033[%sm│\033[0m  \033[%sm✓\033[0m  %s\n' "$UI_C_DIM" "$UI_C_GREEN" "$text" ;;
    warn) printf '  \033[%sm│\033[0m  \033[%sm⚠\033[0m  \033[%sm%s\033[0m\n' "$UI_C_DIM" "$UI_C_ORANGE" "$UI_C_ORANGE" "$text" ;;
    fail) printf '  \033[%sm│\033[0m  \033[%sm✗\033[0m  \033[%sm%s\033[0m\n' "$UI_C_DIM" "$UI_C_RED" "$UI_C_RED" "$text" ;;
    info) printf '  \033[%sm│\033[0m  \033[%sm·\033[0m  \033[%sm%s\033[0m\n' "$UI_C_DIM" "$UI_C_DIM" "$UI_C_FG" "$text" ;;
    *)    printf '  \033[%sm│\033[0m     %s\n' "$UI_C_DIM" "$text" ;;
  esac
}

# ui_phase_end <ok|partial|fail>
ui_phase_end() {
  local kind="${1:?}"
  case "$kind" in
    ok)      printf '  \033[%sm└──\033[0m  \033[%sm✓ done\033[0m\n' "$UI_C_GREEN" "$UI_C_GREEN" ;;
    partial) printf '  \033[%sm└──\033[0m  \033[%sm⚠ partial — warnings logged\033[0m\n' "$UI_C_ORANGE" "$UI_C_ORANGE" ;;
    fail)    printf '  \033[%sm└──\033[0m  \033[%sm✗ failed — see %s\033[0m\n' "$UI_C_RED" "$UI_C_RED" "$HOME/.setup/dotfiles-ai/state/warnings.log" ;;
  esac
}

# ui_gate_pause <title> <deeplink_url> [instruction_lines...]
ui_gate_pause() {
  local title="${1:?}" deeplink="${2:-}"; shift 2 || true
  local face=$(_ui_face) color="$UI_C_ORANGE"
  printf '\n  \033[%sm┌─ %s\033[0m  \033[1;%sm⏸ %s\033[0m\n' "$color" "$face" "$color" "$title"
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
  printf '  \033[%sm└──\033[0m  type \033[1mdone\033[0m to verify · \033[1mskip\033[0m to defer · \033[1mabort\033[0m to stop\n' "$color"
  _ui_sound Pop
  osascript -e "display notification \"$title\" with title \"dotfiles-ai\" sound name \"Glass\"" 2>/dev/null &
}

# ui_doctor_line <key> <ok|warn|fail> <detail>
ui_doctor_line() {
  local key="${1:?}" status="${2:?}" detail="${3:-}"
  local color marker
  case "$status" in
    ok)   color="$UI_C_GREEN";  marker='✓' ;;
    warn) color="$UI_C_ORANGE"; marker='⚠' ;;
    fail) color="$UI_C_RED";    marker='✗' ;;
    *)    color="$UI_C_DIM";    marker='?' ;;
  esac
  printf '  \033[%sm%s\033[0m  %-18s  \033[%sm%s\033[0m\n' \
    "$color" "$marker" "$key" "$UI_C_DIM" "$detail"
}

# ui_celebration — reads stats from ~/.setup/dotfiles-ai/state/last-run.json
ui_celebration() {
  local face='[$_$]' color="$UI_C_GREEN"
  local stats_file="$HOME/.setup/dotfiles-ai/state/last-run.json"
  local auto manual pkgs files duration
  if command -v jq >/dev/null && [ -f "$stats_file" ]; then
    auto=$(jq -r .auto_steps "$stats_file" 2>/dev/null)
    manual=$(jq -r .manual_gates "$stats_file" 2>/dev/null)
    pkgs=$(jq -r .packages "$stats_file" 2>/dev/null)
    files=$(jq -r .files_synced "$stats_file" 2>/dev/null)
    duration=$(jq -r .duration "$stats_file" 2>/dev/null)
  fi
  local profile="${DOTFILES_AI_PROFILE:-?}"
  local host=$(scutil --get LocalHostName 2>/dev/null)
  local tailnet=$(tailscale status --json 2>/dev/null | jq -r '.MagicDNSSuffix // "n/a"' 2>/dev/null)
  printf '\n'
  printf '  \033[%sm┌─ %s\033[0m  \033[1;%sm%s\033[0m\n' "$color" "$face" "$color" "This machine is your machine."
  printf '  \033[%sm│\033[0m\n' "$color"
  printf '  \033[%sm│\033[0m   profile     %s\n' "$color" "$profile"
  printf '  \033[%sm│\033[0m   hostname    %s\n' "$color" "$host"
  printf '  \033[%sm│\033[0m   tailnet     %s.%s\n' "$color" "$(echo "$host" | tr A-Z a-z)" "$tailnet"
  printf '  \033[%sm│\033[0m\n' "$color"
  printf '  \033[%sm│\033[0m      ╭──────────────────────────────╮\n' "$color"
  printf '  \033[%sm│\033[0m      │  %4s auto steps         ✓   │\n' "$color" "${auto:-?}"
  printf '  \033[%sm│\033[0m      │  %4s manual gates       ✓   │\n' "$color" "${manual:-?}"
  printf '  \033[%sm│\033[0m      │  %4s packages           ✓   │\n' "$color" "${pkgs:-?}"
  printf '  \033[%sm│\033[0m      │  %4s files synced       ✓   │\n' "$color" "${files:-?}"
  printf '  \033[%sm│\033[0m      │  %-18s          │\n' "$color" "${duration:-? min ? sec}"
  printf '  \033[%sm│\033[0m      ╰──────────────────────────────╯\n' "$color"
  printf '  \033[%sm│\033[0m\n' "$color"
  printf '  \033[%sm│\033[0m   Try now:\n' "$color"
  printf '  \033[%sm│\033[0m     ssh %s → tmux attach -t claude\n' "$color" "$(echo "$host" | tr A-Z a-z)"
  printf '  \033[%sm│\033[0m     /dotfiles-ai doctor → re-verify any time\n' "$color"
  printf '  \033[%sm│\033[0m\n' "$color"
  printf '  \033[%sm└──\033[0m   \033[1;%smWelcome home.\033[0m\n\n' "$color" "$color"
  _ui_sound Hero
}

# ui_die <message>
ui_die() {
  printf '\n  \033[%sm✗ FATAL\033[0m  %s\n\n' "$UI_C_RED" "${1:-unspecified error}" >&2
  exit 1
}
