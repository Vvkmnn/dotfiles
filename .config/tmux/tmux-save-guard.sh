#!/usr/bin/env bash
# tmux-save-guard.sh -- crash-proof, high-fidelity tmux persistence for the DEFAULT server.
#
# WHY: tmux keeps ZERO on-disk state; a server death loses every session. tmux-continuum's
# autosave silently disarms whenever ANOTHER tmux server exists (e.g. `tmux -L` sockets from
# the isolate-tmux skill) -- that disarmed our autosave for 4 days and a crash lost everything
# (vBookAirM3, 2026-07-11: a full memory-storm crash with no fresh snapshot to restore from).
# This runs from launchd on a fixed interval, independent of tmux status redraws and of
# continuum's server-count logic, so it can NEVER be silently disabled again.
#
# FIDELITY: tmux-resurrect already captures full scrollback + window/pane layout + running
# processes + nvim sessions. Its one weakness is a single shared pane_contents.tar.gz that it
# overwrites each save -- so older snapshots lose their captured text. We fix that by keeping a
# per-save copy (pane_contents_<ts>.tar.gz) beside each snapshot, making every backup a
# self-contained, fully-restorable duplicate. Retention keeps the newest $KEEP.
#
# Modes:
#   save  (default)  guarded resurrect save + per-save pane-content backup + retention + telemetry.
#   chip             print "age|count" for the status bar (right of @random_animal), colored.
#
# GUARD: never save when the default server has no real session -- resurrect's save.sh would
# write an EMPTY snapshot and clobber `last`, recreating the exact silent-loss failure.

set -euo pipefail

# launchd and tmux's #() both exec with a minimal/empty PATH. Pin one so neither a save nor the
# status chip can ever silently die on "command not found" (date/stat/grep/cp/rm all live here).
export PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# launchd ALSO strips LANG, dropping awk/sed/grep to the C locale where they ABORT on the UTF-8
# bytes in pane scrollback (emoji, box-drawing chars) -- resurrect's save.sh then silently writes a
# 0-pane EMPTY snapshot. VERIFIED: env -i save.sh = 0 panes captured; +LANG = all 12. Pin a UTF-8
# locale so an automated launchd save captures the exact same full state an interactive save does.
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

# HOME too can be stripped from the exec env; under set -u that would kill the chip/save outright.
# The script always lives at $HOME/.config/tmux/, so recover HOME from its own path -- correct on
# any fleet machine regardless of username, never a wrong guess that could misplace the snapshots.
if [ -z "${HOME:-}" ]; then HOME="$(cd -- "$(dirname -- "$0")/../.." && pwd)" && export HOME; fi

readonly TMUX_BIN="/opt/homebrew/bin/tmux"
readonly RESURRECT_DIR="${HOME}/.local/share/tmux/resurrect"
readonly SAVE_SCRIPT="${HOME}/.config/tmux/plugins/tmux-resurrect/scripts/save.sh"
readonly LOG="${HOME}/.local/state/tmux-save/save.jsonl"
readonly SAVE_ERR="${HOME}/.local/state/tmux-save/save.stderr.log"  # last save.sh stderr, overwritten each run -- the LANG-empty-snapshot bug hid here because we were >/dev/null'ing it
readonly KEEP=33     # self-contained high-fidelity backups retained (only distinct states kept)
# The (N) gauge counts EVERY heavy process (RSS >= this), not just our agents -- claude, codex, a
# ballooned node/MCP child, a browser, a build, anything that can drive the machine into the swap
# storm that killed it. 100MB is an absolute "heavy" cut that holds across the 8-24GB fleet.
readonly HEAVY_KB=102400   # 100 MiB
# The save loop's cadence. 3 min is ample: a snapshot only holds LAYOUT + scrollback -- the actual
# Claude work is persisted continuously by Claude to its session JSONL and restored via `claude
# --resume` regardless of snapshot age, and the crash itself is prevented by tmux >=3.7. So a stale
# snapshot costs at most re-opening a window created since the last save. Cost ~0.15 CPU-sec/180s =
# 0.08% of a core, ~480 tiny writes/day -- CPU idles between saves, zero battery impact. Gentle on the
# 8-24GB fleet; env-overridable per machine. The chip fades over exactly this window (read from
# telemetry), so the 7s-refresh dot breathes across the real 3-minute save cycle and stays truthful.
readonly SAVE_INTERVAL_DEFAULT=180   # 3 minutes

snapshot_age_s() {
	local target="${RESURRECT_DIR}/last" mtime
	[ -e "$target" ] || { echo -1; return; }
	mtime=$(stat -f %m "$target" 2>/dev/null) || { echo -1; return; }
	echo $(( $(date +%s) - mtime ))
}

human_age() {
	local s="$1"
	if   [ "$s" -lt 0 ];     then echo "never"
	elif [ "$s" -lt 60 ];    then echo "${s}s"
	elif [ "$s" -lt 3600 ];  then echo "$(( s / 60 ))m"
	elif [ "$s" -lt 86400 ]; then echo "$(( s / 3600 ))h"
	else                          echo "$(( s / 86400 ))d"
	fi
}

snapshot_count() {
	# shellcheck disable=SC2012  # macOS find lacks -printf; ls -t is the pragmatic sort
	ls "${RESURRECT_DIR}"/tmux_resurrect_*.txt 2>/dev/null | wc -l | tr -d ' '
}

# ram_gb: this machine's physical RAM in GiB -- fleet-portable, drives RAM-scaled thresholds so an
# 8GB neo warns far earlier than a 24GB box. Fallback 16 if sysctl is somehow unavailable.
ram_gb() { echo $(( $(sysctl -n hw.memsize 2>/dev/null || echo 17179869184) / 1073741824 )); }

# heavy_count: how many processes hold >= HEAVY_KB resident -- the magnitude the (N) gauge shows.
# Not just our agents: claude, codex, a runaway node child, a browser, a build all count.
heavy_count() { ps -Ao rss= 2>/dev/null | awk -v k="$HEAVY_KB" '$1>=k{c++} END{print c+0}'; }

# mem_pressure: the kernel's own verdict (kern.memorystatus_vm_pressure_level: 1 ok / 2 warn / 4 crit).
mem_pressure() { sysctl -n kern.memorystatus_vm_pressure_level 2>/dev/null || echo 1; }

# swap_pct: swap fill as an integer percent -- THE leading indicator of the crash. The storm was
# swap creeping to ~96% over days while live RSS stayed ~8GB; count never moved, swap did. Parse
# vm.swapusage's "used = N.NNM ... total = N.NNM" (tokens: name, "=", value) and divide.
swap_pct() {
	sysctl -n vm.swapusage 2>/dev/null | awk '{
		for (i = 1; i <= NF; i++) { if ($i == "used") u = $(i+2); if ($i == "total") t = $(i+2) }
		gsub(/M/, "", u); gsub(/M/, "", t)
		if (t + 0 > 0) printf "%d", u * 100 / t; else print 0
	}'
}

# risk_level: single crash-risk verdict 0=ok 1=warn 2=crit -- the WORST of three real signals so no
# one stale reading hides danger: heavy-proc count vs RAM-scaled thresholds (warn GB/2, crit
# round(11*GB/16), anchored to the 11-proc storm on 16GB), kernel pressure, and swap fill. Prints
# "level count" so the chip shows the magnitude and colours it by true danger in one cheap pass.
risk_level() {
	local gb warn crit n press sp lc=0 lp=0 ls=0 level
	gb=$(ram_gb); warn=$(( gb / 2 )); crit=$(( (11 * gb + 8) / 16 ))
	n=$(heavy_count); press=$(mem_pressure); sp=$(swap_pct)
	if   [ "$n" -ge "$crit" ];   then lc=2; elif [ "$n" -ge "$warn" ];   then lc=1; fi
	if   [ "$press" -ge 4 ];     then lp=2; elif [ "$press" -ge 2 ];     then lp=1; fi
	if   [ "$sp" -ge 90 ];       then ls=2; elif [ "$sp" -ge 70 ];       then ls=1; fi
	level=$lc
	[ "$lp" -gt "$level" ] && level=$lp
	[ "$ls" -gt "$level" ] && level=$ls
	echo "$level $n"
}

# last_result: result of the most recent REAL save attempt (skips are benign, not failures).
# Drives the chip's ! -- so a failed/unverified save shouts even while the age still looks fresh.
last_result() {
	[ -s "$LOG" ] || { echo none; return; }
	local line
	line="$(grep -v '"result":"skip"' "$LOG" 2>/dev/null | tail -1)"
	case "$line" in
		*'"result":"fail"'*) echo fail ;;
		*'"result":"ok"'*)   echo ok ;;
		*)                   echo none ;;
	esac
}

# breathe_color: gentle luminance swell around a base hex on a ~28s triangle cycle, so the healthy
# fisheye visibly breathes in/out at each 7s repaint on top of the slow hue fade. Brightness rides
# 85%->115%->85%; the freshest (brightest) colour breathes most, the dim "due" end least -- a natural
# "more alive when fresh" feel. Pure integer math + one printf; safe to call on every status redraw.
breathe_color() {
	local hx="$1" now="$2" t tri bf r g b
	t=$(( now % 28 )); [ "$t" -lt 14 ] && tri=$t || tri=$(( 28 - t ))   # 0..14..0 triangle wave
	bf=$(( 85 + tri * 30 / 14 ))                                        # 85..115..85 brightness %
	r=$(( 16#${hx:1:2} * bf / 100 )); g=$(( 16#${hx:3:2} * bf / 100 )); b=$(( 16#${hx:5:2} * bf / 100 ))
	[ "$r" -gt 255 ] && r=255; [ "$g" -gt 255 ] && g=255; [ "$b" -gt 255 ] && b=255
	printf '#%02x%02x%02x' "$r" "$g" "$b"
}

# chip: the breathing save-timer for the status bar (right of the animal), rendered as `λ(N)` -- a
# lambda whose colour IS the save freshness, applied to the count of dangerous (heavy) processes it's
# guarding against. Read-only and CHEAP: it renders each status tick (status-interval 15) + on activity
# and forks nothing heavy. Freshness is the last real save's `epoch` from telemetry, NOT `last`'s mtime
# (resurrect freezes `last` on a static layout while saves keep succeeding, so mtime would look falsely
# stale). Healthy = the λ pulses bright crystalBlue the instant a save lands and fades cool
# (blue->violet->comet dim) across the save interval, breathing all the while; a save that's late or
# FAILED verification turns λ loud (red/amber) and prefixes the human age, so the silent 4-day gap that
# cost everything can never look healthy. The (N) danger count is read straight from telemetry (the save
# loop computes it once per save), never recomputed here -- keeping the redraw free of a `ps -Ao`.
mode_chip() {
	local line epoch interval result risk heavy now age idx lcolor ncolor lead="" n_fade
	local -a f
	line="$(tail -n 5 "$LOG" 2>/dev/null | grep -v '"result":"skip"' | tail -1)"
	if [ -z "$line" ]; then printf '#[fg=#e82424]\xce\xbb never#[default]'; return; fi
	read -r -a f <<< "$(printf '%s' "$line" | sed -E 's/.*"epoch":([0-9]+),"interval":([0-9]+),"result":"([a-z]+)".*"risk":(-?[0-9]+),"heavy":([0-9]+).*/\1 \2 \3 \4 \5/')"
	epoch=${f[0]:-0}; interval=${f[1]:-180}; result=${f[2]:-none}; risk=${f[3]:-0}; heavy=${f[4]:-0}
	now=$(date +%s); age=$(( now - epoch ))

	# Kanagawa Wave breathing gradient: crystalBlue "just saved" pulse -> oniViolet mid -> comet dim
	# "due". The lambda fades across the FULL save interval, and its luminance breathes (breathe_color)
	# so it mirrors real save freshness -- information, not decor. Cool blue/violet, never green.
	local -a fade=( '#7e9cd8' '#7d94cc' '#7e8cc0' '#8a82ba' '#957fb8' '#8574a4' '#726690' '#615c7e' '#54536d' )
	local LAMBDA=$'\xce\xbb'   # U+03BB -- the save heartbeat; colour = freshness, (N) = its argument
	n_fade=${#fade[@]}
	# lcolor = the lambda's colour (freshness/alarm); lead = an optional age+! shown ONLY when unhealthy.
	if   [ "$result" = "fail" ];                       then lcolor="#e82424"; lead="#[fg=#e82424]!$(human_age "$age") #[default]"
	elif [ "$epoch" -le 0 ] || [ "$interval" -le 0 ];  then lcolor="#e82424"; lead="#[fg=#e82424]never #[default]"
	elif [ "$age" -le $(( interval + interval / 4 )) ]; then                                    # healthy -- breathing λ, no lead
		# grace = interval/4: the loop sleeps `interval` AFTER each save completes, so the true
		# period is interval + save-time + jitter (~189s for a 180s interval). Without this margin λ
		# flashed amber for those few seconds every single cycle -- a false "late". Fade still clamps
		# to dim comet past `interval`, so 100%-125% of the window holds "due" until the save lands.
		idx=$(( age * (n_fade - 1) / interval )); [ "$idx" -ge "$n_fade" ] && idx=$(( n_fade - 1 ))
		lcolor="$(breathe_color "${fade[$idx]}" "$now")"
	elif [ "$age" -lt $(( interval * 2 )) ];           then lcolor="#dca561"; lead="#[fg=#dca561]$(human_age "$age") #[default]"   # a window late -- autumnYellow
	elif [ "$age" -lt $(( interval * 5 )) ];           then lcolor="#ff9e3b"; lead="#[fg=#ff9e3b]$(human_age "$age") #[default]"   # slipping -- roninYellow
	else                                                    lcolor="#ff5d62"; lead="#[fg=#ff5d62]$(human_age "$age") #[default]"   # stalled -- peachRed alarm
	fi

	# The dangerous-process gauge is the NUMBER only (heavy RSS count), Kanagawa: comet dim safe ->
	# carpYellow warn -> peachRed "too risky to pile on". The λ and its parens share the freshness
	# colour (one save unit); only the count inside is risk-coloured -- so λ( and ) read as one glyph
	# and the number is the single thing that changes on danger: λ(N).
	case "$risk" in
		2) ncolor="#ff5d62" ;;
		1) ncolor="#e6c384" ;;
		*) ncolor="#54536d" ;;
	esac
	printf '%s#[fg=%s]%s(#[fg=%s]%s#[fg=%s])#[default]' "$lead" "$lcolor" "$LAMBDA" "$ncolor" "$heavy" "$lcolor"
}

log_line() { mkdir -p "$(dirname "$LOG")"; printf '%s\n' "$1" >> "$LOG"; }

ts_of_txt() { local n="${1##*/}"; n="${n#tmux_resurrect_}"; echo "${n%.txt}"; }

# retention: keep newest $KEEP snapshots + their per-save pane_contents; delete older pairs.
prune() {
	local old ots
	# shellcheck disable=SC2012
	ls -t "${RESURRECT_DIR}"/tmux_resurrect_*.txt 2>/dev/null | tail -n +"$(( KEEP + 1 ))" \
		| while IFS= read -r old; do
			ots="$(ts_of_txt "$old")"
			rm -f "$old" "${RESURRECT_DIR}/pane_contents_${ots}.tar.gz"
		done
}

# ensure_last_valid: guarantee `last` points at a RESTORABLE snapshot. Self-heals a dangling or
# clobbered symlink (e.g. a rare same-second save collision) by repointing to the newest file
# that still holds real pane records -- so restore is never left with nothing to load.
ensure_last_valid() {
	local f newest=""
	# filenames are tmux_resurrect_<ISO-ts>.txt, so lexical order == chronological -- glob ascending
	# and keep the LAST valid match (the newest good snapshot).
	for f in "${RESURRECT_DIR}"/tmux_resurrect_*.txt; do
		[ -e "$f" ] || continue                                  # no matches -> literal glob, skip
		{ [ -s "$f" ] && grep -q '^pane' "$f"; } && newest="$f"
	done
	[ -n "$newest" ] || return 1
	ln -sf "${newest##*/}" "${RESURRECT_DIR}/last"
}

# save: the crash-survivor. guarded, high-fidelity, self-contained backups, logged.
mode_save() {
	unset TMUX  # target the default socket, not any caller's server
	local ts sessions
	ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)

	sessions=$("$TMUX_BIN" list-sessions 2>/dev/null | wc -l | tr -d ' ')
	if [ "${sessions:-0}" -eq 0 ]; then
		log_line "{\"ts\":\"$ts\",\"result\":\"skip\",\"reason\":\"no-session\"}"
		return 0
	fi

	local start rc=0 dur windows panes count newtxt newfile newest _f snap_ts verify="ok" risk heavy
	local interval="${SAVE_INTERVAL:-$SAVE_INTERVAL_DEFAULT}"   # recorded so the chip fades over the real window
	start=$(date +%s)
	mkdir -p "$(dirname "$SAVE_ERR")"
	"$SAVE_SCRIPT" quiet >/dev/null 2>"$SAVE_ERR" || rc=$?
	dur=$(( $(date +%s) - start ))

	# VERIFY the save actually landed. save.sh can exit 0 yet leave an empty snapshot -- the
	# precise silent failure that cost us 4 days. Two independent checks:
	#   1. `last` (the restore target) points at a non-empty file holding real `pane` records.
	#   2. save.sh WROTE a fresh timestamped file THIS run (proves it actually executed).
	# We check freshness on the newest written file, NOT on `last`: resurrect only re-points
	# `last` when the snapshot CHANGED (save_all's `files_differ` guard). An unchanged layout
	# leaves `last` at a still-valid older file -- correct behaviour, not a failure. Checking
	# `last`'s mtime here false-flagged every no-change save as "stale" (verified: tmux#files_differ).
	newtxt="$(readlink "${RESURRECT_DIR}/last" 2>/dev/null || true)"
	newfile="${RESURRECT_DIR}/${newtxt}"
	newest=""  # timestamped filenames sort lexically == chronologically; last match is newest
	for _f in "${RESURRECT_DIR}"/tmux_resurrect_*.txt; do [ -e "$_f" ] && newest="$_f"; done
	if [ "$rc" -eq 0 ]; then
		if   [ -z "$newtxt" ] || [ ! -s "$newfile" ];                                   then rc=1; verify="no-snapshot"
		elif ! grep -q '^pane' "$newfile";                                              then rc=1; verify="empty-snapshot"
		elif [ -z "$newest" ] || [ "$(stat -f %m "$newest" 2>/dev/null || echo 0)" -lt "$start" ]; then rc=1; verify="save-not-written"
		fi
	fi

	# a failed save must never leave `last` dangling -- repoint to the newest good snapshot so a
	# crash right now still restores from the last verified one.
	[ "$rc" -ne 0 ] && ensure_last_valid || true

	# preserve THIS save's verified pane contents (resurrect overwrites the shared file each save)
	if [ "$rc" -eq 0 ] && [ -f "${RESURRECT_DIR}/pane_contents.tar.gz" ]; then
		snap_ts="$(ts_of_txt "$newtxt")"
		cp "${RESURRECT_DIR}/pane_contents.tar.gz" "${RESURRECT_DIR}/pane_contents_${snap_ts}.tar.gz"
	fi

	windows=$("$TMUX_BIN" list-windows -a 2>/dev/null | wc -l | tr -d ' ')
	panes=$("$TMUX_BIN" list-panes -a 2>/dev/null | wc -l | tr -d ' ')
	prune
	count=$(snapshot_count)
	# Compute the crash-risk gauge HERE (once per save), not in the chip: the chip renders every
	# second for the breathing timer, and forking `ps -Ao` every second across the fleet is the
	# cost we refuse to pay. The chip reads risk/heavy straight from this telemetry line instead.
	read -r risk heavy < <(risk_level)

	# `epoch` = the save's start second. The chip derives freshness from THIS, never from `last`'s
	# mtime: resurrect only re-points `last` when the layout changed (files_differ), so on a static
	# layout `last` stops advancing while saves keep succeeding -- epoch is the honest "last save" clock.
	log_line "{\"ts\":\"$ts\",\"epoch\":$start,\"interval\":$interval,\"result\":\"$( [ "$rc" -eq 0 ] && echo ok || echo fail )\",\"rc\":$rc,\"verify\":\"$verify\",\"risk\":$risk,\"heavy\":$heavy,\"sessions\":$sessions,\"windows\":$windows,\"panes\":$panes,\"dur_s\":$dur,\"snapshots\":$count}"
	return "$rc"
}

# loop: the resident 7-second saver. launchd keeps ONE of these alive (KeepAlive); it saves, sleeps
# SAVE_INTERVAL, repeats -- so the crash-recovery floor is ~7s of layout, and the status-bar timer has
# a real save event to pulse on every cycle. SAVE_INTERVAL is env-overridable per machine (an 8GB neo
# under load can widen it) but defaults to 7. One save failing never kills the loop (`|| true`).
mode_loop() {
	local interval="${SAVE_INTERVAL:-$SAVE_INTERVAL_DEFAULT}"
	while :; do
		mode_save || true
		sleep "$interval"
	done
}

case "${1:-save}" in
	chip) mode_chip ;;
	save) mode_save; exit $? ;;
	loop) mode_loop ;;
	*) echo "usage: ${0##*/} {save|loop|chip}" >&2; exit 2 ;;
esac
