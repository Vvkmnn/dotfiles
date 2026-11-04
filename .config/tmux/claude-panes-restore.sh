#!/bin/bash
# claude-panes-restore.sh — tmux-resurrect `post-restore-all` hook (tmux.conf, @resurrect-hook-post-restore-all).
#
# Puts @claude_session and @claude_args back on each restored pane from the newest snapshot written by
# claude-panes-save.sh, matched by position (session:window.pane) AND the pane's cwd: resurrect restores
# both, and a pane whose cwd differs from the snapshot is a different pane, never tagged. No process is
# started (the owner's lazy restore, @resurrect-processes 'false'); `c` in the pane resumes its session.
#
# Fails open: no snapshot, an unreadable row, a pane that no longer exists — skipped, never an error.
set -uo pipefail
export PATH="/opt/homebrew/bin:/usr/bin:/bin"

TMUX_BIN="${CLAUDE_TMUX_BIN:-/opt/homebrew/bin/tmux}"   # override = selftest stub
DIR="${CLAUDE_PANES_DIR:-$HOME/.local/state/claude/panes}"

newest=$(ls -1r "$DIR"/*.tsv 2>/dev/null | head -1) || true
[ -n "${newest:-}" ] && [ -s "$newest" ] || exit 0

while IFS=$'\t' read -r pos cwd sid args; do
	[ -n "$pos" ] && [ -n "$sid" ] || continue
	cur=$("$TMUX_BIN" display-message -p -t "$pos" '#{pane_current_path}' 2>/dev/null) || continue
	[ "$cur" = "$cwd" ] || continue
	"$TMUX_BIN" set-option -p -t "$pos" @claude_session "$sid" 2>/dev/null || continue
	[ -n "$args" ] && "$TMUX_BIN" set-option -p -t "$pos" @claude_args "$args" 2>/dev/null
done < "$newest"
exit 0
