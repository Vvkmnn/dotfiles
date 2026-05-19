#!/bin/bash
# All tmux helper functions in one script

# CRASH NOTES (2026-02-21):
# tmux SIGSEGV in job_get_event — null deref in fork path, ASI "crashed on child side of fork pre-exec"
# Crash report: ~/Library/Logs/DiagnosticReports/tmux-2026-02-21-115812.ips
#
# Root cause: #() in automatic-rename-format triggers job_* fork infrastructure on every
# status-interval tick. The same fork path is used by copy-pipe (tmux-yank) and run-shell.
# Known tmux issues:
#   - #4316: maintainer (nicm) advises against #() in automatic-rename-format
#   - #3206: SIGSEGV in run-shell fork path (same job_* system)
#   - #1755: related fork/job crash reports
#
# Fix: replaced #() with chained #{s|A|a|;s|B|b|;...} substitutions in tmux.conf.
# These are pure format evaluation — no fork, no exec, no job_* system, cannot crash.
#
# Also disabled tmux-yank (copy-pipe-and-cancel uses same fork path).
# Replaced with OSC 52 via set-clipboard on + Ghostty clipboard-write=allow.
smart_name() {
	local cmd="$1"
	local pane_tty="$2"

	if [[ -z "$cmd" || "$cmd" == "null" ]]; then
		echo "zsh"
		return
	fi

	# Normalize codex binary names like codex-aarch64-a.
	if [[ "$cmd" == codex-* ]]; then
		echo "codex"
		return
	fi

	# If cmd looks like a semver (claude sets process.title to version), find the real command
	if [[ "$cmd" =~ ^[0-9]+\.[0-9]+\.[0-9]+ && -n "$pane_tty" ]]; then
		local processes=$(ps -t "$pane_tty" -o comm= 2>/dev/null |
			grep -v '/' | grep -v '^-' | grep -v '^(' |
			grep -vE '^[0-9]+\.[0-9]+' |
			grep -vE '^(node|jq|bash|pgrep|grep|awk|sed|cat|head|tail)$')

		# Priority: always prefer "claude" over npm subprocesses
		if echo "$processes" | grep -qx "claude"; then
			echo "claude"
			return
		fi

		# Fallback: filter out npm wrapper commands, take first remaining
		local real_cmd=$(echo "$processes" | grep -v '^npm ' | head -1)
		[[ -n "$real_cmd" ]] && cmd="$real_cmd"
	fi

	echo "$cmd"
}

short_dir() {
	# Returns ":dirname" when path is valid, nothing when empty.
	# Caches result in tmux pane option @cached_dir so the dir persists
	# when pane_current_path goes NULL (e.g. external SSD disconnected).
	local name="${1##*/}" pane_id="$2"
	if [ -n "$name" ]; then
		[ -n "$pane_id" ] && tmux set-option -pq -t "$pane_id" @cached_dir "$name" 2>/dev/null
		echo ":$name"
	fi

	# local basename="${path##*/}"
	#
	# # Split by delimiters (-, _, .)
	# IFS='-_.' read -ra segments <<< "$basename"
	#
	# # Drop empty segments (from leading dots like .claude)
	# local clean_segments=()
	# for seg in "${segments[@]}"; do
	#     [[ -n "$seg" ]] && clean_segments+=("$seg")
	# done
	#
	# # Skip common prefixes
	# local skip_words=("claude" "codex" "awesome" "cc")
	# local filtered_segments=()
	# local skip_first=0
	#
	# # Check if first segment should be skipped
	# for skip_word in "${skip_words[@]}"; do
	#     if [[ "${clean_segments[0]}" == "$skip_word" ]]; then
	#         skip_first=1
	#         break
	#     fi
	# done
	#
	# # Build filtered list
	# for i in "${!clean_segments[@]}"; do
	#     if [[ $skip_first -eq 1 && $i -eq 0 ]]; then
	#         continue
	#     fi
	#     filtered_segments+=("${clean_segments[$i]}")
	# done
	#
	# # If all segments were filtered out, fall back to basename
	# if [[ ${#filtered_segments[@]} -eq 0 ]]; then
	#     echo "$basename"
	#     return
	# fi
	#
	# # Rejoin remaining segments (preserves full name after prefix strip)
	# local IFS='-'
	# echo "${filtered_segments[*]}"
}

window_list() {
	tmux list-windows -a \
		-F "#{session_name}:#{window_index}	#{window_name}	#{pane_current_command}	#{pane_current_path}" |
		/usr/bin/sed "s|$HOME|~|" |
		/usr/bin/awk -F'\t' '{printf "%-8s  %-12s  %-10s  %s\n", $1, $2, $3, $4}'
}

zoxide_list() {
	# Zoxide frecency dirs, deduplicated against paths already open in tmux windows
	local open_paths
	open_paths=$(tmux list-windows -a -F '#{pane_current_path}')
	zoxide query -l 2>/dev/null | while IFS= read -r dir; do
		if ! echo "$open_paths" | /usr/bin/grep -qxF "$dir"; then
			local short="${dir/#$HOME/~}"
			printf "%-8s  %-12s  %-10s  %s\n" "[new]" "---" "zoxide" "$short"
		fi
	done | head -15
}

window_grep() {
	local query="$1"
	[ -z "$query" ] && {
		window_list
		return
	}

	# Get raw data once, format once (single pipeline, no bash loop)
	local raw formatted
	raw=$(tmux list-windows -a \
		-F "#{session_name}:#{window_index}	#{window_name}	#{pane_current_command}	#{pane_current_path}")
	formatted=$(echo "$raw" | /usr/bin/sed "s|$HOME|~|" |
		/usr/bin/awk -F'\t' '{printf "%-8s  %-12s  %-10s  %s\n", $1, $2, $3, $4}')

	# Phase 1: metadata match — single grep over all lines (not per-window)
	local meta_hits skip_list=""
	meta_hits=$(/usr/bin/grep -i "$query" <<<"$formatted" 2>/dev/null) || true
	if [ -n "$meta_hits" ]; then
		printf '%s\n' "$meta_hits"
		skip_list=$'\n'$(/usr/bin/awk '{print $1}' <<<"$meta_hits")$'\n'
	fi

	# Phase 2: content search only for windows not matched above
	while IFS=$'\t' read -r win name cmd path; do
		if [ -n "$skip_list" ] && [ "${skip_list#*$'\n'${win}$'\n'}" != "$skip_list" ]; then
			continue
		fi
		if tmux capture-pane -t "$win" -p -J -S -500 2>/dev/null | /usr/bin/grep -qi "$query"; then
			local short="${path/#$HOME/~}"
			printf '%-8s  %-12s  %-10s  %s\n' "$win" "$name" "$cmd" "$short"
		fi
	done <<<"$raw"
}

window_finder() {
	local me target
	me="$HOME/.config/tmux/tmux.sh"
	target=$(
		window_list |
			fzf --layout reverse \
				--disabled \
				--highlight-line \
				--border-label '  Windows ' \
				--border-label-pos 3 \
				--header '  search all · C-f: fuzzy names · C-z: zoxide dirs' \
				--header-border bottom \
				--prompt '  ' \
				--pointer '▶' \
				--info inline-right \
				--preview 'q={q}; win=$(echo {1}); if [ -n "$q" ]; then tmux capture-pane -t "$win" -p -J -S -500 2>/dev/null | /usr/bin/grep --color=always -i -n -C2 "$q" | head -40; else tmux capture-pane -e -t "$win" -S -50 -p 2>/dev/null; fi' \
				--preview-window 'right:65%:wrap' \
				--preview-border rounded \
				--bind "change:reload:sleep 0.05; $me window_grep {q} || true" \
				--bind "ctrl-f:unbind(change)+enable-search+change-prompt(  )+change-header(  fuzzy names · C-g: search all · C-z: zoxide dirs)+reload($me window_list)+rebind(ctrl-g)+rebind(ctrl-z)" \
				--bind "ctrl-g:disable-search+change-prompt(  )+change-header(  search all · C-f: fuzzy names · C-z: zoxide dirs)+reload($me window_grep {q})+rebind(change)+unbind(ctrl-g)+rebind(ctrl-f)+rebind(ctrl-z)" \
				--bind "ctrl-z:disable-search+change-prompt(  )+change-header(  zoxide dirs · C-g: search all)+reload($me zoxide_list)+unbind(change)+unbind(ctrl-f)+unbind(ctrl-z)+rebind(ctrl-g)" \
				--color 'bg+:#44475a,fg+:#f8f8f2' \
				--color 'hl:#50fa7b,hl+:#50fa7b:bold' \
				--color 'border:#6272a4,label:#50fa7b' \
				--color 'header:#6272a4,header-border:#44475a' \
				--color 'prompt:#50fa7b,pointer:#ff79c6' \
				--color 'info:#6272a4,spinner:#ffb86c' \
				--color 'preview-border:#44475a'
	) || return 0

	local win_id dir
	win_id=$(echo "$target" | awk '{print $1}')
	if [ "$win_id" = "[new]" ]; then
		dir=$(echo "$target" | awk '{print $NF}')
		dir="${dir/#\~/$HOME}"
		tmux new-window -c "$dir"
	else
		tmux switch-client -t "$win_id"
	fi
}

spawn_vscode_window() {
	local cwd="$1"
	[[ -z "$cwd" ]] && cwd="$PWD"

	local config="$HOME/.config/tmux/tmux.conf"
	local -a cmd
	cmd=(tmux)

	if [[ -f "$config" ]]; then
		cmd+=(-f "$config")
	fi

	# Ensure escape-time stays >0 for VS Code terminals so OSC colour queries aren't echoed.
	tmux set-option -s escape-time 10 >/dev/null 2>&1 || true

	exec "${cmd[@]}" new-session -c "$cwd"
}

# Continuous auto-scroll (reading mode). Controlled by @auto_scroll pane option.
# Uses @auto_scroll_token to instantly supersede previous instances (no stop-wait).
# prefix+J/K/q/Escape/mouse set @auto_scroll=off to stop.
auto_scroll() {
	local direction="$1" # "up" or "down"
	local pane_id
	pane_id=$(tmux display-message -p '#{pane_id}')

	# Unique token for this instance — old loops self-terminate on token mismatch
	local token="$$"
	tmux set-option -pq -t "$pane_id" @auto_scroll "$direction" 2>/dev/null
	tmux set-option -pq -t "$pane_id" @auto_scroll_token "$token" 2>/dev/null

	# Enter copy-mode if not already
	tmux copy-mode -e -t "$pane_id" 2>/dev/null

	local cmd="scroll-$direction"
	while true; do
		# Kill condition 1: @auto_scroll changed (J/K/q/Escape set it to "off")
		local state
		state=$(tmux show-option -pqv -t "$pane_id" @auto_scroll 2>/dev/null)
		[ "$state" != "$direction" ] && break
		# Kill condition 2: superseded by a newer auto-scroll instance
		local cur_token
		cur_token=$(tmux show-option -pqv -t "$pane_id" @auto_scroll_token 2>/dev/null)
		[ "$cur_token" != "$token" ] && break
		# Kill condition 3: copy-mode exited + get scroll position (single tmux call)
		local check
		check=$(tmux display-message -t "$pane_id" -p '#{pane_in_mode}|#{scroll_position}' 2>/dev/null)
		[ "${check%%|*}" != "1" ] && break
		local pos_before="${check##*|}"
		# Kill condition 4: send-keys fails (pane closed, window switched, etc.)
		tmux send-keys -t "$pane_id" -X "$cmd" 2>/dev/null || break
		# Kill condition 5: hit boundary (top or bottom — position didn't change)
		local pos_after
		pos_after=$(tmux display-message -t "$pane_id" -p '#{scroll_position}' 2>/dev/null)
		[ "$pos_before" = "$pos_after" ] && break
		sleep 0.42
	done
	# Always clean up — no matter how we exited
	tmux set-option -pq -t "$pane_id" @auto_scroll off 2>/dev/null
}

# Open last Claude-edited file in nvim in a new tmux window (prefix+v).
# First press: creates window with nvim. Subsequent: switches file + jumps to window.
# SmartAutoReload in nvim handles live reload when Claude edits the same file.
# @claude_last_edit is set by PostToolUse hook on every Edit/Write.
claude_follow() {
	local pane_id
	pane_id=$(tmux display-message -p '#{pane_id}')
	local pane_num="${pane_id#%}"

	local last_file
	last_file=$(tmux show-option -pqv -t "$pane_id" @claude_last_edit 2>/dev/null)
	if [ -z "$last_file" ]; then
		tmux display-message "No file edited yet"
		return
	fi

	local line
	line=$(tmux show-option -pqv -t "$pane_id" @claude_last_edit_line 2>/dev/null)
	[ -z "$line" ] && line=1

	local sock="/tmp/nvim-follow-${pane_num}.sock"
	local nvim=/opt/homebrew/bin/nvim

	# If nvim follower already running, switch file + line and jump to its window
	if [ -S "$sock" ]; then
		local escaped="${last_file//\\/\\\\}"
		escaped="${escaped// /\\ }"
		escaped="${escaped//#/\\#}"
		escaped="${escaped//%/\\%}"
		$nvim --server "$sock" --remote-send "<Esc>:e +${line} ${escaped}<CR>zz" 2>/dev/null || true
		# Find the window containing the nvim process and switch to it
		local nvim_win
		nvim_win=$(tmux list-panes -aF '#{window_id} #{pane_pid}' 2>/dev/null | while read wid pid; do
			if ps -p "$pid" -o args= 2>/dev/null | grep -q "$sock"; then
				echo "$wid"
				break
			fi
		done)
		[ -n "$nvim_win" ] && tmux select-window -t "$nvim_win" 2>/dev/null
		return
	fi

	# Create new window adjacent to current, jump to it
	rm -f "$sock"
	tmux new-window -a "bash -c \"$nvim --listen '$sock' +$line '$last_file'; exec \$SHELL\"" || true
}

# Call function based on first argument
case "$1" in
"name")
	smart_name "$2" "$3"
	;;
"finder")
	window_finder
	;;
"window_list")
	window_list
	;;
"window_grep")
	window_grep "$2"
	;;
"zoxide_list")
	zoxide_list
	;;
"vscode")
	spawn_vscode_window "$2"
	;;
"dir")
	short_dir "$2" "$3"
	;;
"auto-scroll")
	auto_scroll "$2"
	;;
"follow")
	claude_follow
	;;
*)
	echo "Usage: $0 {name|finder|dir|auto-scroll|follow} [args...]"
	exit 1
	;;
esac
