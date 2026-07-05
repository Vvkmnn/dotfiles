#!/bin/bash
# machine_badge.sh — machine + session identity badge for the tmux status bar.
#
# Detects the literal chip ONCE (Apple Silicon / Intel / AMD / other, macOS or
# Linux) and picks a BRIGHT base colour per chip so each machine is recognisable
# by hue. Every session then gets a UNIQUE DARK shade from that same hue family,
# so sessions on one machine read as related-but-distinct. Only tmux user options
# + status-left are set; the badge references #{@chip}/#{@chip_color}/
# #{@session_color}, which tmux expands (verified: colour vars DO expand inside
# #[...] styles on tmux 3.6a). Runs at load + session-created/-changed, never on
# the render path — zero forks per redraw.
#
# SAFETY: no #() anywhere (see the SAFETY banner above window-status in tmux.conf).

TMUX_BIN=/opt/homebrew/bin/tmux
command -v "$TMUX_BIN" >/dev/null 2>&1 || TMUX_BIN=tmux

# Glyphs via octal UTF-8 bytes so no editor/transport can strip them (verified
# round-trip):  apple=nf-fa-apple U+F179 · caps=powerline round U+E0B6/U+E0B4 ·
# zoom=nf-md-fullscreen U+F0293. Set here (not in tmux.conf) precisely because
# writing PUA/powerline glyphs into config files silently strips them.
APPLE=$(printf '\357\205\271')
LCAP=$(printf '\356\202\266')
RCAP=$(printf '\356\202\264')
ZOOM=$(printf '\363\260\212\223')

# --- detect the literal chip once, cache bare value in @chip_raw ------------
chip=$("$TMUX_BIN" show-option -gqv @chip_raw)
if [ -z "$chip" ]; then
	# macOS (Apple Silicon + Intel Macs) first, then Linux /proc (AMD/Intel/ARM).
	raw=$(sysctl -n machdep.cpu.brand_string 2>/dev/null)
	[ -z "$raw" ] && [ -r /proc/cpuinfo ] && \
		raw=$(grep -m1 -iE 'model name|^Model' /proc/cpuinfo | sed 's/.*: *//')
	# Normalise to a short label: M3 / M4 / A18 / i7-9750H / R7 / TR3 / EPYC.
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

# --- bright base colour + dark session-shade family, per chip ---------------
# Session shades stay dark so the colourful animal emoji stays legible on them.
case "$chip" in
	M1*)     base='#98bb6c'; family=('#2f3d28' '#364527' '#3d4d2e' '#2b3826' '#42552f' '#334229') ;;  # green
	M2*)     base='#7e9cd8'; family=('#2a3048' '#313a54' '#3a4460' '#262c42' '#40486a' '#2e3450') ;;  # indigo
	M3*)     base='#7aa89f'; family=('#2e4440' '#2a4a44' '#34524a' '#3d5a52' '#285048' '#2e4a40') ;;  # teal
	M4*)     base='#7fb4ca'; family=('#2d4f67' '#26445c' '#335872' '#2a4a60' '#38607a' '#234056') ;;  # blue
	M[5-9]*) base='#d27e99'; family=('#4a2c38' '#522f3e' '#3f2530' '#582f44' '#45283a' '#4e2c40') ;;  # pink
	A[0-9]*) base='#957fb8'; family=('#3a3450' '#443c5c' '#4a4266' '#35304a' '#40385a' '#2f2a44') ;;  # violet (Apple A-series)
	i[0-9]*) base='#c0a36e'; family=('#4a4030' '#524636' '#443a2c' '#4e4432' '#3e3628' '#564a38') ;;  # gold (Intel)
	R[0-9]*|TR*|EPYC*) base='#e46876'; family=('#43242b' '#4a2830' '#522c34' '#3a2028' '#4e2a32' '#45262e') ;;  # red (AMD)
	*)       base='#727169'; family=('#363646' '#2a2a37' '#3a3a4a' '#303040' '#2e2e3c' '#34343f') ;;  # grey (unknown)
esac
"$TMUX_BIN" set-option -g @chip_color "$base"

# --- per-session unique shade (hash the session name into the family) --------
n=${#family[@]}
"$TMUX_BIN" list-sessions -F '#{session_name}' 2>/dev/null | while IFS= read -r s; do
	h=$(printf '%s' "$s" | cksum | cut -d' ' -f1)
	"$TMUX_BIN" set-option -t "$s" @session_color "${family[$(( h % n ))]}"
done

# --- build the badge: bright machine pill + per-session dark pill ------------
# rounded caps; #{@random_animal} + #S + colour vars all resolve at render time.
machine="#[fg=#{@chip_color}]${LCAP}#[bg=#{@chip_color} fg=#1f1f28 bold] ${APPLE} #{@chip} #[bg=default fg=#{@chip_color}]${RCAP}#[default]"
session="#[fg=#{@session_color}]${LCAP}#[bg=#{@session_color} fg=#dcd7ba] #{@random_animal} #S #[bg=default fg=#{@session_color}]${RCAP}#[default]"
badge="${machine} ${session}"

# minimal-tmux-status reads this at plugin-source time; also set status-left
# directly so a plain reload (without re-sourcing the plugin) still updates.
"$TMUX_BIN" set-option -g @minimal-tmux-indicator-str "$badge"
"$TMUX_BIN" set-option -g status-left-length 120
"$TMUX_BIN" set-option -g status-left "#[bg=default,fg=default,bold]#{?client_prefix,,${badge}}#[bg=#e6c384,fg=#1f1f28,bold]#{?client_prefix,${badge},}#[bg=default,fg=default,bold] "

# --- window pills (set here so the rounded-cap + zoom glyphs stay strip-safe) -
# Content is byte-identical to the crash-safe pure-format version — NO #() ever.
# The command label is the same #{?m:...} chain used in automatic-rename-format.
WLABEL="#{?#{m:[0-9]*,#{pane_current_command}},claude,#{?#{m:codex*,#{pane_current_command}},codex,#{pane_current_command}}}"
# idle windows: soft filled card (#2a2a37, one step above bg — caps blend to a clean rounded rect)
wsf="#[fg=#2a2a37]${LCAP}#[bg=#2a2a37 fg=#dcd7ba] #I│${WLABEL}│#{b:pane_current_path} #[bg=default fg=#2a2a37]${RCAP}"
# active window: filled gold rounded pill (matches the badge pills), zoom flag when zoomed
wscf="#[fg=#e6c384]${LCAP}#[bg=#e6c384 fg=#1f1f28] #I│${WLABEL}│#{b:pane_current_path} #{?window_zoomed_flag, ${ZOOM} ,}#[bg=default fg=#e6c384]${RCAP}"
# CRITICAL: the minimal-tmux-status plugin sets window-status-format from this option,
# and its DEFAULT is the dangerous #(ps|grep|sed) ssh fork that crashed tmux. Setting
# it here means the plugin bakes OUR safe rounded card instead — no dangerous default
# is ever applied, even for the instant before the direct set-option below lands.
"$TMUX_BIN" set-option -g @minimal-tmux-window-status-format "$wsf"
"$TMUX_BIN" set-option -gw window-status-format "$wsf"
"$TMUX_BIN" set-option -gw window-status-current-format "$wscf"
