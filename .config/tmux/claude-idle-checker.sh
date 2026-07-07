#!/bin/bash
# claude-idle-checker.sh — background idle killer for Claude sessions
# Usage: claude-idle-checker.sh <parent_pid> <tmux_session> <tmux_window> <cwd> [threshold]
# Exit codes: 0 = claude exited normally, 42 = idle kill performed
#
# Only kills when ALL conditions are true:
#   1. The tmux window is NOT currently focused (user is elsewhere)
#   2. The session JSONL has not been modified for > threshold (no Claude activity)
# Default threshold: 27 minutes. Called from c()/cl()/cc() and claude-session-restore.sh.

PARENT_PID="${1:?parent pid required}"
TMUX_SESSION="${2:-}"
TMUX_WINDOW="${3:-}"
_intended_cwd="${4:-$PWD}"
threshold="${5:-${CLAUDE_IDLE_THRESHOLD:-1620}}"

MAPFILE="$HOME/.config/tmux/claude_sessions"
TMUX="/opt/homebrew/bin/tmux"

# Wait for Claude to start (up to 60s)
claude_pid=""
for _ in $(seq 1 12); do
    sleep 5
    claude_pid=$(pgrep -P "$PARENT_PID" -x 'claude' 2>/dev/null | head -1)
    [ -n "$claude_pid" ] && break
done
[ -z "$claude_pid" ] && exit 0

# Check interval: half the threshold (min 60s, max 300s)
interval=$(( threshold / 2 ))
(( interval < 60 )) && interval=60
(( interval > 300 )) && interval=300

while kill -0 "$claude_pid" 2>/dev/null; do
    sleep "$interval"
    kill -0 "$claude_pid" 2>/dev/null || break

    # --- Guard 1: never kill if the user is looking at this window ---
    if [ -n "$TMUX_SESSION" ] && [ -n "$TMUX_WINDOW" ]; then
        active_window=$("$TMUX" display-message -t "$TMUX_SESSION" -p '#{window_index}' 2>/dev/null)
        if [ "$active_window" = "$TMUX_WINDOW" ]; then
            continue
        fi
    fi

    # --- Guard 2: find the session JSONL ---
    sid=""
    if [ -n "$TMUX_SESSION" ] && [ -n "$TMUX_WINDOW" ]; then
        sid=$(awk -v key="${TMUX_SESSION}:${TMUX_WINDOW}:${_intended_cwd} " \
            'index($0, key) == 1 { print $NF }' "$MAPFILE" 2>/dev/null | tail -1)
        [ -z "$sid" ] && sid=$(awk -v prefix="${TMUX_SESSION}:${TMUX_WINDOW}:" \
            'index($0, prefix) == 1 { print $NF }' "$MAPFILE" 2>/dev/null | tail -1)
    fi

    resolved_cwd=$(cd "$_intended_cwd" 2>/dev/null && pwd -P || echo "$_intended_cwd")
    project_dir="$HOME/.claude/projects/$(echo "$resolved_cwd" | sed 's|/|-|g; s|\.||g')"

    if [ -z "$sid" ] && [ -d "$project_dir" ]; then
        _latest=$(ls -t "$project_dir"/*.jsonl 2>/dev/null | head -1)
        if [ -n "$_latest" ]; then
            sid=$(basename "$_latest" .jsonl)
        fi
    fi
    [ -z "$sid" ] && continue

    jsonl="$project_dir/${sid}.jsonl"
    [ -f "$jsonl" ] || continue

    # --- Guard 3: if JSONL was modified recently, session is active ---
    # This is the ONLY activity check. JSONL is written for ALL events:
    # user prompts, assistant responses, tool use, subagent results, etc.
    # If nothing written for > threshold, session is truly idle.
    file_mtime=$(stat -f %m "$jsonl" 2>/dev/null) || continue
    now=$(date +%s)
    if (( now - file_mtime < threshold )); then
        continue
    fi

    # All guards passed: window unfocused, no JSONL activity for > threshold
    kill "$claude_pid" 2>/dev/null
    exit 42
done

exit 0
