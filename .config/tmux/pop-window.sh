#!/bin/sh
# pop-window.sh — pop the given tmux window OUT into its own brand-new session and open it in a fresh
# Ghostty window. Bound to Alt-Enter (see tmux.conf). Pure tmux: the window is MOVED (it leaves its
# current session) but can never be lost — it lands in the new session BEFORE Ghostty attaches, so even
# if the GUI never opens (headless box, mosh session) the window is safe and reattachable:
#     tmux attach -t <new-session>
#
# The new session takes tmux's OWN auto-numbered name (0,1,2… — how the regular sessions are named), so
# the popped window looks like any other and the status-bar badge renders a clean numeral.
#
# Source session handling (this fleet runs `detach-on-destroy off`, so a client whose session is
# destroyed is SWITCHED to another session rather than exiting — man tmux):
#   • >1 window  — left fully intact; tmux just switches the source client to a sibling window.
#   • sole window — the source session dies on the move; without intervention its Ghostty would be
#     relocated onto the new session, duplicating it. So we capture that client first and, once the
#     session is confirmed gone, `detach-client -P` it: tmux SIGHUPs the client's parent process,
#     closing the orphaned Ghostty window cleanly. (man tmux: "-P … send SIGHUP to the parent … exit").
#
# Takes ONLY the window id ($1 = #{window_id}, an @N target stable across the move and safe to
# interpolate). Set POP_NO_GUI=1 to report + stop before any GUI / client side effects (test harness).

wid="$1"
[ -n "$wid" ] || exit 0

TMUX_BIN=/opt/homebrew/bin/tmux
command -v "$TMUX_BIN" >/dev/null 2>&1 || TMUX_BIN=tmux

# capture the source session and, if this is its sole window, the client ttys about to be orphaned —
# clients relocate the instant the session empties, so this MUST happen before the move. Target them
# by tty (stable across the relocation) rather than by which session they end up on.
src_sess=$("$TMUX_BIN" display-message -p -t "$wid" '#{session_name}' 2>/dev/null)
src_nwin=$("$TMUX_BIN" display-message -p -t "$wid" '#{session_windows}' 2>/dev/null)
src_ttys=""
[ "$src_nwin" = 1 ] && src_ttys=$("$TMUX_BIN" list-clients -t "$src_sess" -F '#{client_tty}' 2>/dev/null)

# 1) new detached session, auto-named by tmux; capture the name it chose
new=$("$TMUX_BIN" new-session -d -P -F '#{session_name}' 2>/dev/null) || exit 1
[ -n "$new" ] || exit 1
# 2) move the EXACT window in — if this fails, tear down the empty new session; the window stays put
if ! "$TMUX_BIN" move-window -s "$wid" -t "${new}:" >/dev/null 2>&1; then
	"$TMUX_BIN" kill-session -t "$new" >/dev/null 2>&1
	exit 1
fi
# 3) drop every window in the new session EXCEPT the one we moved (removes the placeholder shell)
"$TMUX_BIN" list-windows -t "$new" -F '#{window_id}' 2>/dev/null | while IFS= read -r w; do
	[ "$w" = "$wid" ] || "$TMUX_BIN" kill-window -t "$w" >/dev/null 2>&1
done

# test harness: report the outcome and stop before any GUI / client side effects
[ -n "$POP_NO_GUI" ] && { printf 'new=%s src_ttys=%s\n' "$new" "$(echo "$src_ttys" | tr '\n' ',')"; exit 0; }

# 4) open the popped window in a fresh Ghostty (the window is already safe in "$new" regardless)
open -na /Applications/Ghostty.app --args -e /bin/zsh -lc "exec ${TMUX_BIN} attach -t '${new}'" >/dev/null 2>&1 &

# 5) sole-window pop: the source session is now gone and its client relocated. Close each orphaned
#    Ghostty with detach-client -P (SIGHUP its parent → the window's shell exits). Targeted by the
#    pre-move tty so the freshly-opened window above is never touched.
if [ -n "$src_ttys" ] && ! "$TMUX_BIN" has-session -t "$src_sess" 2>/dev/null; then
	echo "$src_ttys" | while IFS= read -r tty; do
		[ -n "$tty" ] && "$TMUX_BIN" detach-client -P -t "$tty" >/dev/null 2>&1
	done
fi
printf '%s\n' "$new"
