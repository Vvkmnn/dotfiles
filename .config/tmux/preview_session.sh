#!/bin/bash
session="$1"
index="$2"

[ -z "$session" ] && exit 0

if [ -z "$index" ]; then
    # Session preview: bordered boxes with real content per window
    windows=$(tmux list-windows -t "$session" -F '#{window_index}|#{window_name}|#{pane_current_command}|#{pane_current_path}|#{window_active}' 2>/dev/null)
    [ -z "$windows" ] && exit 0

    width=${FZF_PREVIEW_COLUMNS:-80}
    lines=${FZF_PREVIEW_LINES:-40}
    win_count=$(printf '%s\n' "$windows" | wc -l | tr -d ' ')

    # Each window: 1 header + content + 1 bottom border = content + 2
    # Use full vertical space with no dead space
    content_lines=$(( (lines / win_count) - 2 ))
    [ "$content_lines" -lt 2 ] && content_lines=2

    inner=$((width - 4))
    border=$(printf '─%.0s' $(seq 1 "$inner"))

    while IFS='|' read -r win_idx win_name win_cmd win_path win_active; do
        [ -z "$win_idx" ] && continue
        short_path="${win_path/#$HOME/\~}"

        # Header with box top
        label="$win_idx: $win_name · $win_cmd  $short_path"
        if [ "$win_active" = "1" ]; then
            printf '\033[1;32m  ┌─ ▶ %s \033[0m\n' "$label"
        else
            printf '\033[90m  ┌─ · \033[36m%s\033[0m\n' "$label"
        fi

        # Real content with native colors: capture with ANSI, filter noise, take last N
        tmux capture-pane -ep -t "${session}:${win_idx}" -S -50 2>/dev/null \
            | grep -v '^[[:space:]]*$' \
            | grep -v 'ॐ\|-- INSERT\|-- NORMAL\|-- REPLACE\|plan mode on\|shift+tab' \
            | tail -"$content_lines" \
            | while IFS= read -r line; do
                printf '\033[90m  │\033[0m %s\n' "$line"
            done

        # Box bottom
        printf '\033[90m  └%s\033[0m\n' "$border"
    done <<< "$windows"
else
    # Window preview - full colored capture
    height=$(tmux display-message -p -t "${session}:${index}" '#{pane_height}' 2>/dev/null)
    [ -z "$height" ] && height=40
    tmux capture-pane -e -t "${session}:${index}" -S "-${height}" -p 2>/dev/null
fi
