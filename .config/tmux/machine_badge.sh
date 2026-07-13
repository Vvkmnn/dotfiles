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

# Shared iconography contract (power-tier shape + per-machine hue), also read by ~/.fleet — ONE source
# of truth so the status bar and the fleet tree never drift. Defines fleet_shape() and fleet_hex().
. "$HOME/.config/fleet/badge.sh"

# Glyphs via octal UTF-8 bytes so no editor/transport can strip them (verified round-trip):
#   apple U+F179 · tux U+F17C · caps U+2590/U+258C (square half-blocks) · zoom U+F0293.
#   power-tier shapes (△□⬠⬡○☆) live in badge.sh now, shared with ~/.fleet.
APPLE=$(printf '\357\205\271')
TUX=$(printf '\357\205\274')
LCAP=$(printf '\356\202\266')   # U+E0B6 left  half-circle — rounded LEFT cap
RCAP=$(printf '\356\202\264')   # U+E0B4 right half-circle — rounded RIGHT cap
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

# --- POWER-TIER shape from core count (sides = strength) — mapping shared with ~/.fleet via badge.sh -
cores=$(sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo 8)
SHAPE=$(fleet_shape "$cores")

# --- PER-MACHINE colour — table + hash-fallback shared with ~/.fleet via badge.sh (fleet_hex) --------
# Each machine has its OWN stable hue (NOT chip-derived, so two same-chip boxes never collide); an
# unrecognised host still auto-gets a unique, stable hue by hashing its name. Edit the table in badge.sh.
host=$(scutil --get LocalHostName 2>/dev/null || hostname -s 2>/dev/null || echo host)
machine_color="#$(fleet_hex "$host")"
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

# --- RIGHT: animal, then save-health chip, then the date -------------------
# The chip is the fading save-freshness age (right of the animal): lambda.sh renders it,
# launchd runs the actual saves. Gold brighter than morbid_year's first entry, fading to red (and
# a loud ! on a failed/unverified save) so the 4-day silent gap that lost everything can't recur.
# Set BOTH @minimal-tmux-status-right (survives a plain reload) AND status-right directly — the
# plugin only bakes the option at load, before this script runs, so status-right must be set here
# too or the chip never reaches the bar (exactly the left-side pattern at status-left above).
animal=" #{@random_animal} "
right="${animal}#(~/.config/tmux/lambda.sh chip) #(~/.config/tmux/morbid_year all)"
"$TMUX_BIN" set-option -g @minimal-tmux-status-right "$right"
"$TMUX_BIN" set-option -g status-right-length 300
"$TMUX_BIN" set-option -g status-right "$right"

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

# --- pane pills (bottom border, right-aligned) — three rounded pills per pane ----
# The top bar already carries cmd + path per window, so the bottom shows DIFFERENT, pane-local
# facts: pane INDEX · SIZE (WxH) · PID. Colour graduates bright→grey (index lit, size muted, pid
# grey) so the active pane's index reads first; an inactive pane greys all three. Padded both
# sides (left inset + right float). Hidden when the window has only 1 pane. No #() — pure format,
# zero forks per redraw. Branches stay comma-free so they render inside the #{?pane_active,…,…}
# selector (commas are the selector's separator).
PLPAD='  '   # left inset off the border line
PGAP='   '   # right float off the edge
# active-pane row: index bright → size muted → pid grey (black text on lit, off-white on dim)
pa="#[fg=#957FB8]${LCAP}#[bg=#957FB8 fg=#1f1f28] #{pane_index} #[bg=default fg=#957FB8]${RCAP} #[fg=#54546d]${LCAP}#[bg=#54546d fg=#dcd7ba] #{pane_width}x#{pane_height} #[bg=default fg=#54546d]${RCAP} #[fg=#2a2a37]${LCAP}#[bg=#2a2a37 fg=#dcd7ba] #{pane_pid} #[bg=default fg=#2a2a37]${RCAP}"
# inactive-pane row: all three dark-grey
pi="#[fg=#2a2a37]${LCAP}#[bg=#2a2a37 fg=#dcd7ba] #{pane_index} #[bg=default fg=#2a2a37]${RCAP} #[fg=#2a2a37]${LCAP}#[bg=#2a2a37 fg=#dcd7ba] #{pane_width}x#{pane_height} #[bg=default fg=#2a2a37]${RCAP} #[fg=#2a2a37]${LCAP}#[bg=#2a2a37 fg=#dcd7ba] #{pane_pid} #[bg=default fg=#2a2a37]${RCAP}"
pbf="#{?#{e|>:#{window_panes},1},#[align=right]${PLPAD}#{?pane_active,${pa},${pi}}${PGAP}#[default],}"
"$TMUX_BIN" set-option -g pane-border-format "$pbf"
