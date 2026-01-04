#!/bin/bash
# All tmux helper functions in one script

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

window_finder() {
    tmux list-windows -a -F '#{session_name}:#{window_index}-#{window_name}-#{pane_current_command}-#{pane_current_path}' | \
    while IFS=- read -r target win_name cmd path; do
        content=$(tmux capture-pane -e -t $target -S -100 -p | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g')
        git_branch=""; [[ -d "$path/.git" ]] && git_branch=$(cd "$path" && git branch --show-current 2>/dev/null)
        port=$(echo "$content" | grep -oE '(localhost|127\.0\.0\.1):[0-9]+|port [0-9]+|:[0-9]{4,5}' | grep -oE '[0-9]+' | head -1)
        status="ok"
        echo "$content" | grep -qi "error\|failed\|exception" && status="error"
        echo "$content" | grep -qi "warning\|warn" && status="warn"
        echo "$content" | grep -qi "success\|done" && status="success"
        framework=""
        [[ -f "$path/package.json" ]] && {
            grep -q '"react"\|"next"' "$path/package.json" && framework="react"
            [[ -z "$framework" ]] && framework="node"
        }
        [[ -f "$path/requirements.txt" || -f "$path/pyproject.toml" ]] && framework="python"
        [[ -f "$path/Cargo.toml" ]] && framework="rust"
        [[ -f "$path/go.mod" ]] && framework="go"

        clean_name=$(smart_name "$cmd" "$path")
        port_info=""; [[ -n "$port" ]] && port_info="port$port"
        git_info=""; [[ -n "$git_branch" ]] && git_info="git$git_branch"
        framework_info=""; [[ -n "$framework" ]] && framework_info="$framework"
        echo "$target $clean_name $status $framework_info $port_info $git_info cmd$cmd dir$(/usr/bin/basename "$path") $content"
    done | \
    fzf --reverse \
        --no-info \
        --no-scrollbar \
        --with-nth='2' \
        --delimiter=' ' \
        --preview='tmux capture-pane -e -t {1} -S -30 -p' \
        --preview-window='right:60%:wrap:noborder' \
        --color='hl:#50fa7b,hl+:#50fa7b' \
        --algo=v2 \
        --scheme=path \
        --ansi \
        --prompt="Window: " \
        --header="Search: command, status, framework, port, git branch, directory" |\
    cut -d' ' -f1 |\
    xargs tmux switch-client -t
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
    "vscode")
        spawn_vscode_window "$2"
        ;;
    *)
        echo "Usage: $0 {name|finder} [args...]"
        exit 1
        ;;
esac
