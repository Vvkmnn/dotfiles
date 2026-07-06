#!/bin/bash
# machine_badge.sh — machine + session identity badge for the tmux status bar.
#
# The left of the status bar is three rounded pills:
#   OS pill   — white Apple (macOS) / Tux (Linux); flips GOLD while prefix is held
#               (this is the prefix "mode light" — no ugly full-width highlight box).
#   chip pill — the FIXED, vivid per-chip colour (M3 teal, M4 blue, A-series violet,
#               AMD red, …) so every machine is recognisable by hue; `vj` into another
#               box and the whole badge changes colour. Black bold text.
#   sess pill — a UNIQUE pale tint DERIVED from the chip colour (blend toward white +
#               per-channel nudge from a hash of the session name; ~68k combos so
#               distinct sessions get distinct, related, black-readable colours).
#               Shows the session as a Roman numeral (numeric sessions) or its name.
# The animal lives on the far right, plain at rest, in a tight white circle only while
# prefix is held.  All colours resolve at render time via #{@…} vars (verified: colour
# vars expand inside #[…] styles on tmux 3.6a).  Runs at load + session-created/attached,
# never on the render path — zero forks per redraw.
#
# SAFETY: no #() anywhere (see the SAFETY banner above window-status in tmux.conf).

TMUX_BIN=/opt/homebrew/bin/tmux
command -v "$TMUX_BIN" >/dev/null 2>&1 || TMUX_BIN=tmux

# Glyphs via octal UTF-8 bytes so no editor/transport can strip them (verified round-trip):
#   apple U+F179 · tux U+F17C · caps U+E0B6/U+E0B4 · zoom U+F0293.
APPLE=$(printf '\357\205\271')
TUX=$(printf '\357\205\274')
LCAP=$(printf '\356\202\266')
RCAP=$(printf '\356\202\264')
ZOOM=$(printf '\363\260\212\223')
GOLD='#e6c384'; WHITE='#fffaf0'; BLACK='#1f1f28'

case "$(uname -s)" in Linux) OSGLYPH="$TUX" ;; *) OSGLYPH="$APPLE" ;; esac

# --- Roman numeral (1–3999); 0/empty -> "0" -------------------------------
to_roman() {
	local n=$1 out='' i
	local -a val=(1000 900 500 400 100 90 50 40 10 9 5 4 1)
	local -a sym=(M CM D CD C XC L XL X IX V IV I)
	for i in "${!val[@]}"; do
		while [ "$n" -ge "${val[$i]}" ]; do out="$out${sym[$i]}"; n=$(( n - val[i] )); done
	done
	[ -z "$out" ] && out='0'
	printf '%s' "$out"
}

# --- detect the literal chip once, cache bare value in @chip_raw ------------
chip=$("$TMUX_BIN" show-option -gqv @chip_raw)
if [ -z "$chip" ]; then
	raw=$(sysctl -n machdep.cpu.brand_string 2>/dev/null)
	[ -z "$raw" ] && [ -r /proc/cpuinfo ] && \
		raw=$(grep -m1 -iE 'model name|^Model' /proc/cpuinfo | sed 's/.*: *//')
	chip=$(printf '%s' "$raw" | sed '
		s/^Apple //
		s/(R)//g; s/(TM)//g
		s/ @.*//; s/ CPU.*//; s/ [0-9]*-Core.*//; s/ Processor.*//
		s/AMD Ryzen Threadripper \([0-9][0-9]*\).*/TR\1/
		s/AMD Ryzen \([0-9]\).*/R\1/
		s/AMD EPYC.*/EPYC/
		s/Intel Core //; s/Intel //; s/AMD //
	')
	[ -z "$chip" ] && chip='?'
	"$TMUX_BIN" set-option -g @chip_raw "$chip"
	"$TMUX_BIN" set-option -g @chip "v$chip"
fi

# --- fixed vivid base colour per chip --------------------------------------
case "$chip" in
	M1*)     base='#98bb6c' ;;  # green
	M2*)     base='#7e9cd8' ;;  # indigo
	M3*)     base='#7aa89f' ;;  # teal
	M4*)     base='#7fb4ca' ;;  # blue
	M[5-9]*) base='#d27e99' ;;  # pink
	A[0-9]*) base='#957fb8' ;;  # violet (Apple A-series)
	i[0-9]*) base='#c0a36e' ;;  # gold (Intel)
	R[0-9]*|TR*|EPYC*) base='#e46876' ;;  # red (AMD)
	*)       base='#727169' ;;  # grey (unknown)
esac
"$TMUX_BIN" set-option -g @chip_color "$base"

# --- per-session UNIQUE pale tint of the base colour + Roman numeral --------
# pale base = blend ~50% toward white; then nudge each channel by decorrelated
# hash bits (±20). ~41^3 ≈ 68k combos -> distinct sessions get distinct, still
# family-related, black-text-readable colours. Clamped to 150..240 (stays light).
br=$(( 16#${base:1:2} )); bgc=$(( 16#${base:3:2} )); bbc=$(( 16#${base:5:2} ))
pr=$(( br + (255-br)/2 )); pg=$(( bgc + (255-bgc)/2 )); pb=$(( bbc + (255-bbc)/2 ))
clamp() { local v=$1; [ "$v" -lt 150 ] && v=150; [ "$v" -gt 240 ] && v=240; printf '%s' "$v"; }
"$TMUX_BIN" list-sessions -F '#{session_name}' 2>/dev/null | while IFS= read -r s; do
	h=$(printf '%s' "$s" | cksum | cut -d' ' -f1)
	r=$(clamp $(( pr + (h % 41) - 20 )))
	g=$(clamp $(( pg + (h/41 % 41) - 20 )))
	b=$(clamp $(( pb + (h/1681 % 41) - 20 )))
	"$TMUX_BIN" set-option -t "$s" @session_color "$(printf '#%02x%02x%02x' "$r" "$g" "$b")"
	if printf '%s' "$s" | grep -qE '^[0-9]+$'; then
		"$TMUX_BIN" set-option -t "$s" @session_roman "$(to_roman "$s")"
	else
		"$TMUX_BIN" set-option -t "$s" @session_roman "$s"
	fi
done

# --- LEFT badge: OS · chip · session (rounded pills) ------------------------
osbg="#{?client_prefix,${GOLD},${WHITE}}"
os_pill="#[fg=${osbg}]${LCAP}#[bg=${osbg} fg=${BLACK}] ${OSGLYPH} #[bg=default fg=${osbg}]${RCAP}#[default]"
chip_pill="#[fg=#{@chip_color}]${LCAP}#[bg=#{@chip_color} fg=${BLACK} bold] #{@chip} #[bg=default fg=#{@chip_color}]${RCAP}#[default]"
sess_pill="#[fg=#{@session_color}]${LCAP}#[bg=#{@session_color} fg=${BLACK} bold] #{@session_roman} #[bg=default fg=#{@session_color}]${RCAP}#[default]"
badge="${os_pill} ${chip_pill} ${sess_pill} "
# Set @minimal-tmux-status-left (plugin uses it verbatim — no prefix-toggle box) AND
# status-left directly (immediate, and wins after a plain reload).
"$TMUX_BIN" set-option -g @minimal-tmux-status-left "$badge"
"$TMUX_BIN" set-option -g status-left-length 140
"$TMUX_BIN" set-option -g status-left "$badge"

# --- RIGHT: animal (tight white circle only on prefix) then the date -------
circ="#[fg=${WHITE}]${LCAP}#[bg=${WHITE}]#{@random_animal}#[bg=default fg=${WHITE}]${RCAP}#[default]"
animal="#{?client_prefix,${circ}, #{@random_animal} }"
# Set via @minimal-tmux-status-right so the plugin bakes it and continuum can still
# prepend its autosave #() — do NOT set status-right directly (that would drop autosave).
"$TMUX_BIN" set-option -g @minimal-tmux-status-right "${animal} #(~/.config/tmux/morbid_year all)"

# --- window pills (glyphs stay strip-safe here; content has NO #() ) -------
WLABEL="#{?#{m:[0-9]*,#{pane_current_command}},claude,#{?#{m:codex*,#{pane_current_command}},codex,#{pane_current_command}}}"
wsf="#[fg=#2a2a37]${LCAP}#[bg=#2a2a37 fg=#dcd7ba] #I│${WLABEL}│#{b:pane_current_path} #[bg=default fg=#2a2a37]${RCAP}"
wscf="#[fg=#e6c384]${LCAP}#[bg=#e6c384 fg=#1f1f28] #I│${WLABEL}│#{b:pane_current_path} #{?window_zoomed_flag, ${ZOOM} ,}#[bg=default fg=#e6c384]${RCAP}"
# CRITICAL: the minimal plugin sets window-status-format from @minimal-tmux-window-status-format,
# and its DEFAULT is the dangerous #(ps|grep|sed) ssh fork that crashed tmux. Setting it here
# means the plugin bakes OUR safe rounded card instead — the dangerous default is never applied.
"$TMUX_BIN" set-option -g @minimal-tmux-window-status-format "$wsf"
"$TMUX_BIN" set-option -gw window-status-format "$wsf"
"$TMUX_BIN" set-option -gw window-status-current-format "$wscf"
