#!/bin/bash
# claude-idle-checker.sh — pressure-adaptive idle killer for Claude sessions
# Usage: claude-idle-checker.sh <parent_pid> <tmux_session> <tmux_window> <cwd> [max_threshold]
# Exit codes: 0 = claude exited normally, 42 = idle reap performed
#
# Reaps a Claude session's process only when ALL are true:
#   1. The tmux window is NOT currently focused (you're looking elsewhere)
#   2. The session JSONL has had no writes for > threshold (no Claude activity)
#
# The threshold is DYNAMIC — it shrinks as the machine's swap fills, so idle
# sessions are reclaimed fast when memory is choking and left alone when the
# machine is healthy. Because every session's checker reads the same live
# pressure, the longest-idle session crosses the shrinking threshold first and
# dies first: a self-limiting, stalest-first eviction queue with no central
# coordinator. Each reap frees pressure, which relaxes the threshold for the
# survivors — so it stops reaping as soon as the machine is comfortable again.
# Whatever you are actively working in is the last thing to go.
#
# The conversation is always on disk: a reaped session is fully resumable via
# `claude --resume <id>` (logged), and the c()/cc() launcher shows a "press
# Enter to resume" prompt when you return to the pane. Reaping frees the running
# process, never the work.
#
# Called from c()/cl()/cc() and claude-session-restore.sh. Set max_threshold=0
# (or CLAUDE_IDLE_THRESHOLD=0) to pin a session as never-reap.

PARENT_PID="${1:?parent pid required}"
TMUX_SESSION="${2:-}"
TMUX_WINDOW="${3:-}"
_intended_cwd="${4:-$PWD}"
THRESHOLD_MAX="${5:-${CLAUDE_IDLE_THRESHOLD:-1800}}"

MAPFILE="$HOME/.config/tmux/claude_sessions"
LOG="$HOME/.cache/claude-idle-reaped.log"
TMUX="/opt/homebrew/bin/tmux"

# Pinned as never-reap for this session
[ "$THRESHOLD_MAX" = "0" ] && exit 0
mkdir -p "$(dirname "$LOG")" 2>/dev/null

# Live swap-used percent (0–100). One sysctl per check — cheap.
_swap_pct() {
    /usr/sbin/sysctl -n vm.swapusage 2>/dev/null | awk '{
        for (i=1;i<=NF;i++) { if($i=="total"){t=$(i+2)+0} if($i=="used"){u=$(i+2)+0} }
        if (t>0){ p=(u/t)*100; printf "%d", (p>100?100:p) } else print 0 }'
}

# Map live swap pressure → idle threshold, clamped to [180, THRESHOLD_MAX].
# Bands: healthy→max, 60%→15m, 80%→7m, 92%+→4m (acute reclaim). The 180s floor
# guarantees a brief step-away is never reaped, even under acute pressure.
_pressure_threshold() {
    local swap="$1" t
    if   (( swap >= 92 )); then t=240
    elif (( swap >= 80 )); then t=420
    elif (( swap >= 60 )); then t=900
    else t="$THRESHOLD_MAX"; fi
    (( t > THRESHOLD_MAX )) && t="$THRESHOLD_MAX"
    (( t < 180 )) && t=180
    echo "$t"
}

# Wait for Claude to start (up to 60s)
claude_pid=""
for _ in $(seq 1 12); do
    sleep 5
    claude_pid=$(pgrep -P "$PARENT_PID" -x 'claude' 2>/dev/null | head -1)
    [ -n "$claude_pid" ] && break
done
[ -z "$claude_pid" ] && exit 0

while kill -0 "$claude_pid" 2>/dev/null; do
    # Recompute threshold + poll interval from LIVE pressure every cycle, so a
    # filling swap tightens the deadline mid-session. Interval = half the current
    # threshold, clamped [30, 300] — reacts within ~2min under acute pressure.
    swap_pct=$(_swap_pct)
    threshold=$(_pressure_threshold "$swap_pct")
    interval=$(( threshold / 2 ))
    (( interval < 30 )) && interval=30
    (( interval > 300 )) && interval=300

    sleep "$interval"
    kill -0 "$claude_pid" 2>/dev/null || break

    # --- Guard 1: never reap if the user is looking at this window ---
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
    idle=$(( now - file_mtime ))
    if (( idle < threshold )); then
        continue
    fi

    # All guards passed: window unfocused, no JSONL activity for > threshold.
    # Log reason + resume id first (so a closed pane is still recoverable),
    # then reap.
    printf '%s reaped %s:%s %s — idle %dm, swap %d%%, resume: claude --resume %s\n' \
        "$(date '+%F %T')" "$TMUX_SESSION" "$TMUX_WINDOW" "$resolved_cwd" \
        "$(( idle / 60 ))" "$swap_pct" "$sid" >> "$LOG" 2>/dev/null
    kill "$claude_pid" 2>/dev/null
    exit 42
done

exit 0
