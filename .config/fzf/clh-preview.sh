#!/opt/homebrew/bin/bash
# clh-preview.sh — render colored conversation preview for a Claude session
# Called by fzf --preview with session UUID as $1
set -euo pipefail

uuid="$1"
[ -z "$uuid" ] && exit 0

CACHE_FILE="$HOME/.cache/clh-sessions.tsv"
SESSIONS_DIR="$HOME/.claude/sessions"

# Find the JSONL file from cache (field 7) or by searching
jsonl=""
if [ -f "$CACHE_FILE" ]; then
  jsonl=$(grep "^${uuid}	" "$CACHE_FILE" | head -1 | cut -f7)
fi
if [ -z "$jsonl" ] || [ ! -f "$jsonl" ]; then
  jsonl=$(find "$HOME/.claude/projects" -maxdepth 2 -name "${uuid}.jsonl" -type f 2>/dev/null | head -1)
fi
[ -z "$jsonl" ] || [ ! -f "$jsonl" ] && exit 0

# Colors (matching window_finder Dracula scheme)
cyan=$'\033[36m'
white=$'\033[37m'
dim=$'\033[2m'
bold=$'\033[1m'
green=$'\033[32m'
yellow=$'\033[33m'
magenta=$'\033[35m'
reset=$'\033[0m'
border=$'\033[38;5;62m'

# Extract header metadata from cache
if [ -f "$CACHE_FILE" ]; then
  IFS=$'\t' read -r _ mtime cwd slug branch prompt < <(grep "^${uuid}	" "$CACHE_FILE" | head -1)
fi

# Format relative time from epoch
now=$(date +%s)
age=$(( now - ${mtime:-0} ))
if   (( age < 60 ));    then rel="just now"
elif (( age < 3600 ));  then rel="$(( age / 60 ))m ago"
elif (( age < 86400 )); then rel="$(( age / 3600 ))h ago"
elif (( age < 604800 ));then rel="$(( age / 86400 ))d ago"
else rel=$(date -r "${mtime:-0}" "+%b %d" 2>/dev/null || echo "?")
fi

# Check if session is active via claude_sessions mapping (maps tmux windows to JSONL UUIDs)
active=""
active_target=""
MAPFILE="$HOME/.config/tmux/claude_sessions"
if [ -f "$MAPFILE" ]; then
  # claude_sessions format: "session:window:cwd uuid" — check all matching lines
  while IFS= read -r match; do
    [ -z "$match" ] && continue
    target="${match%% *}"  # "session:window:cwd"
    tmux_session="${target%%:*}"
    tmux_window=$(echo "$target" | cut -d: -f2)
    tmux_target="${tmux_session}:${tmux_window}"
    # Verify window still exists in tmux
    if tmux list-windows -t "$tmux_session" -F '#{session_name}:#{window_index}' 2>/dev/null | grep -qF "$tmux_target"; then
      active="yes"
      active_target="$tmux_target"
      break
    fi
  done < <(grep " ${uuid}$" "$MAPFILE" 2>/dev/null || true)
fi

# Header
short_cwd="${cwd/#$HOME/~}"
printf '%s  %s %s%s%s' "$border" "$bold" "${slug:-$uuid}" "$reset" ""
if [ -n "$active" ]; then
  printf '  %s ACTIVE%s' "$green" "$reset"
fi
printf '\n'
printf '%s  %s%s%s  %s%s%s  %s%s%s\n' \
  "$border" "$cyan" "$short_cwd" "$reset" \
  "$dim" "$rel" "$reset" \
  "$magenta" "${branch:-}" "$reset"
printf '%s  %s\n' "$border" "$(printf '%.0s─' {1..60})"

# Render conversation: user and assistant text blocks
# Use jq to extract conversation turns, then format with color
lines=${FZF_PREVIEW_LINES:-40}
avail=$(( lines - 4 ))  # subtract header lines

jq -r '
  select(.type == "user" or .type == "assistant") |
  .type as $t |
  .message.content |
  (if type == "string" then [{type: "text", text: .}]
   elif type == "array" then .
   else [] end) |
  map(select(.type == "text" and .text != null and (.text | gsub("\\s";"") | length > 0))) |
  .[] |
  "\($t)\t\(.text | gsub("\n"; " ") | .[:400])"
' "$jsonl" 2>/dev/null | head -100 | while IFS=$'\t' read -r type text; do
  [ -z "$text" ] && continue
  if [ "$type" = "user" ]; then
    printf '\n%s  > %s%s\n' "$cyan" "$text" "$reset"
  else
    printf '%s  %s%s\n' "$dim" "$text" "$reset"
  fi
done | head -"$avail"
