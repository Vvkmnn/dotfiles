#!/usr/bin/env bash
# ai/doctor.sh — standalone verification suite for dotfiles-ai.
#
# Runs every probe declared in AI.md's P18 section. Read-only — never
# mutates state. Designed for drift detection any time (post-bootstrap,
# weekly cron, post-`dotfiles pull`).
#
# Usage:
#   bash ~/.setup/ai/doctor.sh           # run all probes
#   bash ~/.setup/ai/doctor.sh tailscale  # filter to one
#
# Exit codes:
#   0   all probes passed
#   1   at least one warning (non-critical)
#   2   at least one failure (critical: hardware, network, secrets)

set -u

_doctor_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./ux.sh
. "$_doctor_dir/ux.sh"

# Detect profile (same logic as AI.md § Profile detection).
case "${USER:-$(whoami)}" in
  eve) DOCTOR_PROFILE=server ;;
  *)   DOCTOR_PROFILE=workstation ;;
esac
: "${DOTFILES_AI_PROFILE:=$DOCTOR_PROFILE}"

# Tallies.
_doc_ok=0; _doc_warn=0; _doc_fail=0

# probe <key> <severity:ok|warn|fail-on-fail> <cmd...>
# Runs cmd; on success prints ✓; on fail prints status per severity arg.
probe() {
  local key="${1:?}" sev="${2:?}"; shift 2
  if "$@" >/dev/null 2>&1; then
    printf '  \033[%sm✓\033[0m  %-18s\n' "$UI_C_GREEN" "$key"
    _doc_ok=$((_doc_ok + 1))
  else
    case "$sev" in
      warn) printf '  \033[%sm⚠\033[0m  %-18s\n' "$UI_C_ORANGE" "$key"; _doc_warn=$((_doc_warn + 1)) ;;
      fail) printf '  \033[%sm✗\033[0m  %-18s\n' "$UI_C_RED"    "$key"; _doc_fail=$((_doc_fail + 1)) ;;
    esac
  fi
}

filter="${1:-}"
run() {
  local k="$1"
  [ -z "$filter" ] || [ "$k" = "$filter" ] || return 0
  shift
  probe "$k" "$@"
}

ui_header "doctor" "drift check (profile: $DOTFILES_AI_PROFILE)"

# --- Core ---------------------------------------------------------------
run hw         fail test "$(uname -m)" = "arm64"
run ram        fail test "$(sysctl -n hw.memsize)" -ge 17179869184
run macos      fail bash -c 'printf "26.0\n%s\n" "$(sw_vers -productVersion)" | sort -CV'
run apple-id   warn bash -c 'defaults read MobileMeAccounts Accounts 2>/dev/null | grep -q AccountID'

# --- Network ------------------------------------------------------------
run network    fail bash -c 'route -n get default 2>/dev/null | awk "/interface:/ {print \$2}" | grep -qE "^en[0-9]+$"'
run tailscale  warn bash -c 'tailscale ip -4 2>/dev/null | grep -qE "^100\."'
run tail-ssh   warn tailscale status

# --- Services -----------------------------------------------------------
run tmux-svc   warn launchctl print "gui/$(id -u)/com.user.tmux"
run mcp-svc    warn launchctl print "gui/$(id -u)/com.claude.mcp-proxy"
run claude-cli warn command -v claude
run mosh-svr   warn command -v mosh-server
run tmux       warn command -v tmux
run op-cli     warn command -v op

# --- Dotfiles + crypto --------------------------------------------------
run git-crypt  fail bash -c '! head -1 ~/.claude.json 2>/dev/null | grep -q "GITCRYPT"'
run dot-remote warn bash -c '/usr/bin/git --git-dir=$HOME/.dotfiles remote get-url origin 2>/dev/null | grep -q "^git@github.com:"'

# --- Profile-specific ---------------------------------------------------
if [ "$DOTFILES_AI_PROFILE" = workstation ]; then
  run yabai     warn pgrep -x yabai
  run skhd      warn pgrep -x skhd
  run sketchy   warn pgrep -x sketchybar
fi

if [ "$DOTFILES_AI_PROFILE" = server ]; then
  run pmset-sleep fail bash -c 'pmset -g custom | grep -qE "^[[:space:]]*sleep[[:space:]]+0"'
  run pmset-womp  fail bash -c 'pmset -g custom | grep -qE "^[[:space:]]*womp[[:space:]]+1"'
  run pmset-restart fail bash -c 'pmset -g custom | grep -qE "^[[:space:]]*autorestart[[:space:]]+1"'
fi

# --- Continuity ---------------------------------------------------------
run handoff      warn pgrep -x useractivityd
run phone-app    warn test -d "/System/Applications/Phone.app"
run iphone-mirror warn test -d "/System/Applications/iPhone Mirroring.app"
run notes-md     warn bash -c '[ "$(defaults read com.apple.Notes EnableMarkdown 2>/dev/null)" = 1 ]'

# --- TCC ----------------------------------------------------------------
run tcc-fda      warn bash -c 'sqlite3 "$HOME/Library/Application Support/com.apple.TCC/TCC.db" "select 1 from access limit 1" >/dev/null 2>&1'

# --- Summary ------------------------------------------------------------
printf '\n  \033[%sm│\033[0m  %d ✓  %d ⚠  %d ✗\n\n' "$UI_C_DIM" "$_doc_ok" "$_doc_warn" "$_doc_fail"

if   [ "$_doc_fail" -gt 0 ]; then exit 2
elif [ "$_doc_warn" -gt 0 ]; then exit 1
else exit 0
fi
