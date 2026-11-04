#!/bin/bash
# claude-panes-save.sh — tmux-resurrect `post-save-all` hook (tmux.conf, @resurrect-hook-post-save-all).
#
# Every pane that runs Claude carries two pane options: @claude_session (its session id, written by the
# SessionStart and prompt hooks through ~/.claude/hooks/lib/pane-session.js) and @claude_args (the flags it
# was launched with, written by `c`). Pane options die with the tmux server, so this hook snapshots them
# at every resurrect save, and claude-panes-restore.sh puts them back after a restore. `c` then resumes
# the pane's own session even after a reboot; no process is ever started here.
#
# One file per save under ~/.local/state/claude/panes/, newest first by name, the last KEEP kept. A save
# that finds no Claude pane writes nothing: a snapshot taken after a crash or an OOM kill must never
# shadow the last good map (cookiecad/tmux-claude-resurrect lost its only map exactly that way).
#
# Runs from resurrect's save.sh (interactive or lambda.sh's launchd save), inside `eval`, with no stdin.
set -euo pipefail
export PATH="/opt/homebrew/bin:/usr/bin:/bin"

TMUX_BIN="${CLAUDE_TMUX_BIN:-/opt/homebrew/bin/tmux}"   # override = selftest stub
DIR="${CLAUDE_PANES_DIR:-$HOME/.local/state/claude/panes}"
KEEP=100

# position, cwd, session id, launch flags — tab-separated; only panes that carry a session id
rows=$("$TMUX_BIN" list-panes -a -F $'#{session_name}:#{window_index}.#{pane_index}\t#{pane_current_path}\t#{@claude_session}\t#{@claude_args}' 2>/dev/null | awk -F'\t' '$3 != ""') || true
[ -n "$rows" ] || exit 0

mkdir -p "$DIR"
f="$DIR/$(date +%Y%m%dT%H%M%S).tsv"
printf '%s\n' "$rows" > "$f.tmp" && mv "$f.tmp" "$f"

# retention: the newest KEEP snapshots stay (names sort by time)
ls -1r "$DIR"/*.tsv 2>/dev/null | tail -n +$((KEEP + 1)) | while IFS= read -r old; do rm -f -- "$old"; done
exit 0
