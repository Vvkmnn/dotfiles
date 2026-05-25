#!/usr/bin/env bash
# ai/ux.sh — visual primitives for the dotfiles-ai bootstrap.
#
# Tokyo Night palette + face roster + box drawing. Sourced by the skill
# orchestrator and by ai/gate.sh / ai/doctor.sh which build on it.
#
# Palette aligned with ~/.config/tmux/claude-session-restore.sh:67-71.
#
# Usage:
#   . ~/.setup/ai/ux.sh
#   ui_header "dotfiles-ai" "Bootstrap"
#   ui_phase_start P4 "Clone dotfiles bare repo"
#   ui_step ok   "branch v-macos-mini forked"
#   ui_step warn "1 conflict moved to ~/.backup/"
#   ui_step fail "checkout failed: $err"
#   ui_phase_end ok
#   ui_celebration  # accepts stats as env vars; see below

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

_ui_face()  { echo "${UI_FACES[$((RANDOM % ${#UI_FACES[@]}))]}"; }
_ui_color() { echo "${UI_COLORS[$((RANDOM % ${#UI_COLORS[@]}))]}"; }

# ui_header <title> [subtitle]
ui_header() {
  local title="${1:-dotfiles-ai}" sub="${2:-}" face color
  face=$(_ui_face); color=$(_ui_color)
  printf '\n  \033[%sm┌─ %s\033[0m  \033[1;%sm%s\033[0m\n' "$color" "$face" "$color" "$title"
  printf '  \033[%sm│\033[0m\n' "$color"
  [ -n "$sub" ] && printf '  \033[%sm│\033[0m      \033[%sm%s\033[0m\n' "$color" "$UI_C_DIM" "$sub"
  printf '  \033[%sm│\033[0m\n' "$color"
}

# ui_phase_start <id> <title> [subtitle]
ui_phase_start() {
  local id="${1:?}" title="${2:?}" sub="${3:-}" face color
  face=$(_ui_face); color=$(_ui_color)
  printf '\n  \033[%sm┌─ %s\033[0m  \033[1;%sm%s\033[0m  \033[%sm· %s\033[0m\n' \
    "$color" "$face" "$color" "$id" "$UI_C_DIM" "$title"
  [ -n "$sub" ] && printf '  \033[%sm│\033[0m      \033[%sm%s\033[0m\n' "$color" "$UI_C_DIM" "$sub"
}

# ui_step <ok|warn|fail|info> <text>
ui_step() {
  local kind="${1:?}" text="${2:?}"
  case "$kind" in
    ok)   printf '  \033[%sm│\033[0m  \033[%sm✓\033[0m  %s\n' "$UI_C_DIM" "$UI_C_GREEN" "$text" ;;
    warn) printf '  \033[%sm│\033[0m  \033[%sm⚠\033[0m  \033[%sm%s\033[0m\n' "$UI_C_DIM" "$UI_C_ORANGE" "$UI_C_ORANGE" "$text" ;;
    fail) printf '  \033[%sm│\033[0m  \033[%sm✗\033[0m  \033[%sm%s\033[0m\n' "$UI_C_DIM" "$UI_C_RED" "$UI_C_RED" "$text" ;;
    info) printf '  \033[%sm│\033[0m  \033[%sm·\033[0m  \033[%sm%s\033[0m\n' "$UI_C_DIM" "$UI_C_DIM" "$UI_C_FG" "$text" ;;
  esac
}

# ui_phase_end <ok|partial|fail>
ui_phase_end() {
  case "${1:?}" in
    ok)      printf '  \033[%sm└──\033[0m  \033[%sm✓ done\033[0m\n' "$UI_C_GREEN" "$UI_C_GREEN" ;;
    partial) printf '  \033[%sm└──\033[0m  \033[%sm⚠ partial — warnings logged\033[0m\n' "$UI_C_ORANGE" "$UI_C_ORANGE" ;;
    fail)    printf '  \033[%sm└──\033[0m  \033[%sm✗ failed\033[0m\n' "$UI_C_RED" "$UI_C_RED" ;;
  esac
}

# ui_celebration — reads UX_STATS_* env vars; missing values render as ?
#   UX_STATS_AUTO, UX_STATS_MANUAL, UX_STATS_PKGS, UX_STATS_FILES, UX_STATS_DURATION
ui_celebration() {
  local color="$UI_C_GREEN" face='[$_$]'
  local profile="${DOTFILES_AI_PROFILE:-?}"
  local host tailnet
  host=$(scutil --get LocalHostName 2>/dev/null)
  tailnet=$(tailscale status --json 2>/dev/null | jq -r '.MagicDNSSuffix // "n/a"' 2>/dev/null || echo n/a)
  printf '\n  \033[%sm┌─ %s\033[0m  \033[1;%sm%s\033[0m\n' "$color" "$face" "$color" "This machine is your machine."
  printf '  \033[%sm│\033[0m\n' "$color"
  printf '  \033[%sm│\033[0m   profile     %s\n' "$color" "$profile"
  printf '  \033[%sm│\033[0m   hostname    %s\n' "$color" "$host"
  printf '  \033[%sm│\033[0m   tailnet     %s.%s\n' "$color" "$(echo "$host" | tr A-Z a-z)" "$tailnet"
  printf '  \033[%sm│\033[0m\n' "$color"
  printf '  \033[%sm│\033[0m      ╭──────────────────────────────╮\n' "$color"
  printf '  \033[%sm│\033[0m      │  %4s auto phases        ✓   │\n' "$color" "${UX_STATS_AUTO:-?}"
  printf '  \033[%sm│\033[0m      │  %4s manual gates       ✓   │\n' "$color" "${UX_STATS_MANUAL:-?}"
  printf '  \033[%sm│\033[0m      │  %4s packages           ✓   │\n' "$color" "${UX_STATS_PKGS:-?}"
  printf '  \033[%sm│\033[0m      │  %-18s          │\n' "$color" "${UX_STATS_DURATION:-? min ? sec}"
  printf '  \033[%sm│\033[0m      ╰──────────────────────────────╯\n' "$color"
  printf '  \033[%sm│\033[0m\n' "$color"
  printf '  \033[%sm│\033[0m   Try now:  ssh %s → tmux attach -t claude\n' "$color" "$(echo "$host" | tr A-Z a-z)"
  printf '  \033[%sm│\033[0m            bash ~/.setup/ai/doctor.sh → re-verify any time\n' "$color"
  printf '  \033[%sm│\033[0m\n' "$color"
  printf '  \033[%sm└──\033[0m   \033[1;%smWelcome home.\033[0m\n\n' "$color" "$color"
}

# ui_die <message> [exit_code]
ui_die() {
  printf '\n  \033[%sm✗ FATAL\033[0m  %s\n\n' "$UI_C_RED" "${1:-unspecified error}" >&2
  exit "${2:-1}"
}
