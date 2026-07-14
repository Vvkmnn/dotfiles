#!/bin/bash
# High-performance Claude Code statusline
# Output: ॐ ✻ Fᵀˣ ψ 51%¹ᴹ 94% μ 5% λ 40% 30% σ 2h 8.5h θ 0.8h¹·⁵ 6.5d π branch +45 -12 $ 12.34
#
# Error handling: Log errors but always show something (even if incomplete)
set -o pipefail
trap 'log_error "Script failed at line $LINENO"' ERR
#
# ============================================================================
# FORMAT BREAKDOWN (v2, 2026-07-06)
# ============================================================================
# ॐ Fᵀˣ ψ 51%¹ᴹ 94% μ 5% λ 40% 30% σ 2h 8.5h θ 0.8h¹·⁵ 6.5d π branch +45 -12 $ 12.34
# │ │││ │       │     │    │         │         │              │             │
# │ │││ │       │     │    │         │         │              │             └── $ session value (API-equiv, dim) + ¢ REAL
# │ │││ │       │     │    │         │         │              │                 usage-credit spend (orange, only when >0)
# │ │││ │       │     │    │         │         │              └── π git branch +ins -del (hidden outside repos)
# │ │││ │       │     │    │         │         └── θ time-to-reset 5h·7d (superscript = runway; color = pace)
# │ │││ │       │     │    │         └── σ session elapsed + weekly active
# │ │││ │       │     │    └── λ 5h% 7d% quota used (clamped ≤100)
# │ │││ │       │     └── μ daily budget variance
# │ │││ │       └── cache-hit % — 2nd % in the ψ section, κ glyph dropped (blue ≥80, orange <50, red <40)
# │ │││ └── ψ context % (¹ᴹ superscript = 1M-window session)
# │ ││└── effort from stdin (ᴹ max, ˣ xhigh, ⁺ high, ⁻ low, omit medium)
# │ │└── thinking ᵀ (stdin, settings fallback)
# │ └── Model letter (F/O/S/H)
# └── ॐ anchor: model icon + vim state by color — ORANGE insert (typing = resting
#     default), BLUE normal/escaped, gold visual (pairs with hideVimModeIndicator)
#
# DISPLAY MODES: default shows EVERYTHING. STATUSLINE_MINIMAL=1 opts into early-warning
# hiding: κ hides while ≥70, μ hides while on-pace (0..+5), θ hides while pace <0.8×
# sustainable. Nothing is ever deleted — only display-gated.
#
# μ: Budget variance = (days_elapsed/7)×100 - weekly%.
#    Positive = under budget. Negative = over budget. 0 = on track.
#    Red <-5, Orange -5..0, White 0..5, Gray >5.
#    Subscript = hours off the on-pace line = |μ|×1.68 (schedule rate is a
#    constant 100%/168h). Over budget: that many idle hours returns you to 0%.
#    Under budget: you're that many hours ahead (headroom). Hours-only, rounded.
#
# COLOR CODING (warning colors for approaching/critical limits):
# - Context (ψ): orange 60-80%, red >80%
# - 5h used (λ): orange 70-90%, red >90%
# - 7d used (λ): orange 50-75%, red >75%
# - Runway (θ): PACE-BASED coloring (early warning system)
#   * white: pace ≤ sustainable (on track to make it to reset)
#   * orange: pace >1.0× sustainable (need to slow down)
#   * red: pace >1.5× sustainable (way too fast, adjust now)
#
# DATA SOURCES:
# - Model: stdin JSON
# - Context %: native context_window.used_percentage (fallback: transcript)
# - Rate limits: Anthropic API (/api/oauth/usage)
# - Δ session: /tmp/claude_last_activity.cache + session_start.cache
# - Σ weekly: ~/.claude/projects/*/*.jsonl (cached 5 min)
# - Θ runway: calculated from API data
#
# PERFORMANCE:
# - < 100ms typical (cached path, always taken — never blocks on network)
# - Background refresh: curl runs in detached subshell, writes cache when done
# - Next statusline render picks up fresh data from cache
#
# API RATE LIMITING (evolution of fixes, 2026-03):
# Problem: Original code called /api/oauth/usage on EVERY statusline invocation.
# With Claude Code calling statusline after each assistant turn + tmux refresh,
# this produced 100+ calls/hour → 429 rate limit → 1000+ errors → stale data.
#
# Fix 1 — Touch-before-call (prevents concurrent + provides backoff):
#   touch "$cache_file" BEFORE curl. Second invocation sees fresh mtime → skips.
#   On failure, mtime is still fresh → no retry for TTL period. No lockfiles needed.
#
# Fix 2 — Dual age tracking (mtime for TTL, _fetched_at for staleness):
#   mtime controls WHEN to retry (touch refreshes it). _fetched_at embedded in JSON
#   controls WHEN to show stale indicators (only successful fetch updates it).
#   These MUST be separate: touch refreshes mtime without updating content.
#
# Fix 3 — Background refresh (prevents silent crash):
#   Claude Code / tmux may kill the statusline process if it takes too long.
#   Curl blocks for up to 5s → process killed mid-curl → touch happened but no
#   result written → no error log → silent failure. Fix: main process ALWAYS reads
#   cache and returns immediately. Spawns (_refresh_rate_limit &) in background.
#   Background subshell survives parent exit, completes curl, writes cache.
#
# Fix 4 — Threshold separation (TTL=900s, strikethrough=7200s):
#   When TTL = strikethrough threshold, race at boundary: touch updates mtime,
#   concurrent render reads stale content → strikethrough flickers every TTL cycle.
#   Fix: strikethrough threshold (7200s) >> TTL (900s). Content age at refresh
#   boundary (~900s) is well under 7200s → zero flicker. Strikethrough only after
#   2 HOURS of consecutive failures (8 missed refresh cycles) — genuinely broken.
#   TTL history: 30s→120s→300s→900s. /api/oauth/usage rate-limits at ~10/hour.
#   900s = 4 calls/hour, safely under the limit. Rate data changes over hours anyway.
#   Community tool claudeline uses 10-min TTL — our 15-min is more conservative.
#
# KNOWN ISSUES (2026-03):
# - /api/oauth/usage returns persistent 429 for some users (GitHub #30930, OPEN)
#   Even 30s/60s/120s intervals fail. retry-after: 0 is misleading. Intermittent.
# - Claude Code parses anthropic-ratelimit-unified-* headers internally on every
#   API call but does NOT expose them to statusline scripts via stdin JSON.
#   Feature request #19385 (OPEN) tracks adding this. When implemented, the
#   separate /api/oauth/usage call becomes unnecessary — piggybacking on every
#   Claude message would give real-time data with zero extra API calls.
#
# STRIKETHROUGH RULES:
# Applied ONLY to utilization values that change with every API call:
#   λ 5h%, 7d%, Ω% — these are stale undercounts when data is old
# NOT applied to (even when API data is old):
#   Reset timestamps (Θ) — fixed future dates, remain valid
#   Ψ context, Δ elapsed, Σ weekly — local data, always fresh
# Threshold: 7200s (2h). Stale data is still directionally correct — better to
# show slightly outdated values than to strikethrough and make them unreadable.
#
# Result: 4 calls/hour max, zero concurrent, automatic backoff, non-blocking,
# stale data dimmed not hidden. /api/oauth/usage is the ONLY source for Max plan
# utilization % until Claude Code exposes headers (feature request #19385).
# ============================================================================

input=$(cat)

# DEBUG: Dump JSON input to discover transcript_path location (remove after investigation)
# echo "$input" > /tmp/statusline_debug.json

# ---- Colors (Kanagawa Wave — old ANSI values in comments for revert) ----
GRAY='\033[38;2;114;113;105m'    # kanagawa fujiGray #727169 (was \033[33m)
ORANGE='\033[38;2;255;160;102m'  # kanagawa surimiOrange #ffa066 (was \033[33m)
RED='\033[38;2;232;36;36m'       # kanagawa samuraiRed #e82424 (was \033[31m)
DIM='\033[2m'
STRIKE='\033[9m'
RESET='\033[0m'
B='\033[38;2;230;195;132m' # kanagawa gold (#e6c384) for icons
ICON_MODEL="${B}✻${RESET}"   # Claude spark — model section (ॐ is the vim-state anchor)
ICON_RATE="${B}λ${RESET}"
ICON_ELAPSED="${B}δ${RESET}"
ICON_WEEKLY="${B}σ${RESET}"
ICON_RUNWAY="${B}θ${RESET}"
ICON_CTX="${B}ψ${RESET}"
ICON_OMEGA="${B}μ${RESET}"
ICON_GIT="${B}π${RESET}"
ICON_CACHE="${B}κ${RESET}"
ICON_COST="${B}\$${RESET}"
BLUE='\033[38;2;126;156;216m'   # kanagawa crystalBlue #7e9cd8 — the 'healthy' accent (user pref 2026-07-07, was autumnGreen)

# ---- Cache paths ----
DAILY_BUDGET_CACHE="$HOME/.claude/status/daily_budget.json"
ERROR_LOG="/tmp/statusline_error.log"

# ---- Error logging ----
log_error() {
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$ERROR_LOG" 2>/dev/null
}

# ---- Superscript conversion ----
to_superscript() {
	local num="$1"
	echo "$num" | sed '
		s/0/⁰/g; s/1/¹/g; s/2/²/g; s/3/³/g; s/4/⁴/g;
		s/5/⁵/g; s/6/⁶/g; s/7/⁷/g; s/8/⁸/g; s/9/⁹/g;
		s/\./·/g; s/-/⁻/g
	'
}

# Subscript renderer (μ recovery hint). Digits + 'h' only — Unicode has no
# subscript 'd', so recovery stays in hours. Values are rounded positive ints.
to_subscript() {
	local num="$1"
	echo "$num" | sed '
		s/0/₀/g; s/1/₁/g; s/2/₂/g; s/3/₃/g; s/4/₄/g;
		s/5/₅/g; s/6/₆/g; s/7/₇/g; s/8/₈/g; s/9/₉/g;
		s/h/ₕ/g
	'
}

# ---- Check jq ----
command -v jq >/dev/null 2>&1 || {
	echo "ॐ Claude"
	exit 0
}

# ---- Extract model name ----
# model can be a string ("claude-fable-5[1m]") or object ({display_name: "..."})
display_name=$(echo "$input" | jq -r 'if (.model | type) == "object" then .model.display_name else .model end // "Claude"' 2>/dev/null)
full_model=$(echo "$display_name" | grep -oiE "(fable|opus|sonnet|haiku)" | head -1)
case "$(echo "$full_model" | tr '[:upper:]' '[:lower:]')" in
	fable) model_name="F" ;;
	opus) model_name="O" ;;
	sonnet) model_name="S" ;;
	haiku) model_name="H" ;;
	*) model_name="${display_name:-Claude}" ;;
esac

# ---- Effort indicator ----
# Live from stdin effort.level (reflects /effort mid-session changes).
# Was: .effortLevel — but the statusline stdin payload carries live .effort.level, not that
# settings key (which CC does read) → always "medium". Fixed 2026-07-06.
# Glyphs (all superscript, consistent with ᵀ thinking marker):
#   max ᴹ · xhigh ˣ · high ⁺ · medium (none) · low ⁻
effort_indicator=""
effort_level=$(echo "$input" | jq -r '.effort.level // empty' 2>/dev/null)
case "$effort_level" in
	max)    effort_indicator="ᴹ" ;;
	xhigh)  effort_indicator="ˣ" ;;
	high)   effort_indicator="⁺" ;;
	low)    effort_indicator="⁻" ;;
esac

# ---- Thinking mode (ᵀ) ----
# Live from stdin thinking.enabled; falls back to settings for older CC versions
thinking_indicator=""
thinking=$(echo "$input" | jq -r '.thinking.enabled // empty' 2>/dev/null)
[ -z "$thinking" ] && thinking=$(jq -r '.alwaysThinkingEnabled // false' "$HOME/.claude/settings.json" 2>/dev/null)
[ "$thinking" = "true" ] && thinking_indicator="ᵀ"

# ---- Vim mode via ॐ color (compact replacement for the -- INSERT -- banner) ----
# Pairs with statusLine "hideVimModeIndicator": true (issue #16788, ours).
# The leading ॐ IS the vim indicator: gold = NORMAL/vim off (calm), green = INSERT,
# orange = VISUAL. No extra glyph, no shifting layout.
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty' 2>/dev/null)
case "$vim_mode" in
	INSERT)                     vim_color="$ORANGE" ;; # typing at the prompt = resting state (user default)
	VISUAL|"VISUAL LINE")       vim_color="$B" ;;      # gold — selection
	*)                          vim_color="$BLUE" ;;  # NORMAL (escaped) / vim off — the departure signal
esac

# ---- Get context % (native first, transcript fallback) ----
context_pct=""
get_context() {
	# Try native field first (v2.1.x+)
	local native_pct
	native_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty' 2>/dev/null)
	if [ -n "$native_pct" ]; then
		context_pct=$(printf '%.0f' "$native_pct")
		return
	fi

	# Fallback: transcript parsing
	local transcript_path latest_tokens
	local MAX_CONTEXT=200000
	transcript_path=$(echo "$input" | jq -r '.transcript_path // empty' 2>/dev/null)
	[ -z "$transcript_path" ] || [ ! -f "$transcript_path" ] && return
	latest_tokens=$(tail -20 "$transcript_path" 2>/dev/null | jq -r 'select(.message.usage) | .message.usage | ((.input_tokens // 0) + (.cache_read_input_tokens // 0) + (.cache_creation_input_tokens // 0))' 2>/dev/null | tail -1)
	if [ -n "$latest_tokens" ] && [ "$latest_tokens" -gt 0 ]; then
		context_pct=$((latest_tokens * 100 / MAX_CONTEXT))
	else
		context_pct=0
	fi
}

# ---- Color a value based on 5-level thresholds ----
# Usage: color_value <value> <pct> <dim_threshold> <gray_threshold> <orange_threshold> <red_threshold>
# Levels: dim(GRAY) ≤dim | gray(GRAY) ≤gray | white(default) ≤orange | ORANGE ≤red | RED
color_value() {
	local value="$1" pct="$2" dim="$3" gray="$4" orange="$5" red="$6"
	if [ "$pct" -gt "$red" ] 2>/dev/null; then
		echo -e "${RED}${value}${RESET}"
	elif [ "$pct" -gt "$orange" ] 2>/dev/null; then
		echo -e "${ORANGE}${value}${RESET}"
	elif [ "$pct" -gt "$gray" ] 2>/dev/null; then
		echo "$value"  # white (default fg)
	else
		echo -e "${GRAY}${value}${RESET}"
	fi
}

# ---- Get rate limits from API with caching ----
# Architecture: non-blocking read from cache + async background refresh.
# Main process (get_rate_limit): reads cache, returns instantly, spawns background if stale.
# Background (_refresh_rate_limit): touch → credentials → curl → validate → write cache.
#
# Key invariants:
# - Main process NEVER blocks on network (caller may kill slow statuslines)
# - Touch before spawn prevents concurrent refreshes (mtime = "don't retry until TTL")
# - _fetched_at in JSON = content freshness (only success writes it)
# - Strikethrough threshold (7200s) >> TTL (900s) — only when genuinely broken (2h)
# - Null utilization in response = rate-limited garbage → don't overwrite good stale data
# - Token expiration pre-check avoids wasted curl on expired OAuth tokens
rate_pct="" weekly_pct=""
five_hour_reset_sec="" seven_day_reset_sec=""
extra_usd=""  # usage-credit spend (real money) — from /api/oauth/usage extra_usage
rate_content_age=0  # content freshness for stale indicators (separate from mtime TTL)

# Helper: extract all fields from JSON in a single jq call (5→1 jq invocations)
_parse_rate_json() {
	local json="$1"
	local parsed
	# Sentinel "~" prevents bash read from collapsing consecutive empty tab fields.
	# With "" (empty), read treats "\t\t" as one delimiter → fields shift left.
	parsed=$(echo "$json" | jq -r '[
		(.five_hour.utilization // "~"),
		(.seven_day.utilization // "~"),
		(.five_hour.resets_at // "~"),
		(.seven_day.resets_at // "~"),
		(._fetched_at // "~"),
		(.extra_usage.used_usd // .extra_usage.used_credits // .extra_usage.used
		 // .extra_usage.amount_spent_usd // .extra_usage.spent // "~")
	] | join("\t")' 2>/dev/null) || return

	IFS=$'\t' read -r rate_pct weekly_pct five_hour_reset_sec seven_day_reset_sec _fetched_at extra_usd <<< "$parsed"
	[ "$extra_usd" = "~" ] && extra_usd=""
	[ "$rate_pct" = "~" ] && rate_pct=""
	[ "$weekly_pct" = "~" ] && weekly_pct=""
	[ "$five_hour_reset_sec" = "~" ] && five_hour_reset_sec=""
	[ "$seven_day_reset_sec" = "~" ] && seven_day_reset_sec=""
	[ "$_fetched_at" = "~" ] && _fetched_at=""

	# Clamp utilization at 100: API can report >100 (observed λ 103% 2026-07-06),
	# which also drove runway (100-pct)/burn negative → the ⁻⁰·¹ superscript bug.
	# Clamping here fixes display AND downstream runway/pace math in one place.
	if [ -n "$rate_pct" ] && awk "BEGIN {exit !($rate_pct > 100)}"; then rate_pct="100"; fi
	if [ -n "$weekly_pct" ] && awk "BEGIN {exit !($weekly_pct > 100)}"; then weekly_pct="100"; fi

	# Content age: how old is the data itself (not the file mtime)
	# Missing _fetched_at = old cache format = age unknown = assume stale
	if [ -n "$_fetched_at" ]; then
		rate_content_age=$(( $(date +%s) - _fetched_at ))
	else
		rate_content_age=999
	fi
}

# Background API refresh (runs detached, never blocks statusline)
# ── Previous approach (usage API primary, haiku probe fallback) ──
# Commented out for safe revert. Was: /api/oauth/usage at 900s TTL,
# haiku probe only on 429. Failed during heavy use: 15min staleness
# caused 84% shown when actual was 99%.
# _refresh_rate_limit_v1() {
#	... (see git history for full implementation)
# }

# Called as: (_refresh_rate_limit &) 2>/dev/null — subshell survives parent exit.
# On success: writes cache with _fetched_at, clears error log.
#
# Data sources (in priority order):
# 1. Haiku probe (primary) — 1-token Haiku call, reads utilization from response
#    headers. Zero utilization impact on Max plan (verified). Can't be rate-limited
#    by usage API (it's a model call). 300s TTL = 12/hr.
# 2. /api/oauth/usage (fallback) — full JSON with extra fields. Used when haiku
#    probe fails (network, token issues). Rate-limited at ~10/hr.
_refresh_rate_limit() {
	local cache_file="$HOME/.claude/status/rate_limit.json"
	local now creds token_json token expires_at usage

	now=$(date +%s)

	# Get credentials (macOS keychain)
	creds=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null) || return

	# Extract token + check expiration
	token_json=$(echo "$creds" | jq -r '.claudeAiOauth // empty' 2>/dev/null)
	[ -z "$token_json" ] && return
	token=$(echo "$token_json" | jq -r '.accessToken // empty' 2>/dev/null)
	[ -z "$token" ] && return
	expires_at=$(echo "$token_json" | jq -r '.expiresAt // empty' 2>/dev/null)
	if [ -n "$expires_at" ]; then
		local expires_sec=$((expires_at / 1000))
		if [ "$now" -gt "$expires_sec" ]; then
			log_error "OAuth token expired ($(( (now - expires_sec) / 60 ))min ago), skipping API call"
			# Retry in 60s not 300s. Re-checks keychain for refreshed token.
			touch -t "$(date -j -f %s $((now - 240)) +%Y%m%d%H%M.%S)" "$cache_file" 2>/dev/null
			return
		fi
	fi

	# ── Source 1: Haiku probe (primary) ──
	# 1-token Haiku call reads utilization from response headers.
	# Zero utilization impact on Max plan (verified: consecutive probes identical %).
	# Works even when /api/oauth/usage is 429'd (separate rate limit domain).
	local headers h5_util h5_reset h7_util h7_reset h5_status h7_status h_claim
	headers=$(curl -sD- --max-time 8 -o /dev/null \
		-H "Authorization: Bearer $token" \
		-H "Content-Type: application/json" \
		-H "anthropic-beta: oauth-2025-04-20" \
		-H "anthropic-version: 2023-06-01" \
		-d '{"model":"claude-haiku-4-5-20251001","max_tokens":1,"messages":[{"role":"user","content":"h"}]}' \
		"https://api.anthropic.com/v1/messages" 2>/dev/null)

	if [ -n "$headers" ]; then
		h5_util=$(echo "$headers" | grep -i 'anthropic-ratelimit-unified-5h-utilization' | tr -d '\r' | awk '{print $2}')
		h7_util=$(echo "$headers" | grep -i 'anthropic-ratelimit-unified-7d-utilization' | tr -d '\r' | awk '{print $2}')
		h5_reset=$(echo "$headers" | grep -i 'anthropic-ratelimit-unified-5h-reset' | tr -d '\r' | awk '{print $2}')
		h7_reset=$(echo "$headers" | grep -i 'anthropic-ratelimit-unified-7d-reset' | tr -d '\r' | awk '{print $2}')
		# Status (allowed→allowed_warning→rejected) + which window binds (representative-claim):
		# free extra signal from the same response, harvested for the telemetry ledger.
		h5_status=$(echo "$headers" | grep -i 'anthropic-ratelimit-unified-5h-status' | tr -d '\r' | awk '{print $2}')
		h7_status=$(echo "$headers" | grep -i 'anthropic-ratelimit-unified-7d-status' | tr -d '\r' | awk '{print $2}')
		h_claim=$(echo "$headers" | grep -i 'anthropic-ratelimit-unified-representative-claim' | tr -d '\r' | awk '{print $2}')

		if [ -n "$h5_util" ] || [ -n "$h7_util" ]; then
			local pct5 pct7 iso5 iso7
			[ -n "$h5_util" ] && pct5=$(awk "BEGIN{printf \"%.1f\", $h5_util * 100}")
			[ -n "$h7_util" ] && pct7=$(awk "BEGIN{printf \"%.1f\", $h7_util * 100}")
			[ -n "$h5_reset" ] && iso5=$(date -u -r "$h5_reset" "+%Y-%m-%dT%H:%M:%S+00:00" 2>/dev/null)
			[ -n "$h7_reset" ] && iso7=$(date -u -r "$h7_reset" "+%Y-%m-%dT%H:%M:%S+00:00" 2>/dev/null)

			# Carry forward extra_usage (usage credits) from the previous cache — probe
			# headers don't expose it; only the /api/oauth/usage fallback refreshes it.
			local prev_extra
			prev_extra=$(jq -c '.extra_usage // null' "$cache_file" 2>/dev/null) || prev_extra=null
			[ -z "$prev_extra" ] && prev_extra=null

			local json
			json=$(jq -n \
				--argjson t "$now" \
				--argjson h5 "${pct5:-null}" \
				--arg r5 "${iso5:-}" \
				--argjson h7 "${pct7:-null}" \
				--arg r7 "${iso7:-}" \
				--arg s5 "${h5_status:-}" \
				--arg s7 "${h7_status:-}" \
				--arg claim "${h_claim:-}" \
				--argjson extra "$prev_extra" \
				'{
					five_hour: {utilization: $h5, resets_at: (if $r5 == "" then null else $r5 end), status: (if $s5 == "" then null else $s5 end)},
					seven_day: {utilization: $h7, resets_at: (if $r7 == "" then null else $r7 end), status: (if $s7 == "" then null else $s7 end)},
					representative_claim: (if $claim == "" then null else $claim end),
					extra_usage: $extra,
					_fetched_at: $t,
					_source: "haiku_probe"
				}' 2>/dev/null)

			if [ -n "$json" ]; then
				echo "$json" > "$cache_file" 2>/dev/null || log_error "Failed to write cache"
				: > "$ERROR_LOG" 2>/dev/null
				return
			fi
		fi
		log_error "Haiku probe: no utilization headers"
	else
		log_error "Haiku probe: no response"
	fi

	# ── Source 2: /api/oauth/usage (fallback) ──
	# Full JSON with extra fields (sonnet breakdown, extra_usage).
	# Rate-limited at ~10/hr — only used when haiku probe fails.
	local usage
	usage=$(curl -s --max-time 5 "https://api.anthropic.com/api/oauth/usage" \
		-H "Authorization: Bearer $token" \
		-H "anthropic-beta: oauth-2025-04-20" 2>/dev/null)

	if [ -n "$usage" ] && \
	   ! echo "$usage" | jq -e '.error' >/dev/null 2>&1 && \
	   [ "$(echo "$usage" | jq -r '.seven_day.utilization // "null"')" != "null" ]; then
		usage=$(echo "$usage" | jq --argjson t "$now" '. + {_fetched_at: $t}')
		echo "$usage" > "$cache_file" 2>/dev/null || log_error "Failed to write cache"
		: > "$ERROR_LOG" 2>/dev/null
		return
	fi

	if [ -z "$usage" ]; then
		log_error "Usage API: timeout or connection failed"
	else
		log_error "Usage API: $(echo "$usage" | jq -r '.error.message // "null response"' 2>/dev/null)"
	fi
}

get_rate_limit() {
	local cache_file="$HOME/.claude/status/rate_limit.json"
	local now usage

	mkdir -p "$HOME/.claude/status" 2>/dev/null
	now=$(date +%s)

	# ── Always read from cache first (never block on network) ──
	# After cold boot: cache is hours old → first render shows stale + strikethrough.
	# Background refresh completes in ~1-5s → next render picks up fresh data.
	# This is the correct tradeoff: fast render > blocking on network.
	if [ -f "$cache_file" ]; then
		local cache_time mtime_age
		cache_time=$(stat -f %m "$cache_file" 2>/dev/null || echo 0)
		mtime_age=$((now - cache_time))

		usage=$(cat "$cache_file" 2>/dev/null)
		[ -n "$usage" ] && _parse_rate_json "$usage"

		# Spawn background refresh if TTL expired
		# Touch BEFORE spawn — concurrent invocations see fresh mtime → skip
		# 120s (2min) TTL — haiku probe has zero utilization impact on Max plan.
		# Previous: 900s with usage API caused 84% shown at 99%. Then 300s still missed 10% jump.
		if [ "$mtime_age" -ge 120 ]; then
			touch "$cache_file" 2>/dev/null
			(_refresh_rate_limit &) 2>/dev/null

			# Sleep/wake: roll back mtime so next render retries in 60s not 300s.
			# First render shows stale data; background refresh lands in 1-5s.
			if [ "$mtime_age" -ge 3600 ]; then
				touch -t "$(date -j -f %s $((now - 240)) +%Y%m%d%H%M.%S)" "$cache_file" 2>/dev/null
			fi
		fi
	else
		# No cache at all (first run or deleted) — spawn refresh
		touch "$cache_file" 2>/dev/null
		(_refresh_rate_limit &) 2>/dev/null
	fi
}

# ---- Telemetry ledger (append-only usage history) ----
# Recycles the haiku probe + this render's stdin — ZERO extra API calls — into a
# flat, one-object-per-line JSONL history for later analysis (heatmaps, burn rate,
# limit-drift detection). Rate-limit utilization/reset/status is ephemeral and NOT
# in transcripts, so it can only be captured live; cost/context/lines come straight
# from Claude Code's stdin as Anthropic's own numbers (no ccusage estimate needed).
# One flat row per fresh probe (deduped by _fetched_at); idle renders add nothing.
# Runs in the main path (needs $input); append is tail-1 + jq + >> — never blocks.
_append_telemetry() {
	# Zero-cost gate: only act when the rate sample is fresh (a probe just landed → one
	# new row due). ~80% of renders bail here on a single integer test — no subprocess,
	# no latency. The <40s window aligns with the gold τ; ts-dedup below stops repeats.
	[ "${rate_content_age:-999}" -lt 40 ] || return

	# Per-host file (telemetry-<host>.jsonl) — each fleet machine owns its own, so the
	# git-crypt-committed ledgers sync without merge conflicts; analysis globs them all.
	local host; host=$(hostname -s 2>/dev/null || echo unknown)
	local ledger="$HOME/.claude/status/telemetry-${host}.jsonl"
	local cache_file="$HOME/.claude/status/rate_limit.json"
	[ -f "$cache_file" ] || return

	local fetched last_ts in_json row
	fetched=$(jq -r '._fetched_at // empty' "$cache_file" 2>/dev/null)
	[ -z "$fetched" ] && return                       # no valid probe data yet

	# Dedup: one row per unique probe. Skip if the last row already logged this fetch.
	last_ts=$(tail -1 "$ledger" 2>/dev/null | jq -r '.ts // empty' 2>/dev/null)
	[ "$last_ts" = "$fetched" ] && return

	# Whole stdin, compacted; null if it isn't valid JSON (stdin fields fall to null).
	in_json=$(echo "$input" | jq -c . 2>/dev/null) || in_json=null
	[ -z "$in_json" ] && in_json=null

	# Raw + unbiased: store the whole rate-limit object and the whole stdin payload
	# exactly as Claude Code gives them — no field-dropping, no flattening, no renaming.
	# Envelope only: v (schema), ts (dedup+sort key), host (cross-fleet key). Perfect
	# future analytics flattens at read time; you can't recover a field biased away here.
	row=$(jq -cn --slurpfile rl "$cache_file" --argjson in "$in_json" --arg host "$host" '
		{v: 1, ts: ($rl[0]._fetched_at), host: $host, rl: $rl[0], in: $in}' 2>/dev/null) || return

	[ -n "$row" ] && printf '%s\n' "$row" >> "$ledger" 2>/dev/null
}

# ---- Session tracking (Δ elapsed) ----
elapsed_str=""
get_session_elapsed() {
	local now last_activity session_start elapsed_min
	local activity_cache="/tmp/claude_last_activity.cache"
	local session_cache="/tmp/claude_session_start.cache"

	now=$(date +%s)

	# Check last activity
	if [ -f "$activity_cache" ]; then
		last_activity=$(cat "$activity_cache" 2>/dev/null)
		if [ -n "$last_activity" ] && [ $((now - last_activity)) -gt 1800 ]; then
			# > 30 min idle - new session
			echo "$now" > "$session_cache"
		fi
	else
		# First run - new session
		echo "$now" > "$session_cache"
	fi

	# Update last activity
	echo "$now" > "$activity_cache"

	# Get session start
	if [ -f "$session_cache" ]; then
		session_start=$(cat "$session_cache" 2>/dev/null)
		if [ -n "$session_start" ]; then
			elapsed_min=$(((now - session_start) / 60))

			# Format: single value — 45m, 1.1h, 1.2d
			if [ "$elapsed_min" -lt 60 ]; then
				elapsed_str="${elapsed_min}m"
			elif [ "$elapsed_min" -lt 1440 ]; then
				elapsed_str=$(awk "BEGIN { printf \"%.1fh\", $elapsed_min / 60 }")
			else
				elapsed_str=$(awk "BEGIN { printf \"%.1fd\", $elapsed_min / 1440 }")
			fi
		fi
	fi
}

# ---- Weekly active total (Σ) - Non-blocking incremental ----
# NEVER blocks statusline. Always returns immediately.
# Background job handles expensive scanning incrementally.

# Background refresh function (runs detached, never blocks statusline)
# MUST be defined before get_weekly_active since it's called from there
# Calculates wall clock session time by detecting 30-min gaps in timestamps
refresh_weekly_activity() {
	local state_file="$HOME/.claude/status/weekly_activity.json"
	local lockfile="$HOME/.claude/status/weekly_activity.lock"

	# Prevent concurrent updates (with stale lock detection)
	if [ -f "$lockfile" ]; then
		local lock_age=$(($(date +%s) - $(stat -f %m "$lockfile" 2>/dev/null || echo 0)))
		if [ "$lock_age" -gt 600 ]; then
			rm -f "$lockfile"  # Stale lock from crashed process (>10 min old)
		else
			return 0  # Recent lock, another process is running
		fi
	fi
	touch "$lockfile" 2>/dev/null || return 0
	trap 'rm -f "$lockfile" 2>/dev/null' EXIT

	# Get billing window
	local window_end
	window_end=$(jq -r '.seven_day.resets_at // empty' "$HOME/.claude/status/rate_limit.json" 2>/dev/null)
	[ -z "$window_end" ] && { rm -f "$lockfile"; return 0; }

	local reset_epoch window_start_epoch window_start
	reset_epoch=$(date -j -u -f "%Y-%m-%dT%H:%M:%S" "${window_end%%.*}" "+%s" 2>/dev/null)
	window_start_epoch=$((reset_epoch - 7*24*60*60))
	window_start=$(date -u -r $window_start_epoch +%Y-%m-%dT%H:%M:%S 2>/dev/null)

	# Wall clock session time: extract timestamps → epoch via jq → detect 30-min gaps
	# jq converts ISO to epoch (macOS awk lacks mktime), sort -n, awk sums sessions
	touch -t "$(date -r "$window_start_epoch" '+%Y%m%d%H%M.%S')" \
		"$HOME/.claude/status/.window_marker" 2>/dev/null
	local total_min
	total_min=$(/usr/bin/find "$HOME/.claude/projects" -maxdepth 2 -name "*.jsonl" -type f \
		-newer "$HOME/.claude/status/.window_marker" -exec cat {} + 2>/dev/null | \
		jq -r --arg start "$window_start" \
			'select(.timestamp != null and .timestamp >= $start) |
			 .timestamp | sub("\\.[0-9]+Z$"; "") | strptime("%Y-%m-%dT%H:%M:%S") | mktime' 2>/dev/null | \
		sort -n | awk '
		{
			if (NR == 1) { session_start = $1; prev = $1; next }
			if ($1 - prev > 1800) {
				total += prev - session_start
				session_start = $1
			}
			prev = $1
		}
		END {
			total += prev - session_start
			printf "%d", total / 60
		}')

	# Save state
	local now_epoch
	now_epoch=$(date +%s)
	jq -n --arg ws "$window_start" --argjson t "${total_min:-0}" --argjson e "$now_epoch" \
		'{window_start: $ws, total_activity_min: $t, last_update_epoch: $e}' \
		> "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"

	rm -f "$lockfile"
}

weekly_str=""
weekly_dim=""
get_weekly_active() {
	local state_file="$HOME/.claude/status/weekly_activity.json"
	local lockfile="$HOME/.claude/status/weekly_activity.lock"
	local now total_min last_update update_age

	# Ensure status directory exists
	mkdir -p "$HOME/.claude/status" 2>/dev/null

	now=$(date +%s)

	# ALWAYS return immediately with cached value
	if [ -f "$state_file" ]; then
		total_min=$(jq -r '.total_activity_min // 0' "$state_file" 2>/dev/null || echo 0)
		last_update=$(jq -r '.last_update_epoch // 0' "$state_file" 2>/dev/null || echo 0)
		update_age=$((now - last_update))

		# Dim when data source is stale (>10min without update)
		if [ "$update_age" -gt 600 ]; then
			weekly_dim="$STRIKE"
		fi

		# Format with appropriate unit: minutes, hours, or days
		if [ "$total_min" -lt 60 ]; then
			weekly_str="${total_min}m"
		elif [ "$total_min" -lt 1440 ]; then
			local val=$(awk "BEGIN {printf \"%.1f\", $total_min / 60}")
			val=${val%.0}
			weekly_str="${val}h"
		else
			local val=$(awk "BEGIN {printf \"%.1f\", $total_min / 1440}")
			val=${val%.0}
			weekly_str="${val}d"
		fi

		# Check for stale lock (>10 min old = crashed process) - always clean up
		if [ -f "$lockfile" ]; then
			local lock_age=$((now - $(stat -f %m "$lockfile" 2>/dev/null || echo 0)))
			if [ "$lock_age" -gt 600 ]; then
				rm -f "$lockfile"
			fi
		fi

		# Trigger background refresh if stale (>5min) and not already running
		if [ "$update_age" -gt 300 ] && [ ! -f "$lockfile" ]; then
			(refresh_weekly_activity &) 2>/dev/null
		fi
	else
		# No state file - return 0, trigger initial build
		weekly_str="0m"
		[ ! -f "$lockfile" ] && (refresh_weekly_activity &) 2>/dev/null
	fi
}

# ---- Runway calculation (Θ) ----
# Bug fix (2026-03): Θ icon was inside 5h printf block. When 5h resets_at was
# in the past (stale cache), entire 5h block skipped → icon disappeared.
# Fix: runway_icon_printed flag — Θ prints before whichever block renders first.
# Also: fallback when 5h reset is past but utilization exists (window just reset).
five_hour_runway="" five_hour_reset="" five_hour_reset_stale=""
seven_day_runway="" seven_day_reset=""
five_hour_pace_ratio="" seven_day_pace_ratio=""

get_runways() {
	local now reset_epoch seconds_until
	now=$(date +%s)

	# 5h reset time (decimal hours)
	if [ -n "$five_hour_reset_sec" ]; then
		reset_epoch=$(date -j -u -f "%Y-%m-%dT%H:%M:%S" "${five_hour_reset_sec%%.*}" "+%s" 2>/dev/null)
		if [ -n "$reset_epoch" ]; then
			if [ "$reset_epoch" -gt "$now" ]; then
				seconds_until=$((reset_epoch - now))
				five_hour_reset=$(awk "BEGIN {printf \"%.1f\", $seconds_until / 3600}")
				five_hour_reset=${five_hour_reset%.0}
			elif [ -n "$_fetched_at" ] && [ "$reset_epoch" -gt "$_fetched_at" ]; then
				# Stale: reset was future when fetched, now past (e.g., >5h sleep)
				# Show what value was at fetch time — real API data, strikethrough
				seconds_until=$((reset_epoch - _fetched_at))
				five_hour_reset=$(awk "BEGIN {printf \"%.1f\", $seconds_until / 3600}")
				five_hour_reset=${five_hour_reset%.0}
				five_hour_reset_stale=1
			fi
		fi
	fi

	# 7d reset time (decimal days)
	if [ -n "$seven_day_reset_sec" ]; then
		reset_epoch=$(date -j -u -f "%Y-%m-%dT%H:%M:%S" "${seven_day_reset_sec%%.*}" "+%s" 2>/dev/null)
		if [ -n "$reset_epoch" ] && [ "$reset_epoch" -gt "$now" ]; then
			seconds_until=$((reset_epoch - now))
			# Always show 1 decimal for granularity (e.g., 6.9d not 7d)
			seven_day_reset=$(awk "BEGIN { printf \"%.1f\", $seconds_until / 86400 }")
		fi
	fi

	# 5h runway and pace (decimal hours)
	if [ -n "$rate_pct" ] && [ -n "$five_hour_reset" ] && [ -z "$five_hour_reset_stale" ]; then
		local hours_into_5h=$(awk "BEGIN {printf \"%.2f\", 5 - $five_hour_reset}")
		if [ "$(echo "$hours_into_5h > 0" | bc -l)" -eq 1 ]; then
			# Current burn rate (%/h). Floor elapsed at 0.5h (~10% of the window):
			# right after a reset the denominator is tiny, so a little usage extrapolates
			# to a wildly inflated rate/runway — assume ≥0.5h of context, don't extrapolate
			# from noise. A genuine emergency (huge % in minutes) still clears the floor:
			# even a 100%/h burn accumulates enough % to go red within ~12 min regardless.
			local elapsed_5h=$(awk "BEGIN {h=$hours_into_5h; printf \"%.2f\", (h < 0.5 ? 0.5 : h)}")
			local burn_rate=$(awk "BEGIN {printf \"%.2f\", $rate_pct / $elapsed_5h}")
			if [ "$(echo "$burn_rate > 0" | bc -l)" -eq 1 ]; then
				five_hour_runway=$(awk "BEGIN {printf \"%.1f\", (100 - $rate_pct) / $burn_rate}")
				five_hour_runway=${five_hour_runway%.0}

				# Sustainable pace (%/h). At exactly 100% used, sustainable=0 →
				# division blows up; runway is 0h, pace pegged at max-red (2026-07-06)
				local sustainable_pace=$(awk "BEGIN {printf \"%.2f\", (100 - $rate_pct) / $five_hour_reset}")
				if [ "$(echo "$sustainable_pace > 0" | bc -l)" -eq 1 ]; then
					five_hour_pace_ratio=$(awk "BEGIN {printf \"%.2f\", $burn_rate / $sustainable_pace}")
				else
					five_hour_runway="0"
					five_hour_pace_ratio="9.99"
				fi
			fi
			# else: 0% utilization — no burn rate, runway/pace stay empty (reset time still shows)
		fi
		# else: just reset (hours_into_5h ≤ 0) — no burn rate yet, reset time still shows
	fi

	# 7d runway and pace (decimal days)
	if [ -n "$weekly_pct" ] && [ -n "$seven_day_reset" ]; then
		local days_into_week=$(awk "BEGIN {printf \"%.2f\", 7 - $seven_day_reset}")
		if [ "$(echo "$days_into_week > 0" | bc -l)" -eq 1 ]; then
			# Current burn rate (%/d). Floor elapsed at 0.5d (~7% of the window) — same
			# early-window noise guard as the 5h path (see above).
			local elapsed_week=$(awk "BEGIN {d=$days_into_week; printf \"%.2f\", (d < 0.5 ? 0.5 : d)}")
			local burn_rate=$(awk "BEGIN {printf \"%.2f\", $weekly_pct / $elapsed_week}")
			if [ "$(echo "$burn_rate > 0" | bc -l)" -eq 1 ]; then
				seven_day_runway=$(awk "BEGIN {printf \"%.1f\", (100 - $weekly_pct) / $burn_rate}")
				seven_day_runway=${seven_day_runway%.0}

				# Guard division when reset imminent OR quota fully used (2026-07-06)
				if [ "$(echo "$seven_day_reset > 0" | bc -l)" -eq 1 ]; then
					local sustainable_pace=$(awk "BEGIN {printf \"%.2f\", (100 - $weekly_pct) / $seven_day_reset}")
					if [ "$(echo "$sustainable_pace > 0" | bc -l)" -eq 1 ]; then
						seven_day_pace_ratio=$(awk "BEGIN {printf \"%.2f\", $burn_rate / $sustainable_pace}")
					else
						seven_day_runway="0"
						seven_day_pace_ratio="9.99"
					fi
				else
					seven_day_pace_ratio="0.5"
				fi
			fi
			# else: 0% utilization — no burn rate, runway/pace stay empty (reset time still shows)
		fi
		# else: just reset (days_into_week ≤ 0) — no burn rate yet, reset time still shows
	fi
}

get_daily_budget() {
	local current_7d="$1"
	local days_until_reset="$2"

	# Budget variance: expected usage at this point minus actual usage.
	# expected = (days_elapsed / 7) × 100. Positive = under budget, negative = over.
	# 0% at reset is correct: nothing spent, nothing owed.
	local days_elapsed
	days_elapsed=$(awk "BEGIN { de = 7.0 - $days_until_reset; if (de > 7) de = 7; printf \"%.4f\", de }")
	awk "BEGIN { printf \"%d\", sprintf(\"%.0f\", ($days_elapsed / 7.0) * 100.0 - $current_7d) }"
}

# ---- Fetch all data ----
get_context
get_rate_limit
_append_telemetry   # recycle probe + stdin into telemetry.jsonl (no extra API calls)
get_session_elapsed
get_weekly_active
get_runways

# Get daily budget (7d only - 5h resets too frequently for daily tracking)
seven_day_budget=""
mu_recovery_h=""
if [ -n "$weekly_pct" ] && [ -n "$seven_day_reset" ]; then
	seven_day_budget=$(get_daily_budget "$weekly_pct" "$seven_day_reset")
	# Hours off the on-pace line. Schedule rate is constant (100%/168h), so
	# recovery = |μ| × 1.68. Negative μ: idle hours to reach 0%. Positive μ:
	# hours you're ahead of schedule (banked headroom). Rounded whole hours.
	mu_recovery_h=$(awk "BEGIN { b = $seven_day_budget; if (b < 0) b = -b; printf \"%.0f\", b * 1.68 }")
fi

# ---- Render statusline ----
# ॐ = single anchor: model section icon AND vim state via color
# (orange normal/off, green insert, gold visual)
printf '%b %s%s%s' "${vim_color}ॐ${RESET}" "$model_name" "$thinking_indicator" "$effort_indicator"

# ψ Context (superscript ¹ᴹ marks a 1M-context session — % means 5× more there)
if [ -n "$context_pct" ]; then
	ctx_colored=$(color_value "${context_pct}%" "$context_pct" 20 40 65 80)
	window_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty' 2>/dev/null)
	window_mark=""
	[ "$window_size" = "1000000" ] && window_mark="¹ᴹ"
	printf ' %b %s%s' "$ICON_CTX" "$ctx_colored" "$window_mark"
fi

# κ Cache-hit % (token-efficiency dial: cache reads / all input-side tokens this turn)
# ≥80 green (healthy prefix reuse) · 50-79 plain · <50 orange (cache being invalidated)
cache_pct=$(echo "$input" | jq -r '
	(.context_window.current_usage // {}) as $u |
	(($u.cache_read_input_tokens // 0) + ($u.cache_creation_input_tokens // 0) + ($u.input_tokens // 0)) as $total |
	if $total > 1000 then (($u.cache_read_input_tokens // 0) * 100 / $total | floor) else empty end' 2>/dev/null)
# Early-warning gate: κ hidden while healthy (≥70 — safely ignorable). Appearing =
# cache efficiency degrading with time to fix (don't edit early context, keep turns
# <5min apart). STATUSLINE_VERBOSE=1 shows it always (green when healthy).
# Default: always shown ("show everything, optimize later"). STATUSLINE_MINIMAL=1
# enables the early-warning gate (hide while ≥70 = safely ignorable).
if [ -n "$cache_pct" ] && { [ -z "${STATUSLINE_MINIMAL:-}" ] || [ "$cache_pct" -lt 70 ]; }; then
	if [ "$cache_pct" -ge 80 ]; then cache_col="$BLUE"
	elif [ "$cache_pct" -ge 70 ]; then cache_col=""
	elif [ "$cache_pct" -ge 40 ]; then cache_col="$ORANGE"
	else cache_col="$RED"; fi
	printf ' %b%s%%%b' "$cache_col" "$cache_pct" "$RESET"   # merged into ψ: κ glyph dropped, cache = 2nd % after context (color-coded)
fi

# μ Budget variance (expected - actual at this point in the week)
# Positive = under budget. Negative = overspent. 0 = exactly on pace.
# Strikethrough stale utilization values (>2h = genuinely broken)
# 7200s = 8 missed refresh cycles at 900s TTL. Known issue:
# /api/oauth/usage returns intermittent 429s (GitHub #30930).
rate_stale=""
if [ "$rate_content_age" -gt 7200 ]; then
	# Suppress strikethrough if staleness is caused by expired token.
	# Token expiry is benign (computer sleep) — 60s retry picks it up fast.
	# Strikethrough only for genuine API failures (429s, network errors).
	if ! grep -q "token expired" "$ERROR_LOG" 2>/dev/null; then
		rate_stale="$STRIKE"
	fi
fi

# Early-warning gate: μ hidden while on-pace (0..+5 — safely ignorable). Appearing =
# drifting off budget with week left to correct. Orange slightly over, red >5 over,
# gray >5 under (surplus — spend more, you paid for it). VERBOSE shows always.
if [ -n "$seven_day_budget" ] && { [ -z "${STATUSLINE_MINIMAL:-}" ] || [ "$seven_day_budget" -lt 0 ] 2>/dev/null || [ "$seven_day_budget" -gt 5 ] 2>/dev/null || [ -n "$rate_stale" ]; }; then
	omega_color=""
	if [ "$seven_day_budget" -lt -5 ] 2>/dev/null; then
		omega_color="$RED"      # >5% over budget
	elif [ "$seven_day_budget" -lt 0 ] 2>/dev/null; then
		omega_color="$ORANGE"   # slightly over budget — earliest signal
	elif [ "$seven_day_budget" -gt 5 ] 2>/dev/null; then
		omega_color="$GRAY"     # >5% under budget — surplus
	fi

	# Subscript recovery hint (hours off the on-pace line). Omitted at 0% (on-pace).
	mu_sub=""
	if [ -n "$mu_recovery_h" ] && [ "$mu_recovery_h" -ge 1 ] 2>/dev/null; then
		mu_sub=$(to_subscript "${mu_recovery_h}h")
	fi

	if [ -n "$rate_stale" ]; then
		printf ' %b %b%s%%%s%b' "$ICON_OMEGA" "$rate_stale" "$seven_day_budget" "$mu_sub" "$RESET"
	else
		printf ' %b %b%s%%%s%b' "$ICON_OMEGA" "$omega_color" "$seven_day_budget" "$mu_sub" "$RESET"
	fi
fi

# λ Rate limits (5h%, 7d%) — values clamped ≤100 at parse (over-quota shows red 100%)
if [ -n "$rate_pct" ]; then
	rate_colored=$(color_value "$(printf '%.0f' "$rate_pct")%" "${rate_pct%.*}" 10 40 70 90)
	printf ' %b %b%s%b' "$ICON_RATE" "$rate_stale" "$rate_colored" "$RESET"

	if [ -n "$weekly_pct" ]; then
		weekly_colored=$(color_value "$(printf '%.0f' "$weekly_pct")%" "${weekly_pct%.*}" 15 40 65 80)
		printf ' %b%s%b' "$rate_stale" "$weekly_colored" "$RESET"
	fi
fi

# σ Time (session / weekly active) — always shown; time context is never noise
if [ -n "$elapsed_str" ]; then
	if [ -n "$weekly_str" ]; then
		printf ' %b%b %s %s%b' "$weekly_dim" "$ICON_WEEKLY" "$elapsed_str" "$weekly_str" "$RESET"
	else
		printf ' %b %s' "$ICON_WEEKLY" "$elapsed_str"
	fi
elif [ -n "$weekly_str" ]; then
	printf ' %b%b %s%b' "$weekly_dim" "$ICON_WEEKLY" "$weekly_str" "$RESET"
fi

# Runways and resets (color-coded, decimal precision)
# Replaced symbol-based display with color-only for cleaner look and smooth transitions.
# Old symbol logic (≪ < > ≫) commented out below for reference.
# Θ icon is printed once before whichever runway renders first (decoupled from 5h block).

runway_icon_printed=""

# EARLY-WARNING GATE (2026-07-06, user design): θ hides only when SAFELY ignorable
# (pace <0.8× sustainable = on track to make the reset). Appears the moment pace
# reaches 0.8 — early enough to adjust. Orange 0.8-1.2, red >1.2.
# NOTHING deleted: STATUSLINE_VERBOSE=1 restores always-on θ with healthy display.

# Default: θ always shown when data exists ("show everything, optimize later").
# STATUSLINE_MINIMAL=1 hides θ while pace <0.8× sustainable (safely ignorable).
show_5h="" show_7d=""
[ -n "$five_hour_reset" ] && show_5h=1
[ -n "$seven_day_reset" ] && show_7d=1
if [ -n "${STATUSLINE_MINIMAL:-}" ]; then
	show_5h="" show_7d=""
	if [ -n "$five_hour_reset" ] && [ -n "$five_hour_runway" ] && [ -n "$five_hour_pace_ratio" ] \
		&& [ "$(echo "$five_hour_pace_ratio >= 0.8" | bc -l)" -eq 1 ]; then show_5h=1; fi
	if [ -n "$seven_day_reset" ] && [ -n "$seven_day_runway" ] && [ -n "$seven_day_pace_ratio" ] \
		&& [ "$(echo "$seven_day_pace_ratio >= 0.8" | bc -l)" -eq 1 ]; then show_7d=1; fi
fi

if [ -n "$show_5h" ]; then
	runway_icon_printed=1
	if [ "$(echo "${five_hour_pace_ratio:-0} > 1.0" | bc -l)" -eq 1 ]; then
		five_hour_color="$ORANGE"
		[ "$(echo "$five_hour_pace_ratio > 1.25" | bc -l)" -eq 1 ] && five_hour_color="$RED"
		runway_super=$(to_superscript "$five_hour_runway")
		printf ' %b %b%sh%s%b' "$ICON_RUNWAY" "$five_hour_color" "$five_hour_reset" "$runway_super" "$RESET"
	elif [ -n "$five_hour_reset_stale" ]; then
		printf ' %b %b%sh%b' "$ICON_RUNWAY" "$STRIKE" "$five_hour_reset" "$RESET"
	else
		printf ' %b %sh' "$ICON_RUNWAY" "$five_hour_reset"   # verbose healthy path
	fi
fi

if [ -n "$show_7d" ]; then
	[ -z "$runway_icon_printed" ] && printf ' %b' "$ICON_RUNWAY"
	if [ "$(echo "${seven_day_pace_ratio:-0} > 1.0" | bc -l)" -eq 1 ]; then
		seven_day_color="$ORANGE"
		[ "$(echo "$seven_day_pace_ratio > 1.25" | bc -l)" -eq 1 ] && seven_day_color="$RED"
		runway_super=$(to_superscript "$seven_day_runway")
		printf ' %b%sd%s%b' "$seven_day_color" "$seven_day_reset" "$runway_super" "$RESET"
	else
		printf ' %sd' "$seven_day_reset"   # verbose healthy path
	fi
fi

# OLD SYMBOL-BASED LOGIC (commented out 2026-01-09):
# Integer rounding caused discontinuous jumps (0.7h→1h→0h) and confusing visual feedback.
# Symbols were redundant when color already conveys health status.
#
# if [ -n "$five_hour_runway" ] && [ -n "$five_hour_reset" ]; then
# 	runway_5h_display=$five_hour_runway
# 	[ "$runway_5h_display" -gt 9 ] && runway_5h_display=9
# 	symbol_5h=""
# 	if [ "$five_hour_runway" -ge "$((five_hour_reset * 2))" ]; then
# 		symbol_5h="≫"
# 	elif [ "$five_hour_runway" -ge "$five_hour_reset" ]; then
# 		symbol_5h=">"
# 	elif [ "$((five_hour_runway * 2))" -ge "$five_hour_reset" ]; then
# 		symbol_5h="${ORANGE}<${RESET}"
# 	else
# 		symbol_5h="${RED}≪${RESET}"
# 	fi
# 	printf ' %b %b%sh' "$ICON_RUNWAY" "$symbol_5h" "$five_hour_reset"
# fi
#
# if [ -n "$seven_day_runway" ] && [ -n "$seven_day_reset" ]; then
# 	runway_7d_display=$seven_day_runway
# 	[ "$runway_7d_display" -gt 9 ] && runway_7d_display=9
# 	symbol_7d=""
# 	if [ "$seven_day_runway" -ge "$((seven_day_reset * 2))" ]; then
# 		symbol_7d="≫"
# 	elif [ "$seven_day_runway" -ge "$seven_day_reset" ]; then
# 		symbol_7d=">"
# 	elif [ "$((seven_day_runway * 2))" -ge "$seven_day_reset" ]; then
# 		symbol_7d="${ORANGE}<${RESET}"
# 	else
# 		symbol_7d="${RED}≪${RESET}"
# 	fi
# 	printf ' %b%sd' "$symbol_7d" "$seven_day_reset"
# fi

# Π Git: branch +lines -lines (hidden when not in a git repo)
# Disable ERR trap for this section — grep returns 1 on no-match which is normal
cwd=$(echo "$input" | jq -r '.cwd // empty' 2>/dev/null)
if [ -n "$cwd" ]; then
	branch=$(git -C "$cwd" branch --show-current 2>/dev/null | cut -c1-16) || true
	if [ -n "$branch" ]; then
		printf ' %b %s' "$ICON_GIT" "$branch"
		# Diff stats: tracked changes + untracked file count
		diffstat=$(git -C "$cwd" diff --shortstat HEAD 2>/dev/null) || true
		untracked=$(git -C "$cwd" ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ') || true
		if [ -n "$diffstat" ] || [ "${untracked:-0}" -gt 0 ]; then
			ins=$(echo "$diffstat" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+') || true
			del=$(echo "$diffstat" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+') || true
			# Add untracked files to insertion count (new content)
			if [ "${untracked:-0}" -gt 0 ] && [ -n "$ins" ]; then
				ins=$((ins + untracked))
			elif [ "${untracked:-0}" -gt 0 ]; then
				ins=$untracked
			fi
			[ -n "$ins" ] && printf ' %b+%s%b' "$BLUE" "$ins" "$RESET"
			[ -n "$del" ] && printf ' %b-%s%b' "$RED" "$del" "$RESET"
		fi
	fi
fi

# $ Session value — far right, past pacing. Dim number = API-equivalent ESTIMATE
# (subscription scoreboard: higher = better). Orange ¢ number = REAL usage-credit
# spend (post 2026-07-08 Fable draws credits) — only renders when credits burned.
# Field names defensive (shape unverified until first real credit spend).
cost_usd=$(echo "$input" | jq -r '.cost.total_cost_usd // empty' 2>/dev/null)
if [ -n "$cost_usd" ] && awk "BEGIN {exit !($cost_usd >= 0.01)}" 2>/dev/null; then
	printf ' %b %b%.2f%b' "$ICON_COST" "$DIM" "$cost_usd" "$RESET"
fi
if [ -n "$extra_usd" ] && awk "BEGIN {exit !($extra_usd > 0)}" 2>/dev/null; then
	printf ' %b¢%.2f%b' "$ORANGE" "$extra_usd" "$RESET"
fi

# ---- τ telemetry heartbeat ----
# tau = telemetry. Gold = the rate-limit sample is fresh (a probe captured within
# ~one refresh interval → a row just landed this cycle); dim = between captures.
# Keyed to sample freshness (rate_content_age), NOT "did THIS render append": the
# ledger is shared across sessions, so an append-based flag would only ever fire in
# whichever session won the race. Freshness is true in EVERY session at once.
if [ -n "$rate_content_age" ] && [ "$rate_content_age" -lt 40 ]; then
	printf ' %bτ%b' "$B" "$RESET"
else
	printf ' %bτ%b' "$DIM" "$RESET"
fi

printf '\n'
