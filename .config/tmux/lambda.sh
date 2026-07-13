#!/usr/bin/env bash
# lambda.sh (λ) -- crash-proof, high-fidelity tmux persistence for the DEFAULT server, plus the
# status-bar λ chip (save-freshness heartbeat + machine uptime).
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

# cpu_load_9: current CPU load as a single 0-9 digit -- the 1-min loadavg normalized to cores, where
# 0 = idle and 9 = fully loaded or oversubscribed (>= 1.0 runnable per core, back off). A compact load
# meter. Cheap (sysctl); safe to read live each render. Distinct from memory risk (that is (N)'s colour).
cpu_load_9() {
	sysctl -n vm.loadavg 2>/dev/null | awk -v n="$(sysctl -n hw.logicalcpu 2>/dev/null || echo 8)" \
		'{ d = ($2 / n) * 9; if (d > 9) d = 9; printf "%d", d + 0.5 }'
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

# grad: smooth colour at position p across [0,pmax] through ordered anchor hexes (>=2). Pure integer
# math, result via printf -v (global _G, NO subshell) -- a perfectly smooth gradient costs no more than
# a hard step and adds zero forks. Drives the gold->rose->purple frame and the dim-gray->red dials.
grad() {   # $1=p $2=pmax ; $3.. anchors -> sets _G
	local p=$1 pmax=$2; shift 2
	local -a k=( "$@" ); local segs=$(( ${#k[@]} - 1 ))
	[ "$pmax" -le 0 ] && pmax=1
	[ "$p" -lt 0 ] && p=0; [ "$p" -gt "$pmax" ] && p=$pmax
	local seg=$(( p * segs / pmax )); [ "$seg" -ge "$segs" ] && seg=$(( segs - 1 ))
	local lo=$(( seg * pmax / segs )) hi=$(( (seg + 1) * pmax / segs ))
	(( hi > lo )) || hi=$(( lo + 1 ))   # total-function guard: never divide by zero if pmax < segments
	local t=$(( (p - lo) * 1000 / (hi - lo) )) a=${k[$seg]} b=${k[$((seg + 1))]}
	printf -v _G '#%02x%02x%02x' \
		$(( 16#${a:1:2} + (16#${b:1:2} - 16#${a:1:2}) * t / 1000 )) \
		$(( 16#${a:3:2} + (16#${b:3:2} - 16#${a:3:2}) * t / 1000 )) \
		$(( 16#${a:5:2} + (16#${b:5:2} - 16#${a:5:2}) * t / 1000 ))
}


# chip: the breathing save-timer for the status bar (right of the animal), rendered as `λ(N)(U)` -- a
# lambda whose colour IS the save freshness, applied to the count of dangerous (heavy) processes it's
# guarding against. Read-only and CHEAP: it renders each status tick (status-interval 30) + on activity
# and forks nothing heavy. Freshness is the last real save's `epoch` from telemetry, NOT `last`'s mtime
# (resurrect freezes `last` on a static layout while saves keep succeeding, so mtime would look falsely
# stale). Healthy = the λ frame sweeps smoothly from a deep Kanagawa blue "just saved" to a grape purple
# as the next save comes "due", breathing all the while (capped, never a pale wash); a save that's late
# or FAILED turns the whole frame loud red and prefixes the human age, so the silent 4-day gap that cost
# everything can never look healthy. The (N) danger count is read straight from telemetry (the save loop
# computes it once per save), never recomputed here -- keeping the redraw free of a `ps -Ao`.
# Curried fields λ(Nᵖ)(Uᵀ)(Lᴸ), each value carrying a superscript unit: Nᵖ = heavy-process count (colour
# = memory-crash risk), Uᵀ = uptime in mach Teraticks (mach ticks / 10^12, floored to min 1 so a fresh
# boot reads 1ᵀ not 0), Lᴸ = CPU Load 0-9 (1-min loadavg normalized to cores, 9 = at/over capacity). The
# three values share one monochrome dim-gray -> red ramp; only they carry it, the frame stays gold/purple.
# All colour math is pure integer + printf -v (grad/breathe set _G, no subshell) so smoothness is free.
# Display-only; boottime + loadavg via cheap sysctls, so the save path is untouched.
mode_chip() {
	local line epoch interval result risk heavy now age lcolor ncolor lead="" _G
	local -a f
	# shared palette: the frame swings gold (each save) -> deep rose -> deep royal purple (midpoint),
	# cosine-eased -- the rose bridge keeps the sweep saturated so it NEVER desaturates to a pale/white mid
	# Ghostty's `minimum-contrast = 3` force-brightens any fg below ~3:1 contrast vs the dark bar to WHITE,
	# so EVERY colour here is kept ABOVE that floor (luminance >= ~130) -- nothing can be dim/dark or it
	# flips white (that was the whole "still white" saga). The frame swings Kanagawa GOLD (each save,
	# matching the badge's prefix-gold) through sakuraPink to oniViolet (midpoint) -- a sunset that stays
	# colourful, never muddy; dials are a muted violet-gray -> red ramp (calm when safe, red on trouble).
	local FGOLD='#e6c384' FBRIDGE='#d27e99' FVIOLET='#957fb8' GRAY='#8a86a0' RED='#ff5d62'
	line="$(tail -n 5 "$LOG" 2>/dev/null | grep -v '"result":"skip"' | tail -1)"
	if [ -z "$line" ]; then printf '#[fg=#e82424]\xce\xbb never#[default]'; return; fi
	read -r -a f <<< "$(printf '%s' "$line" | sed -E 's/.*"epoch":([0-9]+),"interval":([0-9]+),"result":"([a-z]+)".*"risk":(-?[0-9]+),"heavy":([0-9]+).*/\1 \2 \3 \4 \5/')"
	epoch=${f[0]:-0}; interval=${f[1]:-180}; result=${f[2]:-none}; risk=${f[3]:-0}; heavy=${f[4]:-0}
	now=$(date +%s); age=$(( now - epoch ))

	# machine uptime for the curried λ(N)(U) group: seconds since boot, coloured by "too long".
	# boottime read fork-light -- one sysctl + pure param-expansion (no sed), keeping the tick cheap.
	local bt up ucolor="" ustr=""
	bt=$(sysctl -n kern.boottime 2>/dev/null); bt=${bt#*sec = }; bt=${bt%%,*}
	if [ -n "$bt" ] && [ "$bt" -gt 0 ] 2>/dev/null && [ "$now" -gt "$bt" ]; then
		up=$(( now - bt ))
		# U = mach_absolute_time in TERATICKS -- the machine's own monotonic tick counter (mach ticks =
		# up x hw.tbfrequency, ~24MHz on Apple Silicon), scaled by 10^12. The truest machine clock; a pure
		# number that climbs (~1 per 11.6h at 24MHz), 3 digits up to ~482 days. Colour ramps dim gray ->
		# red by days-up (a reboot nudge), shared with the N/L dials; clamps full red past 21d.
		local tbf tt; tbf=$(sysctl -n hw.tbfrequency 2>/dev/null || echo 1000000000)
		grad "$(( up / 86400 ))" 21 "$GRAY" "$RED"; ucolor=$_G
		tt=$(( up * tbf / 1000000000000 )); (( tt < 1 )) && tt=1   # min 1: under a teratick still reads 1ᵀ
		ustr="${tt}"$'\xe1\xb5\x80'                                # teraticks + superscript T (Tera/trillion)
	fi

	# third curried field: live CPU load as a 0-9 digit ("current load", 1-min loadavg normalized to
	# cores; 9 = at/over capacity -> back off). CPU axis only; memory/crash risk is (N)'s colour.
	local ld pcolor pstr
	ld=$(cpu_load_9); [ -n "$ld" ] || ld=0
	grad "$ld" 9 "$GRAY" "$RED"; pcolor=$_G
	pstr="${ld}"$'\xe1\xb4\xb8'   # load digit + superscript L (load)

	# The frame timer: a raised-cosine swing from Kanagawa gold (each save) through sakuraPink to oniViolet
	# (the moment furthest from any save), driven by the real save phase -- so it eases gold -> purple
	# -> gold with NO snap, once per ~3-min save cycle. No manufactured oscillator: the save clock IS
	# the rhythm; the cosine is only the easing. Pure integer LUT, fork-free.
	local LAMBDA=$'\xce\xbb'   # U+03BB -- the save heartbeat; frame colour = the save timer
	# lcolor = the lambda/frame colour; lead = an optional age+! shown ONLY when a save is late/failed.
	if   [ "$result" = "fail" ];                       then lcolor="#e82424"; lead="#[fg=#e82424]!$(human_age "$age") #[default]"
	elif [ "$epoch" -le 0 ] || [ "$interval" -le 0 ];  then lcolor="#e82424"; lead="#[fg=#e82424]never #[default]"
	elif [ "$age" -le $(( interval + interval / 4 )) ]; then                                    # healthy -- gold<->purple swing
		# grace = interval/4: the loop sleeps `interval` AFTER each save, so the true period is
		# interval + save-time + jitter (~189s for 180s). COS[k] = (1-cos(2π·k/24))·500 = 0 at each save
		# (phase 0 & interval), 1000 at the midpoint. Past `interval` the index clamps to the gold end
		# (a save is due, so we hold gold rather than false-alarming).
		local -a COS=(0 17 67 146 250 371 500 629 750 854 933 983 1000 983 933 854 750 629 500 371 250 146 67 17)
		local ci=$(( age * 24 / interval )); (( ci > 23 )) && ci=23
		grad "${COS[$ci]}" 1000 "$FGOLD" "$FBRIDGE" "$FVIOLET"; lcolor=$_G
	elif [ "$age" -lt $(( interval * 2 )) ];           then lcolor="#dca561"; lead="#[fg=#dca561]$(human_age "$age") #[default]"   # a window late -- autumnYellow
	elif [ "$age" -lt $(( interval * 5 )) ];           then lcolor="#ff9e3b"; lead="#[fg=#ff9e3b]$(human_age "$age") #[default]"   # slipping -- roninYellow
	else                                                    lcolor="#ff5d62"; lead="#[fg=#ff5d62]$(human_age "$age") #[default]"   # stalled -- peachRed alarm
	fi

	# N (danger), U (uptime), L (load) share ONE monochrome ramp -- dim gray -> red (no amber). N maps
	# risk 0/1/2 across it; the λ and its parens stay the frame colour, so only the values inside change.
	grad "$risk" 2 "$GRAY" "$RED"; ncolor=$_G
	# defensive: an empty colour var would emit "#[fg=]" which tmux renders as default WHITE. If any
	# grad ever left its var blank, fall back to a valid colour so the chip can NEVER flash white.
	: "${lcolor:=$FVIOLET}" "${ucolor:=$RED}" "${pcolor:=$RED}" "${ncolor:=$RED}"
	local nstr="${heavy}"$'\xe1\xb5\x96' up_grp="" p_grp=""   # heavy count + superscript p (processes)
	[ -n "$ustr" ] && up_grp="#[fg=${lcolor}](#[fg=${ucolor}]${ustr}#[fg=${lcolor}])"
	p_grp="#[fg=${lcolor}](#[fg=${pcolor}]${pstr}#[fg=${lcolor}])"
	printf '%s#[fg=%s]%s(#[fg=%s]%s#[fg=%s])%s%s#[default]' "$lead" "$lcolor" "$LAMBDA" "$ncolor" "$nstr" "$lcolor" "$up_grp" "$p_grp"
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

	local start rc=0 dur windows panes count newtxt newfile snap_ts verify="ok" risk heavy
	local interval="${SAVE_INTERVAL:-$SAVE_INTERVAL_DEFAULT}"   # recorded so the chip fades over the real window
	start=$(date +%s)
	mkdir -p "$(dirname "$SAVE_ERR")"
	"$SAVE_SCRIPT" quiet >/dev/null 2>"$SAVE_ERR" || rc=$?
	dur=$(( $(date +%s) - start ))

	# VERIFY the RESTORE TARGET is good -- that is what actually protects you. save.sh can exit 0 yet
	# leave an empty snapshot (the silent failure that cost us 4 days), so we validate `last` directly:
	#   1. `last` points at a non-empty file...
	#   2. ...holding real `pane` records.
	# We deliberately do NOT require a fresh timestamped file each run: resurrect DELETES the new dump
	# when the layout is unchanged (save_all's `files_differ` -> rm), a legitimate no-op success -- the
	# existing `last` is still the correct, current restore target. Demanding a per-run file false-
	# reddened every static-layout save (reproduced: "save-not-written" with a valid 13-pane `last`).
	# Protection freshness is tracked by `epoch` (the chip's fade), not by whether a file was written.
	newtxt="$(readlink "${RESURRECT_DIR}/last" 2>/dev/null || true)"
	newfile="${RESURRECT_DIR}/${newtxt}"
	if [ "$rc" -eq 0 ]; then
		if   [ -z "$newtxt" ] || [ ! -s "$newfile" ]; then rc=1; verify="no-snapshot"
		elif ! grep -q '^pane' "$newfile";            then rc=1; verify="empty-snapshot"
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
