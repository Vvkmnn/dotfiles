#!/bin/bash

# Move-window chooser - search all windows across all sessions
# Select a window; the current window will be inserted right after it.

CURRENT_SESSION=$(tmux display-message -p '#S')
CURRENT_WINDOW=$(tmux display-message -p '#I')
CURRENT_WINDOW_ID=$(tmux display-message -p '#{window_id}')
LAST_TARGET_KEY=$(tmux show-options -gqv @smart_move_last_target)
LAST_TARGET_SESSION=""
LAST_TARGET_INDEX=""

if [ -n "$LAST_TARGET_KEY" ]; then
	LAST_TARGET_SESSION=${LAST_TARGET_KEY%%:*}
	LAST_TARGET_INDEX=${LAST_TARGET_KEY##*:}
fi

build_window_list() {
	local session_list session windows count i total branch star idx name wid cmd

	if [ -n "$LAST_TARGET_SESSION" ]; then
		session_list=$(
			printf '%s\n' "$LAST_TARGET_SESSION"
			tmux list-sessions -F '#{session_name}' | awk -v s="$LAST_TARGET_SESSION" '$0!=s'
		)
	else
		session_list=$(tmux list-sessions -F '#{session_name}')
	fi

	while IFS= read -r session; do
		[ -z "$session" ] && continue

		windows=$(tmux list-windows -t "$session" -F '#{window_index}	#{window_name}	#{window_id}	#{pane_current_command}')
		count=$(printf '%s\n' "$windows" | awk 'NF{c++} END{print c+0}')
		printf "Session %s (%s)\t%s\t\t\t\t\n" "$session" "$count" "$session"

		if [ "$session" = "$LAST_TARGET_SESSION" ] && [ -n "$LAST_TARGET_INDEX" ]; then
			last_line=$(printf '%s\n' "$windows" | awk -F'\t' -v idx="$LAST_TARGET_INDEX" '$1==idx {print; exit}')
			if [ -n "$last_line" ]; then
				windows=$(printf '%s\n' "$windows" | awk -F'\t' -v idx="$LAST_TARGET_INDEX" '$1!=idx')
				windows=$(printf '%s\n%s\n' "$last_line" "$windows")
			fi
		fi

		i=0
		total=$(printf '%s\n' "$windows" | awk 'NF{c++} END{print c+0}')
		while IFS=$'\t' read -r idx name wid cmd; do
			[ -z "$idx" ] && continue
			i=$((i + 1))
			branch="├─"
			[ "$i" -eq "$total" ] && branch="└─"
			star=""
			if [ -n "$LAST_TARGET_SESSION" ] && [ -n "$LAST_TARGET_INDEX" ] && [ "$session" = "$LAST_TARGET_SESSION" ] && [ "$idx" = "$LAST_TARGET_INDEX" ]; then
				star="★ "
			fi
			if [ -n "$cmd" ]; then
				printf "│  %s %s%s: %s · %s\t%s\t%s\t%s\t%s\t%s\n" "$branch" "$star" "$idx" "$name" "$cmd" "$session" "$name" "$idx" "$wid" "$cmd"
			else
				printf "│  %s %s%s: %s\t%s\t%s\t%s\t%s\t\n" "$branch" "$star" "$idx" "$name" "$session" "$name" "$idx" "$wid"
			fi
		done <<<"$windows"
	done <<<"$session_list"

	printf "Session +\tnew\t\t\t\t\n"
}

selected=$(build_window_list |
	fzf --reverse \
		--cycle \
		--no-info \
		--no-scrollbar \
		--header='Move current window after (type to filter):' \
		--preview='~/.config/tmux/preview_session.sh {2} {4}' \
		--preview-window='right:70%:noborder' \
		--color='hl:#50fa7b,hl+:#50fa7b' \
		--algo=v2 \
		--scheme=path \
		--ansi \
		--delimiter=$'\t' \
		--with-nth=1 \
		--nth=1,2,3,6 \
		--no-sort)

[ -z "$selected" ] && exit 0

TARGET_SESSION=$(printf '%s' "$selected" | awk -F'\t' '{print $2}')
TARGET_INDEX=$(printf '%s' "$selected" | awk -F'\t' '{print $4}')
TARGET_ID=$(printf '%s' "$selected" | awk -F'\t' '{print $5}')

# Debug logging
{
	echo "=== MOVE DEBUG ==="
	echo "CURRENT: ${CURRENT_SESSION}:${CURRENT_WINDOW} (ID: ${CURRENT_WINDOW_ID})"
	echo "SELECTED LINE: $selected"
	echo "TARGET_SESSION: $TARGET_SESSION"
	echo "TARGET_INDEX: $TARGET_INDEX"
	echo "TARGET_ID: $TARGET_ID"
	echo "================="
} >>/tmp/move_debug.log

[ -z "$TARGET_SESSION" ] && exit 0

# Check for new session creation
if [ "$TARGET_SESSION" = "new" ]; then
	# Create new session with tmux's default naming (next available number)
	new_name=$(tmux new-session -d -P -F '#{session_name}')
	tmux move-window -s "${CURRENT_SESSION}:${CURRENT_WINDOW}" -t "${new_name}:"
	tmux switch-client -t "$new_name"
	tmux select-window -t "$CURRENT_WINDOW_ID"
	exit 0
fi

# Check if session or window was selected
if [ -z "$TARGET_INDEX" ]; then
	# Session selected - append to end of session
	target_session="$TARGET_SESSION"
	last_window=$(tmux list-windows -t "$TARGET_SESSION" -F '#{window_index}' 2>/dev/null | tail -1)
	if [ -n "$last_window" ]; then
		tmux move-window -s "${CURRENT_SESSION}:${CURRENT_WINDOW}" -a -t "${TARGET_SESSION}:${last_window}"
	else
		tmux move-window -s "${CURRENT_SESSION}:${CURRENT_WINDOW}" -t "${TARGET_SESSION}:"
	fi
else
	# Window selected - move after it
	tmux move-window -s "${CURRENT_SESSION}:${CURRENT_WINDOW}" -a -t "${TARGET_SESSION}:${TARGET_INDEX}"
	target_session="$TARGET_SESSION"

	# Save last target for ★ marker
	tmux set-option -g @smart_move_last_target "${TARGET_SESSION}:${TARGET_INDEX}"
fi

# Switch to target session and select the moved window
tmux switch-client -t "$target_session"
tmux select-window -t "$CURRENT_WINDOW_ID"
