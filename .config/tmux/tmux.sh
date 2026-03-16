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
        local processes=$(ps -t "$pane_tty" -o comm= 2>/dev/null | \
            grep -v '/' | grep -v '^-' | grep -v '^(' | \
            grep -vE '^[0-9]+\.[0-9]+' | \
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
        -F "#{session_name}:#{window_index}	#{window_name}	#{pane_current_command}	#{pane_current_path}" | \
    /usr/bin/sed "s|$HOME|~|" | \
    /usr/bin/awk -F'\t' '{printf "%-8s  %-12s  %-10s  %s\n", $1, $2, $3, $4}'
}

window_grep() {
    local query="$1"
    [ -z "$query" ] && { window_list; return; }

    # Get raw data once, format once (single pipeline, no bash loop)
    local raw formatted
    raw=$(tmux list-windows -a \
        -F "#{session_name}:#{window_index}	#{window_name}	#{pane_current_command}	#{pane_current_path}")
    formatted=$(echo "$raw" | /usr/bin/sed "s|$HOME|~|" | \
        /usr/bin/awk -F'\t' '{printf "%-8s  %-12s  %-10s  %s\n", $1, $2, $3, $4}')

    # Phase 1: metadata match — single grep over all lines (not per-window)
    local meta_hits skip_list=""
    meta_hits=$(/usr/bin/grep -i "$query" <<< "$formatted" 2>/dev/null) || true
    if [ -n "$meta_hits" ]; then
        printf '%s\n' "$meta_hits"
        skip_list=$'\n'$(/usr/bin/awk '{print $1}' <<< "$meta_hits")$'\n'
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
    done <<< "$raw"
}

window_finder() {
    local me target
    me="$HOME/.config/tmux/tmux.sh"
    target=$(
        window_list | \
        fzf --layout reverse \
            --disabled \
            --highlight-line \
            --border-label '  Windows ' \
            --border-label-pos 3 \
            --header '  search all · C-f: fuzzy names only' \
            --header-border bottom \
            --prompt '  ' \
            --pointer '▶' \
            --info inline-right \
            --preview 'q={q}; win=$(echo {1}); if [ -n "$q" ]; then tmux capture-pane -t "$win" -p -J -S -500 2>/dev/null | /usr/bin/grep --color=always -i -n -C2 "$q" | head -40; else tmux capture-pane -e -t "$win" -S -50 -p 2>/dev/null; fi' \
            --preview-window 'right:65%:wrap' \
            --preview-border rounded \
            --bind "change:reload:sleep 0.05; $me window_grep {q} || true" \
            --bind "ctrl-f:unbind(change)+enable-search+change-prompt(  )+change-header(  fuzzy names · C-g: search all)+reload($me window_list)+rebind(ctrl-g)" \
            --bind "ctrl-g:disable-search+change-prompt(  )+change-header(  search all · C-f: fuzzy names only)+reload($me window_grep {q})+rebind(change)+unbind(ctrl-g)+rebind(ctrl-f)" \
            --color 'bg+:#44475a,fg+:#f8f8f2' \
            --color 'hl:#50fa7b,hl+:#50fa7b:bold' \
            --color 'border:#6272a4,label:#50fa7b' \
            --color 'header:#6272a4,header-border:#44475a' \
            --color 'prompt:#50fa7b,pointer:#ff79c6' \
            --color 'info:#6272a4,spinner:#ffb86c' \
            --color 'preview-border:#44475a'
    ) || return 0

    tmux switch-client -t "$(echo "$target" | awk '{print $1}')"
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
    "vscode")
        spawn_vscode_window "$2"
        ;;
    "dir")
        short_dir "$2" "$3"
        ;;
    *)
        echo "Usage: $0 {name|finder|dir} [args...]"
        exit 1
        ;;
esac
