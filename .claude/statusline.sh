#!/bin/bash
# statusline.sh v4 (2026-11-03) — one row, every value from the stdin JSON Claude Code sends; render_v4 at
# the end is the live renderer, the v3 superscript line documented here stays behind CLAUDE_STATUSLINE_STYLE=v3.
#
# ॐ Fᵀˣ ψ 51¹ᴹ·94 λ 40⁰·⁸ʰ 30⁻³ʰ σ 2h⁴⁰ π main⁺⁴⁵⁻¹² #1234 $12.3
# │ │   │          │                │      │               │     └ $ session API-equivalent (dim)
# │ │   │          │                │      │               └ #PR, colored by review state
# │ │   │          │                │      │                 (blue approved · orange pending · red changes · gray draft)
# │ │   │          │                │      └ π branch or worktree name · ⁺inserted ⁻deleted lines (repos only)
# │ │   │          │                └ σ session elapsed · superscript = % of it spent waiting on the API
# │ │   │          └ λ 5h used% ⁰·⁸ʰ time to reset · 7d used% ⁻²ᵈ runs out 2 days BEFORE the reset at the current burn
# │ │   │            (⁺ = slack past the reset; hours ahead/behind the on-pace line until 15 min of samples exist)
# │ │   └ ψ context % (¹ᴹ = 1M window) · ·94 = cache hit % dim (· warm, ○ cold)
# │ └ model letter F/O/S/H · ᵀ thinking · effort ᴹ max ˣ xhigh ⁺ high ⁻ low · ᶠ fast mode · @name as an agent
# └ ॐ anchor: RED = this pane is waiting on you (tmux pane option @claude_waiting, set by
#   hooks/notification.js, cleared by hooks/user-prompt-submit.js); otherwise vim state:
#   orange INSERT (typing = resting default), blue NORMAL / vim off, gold VISUAL.
#
# Colors (Kanagawa Wave): ψ orange 60–80, red >80 · 5h orange 70–90, red >90 · 7d orange 50–75, red >75 ·
# λ severity = worst of: threshold, pace (5h only: used share ÷ elapsed share, >1.0 orange, >1.5 red),
# and burn rate (slope of the last 6 h of samples: red if 100 % lands before the reset, orange if
# within ORANGE_MARGIN of it; the 7d window uses threshold + burn only). The whole λ group takes that color; red adds a trailing "!". Owner 2026-10-15:
# a single orange number was invisible, and cumulative pace hid a burst after quiet days.
#
# Sources: stdin only (rate_limits, prompt_cache, cost, context_window, worktree, pr, effort, thinking,
# vim, fast_mode, agent) + git for π + one tmux option for the waiting flag. No network, no cache
# files, no state on disk. The v2 script (curl to /api/oauth/usage, TTL caches, strikethrough) is
# backups/statusline.sh.20261013.bak; its reason ended when Claude Code started sending rate_limits
# on stdin (feature request #19385). Budget: < 100 ms; one jq pass, one git call.
set -o pipefail
shopt -s extglob   # render_v4 strips colour codes with an extglob pattern; it must be on before the parse
case "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" in *UTF-8*|*utf8*) ;; *) export LC_CTYPE=en_US.UTF-8 ;; esac   # cell counting of glyphs
command -v jq >/dev/null 2>&1 || { printf 'ॐ Claude\n'; exit 0; }

# `statusline.sh demo [columns]`: every state of the live line, in this terminal, before you trust it.
# Synthetic payloads go through the real renderer; the waiting count is pinned ("0:" = none) so the live
# tmux flags can never leak into a demo. Runs before stdin is read, so it never blocks.
if [ "${1:-}" = demo ]; then
	self="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"; t=$(date +%s); want="${2:-}"
	payload() { # d7 d7reset ctx warm expires recache [h5 h5reset]
		printf '{"model":{"id":"claude-fable-5-1"},"effort":{"level":"high"},"thinking":{"enabled":true},"cwd":"%s","workspace":{"current_dir":"%s"},"cost":{"total_cost_usd":273.8,"total_duration_ms":29520000,"total_lines_added":120,"total_lines_removed":34},"context_window":{"used_percentage":%s,"context_window_size":1000000},"prompt_cache":{"warm":%s,"hit_ratio":0.98,"expires_at":%s,"recache_tokens_if_cold":%s},"rate_limits":{"five_hour":{"used_percentage":%s,"resets_at":%s},"seven_day":{"used_percentage":%s,"resets_at":%s}},"vim":{"mode":"NORMAL"},"pr":{"number":1234,"review_state":"pending"}}' \
			"$HOME" "$HOME" "$3" "$4" "${5:-null}" "$6" "${7:-null}" "${8:-null}" "$1" "$2"
	}
	show() { # label columns waiting ring payload
		[ -n "$want" ] && [ "$want" != "$2" ] && return 0
		printf '\e[2m%-13s %3s\e[0m  ' "$1" "$2"
		printf '%s' "$5" | COLUMNS="$2" CLAUDE_STATUSLINE_WAITING="$3" CLAUDE_STATUSLINE_MODE="${demo_mode:-default}" CLAUDE_STATUSLINE_AGENTS="${demo_agents:-0}" CLAUDE_USAGE_RING="$4" "$self"
	}
	show quiet        140 "0:"  /dev/null     "$(payload 30 $((t + 345600)) 49 true $((t + 2280)) 45000)"
	demo_agents=3
	show waiting      140 "10:" /dev/null     "$(payload 30 $((t + 345600)) 49 true $((t + 2280)) 45000)"
	demo_agents=0
	show high         140 "0:"  /dev/null     "$(payload 85 $((t + 345600)) 49 true $((t + 2280)) 45000)"
	show running-dry  140 "0:"  /dev/null     "$(payload 81 $((t + 300000)) 62 true $((t + 2280)) 45000)"
	show cold-cache   140 "0:"  /dev/null     "$(payload 30 $((t + 345600)) 49 false "" 45000)"
	show compact-zone 140 "0:"  /dev/null     "$(payload 30 $((t + 345600)) 88 true $((t + 2280)) 45000)"
	show with-5h      140 "0:"  /dev/null     "$(payload 30 $((t + 345600)) 49 true $((t + 2280)) 45000 31 $((t + 2880)))"
	show half-screen   95 "10:" /dev/null     "$(payload 81 $((t + 300000)) 62 true $((t + 2280)) 45000)"
	show tall-window   70 "10:" /dev/null     "$(payload 81 $((t + 300000)) 62 true $((t + 2280)) 45000)"
	show small-pane    50 "10:" /dev/null     "$(payload 81 $((t + 300000)) 62 true $((t + 2280)) 45000)"
	show odd-width     63 "10:" /dev/null     "$(payload 30 $((t + 345600)) 49 true $((t + 2280)) 45000)"
	exit 0
fi

# `statusline.sh poll`: refresh the plan-usage cache from Anthropic's usage endpoint, the one `/usage` and
# ccstatusline read (undocumented). It carries what the stdin payload lacks: the Fable week and the
# credits. Runs detached from a render when the cache is older than POLL_S; one GET with Claude Code's
# own keychain token, 5 s timeout, never on the render path. Cache: regenerable state, never required.
USAGE_CACHE="${CLAUDE_USAGE_CACHE:-$HOME/.local/state/claude/usage-api.json}"; POLL_S=600   # override = selftest fixture
if [ "${1:-}" = poll ]; then
	tok=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null | jq -r '.claudeAiOauth.accessToken // empty')
	[ -n "$tok" ] || exit 0
	tmp="${USAGE_CACHE}.$$"
	code=$(curl -sS -m 5 -o "$tmp" -w '%{http_code}' -H "Authorization: Bearer $tok" -H 'anthropic-beta: oauth-2025-04-20' https://api.anthropic.com/api/oauth/usage 2>/dev/null)
	if [ "$code" = 200 ] && jq -e . "$tmp" >/dev/null 2>&1; then
		jq -c --arg t "$(date +%s)" '. + {fetched_at: ($t | tonumber)}' "$tmp" > "$tmp.2" && mv "$tmp.2" "$USAGE_CACHE"
	fi
	rm -f "$tmp" "$tmp.2"; exit 0
fi

input=$(cat)

GOLD=$'\e[38;2;230;195;132m'; BLUE=$'\e[38;2;126;156;216m'; ORANGE=$'\e[38;2;255;160;102m'
RED=$'\e[38;2;232;36;36m'; GRAY=$'\e[38;2;114;113;105m'; DIM=$'\e[2m'; R=$'\e[0m'

# Fields are joined with \x1f (unit separator), not tabs: bash `read` collapses runs of
# whitespace IFS, so an empty field (e.g. no agent name) would shift every later value.
IFS=$'\x1f' read -r model effort thinking fast agent ctx_pct ctx_size cache_hit cache_warm \
	h5_pct h5_reset d7_pct d7_reset dur_ms api_ms cost wt pr_num pr_state vim cwd <<<"$(jq -r '[
	(.model | if type == "object" then (.id // .display_name // "") else (. // "") end),
	(.effort.level // ""), (.thinking.enabled // false), (.fast_mode // false), (.agent.name // ""),
	(.context_window.used_percentage // ""), (.context_window.context_window_size // 0),
	(.prompt_cache.hit_ratio // ""), (.prompt_cache.warm | if . == null then "" else . end),
	(.rate_limits.five_hour.used_percentage // ""), (.rate_limits.five_hour.resets_at // ""),
	(.rate_limits.seven_day.used_percentage // ""), (.rate_limits.seven_day.resets_at // ""),
	(.cost.total_duration_ms // 0), (.cost.total_api_duration_ms // 0), (.cost.total_cost_usd // 0),
	(.worktree.name // .workspace.git_worktree // ""), (.pr.number // ""), (.pr.review_state // ""),
	(.vim.mode // ""), (.workspace.current_dir // .cwd // "")
] | map(tostring) | join("\u001f")' <<<"$input" 2>/dev/null)"

now=$(date +%s)

# One-shot raw capture for accuracy checks: `touch ~/.local/state/claude/dump-statusline-once`, and the
# next render writes its exact stdin to statusline-last.json and removes the trigger. No steady-state writes.
if [ -e "$HOME/.local/state/claude/dump-statusline-once" ]; then
	printf '%s\n' "$input" > "$HOME/.local/state/claude/statusline-last.json" 2>/dev/null && rm -f "$HOME/.local/state/claude/dump-statusline-once"
fi

# Superscript renderer: digits, sign, decimal point and the unit letters h/d/m.
sup() {
	printf '%s' "$1" | sed 's/0/⁰/g; s/1/¹/g; s/2/²/g; s/3/³/g; s/4/⁴/g; s/5/⁵/g; s/6/⁶/g; s/7/⁷/g; s/8/⁸/g; s/9/⁹/g; s/\./·/g; s/-/⁻/g; s/+/⁺/g; s/h/ʰ/g; s/d/ᵈ/g; s/m/ᵐ/g'
}
# Seconds → short duration: 42m / 0.8h / 6.5d
dur() {
	awk -v s="$1" 'BEGIN { if (s < 0) s = 0; if (s < 3600) printf "%dm", s / 60; else if (s < 86400) printf "%.1fh", s / 3600; else printf "%.1fd", s / 86400 }'
}
# Severity 0/1/2 → color (none / orange / red).
sev_color() { case "$1" in 2) printf '%s' "$RED" ;; 1) printf '%s' "$ORANGE" ;; *) printf '' ;; esac; }
# Threshold severity: value, orange-from, red-from
thr() { awk -v v="$1" -v o="$2" -v r="$3" 'BEGIN { print (v > r) ? 2 : (v > o) ? 1 : 0 }'; }
# Pace severity: used% vs elapsed share of a window `len` seconds long that resets at `reset`.
pace() {
	awk -v used="$1" -v reset="$2" -v now="$now" -v len="$3" 'BEGIN {
		left = reset - now; if (left < 0) left = 0; if (left > len) left = len
		el = (len - left) / len; if (el < 0.05) el = 0.05
		p = (used / 100) / el; print (p > 1.5) ? 2 : (p > 1.0) ? 1 : 0 }'
}
max() { if [ "$1" -ge "$2" ]; then printf '%s' "$1"; else printf '%s' "$2"; fi; }

# ---- λ burn-rate ring: (ts, used5h, used7d), one row a minute at most, pruned in place past RING_HOURS ----
# Data ledger under ~/.local/state/claude (regenerable; owner-approved exception to the no-state-files
# rule, 2026-10-15). Shared by every session's statusline: the values are account-wide, so any writer
# is as good as another. CLAUDE_USAGE_RING overrides the path (selftest keeps sample renders out of it).
RING="${CLAUDE_USAGE_RING:-$HOME/.local/state/claude/usage.tsv}"
RING_HOURS=12        # how much history to keep
SLOPE_WINDOW=7200    # seconds of history the burn rate is computed over (2 h: fast enough to follow a change of pace, long enough to smooth one turn; owner 2026-11-03)
MIN_SPAN=1800        # no projection until the samples span at least this (30 min: a shorter burst stretched over a week lied)
ORANGE_MARGIN=0.2    # orange when 100 % lands after the reset but within 20 % of the time left
ring_update() {
	[ -n "$h5_pct$d7_pct" ] || return 0
	mkdir -p "${RING%/*}" 2>/dev/null || return 0
	local last_ts last_d7 last_reset first_ts
	# awk, not `read` with IFS=tab: tab is whitespace to bash, so an empty 5 h column (Ultra has none)
	# collapses and the reset lands in the d7 slot; that froze the ring at the week's rollover (2026-11-04).
	IFS='|' read -r last_ts last_d7 last_reset <<<"$(tail -1 "$RING" 2>/dev/null | awk -F'\t' '{ print $1 "|" $3 "|" $4 }')"
	[ $(( now - ${last_ts:-0} )) -ge 60 ] || return 0
	# Every session on this Mac writes the ring, and an idle session keeps reporting the value frozen at
	# its last API response. Usage never falls inside one window, so a lower weekly value for the same
	# reset is that stale echo (39 % beside a live 48 % painted λ red on 2026-11-03) and is not written.
	if [ -n "$d7_pct" ] && [ -n "$last_d7" ] && [ "${last_reset:-$d7_reset}" = "$d7_reset" ] \
		&& awk -F'\t' -v n="$d7_pct" -v r="$d7_reset" '$4 == r && $3 != "" && $3 + 0 > m { m = $3 + 0 } END { exit !(n < m) }' "$RING"; then return 0; fi   # rows without a reset (pre-11-03) never vote
	printf '%s\t%s\t%s\t%s\n' "$now" "${h5_pct}" "${d7_pct}" "${d7_reset}" >> "$RING" 2>/dev/null || return 0
	first_ts=$(head -1 "$RING" | cut -f1)
	if [ $(( now - ${first_ts:-$now} )) -gt $(( RING_HOURS * 3600 + 3600 )) ]; then
		awk -F'\t' -v cut=$(( now - RING_HOURS * 3600 )) '$1 >= cut' "$RING" > "$RING.tmp" 2>/dev/null && mv "$RING.tmp" "$RING"
	fi
}
# burn <col> <used> <reset>: prints "<sev> <signed seconds>" where the seconds are (time until 100 %)
# minus (time until reset): negative = runs out before the reset. col 2 = 5h, col 3 = 7d. Only
# samples after the last reset count (walks back while usage is non-increasing backwards). Prints
# "0 +" when usage is flat or falling, nothing when fewer than MIN_SPAN seconds of samples exist.
burn() {
	[ -s "$RING" ] || return 0
	awk -F'\t' -v col="$1" -v used="$2" -v reset="$3" -v now="$now" -v win="$SLOPE_WINDOW" -v minspan="$MIN_SPAN" -v margin="$ORANGE_MARGIN" '
		$1 >= now - win && $col != "" { n++; t[n] = $1; u[n] = $col }
		END {
			if (n < 2) exit
			i = n; while (i > 1 && u[i-1] <= u[i]) i--
			span = t[n] - t[i]; if (span < minspan) exit
			slope = (u[n] - u[i]) / span
			if (slope <= 0) { print "0 +"; exit }
			left = reset - now; if (left < 0) left = 0
			tto = (100 - used) / slope
			sev = (tto < left) ? 2 : (tto < left * (1 + margin)) ? 1 : 0
			printf "%d %+d\n", sev, tto - left
		}' "$RING" 2>/dev/null
}
signed_dur() { local s="$1" sign="+"; case "$s" in -*) sign="-"; s="${s#-}" ;; +*) s="${s#+}" ;; esac; printf '%s%s' "$sign" "$(dur "$s")"; }

# ---- ॐ anchor: waiting flag beats vim state ----
waiting=""
TMUX_BIN="${CLAUDE_TMUX_BIN:-$(command -v /opt/homebrew/bin/tmux || command -v tmux)}"   # override = selftest stub
# No $TMUX guard: the footer mod's child may lack the variable while the server is there; a missing
# server fails fast and quietly. TMUX_PANE still names this pane for -p.
[ -n "$TMUX_BIN" ] && waiting=$("$TMUX_BIN" show-options -pqv @claude_waiting 2>/dev/null)
anchor="ॐ"   # always ॐ: a `?` here collided with the `? N waiting` section (owner saw two)
# The footer mod passes draft/working: the pane flag lies while you type or Claude runs, so red only when idle.
if [ "$waiting" = "1" ] && [ "${CLAUDE_STATUSLINE_STATE:-idle}" = "idle" ]; then anchor_color="$RED"
else
	case "$vim" in   # owner default = Kanagawa gold; orange while typing; blue only in VISUAL
		INSERT) anchor_color="$ORANGE" ;;
		VISUAL*) anchor_color="$BLUE" ;;
		*) anchor_color="$GOLD" ;;
	esac
fi

# ---- model · thinking · effort · fast · agent ----
case "$(printf '%s' "$model" | tr '[:upper:]' '[:lower:]')" in
	*fable*) letter="F" ;; *opus*) letter="O" ;; *sonnet*) letter="S" ;; *haiku*) letter="H" ;;
	*) letter="${model:-Claude}" ;;
esac
[ "$thinking" = "true" ] && letter="${letter}ᵀ"
case "$effort" in max) letter="${letter}ᴹ" ;; xhigh) letter="${letter}ˣ" ;; high) letter="${letter}⁺" ;; low) letter="${letter}⁻" ;; esac
[ "$fast" = "true" ] && letter="${letter}ᶠ"
[ -n "$agent" ] && letter="${letter}${DIM}@${agent}${R}"

# ---- ψ context + cache ----
psi=""
if [ -n "$ctx_pct" ]; then
	ctx_int=$(awk -v v="$ctx_pct" 'BEGIN { printf "%d", v + 0.5 }')
	ctx_color=$(sev_color "$(thr "$ctx_int" 60 80)")
	psi="${GOLD}ψ${R} ${ctx_color}${ctx_int}${R}"
	[ "${ctx_size:-0}" -ge 1000000 ] 2>/dev/null && psi="${psi}¹ᴹ"
	if [ -n "$cache_hit" ]; then
		hit=$(awk -v h="$cache_hit" 'BEGIN { printf "%d", h * 100 + 0.5 }')
		sep="·"; [ "$cache_warm" = "false" ] && sep="○"
		psi="${psi}${DIM}${sep}${hit}${R}"
	fi
fi

# ---- λ rate limits: 5h with time-to-reset, 7d with the burn-rate projection; one color for the group ----
lambda=""; l_sev=0
[ "${CLAUDE_STATUSLINE_STYLE:-}" = v3 ] && ring_update   # only v3 reads the ring (its burn slope); v4 writes no state
if [ -n "$h5_pct" ]; then
	h5=$(awk -v v="$h5_pct" 'BEGIN { printf "%d", v + 0.5 }')
	read -r b5_sev _ <<<"$(burn 2 "$h5" "${h5_reset:-0}")"
	h5_sev=$(max "$(max "$(thr "$h5" 70 90)" "$(pace "$h5" "${h5_reset:-0}" 18000)")" "${b5_sev:-0}")
	l_sev=$(max "$l_sev" "$h5_sev")
	lambda="${h5}$(sup "$(dur $(( ${h5_reset:-0} - now )))")"
fi
if [ -n "$d7_pct" ]; then
	d7=$(awk -v v="$d7_pct" 'BEGIN { printf "%d", v + 0.5 }')
	read -r b7_sev b7_delta <<<"$(burn 3 "$d7" "${d7_reset:-0}")"
	# 7d: threshold + burn rate only. Cumulative pace is wrong at both ends of a week-long window
	# (explodes in the first day, hides a burst after quiet days); the trailing slope is the signal.
	d7_sev=$(max "$(thr "$d7" 50 75)" "${b7_sev:-0}")
	l_sev=$(max "$l_sev" "$d7_sev")
	if [ -n "${b7_delta:-}" ] && [ "$b7_delta" != "+" ]; then
		d7_sup=$(sup "$(signed_dur "$b7_delta")")     # ⁻²ᵈ = runs out 2 days before the reset at this burn
	else
		# No usable slope yet: hours ahead (+) or behind (−) the line from 0 % at window start to 100 % at reset.
		ahead=$(awk -v used="$d7" -v reset="${d7_reset:-0}" -v now="$now" 'BEGIN {
			left = reset - now; if (left < 0) left = 0; if (left > 604800) left = 604800
			expected = (604800 - left) / 604800 * 100
			h = (expected - used) / 100 * 168; printf "%+d", (h < 0) ? h - 0.5 : h + 0.5 }')
		d7_sup=$(sup "${ahead}h")
	fi
	lambda="${lambda:+$lambda }${d7}${d7_sup}"
fi
if [ -n "$lambda" ]; then
	l_color=$(sev_color "$l_sev")
	if [ -n "$l_color" ]; then
		bang=""; [ "$l_sev" -eq 2 ] && bang="!"
		lambda="${l_color}λ ${lambda}${bang}${R}"   # whole group in the warning color; red shouts
	else
		lambda="${GOLD}λ${R} ${lambda}"
	fi
fi
# ---- ?N: how many Claude panes on this tmux server are waiting on you (owner 2026-10-15: "λ should
# tell me how many Claudes need me"). Counts the @claude_waiting flag the hooks maintain, one tmux
# call, no claude process spawned (that poll would blow the 150 ms render budget). Fleet-wide in S3.
if [ -n "$TMUX_BIN" ]; then
	nwait=$("$TMUX_BIN" list-panes -a -F '#{@claude_waiting}' 2>/dev/null | grep -c '^1$')
	[ "${nwait:-0}" -gt 0 ] && lambda="${lambda:+$lambda }${RED}?${nwait}${R}"
fi

# ---- σ session elapsed + API share ----
sigma=""
if [ "${dur_ms:-0}" -gt 0 ] 2>/dev/null; then
	# API share of wall time. After a resume Claude Code can report api_ms > dur_ms (the durations come
	# from different clocks), so the value is clamped: a share over 100 % is a wrong number, not a signal.
	share=$(awk -v a="$api_ms" -v d="$dur_ms" 'BEGIN { s = a * 100 / d + 0.5; if (s > 100) s = 100; printf "%d", s }')
	sigma="${GOLD}σ${R} $(dur $(( dur_ms / 1000 )))$(sup "$share")"
fi

# ---- π git (falls back to the bare dotfiles repo anywhere under $HOME) ----
pi=""
g=(git -C "$cwd" --no-optional-locks)
if [ -n "$cwd" ] && ! "${g[@]}" rev-parse --is-inside-work-tree >/dev/null 2>&1 \
	&& [ -d "$HOME/.dotfiles" ] && case "$cwd" in "$HOME"*) true ;; *) false ;; esac; then
	g=(git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" --no-optional-locks)
fi
if [ -n "$cwd" ] && branch=$("${g[@]}" rev-parse --abbrev-ref HEAD 2>/dev/null); then
	name="${wt:-$branch}"
	# Net lines changed (insertions − deletions) as one signed superscript; nothing when zero. v3 only:
	# v4 shows the payload's Δ instead, so the diff is not paid for on the live path.
	net=""; [ "${CLAUDE_STATUSLINE_STYLE:-}" = v3 ] && net=$("${g[@]}" diff --shortstat -- "$cwd" 2>/dev/null | awk '{ i = 0; d = 0; for (k = 1; k <= NF; k++) { if ($(k+1) ~ /^insertion/) i = $k; if ($(k+1) ~ /^deletion/) d = $k } ; n = i - d; if (n != 0) printf "%+d", n }')
	pi="${GOLD}π${R} ${name}$(sup "$net")"
fi
if [ -n "$pr_num" ]; then
	case "$pr_state" in approved) pc="$BLUE" ;; pending) pc="$ORANGE" ;; changes_requested) pc="$RED" ;; draft) pc="$GRAY" ;; *) pc="" ;; esac
	pi="${pi:+$pi }${pc}#${pr_num}${R}"
fi

# ---- $ cost ----
dollar="${GOLD}\$${R} ${DIM}$(awk -v c="$cost" 'BEGIN { printf "%.1f", c }')${R}"


# ============================================================================================
# v4 (2026-11-03): one row in the grammar of Claude's own footer (glyph, number, words, a dot between groups and a gap within them,
# sections), seven sections that never change order, the most actionable first:
#   ॐ Fᵀ⁺ high + thinking  ? 5 waiting · ψ 61% context  λ 48% (41%ᶠ)  τ 4d 10h reset  δ 71% 2d 3h to spare · π +702 lines across 27 files uncommitted on v-macos PR #1234  $ 283 over 2h 40m
# δ is the pacing tile (owner 2026-11-04): where the week lands at its average pace (unclipped), then the
# margin against the reset as the action: "stop for 5d 3h" (red), "1d 8h to spare", "on pace". The pace is
# used % over the time since the window opened (the endpoint's window_started_at), the 2026-11-02 method:
# two exact inputs, never a slope over whole-percent samples. $ carries the session's clock ("over 2h 40m").
# No commas anywhere, no words a glyph already says.
# Rules (owner, 2026-11-03): every glyph always drawn, Kanagawa gold, one space, then its number; words
# come after the number and shrink away first; a superscript is a unit on a number, never alone; no
# decimals, no `!`; red only on ॐ (this pane waits), the ? count, and λ/τ when the pace runs the week dry.
# Fit: each section has a long, short and minimal form; the row is measured in cells against COLUMNS
# (Claude sets it to the pane) and sections shrink from the right, then $, π and τ drop; a hard cut
# guards the rest. ॐ ? ψ λ are the floor. Ultra has no five-hour window (Boris Cherny, X, 2026-10-30),
# so λ is the week; a 5 h window shows in brackets when the payload carries one. The estimate is the
# ring's burn slope carried to the reset. Mode and agent counts wait for the tmux station.
# CLAUDE_STATUSLINE_STYLE=v3 renders the previous line. Earlier drafts: backups/statusline.sh.20261103.removed-blocks.bak.
# ============================================================================================
# Time left in words, two units at most: "4d 10h", "10h 5m", "42m".
# Numbers stay short: whole units, two digits where the unit allows, thousands as "k" (owner 2026-11-03).
short_n() { awk -v n="$1" 'BEGIN { s = (n < 0) ? "-" : ""; a = (n < 0) ? -n : n; if (a >= 1000) printf "%s%dk", s, (a + 500) / 1000; else printf "%s%d", s, a }'; }
left_words() { awk -v s="$1" 'BEGIN { if (s < 0) s = 0; d = int(s / 86400); h = int((s % 86400) / 3600); m = int((s % 3600) / 60)
	if (d > 0) printf "%dd%s", d, (h > 0 ? " " h "h" : ""); else if (h > 0) printf "%dh%s", h, (m > 0 ? " " m "m" : ""); else printf "%dm", m }'; }
render_v4() {
	local cols="${COLUMNS:-120}" SEP="  "   # the gold glyph opens every section, so the gap is the separator (owner 2026-11-04)
	# --- ? N: Claude panes waiting elsewhere. tmux names the native binary by its version ("2.1.316").
	# The count only (owner 2026-11-04: names and addresses were unreadable; the tmux pills say which).
	local nw=0 who=""
	if [ -n "${CLAUDE_STATUSLINE_WAITING:-}" ]; then nw="${CLAUDE_STATUSLINE_WAITING%%:*}"
	elif [ -n "$TMUX_BIN" ]; then
		nw=$("$TMUX_BIN" list-panes -a -F '#{@claude_waiting}	#{pane_current_command}' 2>/dev/null | awk -F'\t' '$1 == "1" && $2 ~ /^(claude|node|[0-9]+\.[0-9]+\.[0-9]+)$/ { n++ } END { print n + 0 }')
	fi
	local nwc="$DIM"; [ "${nw:-0}" -gt 0 ] 2>/dev/null && nwc="$RED"
	# --- the usage cache first: the poll's endpoint carries what the payload lacks: the Fable week, the
	# window's exact start, a fresher weekly figure. Absent in demos and tests, which pin the ? count.
	local fab="" wstart="" cused="" creset=""
	if [ -z "${CLAUDE_STATUSLINE_WAITING:-}" ] || [ -n "${CLAUDE_USAGE_CACHE:-}" ]; then
		local age=$(( now - $(stat -f %m "$USAGE_CACHE" 2>/dev/null || echo 0) ))
		if [ "$age" -gt "$POLL_S" ]; then touch "$USAGE_CACHE" 2>/dev/null; (nohup "$0" poll >/dev/null 2>&1 &); fi
		# Verified 2026-11-03/04 against live responses: limits[] carry kind, percent, resets_at and
		# scope.model.display_name; seven_day_breakdown.window_started_at is the week's start (ISO, UTC).
		if [ -s "$USAGE_CACHE" ]; then
			IFS='|' read -r fab cused creset wstart <<<"$(jq -r '[
				([.limits[]? | select(.kind == "weekly_scoped" and ((.scope.model.display_name // "") | ascii_downcase) == "fable") | .percent][0] // ""),
				([.limits[]? | select(.kind == "weekly_all") | .percent][0] // .seven_day.utilization // ""),
				([.limits[]? | select(.kind == "weekly_all") | .resets_at][0] // .seven_day.resets_at // ""),
				(.seven_day_breakdown.window_started_at // "")
			] | map(tostring) | join("|")' "$USAGE_CACHE" 2>/dev/null)"
			# ISO to epoch once, here: the window's start and its reset (BSD date, ~2 ms each)
			local iso; for iso in wstart creset; do [ -n "${!iso}" ] && printf -v "$iso" '%s' "$(date -ju -f '%Y-%m-%dT%H:%M:%S' "${!iso%%.*}" +%s 2>/dev/null)"; done
		fi
	fi
	local fabi="" fc=""
	if [ -n "$fab" ]; then fabi=$(awk -v v="$fab" 'BEGIN { printf "%d", v + 0.5 }'); fc=$(sev_color "$(thr "$fabi" 80 90)"); fi
	# --- λ, τ, δ: the primary window (the week; the 5 h only when that is all there is). The method of
	# 2026-11-02 (plan, station 6): the pace is the window's average, used % over the time since it opened,
	# two exact inputs, so the landing and the margin move with every render and never jump (a two-hour
	# slope over whole-percent samples swung the landing by hundreds of points, 2026-11-04); the projection
	# shows from 10 % used; amber at 80 % used or a landing of 90 %+, red at 90 % used or running out before
	# the reset (claude-hud and Owloops thresholds). Used % is the larger of the payload (frozen at this
	# session's last response) and the endpoint (10-min poll): usage never falls inside a window.
	local used="" reset="" len="" other="" est="" tto=-1 lsev=0 left=0 elapsed=0
	if [ -n "${d7:-}" ]; then used="$d7"; reset="${d7_reset:-0}"; len=604800; [ -n "${h5:-}" ] && other="${h5}"
	elif [ -n "${h5:-}" ]; then used="$h5"; reset="${h5_reset:-0}"; len=18000; fi
	# the endpoint's week, when it is there, and it is a different week from the payload's: a session that
	# outlives a reset keeps reporting last week's figure (95 % beside a true 3 %), so the fresher source wins
	# outright; inside one week the larger of the two is the truer, since usage never falls within a window
	if [ -n "$cused" ] && [ "${creset:-0}" -gt 0 ]; then
		if [ -z "$used" ] || [ "$len" -ne 604800 ] || [ $(( reset > creset ? reset - creset : creset - reset )) -gt 3600 ]; then
			used=$(awk -v v="$cused" 'BEGIN { printf "%d", v + 0.5 }'); reset="$creset"; len=604800; other=""
		else used=$(awk -v a="$used" -v b="$cused" 'BEGIN { printf "%d", (b > a ? b : a) + 0.5 }'); fi
	fi
	if [ -n "$used" ]; then
		left=$(( reset - now )); [ "$left" -lt 0 ] && left=0; [ "$left" -gt "$len" ] && left="$len"
		elapsed=$(( len - left ))
		[ "${wstart:-0}" -gt 0 ] 2>/dev/null && [ "$wstart" -lt "$now" ] && [ "$len" -eq 604800 ] && elapsed=$(( now - wstart ))
		if [ "$used" -ge 10 ] && [ "$elapsed" -gt 0 ]; then
			read -r est tto <<<"$(awk -v u="$used" -v e="$elapsed" -v l="$left" 'BEGIN { r = u / e; printf "%d %d", u + r * l + 0.5, (100 - u) / r }')"
		fi
		if [ "$used" -ge 90 ] || { [ "$tto" -ge 0 ] && [ "$tto" -lt "$left" ]; }; then lsev=2
		elif [ "$used" -ge 80 ] || [ "${est:-0}" -ge 90 ]; then lsev=1; fi
		[ -n "$est" ] && est="${est}%"
	fi
	local lc; lc=$(sev_color "$lsev")
	# --- π: uncommitted work, the branch, the PR badge in its review colour. Inside a project repo one
	# diff against HEAD gives lines and files; on the dotfiles fallback (work tree = $HOME) that diff
	# costs two seconds, so there only the files count is read, from a 30 ms status.
	local files=0 net="" pr=""
	if [ -n "${name:-}" ]; then
		if [ "${g[1]}" = "--git-dir=$HOME/.dotfiles" ]; then
			files=$("${g[@]}" status --porcelain --untracked-files=no 2>/dev/null | grep -c .)
		else
			read -r files net <<<"$("${g[@]}" diff --shortstat HEAD 2>/dev/null | awk '{ f = 0; i = 0; d = 0; for (k = 1; k <= NF; k++) { if ($(k+1) ~ /^files?/) f = $k; if ($(k+1) ~ /^insertion/) i = $k; if ($(k+1) ~ /^deletion/) d = $k } print f + 0, i - d }')"
		fi
	fi
	local netw=""; [ -n "$net" ] && { netw=$(short_n "$net"); [ "$net" -gt 0 ] && netw="+$netw"; }
	# --- sections: long · short · minimal forms, built twice, coloured and plain, so the fit can measure
	# cells with ${#} instead of stripping escapes (a pattern substitution costs ~50 ms a pass in bash 3.2).
	# G marks a section that opens a group (who · budgets · where): a dim dot precedes it, a gap the rest.
	local -a L=() S=() M=() D=() G=() PL=() PS=() PM=()
	local mode=c
	sec() {
		if [ "$mode" = c ]; then L+=("$1"); S+=("${2:-$1}"); M+=("${3:-${2:-$1}}"); D+=("${4:-0}"); G+=("${5:-0}")
		else PL+=("$1"); PS+=("${2:-$1}"); PM+=("${3:-${2:-$1}}"); fi
	}
	build() { # colour vars come in as arguments, empty on the plain pass
		local GOLD="$1" RED="$2" DIM="$3" R="$4" ac="$5" cc="$6" lc="$7" nwc="$8" pcol="$9" badge="${10}" fcol="${11}" bc="${12}"
		local pr=""; [ -n "$pr_num" ] && pr="${pcol}#${pr_num}${R}"
		sec "${ac}${anchor}${R} ${badge} ${DIM}${model_word}${R}" "${ac}${anchor}${R} ${badge}"
		sec "${GOLD}?${R} ${nwc}${nw}${R} ${DIM}waiting${who:+  $who}${R}" "${GOLD}?${R} ${nwc}${nw}${R} ${DIM}waiting${R}" "${GOLD}?${R} ${nwc}${nw}${R}"
		[ -n "${ctx_int:-}" ] && sec "${GOLD}ψ${R} ${cc}${ctx_int}%${R} ${DIM}context${R}" "${GOLD}ψ${R} ${cc}${ctx_int}%${R}" "" 0 1
		if [ -n "$used" ]; then
			# the bracket: numbers in their own colour, only the words dim
			local lp="${lc}${used}%${R}" ol="" os="" bl="" bs=""
			[ -n "$other" ] && { bl="${other}%${DIM} 5h${R}"; bs="${other}%"; }
			[ -n "$fabi" ] && { bl="${bl:+$bl }${fcol}${fabi}%${R}ᶠ"; bs="${bs:+$bs }${fcol}${fabi}%${R}ᶠ"; }
			[ -n "$bl" ] && ol=" ${DIM}(${R}${bl}${DIM})${R}" && os=" ${DIM}(${R}${bs}${DIM})${R}"
			sec "${GOLD}λ${R} ${lp}${ol}" "${GOLD}λ${R} ${lp}${os}" "${GOLD}λ${R} ${lp}"
			sec "${GOLD}τ${R} ${lw} ${DIM}reset${R}" "${GOLD}τ${R} ${lw}" "${GOLD}τ${R} ${lw%% *}" 3
			# δ: the pacing tile (owner 2026-11-04): where the window lands at the average pace, then the margin
			# against the reset: "stop for 5d 3h" is the pause that lands it at 100 % (red), "1d 8h to spare" the
			# room left, "on pace" within rounding. From 10 % used. Outlives τ when the row shrinks.
			if [ -n "$est" ]; then
				local dl="" ds=""
				case "$bword" in
					"on pace") dl=" ${DIM}on pace${R}" ;;
					"stop for") dl=" ${DIM}stop for${R} ${bc}${bw}${R}"; ds=" ${bc}-${bw}${R}" ;;
					"to spare") dl=" ${bc}${bw}${R} ${DIM}to spare${R}"; ds=" ${bc}+${bw}${R}" ;;
				esac
				sec "${GOLD}δ${R} ${bc}${est}${R}${dl}" "${GOLD}δ${R} ${bc}${est}${R}${ds}" "${GOLD}δ${R} ${bc}${est}${R}" 4
			fi
		fi
		if [ -n "${name:-}" ]; then
			local nm="${name:0:14}"
			if [ "${files:-0}" -gt 0 ] && [ -n "$netw" ]; then
				sec "${GOLD}π${R} ${netw} ${DIM}lines across${R} ${files} ${DIM}files uncommitted on${R} ${nm}${pr:+ ${DIM}PR${R} $pr}" "${GOLD}π${R} ${netw}ˡ ${files}ᶠ ${nm}${pr:+ $pr}" "${GOLD}π${R} ${nm}" 2 1
			elif [ "${files:-0}" -gt 0 ]; then
				sec "${GOLD}π${R} ${files} ${DIM}files uncommitted on${R} ${nm}${pr:+ ${DIM}PR${R} $pr}" "${GOLD}π${R} ${files}ᶠ ${nm}${pr:+ $pr}" "${GOLD}π${R} ${nm}" 2 1
			else
				sec "${GOLD}π${R} 0 ${DIM}uncommitted on${R} ${nm}${pr:+ ${DIM}PR${R} $pr}" "${GOLD}π${R} ${nm}${pr:+ $pr}" "${GOLD}π${R} ${nm}" 2 1
			fi
			sec "${GOLD}\$${R} ${costi}${ew:+ ${DIM}over${R} $ew}" "${GOLD}\$${R} ${costi}${ew:+ ${DIM}over${R} $ew}" "${GOLD}\$${R} ${costi}" 1
		else
			sec "${GOLD}\$${R} ${costi}${ew:+ ${DIM}over${R} $ew}" "${GOLD}\$${R} ${costi}${ew:+ ${DIM}over${R} $ew}" "${GOLD}\$${R} ${costi}" 1 1
		fi
	}
	local lw="" bw="" bc="" bword="" costi model_word ew=""; costi=$(short_n "$(awk -v c="$cost" 'BEGIN { printf "%d", c + 0.5 }')")
	# the session's clock rides on $: what it cost over how long (owner 2026-11-04); absent before the first minute
	[ "${dur_ms:-0}" -ge 60000 ] 2>/dev/null && ew=$(left_words $(( dur_ms / 1000 )))
	# δ's margin: time to run out minus time to reset at the average pace. Claude reports whole percents,
	# so a margin under 5 % of the window is inside the rounding and reads "on pace" instead of a sign.
	if [ -n "$est" ] && [ "${tto:--1}" -ge 0 ]; then
		local dsec=$(( tto - left )) band=$(( len / 20 ))
		if [ "${dsec#-}" -lt "$band" ]; then bw=""; bc="$DIM"; bword="on pace"
		elif [ "$dsec" -lt 0 ]; then bw="$(left_words $(( -dsec )))"; bc="$RED"; bword="stop for"
		else bw="$(left_words "$dsec")"; bc=""; bword="to spare"; fi
	fi
	# Beside the badge at full width: the one parameter you turn (effort), plus fast and the agent when
	# they apply. The model letter and the thinking mark already say the rest. The badge alone when narrow.
	model_word="$effort"
	[ "$thinking" = "true" ] && model_word="${model_word:+$model_word }+ thinking"
	[ "$fast" = "true" ] && model_word="${model_word:+$model_word }+ fast"
	[ -n "$agent" ] && model_word="${model_word:+$model_word }@${agent}"
	[ -n "$used" ] && lw=$(left_words "$left")
	local badge_plain="${letter//$'\e'\[*([0-9;])m/}"   # one short strip: the agent suffix carries DIM
	build "$GOLD" "$RED" "$DIM" "$R" "$anchor_color" "$ctx_color" "$lc" "$nwc" "${pc:-}" "$letter" "$fc" "$bc"
	mode=p; build "" "" "" "" "" "" "" "" "" "$badge_plain" "" ""
	# --- fit: measure in cells, shrink from the right, then drop, then cut
	local n=${#L[@]} i out="" pout="" w=0 limit=$(( cols - 2 ))
	local -a lv=() on=(); for ((i = 0; i < n; i++)); do lv+=(0); on+=(1); done
	compose() {
		local c p first=1; out=""; pout=""; w=0
		for ((i = 0; i < n; i++)); do
			[ "${on[$i]}" -eq 1 ] || continue
			case "${lv[$i]}" in 0) c="${L[$i]}"; p="${PL[$i]}" ;; 1) c="${S[$i]}"; p="${PS[$i]}" ;; *) c="${M[$i]}"; p="${PM[$i]}" ;; esac
			if [ "$first" -eq 1 ]; then out="$c"; pout="$p"; first=0
			elif [ "${G[$i]}" -eq 1 ]; then out="$out ${DIM}·${R} $c"; pout="$pout · $p"
			else out="$out$SEP$c"; pout="$pout$SEP$p"; fi
		done
		w=${#pout}
	}
	compose
	while [ "$w" -gt "$limit" ]; do
		local moved=0
		# the badge's words are the first to go (the least actionable words on the row), then from the right
		if [ "${lv[0]}" -lt 1 ]; then lv[0]=1; compose; continue; fi
		for ((i = n - 1; i >= 0; i--)); do
			if [ "${on[$i]}" -eq 1 ] && [ "${lv[$i]}" -lt 2 ]; then lv[$i]=$(( lv[$i] + 1 )); moved=1; break; fi
		done
		if [ "$moved" -eq 0 ]; then
			# D is the drop order (1 goes first); ties go to the rightmost. $ 1 · π 2 · τ 3 · δ 4.
			local best=-1 bestd=99
			for ((i = n - 1; i >= 0; i--)); do
				if [ "${on[$i]}" -eq 1 ] && [ "${D[$i]}" -gt 0 ] && [ "${D[$i]}" -lt "$bestd" ]; then best=$i; bestd=${D[$i]}; fi
			done
			[ "$best" -ge 0 ] && { on[$best]=0; moved=1; }
		fi
		[ "$moved" -eq 0 ] && break
		compose
	done
	[ "$w" -gt "$limit" ] && out="${pout:0:$limit}"
	printf '%s\n' "$out"
}
case "${CLAUDE_STATUSLINE_STYLE:-}" in v3) ;; *) render_v4; exit 0 ;; esac

printf '%s' "${anchor_color}${anchor}${R} ${letter}"
for seg in "$psi" "$lambda" "$sigma" "$pi" "$dollar"; do [ -n "$seg" ] && printf ' %s' "$seg"; done
printf '\n'
