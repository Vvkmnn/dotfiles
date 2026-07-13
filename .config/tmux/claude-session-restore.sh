#!/bin/bash
# tmux-resurrect restore wrapper: resumes exact claude session if known
# Falls back to claude --continue if no mapping found or resume fails
# Ctrl+C replaces script with user's shell (no extra shell layer to exit from)
# Called by @resurrect-processes config

trap 'printf "\033[0m\n"; exec "$SHELL" -l 2>/dev/null || exit 0' INT

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

# Read session JSONL for context: title, idle time, recent prompts
_session_info() {
  local sid="$1"
  [ -z "$sid" ] && return
  local resolved_cwd
  resolved_cwd=$(cd "$_intended_cwd" 2>/dev/null && pwd -P || echo "$_intended_cwd")
  local project_dir="$HOME/.claude/projects/$(echo "$resolved_cwd" | sed 's|/|-|g; s|\.|-|g')"
  local jsonl="$project_dir/${sid}.jsonl"
  [ -f "$jsonl" ] || return
  python3 -c "
import json, time
title, prompts, last_epoch = None, [], None
for line in open('$jsonl'):
    try:
        d = json.loads(line)
        t = d.get('type')
        if t == 'custom-title':
            title = d.get('customTitle', '')
        elif t == 'user':
            msg = d.get('message', {})
            content = msg.get('content', msg) if isinstance(msg, dict) else msg
            text = content if isinstance(content, str) else next((c['text'] for c in content if isinstance(c, dict) and c.get('type') == 'text'), '') if isinstance(content, list) else ''
            if text: prompts.append(text[:60])
            ts = d.get('timestamp', '')
            if ts:
                from datetime import datetime
                try: last_epoch = datetime.fromisoformat(ts.replace('Z', '+00:00')).timestamp()
                except: pass
    except: pass
idle_str = ''
if last_epoch:
    s = int(time.time() - last_epoch)
    idle_str = f'{s}s' if s < 60 else f'{s//60}m' if s < 3600 else f'{s//3600}h' if s < 86400 else f'{s//86400}d'
if title: print(f'TITLE:{title}')
if idle_str: print(f'IDLE:{idle_str}')
for p in prompts[-3:]: print(f'PROMPT:{p}')
" 2>/dev/null
}

# E4 prompt: bracket, face, and command share one random Tokyo Night color
_prompt() {
  local faces=('[¬_¬]' '[^_^]' '[-_-]' '[o_o]' '[>_<]' '[T_T]' '[u_u]' '[n_n]' '[x_x]' '[~_~]' '[$_$]' '[+_+]' '[v_v]')
  local colors=('38;2;122;162;247' '38;2;187;154;247' '38;2;125;207;255' '38;2;158;206;106' '38;2;224;175;104' '38;2;247;118;142')
  local face="${faces[$((RANDOM % ${#faces[@]}))]}"
  local color="${colors[$((RANDOM % ${#colors[@]}))]}"
  local dim='38;2;86;95;137'
  echo ""

  local ctx
  ctx=$(_context)

  # Read session context
  local title="" idle=""
  local -a prompts=()
  if [ -n "$SESSION_ID" ]; then
    while IFS= read -r line; do
      case "$line" in
        TITLE:*) title="${line#TITLE:}" ;;
        IDLE:*)  idle="${line#IDLE:}" ;;
        PROMPT:*) prompts+=("${line#PROMPT:}") ;;
      esac
    done < <(_session_info "$SESSION_ID")
  fi

  [ -n "$idle" ] && ctx="$ctx • ${idle} idle"

  echo -e "  \033[${color}m┌─ ${face}\033[0m  \033[1;${color}m$*\033[0m"
  echo -e "  \033[${color}m│\033[0m"
  echo -e "  \033[${color}m│\033[0m      \033[${color}m${ctx}\033[0m"

  if [ -n "$title" ]; then
    echo -e "  \033[${color}m│\033[0m"
    echo -e "  \033[${color}m├──\033[0m \033[${color}m\033[0m \033[1m${title}\033[0m"
  fi

  if [ ${#prompts[@]} -gt 0 ]; then
    echo -e "  \033[${color}m│\033[0m"
    for p in "${prompts[@]}"; do
      echo -e "  \033[${color}m│\033[0m      \033[${dim}m❯ ${p}\033[0m"
    done
  fi

  echo -e "  \033[${color}m│\033[0m"
  echo -e "  \033[${color}m└──\033[0m Press Enter to resume, Ctrl+C for shell"
  echo ""
}

# Look up session ID from hook-generated mapping file
TMUX_SESSION=$(/opt/homebrew/bin/tmux display-message -p '#{session_name}' 2>/dev/null)
TMUX_WINDOW=$(/opt/homebrew/bin/tmux display-message -p '#{window_index}' 2>/dev/null)

MAPFILE="$HOME/.config/tmux/claude_sessions"

# Prune mapping file: keep only last entry per unique key, strip non-UUID entries
if [ -f "$MAPFILE" ]; then
    awk '{ id = $NF; if (id !~ /^[0-9a-f]{8}-[0-9a-f]{4}-/) next; idx = match($0, / [^ ]+$/); if (idx > 0) { key = substr($0, 1, idx - 1); lines[key] = $0 } } END { for (k in lines) print lines[k] }' "$MAPFILE" > "$MAPFILE.tmp" \
        && mv "$MAPFILE.tmp" "$MAPFILE"
fi

# Resolve project dir early (needed by all lookup strategies)
_resolved_cwd=$(cd "$PWD" 2>/dev/null && pwd -P || echo "$PWD")
_project_dir="$HOME/.claude/projects/$(echo "$_resolved_cwd" | sed 's|/|-|g; s|\.|-|g')"

# --- Session lookup: find the best session for this pane ---
# Strategy: try exact match first, then broaden, always validate against JSONL

# 1. Exact: session:window:path
SESSION_ID=$(awk -v key="${TMUX_SESSION}:${TMUX_WINDOW}:${PWD} " 'index($0, key) == 1 { print $NF }' "$MAPFILE" 2>/dev/null | tail -1)

# 2. Same window, any path (entries before path-aware migration)
if [ -z "$SESSION_ID" ]; then
    SESSION_ID=$(awk -v prefix="${TMUX_SESSION}:${TMUX_WINDOW}:" 'index($0, prefix) == 1 { print $NF }' "$MAPFILE" 2>/dev/null | tail -1)
fi

# 3. Same path, any window — picks most recently active JSONL
#    Handles session/window renumbering after restart (7:5 -> 14:4)
if [ -z "$SESSION_ID" ]; then
    SESSION_ID=$(
        awk -v path=":${PWD} " 'index($0, path) > 0 { print $NF }' "$MAPFILE" 2>/dev/null | \
        while read -r _sid; do
            _f="$_project_dir/${_sid}.jsonl"
            [ -f "$_f" ] && echo "$(stat -f %m "$_f" 2>/dev/null) $_sid"
        done | sort -rn | head -1 | awk '{ print $2 }'
    )
fi

# 4. No mapping match — find most recently modified JSONL in project dir
if [ -z "$SESSION_ID" ] && [ -d "$_project_dir" ]; then
    _latest=$(ls -t "$_project_dir"/*.jsonl 2>/dev/null | head -1)
    if [ -n "$_latest" ] && grep -q '"type":"user"' "$_latest" 2>/dev/null; then
        SESSION_ID=$(basename "$_latest" .jsonl)
    fi
fi

# Validate: must be UUID, file must exist, must contain conversation
if [ -n "$SESSION_ID" ]; then
    if ! echo "$SESSION_ID" | grep -qE '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'; then
        SESSION_ID=""
    else
        _session_file="$_project_dir/${SESSION_ID}.jsonl"
        if [ ! -f "$_session_file" ] || ! grep -q '"type":"user"' "$_session_file" 2>/dev/null; then
            SESSION_ID=""
        fi
    fi
fi

# Idle checker: delegates to shared script (also used by c()/cl()/cc() in .functions).
# Kills Claude if no user prompt for CLAUDE_IDLE_THRESHOLD seconds.
# Runs as a background coprocess; self-terminates when Claude exits.
_idle_checker() {
    local threshold="${CLAUDE_IDLE_THRESHOLD:-1800}"
    local checker="$HOME/.config/tmux/claude-idle-checker.sh"
    [ -x "$checker" ] || return 0
    "$checker" "$$" "$TMUX_SESSION" "$TMUX_WINDOW" "$_intended_cwd" "$threshold"
}

/opt/homebrew/bin/tmux rename-window "claude" 2>/dev/null

_rapid=0   # consecutive sub-2s claude exits → crash-loop guard

while true; do
    if [ -n "$SESSION_ID" ]; then
        _prompt "claude --resume $SESSION_ID"
    else
        _prompt "claude --continue"
    fi

    # Wait for the human before (re)starting claude. Read the keypress from the
    # TERMINAL, not inherited stdin — buffered keystrokes there drove a runaway
    # restart loop. Drain any queued input first so held/pasted Enters can't
    # auto-advance. Non-interactive or EOF (Ctrl+D) → drop to a login shell,
    # matching the INT trap above (never fall off the end and close the pane).
    if [[ ! -t 0 || ! -t 1 ]]; then
        printf '\033[0m\n'; exec "$SHELL" -l 2>/dev/null || exit 0
    fi
    _drain=0
    while (( _drain++ < 4096 )) && read -rsn1 -t 0.005 _ 2>/dev/null; do :; done
    read -r _ </dev/tty || { printf '\033[0m\n'; exec "$SHELL" -l 2>/dev/null || exit 0; }

    [[ -d "$_intended_cwd" ]] && cd "$_intended_cwd" 2>/dev/null
    /opt/homebrew/bin/tmux set-window-option automatic-rename on 2>/dev/null

    # Start idle checker in background
    _idle_checker &
    _checker_pid=$!

    # Pre-flight: only resume if the transcript is really there. A stale mapfile pointing at a
    # deleted/empty jsonl made `claude --resume` fail and then blind-fall to `claude --continue`,
    # which silently resumes whatever is NEWEST in this cwd -- the wrong session. Re-derive from the
    # newest real transcript before giving up (same fallback as the initial lookup, :153-158).
    if [ -n "$SESSION_ID" ]; then
        _sf="$_project_dir/${SESSION_ID}.jsonl"
        if [ ! -s "$_sf" ] || ! grep -q '"type":"user"' "$_sf" 2>/dev/null; then
            _latest=$(ls -t "$_project_dir"/*.jsonl 2>/dev/null | head -1)
            if [ -n "$_latest" ] && grep -q '"type":"user"' "$_latest" 2>/dev/null; then
                SESSION_ID=$(basename "$_latest" .jsonl)
                printf '  \033[38;2;224;175;104mmapping was stale -- resuming newest transcript (%s)\033[0m\n' "${SESSION_ID:0:8}"
            else
                SESSION_ID=""
                printf '  \033[38;2;224;175;104mno transcript for this pane -- starting fresh\033[0m\n'
            fi
        fi
    fi

    # Run Claude in foreground (preserves TUI). Surface resume errors (no 2>/dev/null) and do NOT
    # blind-fallback to --continue -- a failed resume is handled below via exit code + timing.
    _start=$SECONDS
    if [ -n "$SESSION_ID" ]; then
        claude --resume "$SESSION_ID"
    else
        claude --continue
    fi
    _rc=$?

    # Clean up checker
    kill "$_checker_pid" 2>/dev/null
    wait "$_checker_pid" 2>/dev/null

    # Crash-loop floor: claude dying in <2s repeatedly → drop to a shell so a broken
    # resume can't spin the pane (mirrors the __claude_run guard in ~/.functions).
    if (( SECONDS - _start < 2 )); then
        # A fast non-zero exit right after a resume is a resume FAILURE, not a normal session end.
        # Say so (instead of the old silent 2>/dev/null) so a bad/corrupt transcript is debuggable.
        if [ -n "$SESSION_ID" ] && (( _rc != 0 )); then
            printf '\033[0m  \033[38;2;247;118;142mresume of %s exited immediately (code %d)\033[0m\n' "${SESSION_ID:0:8}" "$_rc"
        fi
        (( ++_rapid >= 3 )) && { printf '\033[0m\n  claude keeps exiting immediately — dropping to shell\n'; exec "$SHELL" -l 2>/dev/null || exit 0; }
    else
        _rapid=0
    fi

    # Re-read session mapping for next restart (exact match, then path-only)
    SESSION_ID=$(awk -v key="${TMUX_SESSION}:${TMUX_WINDOW}:${_intended_cwd} " \
        'index($0, key) == 1 { print $NF }' "$MAPFILE" 2>/dev/null | tail -1)
    if [ -z "$SESSION_ID" ]; then
        SESSION_ID=$(awk -v path=":${_intended_cwd} " 'index($0, path) > 0 { print $NF }' "$MAPFILE" 2>/dev/null | tail -1)
    fi
    # Validate UUID format
    if [ -n "$SESSION_ID" ] && ! echo "$SESSION_ID" | grep -qE '^[0-9a-f]{8}-[0-9a-f]{4}-'; then
        SESSION_ID=""
    fi
done
