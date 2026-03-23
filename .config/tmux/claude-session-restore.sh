#!/bin/bash
# tmux-resurrect restore wrapper: resumes exact claude session if known
# Falls back to claude --continue if no mapping found or resume fails
# Ctrl+C drops to shell instead of closing pane
# Called by @resurrect-processes config

trap 'trap "" INT; exec "$SHELL" -l' INT

# save intended CWD + recover if stale (e.g., SSD disconnected)
_intended_cwd="$PWD"
[[ -d . ]] || builtin cd "$PWD" 2>/dev/null || builtin cd ~ 2>/dev/null

_context() {
  local ctx
  if [[ "$PWD" != "$_intended_cwd" ]]; then
    ctx="${_intended_cwd/#$HOME/~} (not found)"
  else
    ctx="${PWD/#$HOME/~}"
  fi
  local branch
  branch=$(git branch --show-current 2>/dev/null)
  [ -n "$branch" ] && ctx="$ctx • $branch"
  echo "$ctx"
}

# E4 prompt: bracket, face, and command share one random Tokyo Night color
_prompt() {
  local faces=('[¬_¬]' '[^_^]' '[-_-]' '[o_o]' '[>_<]' '[T_T]' '[u_u]' '[n_n]' '[x_x]' '[~_~]' '[$_$]' '[+_+]' '[v_v]')
  local colors=('38;2;122;162;247' '38;2;187;154;247' '38;2;125;207;255' '38;2;158;206;106' '38;2;224;175;104' '38;2;247;118;142')
  local face="${faces[$((RANDOM % ${#faces[@]}))]}"
  local color="${colors[$((RANDOM % ${#colors[@]}))]}"
  echo ""
  local ctx
  ctx=$(_context)
  echo -e "  \033[${color}m┌─ ${face}\033[0m  \033[1;${color}m$*\033[0m"
  echo -e "  \033[${color}m│\033[0m  \033[${color}m${ctx}\033[0m"
  echo -e "  \033[${color}m└─\033[0m Press Enter to start, Ctrl+C for shell"
  echo ""
}

# Look up session ID from hook-generated mapping file
TMUX_SESSION=$(/opt/homebrew/bin/tmux display-message -p '#{session_name}' 2>/dev/null)
TMUX_WINDOW=$(/opt/homebrew/bin/tmux display-message -p '#{window_index}' 2>/dev/null)

MAPFILE="$HOME/.config/tmux/claude_sessions"

# Prune mapping file: keep only last entry per unique key (atomic dedup for append-only file)
if [ -f "$MAPFILE" ]; then
    awk '{ idx = match($0, / [^ ]+$/); if (idx > 0) { key = substr($0, 1, idx - 1); lines[key] = $0 } } END { for (k in lines) print lines[k] }' "$MAPFILE" > "$MAPFILE.tmp" \
        && mv "$MAPFILE.tmp" "$MAPFILE"
fi

# Path-aware lookup: match session:window:path exactly (trailing space prevents /foo matching /foobar)
SESSION_ID=$(awk -v key="${TMUX_SESSION}:${TMUX_WINDOW}:${PWD} " 'index($0, key) == 1 { print $NF }' "$MAPFILE" 2>/dev/null | tail -1)

# Fallback: path-agnostic for entries written before path-aware migration
if [ -z "$SESSION_ID" ]; then
    SESSION_ID=$(awk -v prefix="${TMUX_SESSION}:${TMUX_WINDOW}:" 'index($0, prefix) == 1 { print $NF }' "$MAPFILE" 2>/dev/null | tail -1)
fi

# Validate session is resumable: file must exist AND contain actual conversation
# (stale sessions may have only file-history-snapshot metadata, 0 messages)
if [ -n "$SESSION_ID" ]; then
    _project_dir="$HOME/.claude/projects/$(echo "$PWD" | sed 's|/|-|g; s|\.||g')"
    _session_file="$_project_dir/${SESSION_ID}.jsonl"
    if [ ! -f "$_session_file" ] || ! grep -q '"type":"user"' "$_session_file" 2>/dev/null; then
        SESSION_ID=""
    fi
fi

/opt/homebrew/bin/tmux rename-window "claude" 2>/dev/null

if [ -n "$SESSION_ID" ]; then
    _prompt "claude --resume $SESSION_ID"
else
    _prompt "claude --continue"
fi
read -r

# re-try intended CWD (SSD may have reconnected while waiting at prompt)
[[ -d "$_intended_cwd" ]] && cd "$_intended_cwd" 2>/dev/null

/opt/homebrew/bin/tmux set-window-option automatic-rename on 2>/dev/null

if [ -n "$SESSION_ID" ]; then
    # Try exact resume first; fall back to --continue if session expired/invalid
    claude --resume "$SESSION_ID" 2>/dev/null || exec claude --continue
else
    exec claude --continue
fi
