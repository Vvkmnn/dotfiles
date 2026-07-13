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
# destroyed is SWITCHED to another session rather than exiting — man tmux). We snapshot the source
# clients before the move and, after it, close only the ones the pop STRANDED — decided per client by
# where it sits NOW, not by a pre-count of windows:
#   • multi-window source — its client stays ON the source session (tmux just switches it to a sibling
#     window): left fully intact, so the regular flow is never disturbed.
#   • sole-window source  — the session dies on the move and the client is relocated onto another
#     session (the empty leftover window). Detected as "current session ≠ source" → closed.
#   • vw grouped view      — a throwaway picker view (destroy-unattached on); once its window pops it
#     has served its purpose → closed.
#   Closing = `detach-client -P`: tmux SIGHUPs the client's parent process, and with ZSH_TMUX AUTOQUIT
#   the orphaned Ghostty exits cleanly. (man tmux: "-P … send SIGHUP to the parent … exit").
#
# Takes ONLY the window id ($1 = #{window_id}, an @N target stable across the move and safe to
# interpolate). Set POP_NO_GUI=1 to report + stop before any GUI / client side effects (test harness).

wid="$1"
[ -n "$wid" ] || exit 0

TMUX_BIN=/opt/homebrew/bin/tmux
command -v "$TMUX_BIN" >/dev/null 2>&1 || TMUX_BIN=tmux

# Snapshot BEFORE the move (targets stay valid across the relocation the move can trigger):
#   • src_sess — the session the window is leaving.
#   • src_view — is the source a THROWAWAY vw view? `destroy-unattached on` is set ONLY by the vw
#                picker's grouped view session, never a base session, so it's a safe marker.
#   • src_ttys — every client on the source. We keep ALL of them and decide per-client AFTER the move
#                which the pop stranded (see close stage). tty is stable across a relocation; the
#                session a client lands on is not — so we target by tty.
src_sess=$("$TMUX_BIN" display-message -p -t "$wid" '#{session_name}' 2>/dev/null)
src_widx=$("$TMUX_BIN" display-message -p -t "$wid" '#{window_index}' 2>/dev/null)
src_view=0
case "$("$TMUX_BIN" show-options -t "$src_sess" destroy-unattached 2>/dev/null)" in *on) src_view=1 ;; esac
src_ttys=$("$TMUX_BIN" list-clients -t "$src_sess" -F '#{client_tty}' 2>/dev/null)

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
[ -n "$POP_NO_GUI" ] && { printf 'new=%s src_view=%s src_ttys=%s\n' "$new" "$src_view" "$(echo "$src_ttys" | tr '\n' ',')"; exit 0; }

# 4) open the popped window in a fresh Ghostty (the window is already safe in "$new" regardless)
open -na /Applications/Ghostty.app --args -e /bin/zsh -lc "exec ${TMUX_BIN} attach -t '${new}'" >/dev/null 2>&1 &

# 5) Close only the source clients the pop STRANDED. Compare the pre-move client ttys against the
#    clients STILL on the source session now — `list-clients -t <sess>` filters by each client's real
#    session, which is reliable (unlike `display-message -c <tty> '#{session_name}'`, which resolves
#    against the current target, NOT the client, and so lies):
#      • a captured tty no longer on src_sess was RELOCATED — a sole-window source died and
#        `detach-on-destroy off` switched its client onto another session (the empty leftover window).
#      • src_view — a vw grouped view keeps its clients but has served its one purpose once its window
#        pops, so close them too.
#    Closing = detach-client -P (SIGHUP the client's parent; with ZSH_TMUX AUTOQUIT the Ghostty exits).
#    A normal MULTI-window source client stays ON src_sess (tmux just switched its window) → still
#    listed → left intact, so the regular flow is untouched. The freshly-opened window above is a
#    different tty on the new session, never in src_ttys.
still=$("$TMUX_BIN" list-clients -t "$src_sess" -F '#{client_tty}' 2>/dev/null)
echo "$src_ttys" | while IFS= read -r tty; do
	[ -n "$tty" ] || continue
	if [ "$src_view" = 1 ] || ! printf '%s\n' "$still" | grep -qxF "$tty"; then
		"$TMUX_BIN" detach-client -P -t "$tty" >/dev/null 2>&1
	fi
done

# 6) Surviving (multi-window) source: tmux switches its client off the popped window, but its choice
#    isn't reliably leftward and can land on a sibling left in copy-mode (renders frozen, [0/N]). Select
#    the nearest window on the LEFT (greatest index below the popped one; else the lowest remaining) and
#    drop any copy-mode so the client lands live. has-session skips sole-window / view sources (closed
#    above); a target with no clients just makes this a harmless no-op.
if [ -n "$src_widx" ] && "$TMUX_BIN" has-session -t "$src_sess" 2>/dev/null; then
	left_win=$("$TMUX_BIN" list-windows -t "$src_sess" -F '#{window_index}' 2>/dev/null | awk -v x="$src_widx" '$1<x{c=$1} END{if(c!="")print c}')
	[ -z "$left_win" ] && left_win=$("$TMUX_BIN" list-windows -t "$src_sess" -F '#{window_index}' 2>/dev/null | head -n1)
	[ -n "$left_win" ] && "$TMUX_BIN" select-window -t "${src_sess}:${left_win}" >/dev/null 2>&1
	[ "$("$TMUX_BIN" display-message -p -t "$src_sess" '#{pane_in_mode}' 2>/dev/null)" = 1 ] &&
		"$TMUX_BIN" send-keys -t "$src_sess" -X cancel >/dev/null 2>&1
fi
printf '%s\n' "$new"
