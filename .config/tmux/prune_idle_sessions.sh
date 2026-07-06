#!/bin/bash
# Idle-session sweep. Triggered by `session-created` hook in tmux.conf — fires each
# time a new window/session is opened (this workflow's natural cadence), so genuinely
# idle navigation spawns get cleaned up without ever needing manual pruning.
#
# Reaps ONLY sessions that are ALL of: detached, single-window, plain zsh, idle 7h+.
# Every predicate is a hard exclusion — if a session fails ANY check, it is never touched:
#   session_attached == 0        -> never kills a session you're currently in
#   session_windows  == 1        -> never kills multi-window work
#   pane_current_command == zsh  -> never kills claude/codex/vim/ssh/anything running a program
#   idle (session_activity) >= 7h -> real inactivity, not the unreliable history_size
#     (history_size is inflated by tmux-resurrect replaying a saved welcome-banner into
#     scrollback on every restore — proven live: a never-typed-in session showed history_size=53)
#
# Nothing is pruned silently — every kill is logged with session name, idle hours, and time.

IDLE_THRESHOLD_H=7
LOG="$HOME/.cache/tmux-pruned-sessions.log"
mkdir -p "$(dirname "$LOG")"
now=$(date +%s)

/opt/homebrew/bin/tmux list-sessions -F '#{session_name}|#{session_attached}|#{session_windows}|#{session_activity}|#{pane_current_command}' 2>/dev/null |
while IFS='|' read -r name attached windows activity cmd; do
	[ "$attached" = "1" ] && continue
	[ "$windows" != "1" ] && continue
	[ "$cmd" != "zsh" ] && continue
	idle_h=$(( (now - activity) / 3600 ))
	[ "$idle_h" -lt "$IDLE_THRESHOLD_H" ] && continue
	echo "$(date '+%F %T') pruned session '$name' (idle ${idle_h}h, detached, single-window, zsh)" >> "$LOG"
	/opt/homebrew/bin/tmux kill-session -t "$name"
done
