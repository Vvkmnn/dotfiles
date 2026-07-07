#!/opt/homebrew/bin/bash
# clh.sh — fzf picker for Claude Code sessions
# Lists all sessions sorted by recency, previews conversations, resumes or jumps to active
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MAPFILE="$HOME/.config/tmux/claude_sessions"

# Format index TSV into display columns (awk is ~50x faster than bash loop for 500+ lines)
format_lines() {
  awk -F'\t' -v now="$(date +%s)" -v home="$HOME" '
  {
    uuid=$1; mtime=$2; cwd=$3; slug=$4; branch=$5; prompt=$6
    if (uuid == "") next
    age = now - mtime
    if      (age < 60)     rel = "now"
    else if (age < 3600)   rel = int(age/60) "m"
    else if (age < 86400)  rel = int(age/3600) "h"
    else                   rel = int(age/86400) "d"
    # Shorten home prefix and long paths
    sub("^" home, "~", cwd)
    # Clean prompt: strip XML tags and caveat boilerplate
    gsub(/<[^>]*>/, "", prompt)
    if (prompt ~ /^Caveat:/) prompt = "-"
    sub(/^\\n/, "", prompt)
    if (prompt == "" || prompt == "-") prompt = "-"
    if (slug == "") slug = "-"
    if (branch == "" || branch == "-" || branch == "HEAD") branch = ""
    else branch = " " branch
    # Truncate long paths: keep last folder name, prefix with ..
    if (length(cwd) > 22) {
      n = split(cwd, parts, "/")
      cwd = "../" parts[n]
      if (length(cwd) > 22) cwd = substr(cwd, 1, 20) ".."
    }
    # Truncate long slugs: keep prefix
    if (length(slug) > 20) slug = substr(slug, 1, 18) ".."
    # Truncate prompt so total visible line fits without hscroll
    if (length(prompt) > 50) prompt = substr(prompt, 1, 47) "..."
    # Tab-separate UUID from visible content so fzf --with-nth hides UUID cleanly
    printf "%s\t%4s  %-22s  %-20s%-7s  %s\n", uuid, rel, cwd, slug, branch, prompt
  }'
}

# List-only mode for fzf reload
if [[ "${1:-}" == "--list" ]]; then
  "$SCRIPT_DIR/clh-index.sh" | format_lines
  exit 0
fi

# Always plain fzf — tmux popup is provided by the display-popup binding (prefix+g)
# Shell command `clh` runs inline in the terminal
fzf_cmd=(fzf)

# Run picker — pipe directly, no intermediate variable
selection=$("$SCRIPT_DIR/clh-index.sh" | format_lines | "${fzf_cmd[@]}" \
  --ansi \
  --layout reverse \
  --highlight-line \
  --border-label '  Claude Sessions ' \
  --border-label-pos 3 \
  --header '  enter: resume/jump · ctrl-f: fork · ctrl-r: rebuild cache' \
  --header-border bottom \
  --prompt '  ' \
  --pointer '▶' \
  --info inline-right \
  --delimiter $'\t' \
  --with-nth 2 \
  --hscroll-off 9999 \
  --preview "$SCRIPT_DIR/clh-preview.sh {1}" \
  --preview-window 'right:55%:wrap' \
  --preview-border rounded \
  --bind "ctrl-r:reload(rm -f $HOME/.cache/clh-sessions.tsv && $SCRIPT_DIR/clh.sh --list)+clear-query" \
  --bind 'ctrl-f:become(echo fork:{1})' \
  --color 'bg+:#44475a,fg+:#f8f8f2' \
  --color 'hl:#50fa7b,hl+:#50fa7b:bold' \
  --color 'border:#6272a4,label:#50fa7b' \
  --color 'header:#6272a4,header-border:#44475a' \
  --color 'prompt:#50fa7b,pointer:#ff79c6' \
  --color 'info:#6272a4,spinner:#ffb86c' \
  --color 'preview-border:#44475a' \
) || exit 0

# Parse selection — UUID is tab-delimited field 1
uuid=$(echo "$selection" | cut -f1)
[ -z "$uuid" ] && exit 0

# Handle fork request
if [[ "$uuid" == fork:* ]]; then
  uuid="${uuid#fork:}"
  # Get cwd from cache
  cwd=$(grep "^${uuid}	" "$HOME/.cache/clh-sessions.tsv" | head -1 | cut -f3)
  cwd="${cwd:-$HOME}"
  if [ -n "${TMUX:-}" ]; then
    /opt/homebrew/bin/tmux new-window -c "$cwd" "claude --resume $uuid --fork-session"
  else
    cd "$cwd" && exec claude --resume "$uuid" --fork-session
  fi
  exit 0
fi

# Check if session is active in a tmux window via claude_sessions mapping
if [ -n "${TMUX:-}" ] && [ -f "$MAPFILE" ]; then
  while IFS= read -r match; do
    [ -z "$match" ] && continue
    target="${match%% *}"
    tmux_session="${target%%:*}"
    tmux_window=$(echo "$target" | cut -d: -f2)
    tmux_target="${tmux_session}:${tmux_window}"
    if /opt/homebrew/bin/tmux list-windows -t "$tmux_session" -F '#{session_name}:#{window_index}' 2>/dev/null | grep -qF "$tmux_target"; then
      /opt/homebrew/bin/tmux select-window -t "$tmux_target" 2>/dev/null \
        && /opt/homebrew/bin/tmux switch-client -t "$tmux_session" 2>/dev/null
      exit 0
    fi
  done < <(grep " ${uuid}$" "$MAPFILE" 2>/dev/null || true)
fi

# Not active — cd to project dir and resume in current terminal
cwd=$(grep "^${uuid}	" "$HOME/.cache/clh-sessions.tsv" | head -1 | cut -f3)
cwd="${cwd:-$HOME}"
cd "$cwd" && exec claude --resume "$uuid"
