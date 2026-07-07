#!/bin/bash
# machine_badge.sh — machine + session identity badge for the tmux status bar.
#
# The left of the status bar is three rounded pills:
#   apple pill   — the OS glyph (Apple / Tux) in the MACHINE colour.
#   machine pill — a POWER-TIER SHAPE + the real hostname, in the MACHINE colour.
#                    shape encodes strength (more sides = more power), auto-detected
#                    from core count: △≤8  □≤10  ⬠≤12  ⬡≤16  ○≤24  ☆>24.
#                    colour is PER-MACHINE (curated table + hash-fallback), so two
#                    same-chip boxes still differ; `vj` into another and the hue changes.
#   session pill — the session as a Roman numeral (or its name), in a lighter SHADE
#                    of the machine colour (hue-preserving tint, per-session hash).
# All three pills flip GOLD while prefix is held — the "mode light", no full-width box.
# The animal lives on the far right, plain at rest, in a tight white circle only while
# prefix is held.  Colours resolve at render time via #{@…} vars (verified: colour vars
# expand inside #[…] styles on tmux 3.6a).  Runs at load + session-created/attached,
# never on the render path — zero forks per redraw.
#
# SAFETY: no #() anywhere (see the SAFETY banner above window-status in tmux.conf).

TMUX_BIN=/opt/homebrew/bin/tmux
command -v "$TMUX_BIN" >/dev/null 2>&1 || TMUX_BIN=tmux

# Glyphs via octal UTF-8 bytes so no editor/transport can strip them (verified round-trip):
#   apple U+F179 · tux U+F17C · caps U+E0B6/U+E0B4 · zoom U+F0293.
#   power shapes: triangle U+25B3 · square U+25A1 · pentagon U+2B20 · hexagon U+2B21 ·
#                 circle U+25CB · star U+2606 (geometric symbols, NOT emoji).
APPLE=$(printf '\357\205\271')
TUX=$(printf '\357\205\274')
LCAP=$(printf '\356\202\266')
RCAP=$(printf '\356\202\264')
ZOOM=$(printf '\363\260\212\223')
TRI=$(printf '\342\226\263'); SQ=$(printf '\342\226\241'); PENT=$(printf '\342\254\240')
HEX=$(printf '\342\254\241'); CIRC=$(printf '\342\227\213'); STAR=$(printf '\342\230\206')
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

# --- POWER-TIER shape from core count (sides = strength; zero fork) ----------
cores=$(sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo 8)
if   [ "$cores" -le 8 ];  then SHAPE=$TRI
elif [ "$cores" -le 10 ]; then SHAPE=$SQ
elif [ "$cores" -le 12 ]; then SHAPE=$PENT
elif [ "$cores" -le 16 ]; then SHAPE=$HEX
elif [ "$cores" -le 24 ]; then SHAPE=$CIRC
else                           SHAPE=$STAR
fi

# --- PER-MACHINE colour (curated table; hash-fallback for any new box) -------
# Each machine has its OWN stable hue — NOT derived from the chip, so two same-chip
# machines never collide. Add a machine by dropping a line in the case below; an
# unrecognised host still auto-gets a unique, stable hue by hashing its name.
host=$(scutil --get LocalHostName 2>/dev/null || hostname -s 2>/dev/null || echo host)
hl=$(printf '%s' "$host" | tr '[:upper:]' '[:lower:]')
case "$hl" in
	*air*)    machine_color='#7aa89f' ;;   # teal
	*mini*)   machine_color='#e0a45c' ;;   # amber
	*neo*)    machine_color='#9d7cc9' ;;   # violet
	*studio*) machine_color='#c98a6b' ;;   # clay (reserved)
	*)  machine_color=$(python3 - "$host" 2>/dev/null <<'PY'
import sys, colorsys, hashlib
h = int(hashlib.md5(sys.argv[1].encode()).hexdigest(), 16) % 360
r, g, b = colorsys.hls_to_rgb(h/360, 0.64, 0.45)
print("#%02x%02x%02x" % (round(r*255), round(g*255), round(b*255)))
PY
)
	    machine_color="${machine_color:-#9a9a9a}" ;;   # grey if python3 missing
esac
"$TMUX_BIN" set-option -g @machine_color "$machine_color"

# --- per session: Roman numeral + a lighter SHADE of the machine colour ------
# The tint lightens the machine colour 22–42% (hue-preserving) with a small per-channel
# nudge from the session-name hash, so distinct sessions get distinct, related, black-
# readable colours. python once per session (load-time only, never on redraw); if python
# is missing the session pill simply falls back to the flat machine colour.
"$TMUX_BIN" list-sessions -F '#{session_name}' 2>/dev/null | while IFS= read -r s; do
	[ -z "$s" ] && continue
	if printf '%s' "$s" | grep -qE '^[0-9]+$'; then
		"$TMUX_BIN" set-option -t "$s" @session_roman "$(to_roman "$s")"
	else
		"$TMUX_BIN" set-option -t "$s" @session_roman "$s"
	fi
	sc=$(python3 - "$machine_color" "$s" 2>/dev/null <<'PY'
import sys, hashlib
base = sys.argv[1].lstrip('#'); s = sys.argv[2]
br, bg, bb = int(base[0:2],16), int(base[2:4],16), int(base[4:6],16)
h = int(hashlib.md5(s.encode()).hexdigest(), 16); bl = 22 + h % 21
r = min(235, max(150, br + (255-br)*bl//100 + (h//100    % 25) - 12))
g = min(235, max(150, bg + (255-bg)*bl//100 + (h//2500   % 25) - 12))
b = min(235, max(150, bb + (255-bb)*bl//100 + (h//62500  % 25) - 12))
print("#%02x%02x%02x" % (r, g, b))
PY
)
	"$TMUX_BIN" set-option -t "$s" @session_color "${sc:-$machine_color}"
done

# --- LEFT badge: apple · [shape hostname] · session-roman -------------------
# apple + machine pills = machine colour; session pill = its lighter shade. Every pill
# flips GOLD while prefix is held (same safe #{?...} pattern — both branches commaless,
# so it renders inside #[…] styles). SHAPE + OS glyph are literal bytes baked in here.
mbg="#{?client_prefix,${GOLD},#{@machine_color}}"
sbg="#{?client_prefix,${GOLD},#{@session_color}}"
apple_pill="#[fg=${mbg}]${LCAP}#[bg=${mbg} fg=${BLACK} bold] ${OSGLYPH} #[bg=default fg=${mbg}]${RCAP}#[default]"
machine_pill="#[fg=${mbg}]${LCAP}#[bg=${mbg} fg=${BLACK} bold] ${SHAPE} #{host_short} #[bg=default fg=${mbg}]${RCAP}#[default]"
session_pill="#[fg=${sbg}]${LCAP}#[bg=${sbg} fg=${BLACK} bold] #{@session_roman} #[bg=default fg=${sbg}]${RCAP}#[default]"
badge="${apple_pill} ${machine_pill} ${session_pill} "
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
