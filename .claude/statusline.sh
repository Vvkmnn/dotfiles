#!/bin/bash
# High-performance Claude Code statusline
# Output: ॐ Oᵀ+ Ψ 55% λ 40% 30% Δ 2h 15m Σ 8.5h Θ 8|4h 9|6d
#
# Error handling: Log errors but always show something (even if incomplete)
set -o pipefail
trap 'log_error "Script failed at line $LINENO"' ERR
#
# ============================================================================
# FORMAT BREAKDOWN
# ============================================================================
# ॐ Oᵀ+ Ψ 55% λ 40% 30% Δ 2h 15m Σ 8.5h Θ 8|4h 9|6d
# │ ││││ │     │  │    │        │    │    │
# │ ││││ │     │  │    │        │    │    └── 7d: runway|reset (days)
# │ ││││ │     │  │    │        │    └── 5h: runway|reset (hours, floored)
# │ ││││ │     │  │    │        └── weekly active total (45m → 8.5h → 1.8d)
# │ ││││ │     │  │    └── session elapsed (resets after 30 min inactivity)
# │ ││││ │     │  └── 7d used %
# │ ││││ │     └── 5h used %
# │ ││││ └── context %
# │ ││└┘── effort (+high, -low, omit medium)
# │ │└── thinking (ᵀ when on)
# │ └── Model (O/S/H)
# └── model icon
#
# COLOR CODING (warning colors for approaching/critical limits):
# - Context (Ψ): orange 60-80%, red >80%
# - 5h used (λ): orange 70-90%, red >90%
# - 7d used (λ): orange 50-75%, red >75%
# - Runway (Θ): PACE-BASED coloring (early warning system)
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
# - < 100ms typical (cached path)
# - < 1s worst case (API call)
# - Aggressive caching, graceful degradation
# ============================================================================

input=$(cat)

# ---- Colors ----
ORANGE='\033[33m'
RED='\033[31m'
RESET='\033[0m'
B='\033[34m' # blue for icons
ICON_MODEL="${B}ॐ${RESET}"
ICON_RATE="${B}λ${RESET}"
ICON_ELAPSED="${B}Δ${RESET}"
ICON_WEEKLY="${B}Σ${RESET}"
ICON_RUNWAY="${B}Θ${RESET}"
ICON_CTX="${B}Ψ${RESET}"
ICON_OMEGA="${B}Ω${RESET}"

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

# ---- Check jq ----
command -v jq >/dev/null 2>&1 || {
	echo "ॐ Claude"
	exit 0
}

# ---- Extract model name ----
display_name=$(echo "$input" | jq -r '.model.display_name // "Claude"' 2>/dev/null)
full_model=$(echo "$display_name" | grep -oE "(Opus|Sonnet|Haiku)" | head -1)
case "$full_model" in
	Opus) model_name="O" ;;
	Sonnet) model_name="S" ;;
	Haiku) model_name="H" ;;
	*) model_name="${display_name:-Claude}" ;;
esac

# ---- Effort indicator (+/-) ----
effort_indicator=""
effort_level=$(jq -r '.effortLevel // "medium"' "$HOME/.claude/settings.json" 2>/dev/null)
case "$effort_level" in
	high)   effort_indicator="+" ;;
	low)    effort_indicator="-" ;;
esac

# ---- Thinking mode (ᵀ) ----
thinking_indicator=""
thinking=$(jq -r '.alwaysThinkingEnabled // false' "$HOME/.claude/settings.json" 2>/dev/null)
[ "$thinking" = "true" ] && thinking_indicator="ᵀ"

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

# ---- Color a value based on percentage thresholds ----
# Usage: color_value <value> <pct> <orange_threshold> <red_threshold>
color_value() {
	local value="$1" pct="$2" orange="$3" red="$4"
	if [ "$pct" -gt "$red" ] 2>/dev/null; then
		echo -e "${RED}${value}${RESET}"
	elif [ "$pct" -gt "$orange" ] 2>/dev/null; then
		echo -e "${ORANGE}${value}${RESET}"
	else
		echo "$value"
	fi
}

# ---- Get rate limits from API with caching ----
rate_pct="" weekly_pct=""
five_hour_reset_sec="" seven_day_reset_sec=""

get_rate_limit() {
	local cache_file="$HOME/.claude/status/rate_limit.json"
	local cache_age now cache_time usage creds token

	# Ensure status directory exists
	mkdir -p "$HOME/.claude/status" 2>/dev/null

	# Check cache freshness
	if [ -f "$cache_file" ]; then
		now=$(date +%s)
		cache_time=$(stat -f %m "$cache_file" 2>/dev/null || echo 0)
		cache_age=$((now - cache_time))

		# Fresh cache (< 30s)
		if [ "$cache_age" -lt 30 ]; then
			usage=$(cat "$cache_file" 2>/dev/null)
			if [ -n "$usage" ]; then
				rate_pct=$(echo "$usage" | jq -r '.five_hour.utilization // empty' 2>/dev/null)
				weekly_pct=$(echo "$usage" | jq -r '.seven_day.utilization // empty' 2>/dev/null)
				five_hour_reset_sec=$(echo "$usage" | jq -r '.five_hour.resets_at // empty' 2>/dev/null)
				seven_day_reset_sec=$(echo "$usage" | jq -r '.seven_day.resets_at // empty' 2>/dev/null)
				return
			fi
		fi
	fi

	# Stale or missing cache - try API
	creds=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null) || {
		# No credentials - use stale cache if available
		[ -f "$cache_file" ] && usage=$(cat "$cache_file" 2>/dev/null)
		if [ -n "$usage" ]; then
			rate_pct=$(echo "$usage" | jq -r '.five_hour.utilization // empty' 2>/dev/null)
			weekly_pct=$(echo "$usage" | jq -r '.seven_day.utilization // empty' 2>/dev/null)
			five_hour_reset_sec=$(echo "$usage" | jq -r '.five_hour.resets_at // empty' 2>/dev/null)
			seven_day_reset_sec=$(echo "$usage" | jq -r '.seven_day.resets_at // empty' 2>/dev/null)
		fi
		return
	}

	token=$(echo "$creds" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
	[ -z "$token" ] && return

	# Fetch from API
	usage=$(curl -s --max-time 2 "https://api.anthropic.com/api/oauth/usage" \
		-H "Authorization: Bearer $token" \
		-H "anthropic-beta: oauth-2025-04-20" 2>/dev/null)

	if [ -n "$usage" ] && ! echo "$usage" | jq -e '.error' >/dev/null 2>&1; then
		# Valid response - cache it
		echo "$usage" > "$cache_file" 2>/dev/null || log_error "Failed to write cache file"
		rate_pct=$(echo "$usage" | jq -r '.five_hour.utilization // empty' 2>/dev/null)
		weekly_pct=$(echo "$usage" | jq -r '.seven_day.utilization // empty' 2>/dev/null)
		five_hour_reset_sec=$(echo "$usage" | jq -r '.five_hour.resets_at // empty' 2>/dev/null)
		seven_day_reset_sec=$(echo "$usage" | jq -r '.seven_day.resets_at // empty' 2>/dev/null)
	else
		# API failed - use stale cache
		if [ -z "$usage" ]; then
			log_error "API timeout or connection failed"
		else
			log_error "API returned error: $(echo "$usage" | jq -r '.error.message // "unknown"' 2>/dev/null)"
		fi

		[ -f "$cache_file" ] && usage=$(cat "$cache_file" 2>/dev/null)
		if [ -n "$usage" ]; then
			log_error "Using stale cache (age: ${cache_age}s)"
			rate_pct=$(echo "$usage" | jq -r '.five_hour.utilization // empty' 2>/dev/null)
			weekly_pct=$(echo "$usage" | jq -r '.seven_day.utilization // empty' 2>/dev/null)
			five_hour_reset_sec=$(echo "$usage" | jq -r '.five_hour.resets_at // empty' 2>/dev/null)
			seven_day_reset_sec=$(echo "$usage" | jq -r '.seven_day.resets_at // empty' 2>/dev/null)
		else
			log_error "No cache available, statusline will be incomplete"
		fi
	fi
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

			# Format: 45m, 2h 15m, 1d 5h 30m
			if [ "$elapsed_min" -lt 60 ]; then
				elapsed_str="${elapsed_min}m"
			elif [ "$elapsed_min" -lt 1440 ]; then
				local h=$((elapsed_min / 60))
				local m=$((elapsed_min % 60))
				elapsed_str="${h}h ${m}m"
			else
				local d=$((elapsed_min / 1440))
				local h=$(((elapsed_min % 1440) / 60))
				local m=$((elapsed_min % 60))
				elapsed_str="${d}d ${h}h ${m}m"
			fi
		fi
	fi
}

# ---- Weekly active total (Σ) - Non-blocking incremental ----
# NEVER blocks statusline. Always returns immediately.
# Background job handles expensive scanning incrementally.

# Background refresh function (runs detached, never blocks statusline)
# MUST be defined before get_weekly_active since it's called from there
# Calculates actual Claude processing time by summing durationMs from jsonl entries
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
	local window_end=$(jq -r '.seven_day.resets_at // empty' "$HOME/.claude/status/rate_limit.json" 2>/dev/null)
	[ -z "$window_end" ] && { rm -f "$lockfile"; return 0; }

	local reset_epoch=$(date -j -u -f "%Y-%m-%dT%H:%M:%S" "${window_end%%.*}" "+%s" 2>/dev/null)
	local window_start_epoch=$((reset_epoch - 7*24*60*60))
	local window_start=$(date -u -r $window_start_epoch +%Y-%m-%dT%H:%M:%S 2>/dev/null)

	# Sum durationMs from files modified in billing window (single pipeline)
	touch -t "$(date -r "$window_start_epoch" '+%Y%m%d%H%M.%S')" \
		"$HOME/.claude/status/.window_marker" 2>/dev/null
	local total_ms=$(/usr/bin/find "$HOME/.claude/projects" -maxdepth 2 -name "*.jsonl" -type f \
		-newer "$HOME/.claude/status/.window_marker" -exec cat {} + 2>/dev/null | \
		jq -r --arg start "$window_start" \
			'select(.timestamp >= $start and .durationMs > 0) | .durationMs' 2>/dev/null | \
		awk '{sum+=$1} END{print sum+0}')
	local total_min=$((total_ms / 60000))

	# Save state
	local now_epoch=$(date +%s)
	jq -n --arg ws "$window_start" --argjson t "$total_min" --argjson e "$now_epoch" \
		'{window_start: $ws, total_activity_min: $t, last_update_epoch: $e}' \
		> "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"

	rm -f "$lockfile"
}

weekly_str=""
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

		# Format and return immediately
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
five_hour_runway="" five_hour_reset=""
seven_day_runway="" seven_day_reset=""
five_hour_pace_ratio="" seven_day_pace_ratio=""

get_runways() {
	local now reset_epoch seconds_until
	now=$(date +%s)

	# 5h reset time (decimal hours)
	if [ -n "$five_hour_reset_sec" ]; then
		reset_epoch=$(date -j -u -f "%Y-%m-%dT%H:%M:%S" "${five_hour_reset_sec%%.*}" "+%s" 2>/dev/null)
		if [ -n "$reset_epoch" ] && [ "$reset_epoch" -gt "$now" ]; then
			seconds_until=$((reset_epoch - now))
			five_hour_reset=$(awk "BEGIN {printf \"%.1f\", $seconds_until / 3600}")
			five_hour_reset=${five_hour_reset%.0}
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
	if [ -n "$rate_pct" ] && [ -n "$five_hour_reset" ]; then
		local hours_into_5h=$(awk "BEGIN {printf \"%.2f\", 5 - $five_hour_reset}")
		if [ "$(echo "$hours_into_5h > 0" | bc -l)" -eq 1 ]; then
			# Current burn rate (%/h)
			local burn_rate=$(awk "BEGIN {printf \"%.2f\", $rate_pct / $hours_into_5h}")
			if [ "$(echo "$burn_rate > 0" | bc -l)" -eq 1 ]; then
				five_hour_runway=$(awk "BEGIN {printf \"%.1f\", (100 - $rate_pct) / $burn_rate}")
				five_hour_runway=${five_hour_runway%.0}

				# Sustainable pace (%/h)
				local sustainable_pace=$(awk "BEGIN {printf \"%.2f\", (100 - $rate_pct) / $five_hour_reset}")
				# Pace ratio (current / sustainable)
				five_hour_pace_ratio=$(awk "BEGIN {printf \"%.2f\", $burn_rate / $sustainable_pace}")
			fi
		fi
	fi

	# 7d runway and pace (decimal days)
	if [ -n "$weekly_pct" ] && [ -n "$seven_day_reset" ]; then
		local days_into_week=$(awk "BEGIN {printf \"%.2f\", 7 - $seven_day_reset}")
		if [ "$(echo "$days_into_week > 0" | bc -l)" -eq 1 ]; then
			# Current burn rate (%/d)
			local burn_rate=$(awk "BEGIN {printf \"%.2f\", $weekly_pct / $days_into_week}")
			if [ "$(echo "$burn_rate > 0" | bc -l)" -eq 1 ]; then
				seven_day_runway=$(awk "BEGIN {printf \"%.1f\", (100 - $weekly_pct) / $burn_rate}")
				seven_day_runway=${seven_day_runway%.0}

				# Guard division when reset imminent
				if [ "$(echo "$seven_day_reset > 0" | bc -l)" -eq 1 ]; then
					local sustainable_pace=$(awk "BEGIN {printf \"%.2f\", (100 - $weekly_pct) / $seven_day_reset}")
					seven_day_pace_ratio=$(awk "BEGIN {printf \"%.2f\", $burn_rate / $sustainable_pace}")
				else
					seven_day_pace_ratio="0.5"
				fi
			fi
		else
			# Just reset (days_into_week ≤ 0) - no burn rate yet, assume healthy
			seven_day_runway="99"
			seven_day_pace_ratio="0.5"
		fi
	fi
}

get_daily_budget() {
	local current_7d="$1"
	local days_until_reset="$2"

	# Daily budget: what % can you use per day sustainably?
	local daily_budget=$(awk "BEGIN { printf \"%.1f\", 100.0 / 7.0 }")  # 14.3%

	# Today's usage: approximate from 7d total and days elapsed
	local days_elapsed=$(awk "BEGIN { printf \"%.2f\", 7.0 - $days_until_reset }")

	# Daily budget remaining = ideal_usage - current_7d
	# Include today (+1) so day 1 has 14.3% budget, cap at 100%
	local days_including_today=$(awk "BEGIN { printf \"%.2f\", $days_elapsed + 1 }")
	local ideal_usage=$(awk "BEGIN { x = $days_including_today * $daily_budget; printf \"%.1f\", (x > 100) ? 100 : x }")
	local budget=$(awk "BEGIN { printf \"%.0f\", $ideal_usage - $current_7d }")

	# Output: just the budget percentage (no break hours)
	echo "$budget"
}

# ---- Fetch all data ----
get_context
get_rate_limit
get_session_elapsed
get_weekly_active
get_runways

# Get daily budget (7d only - 5h resets too frequently for daily tracking)
seven_day_budget=""
if [ -n "$weekly_pct" ] && [ -n "$seven_day_reset" ]; then
	seven_day_budget=$(get_daily_budget "$weekly_pct" "$seven_day_reset")
fi

# ---- Render statusline ----
printf '%b %s%s%s' "$ICON_MODEL" "$model_name" "$thinking_indicator" "$effort_indicator"

# Context
if [ -n "$context_pct" ]; then
	ctx_colored=$(color_value "${context_pct}%" "$context_pct" 50 67)
	printf ' %b %s' "$ICON_CTX" "$ctx_colored"
fi

# Rate limits
if [ -n "$rate_pct" ]; then
	rate_colored=$(color_value "$(printf '%.0f' "$rate_pct")%" "${rate_pct%.*}" 69 90)
	printf ' %b %s' "$ICON_RATE" "$rate_colored"

	if [ -n "$weekly_pct" ]; then
		weekly_colored=$(color_value "$(printf '%.0f' "$weekly_pct")%" "${weekly_pct%.*}" 50 75)
		printf ' %s' "$weekly_colored"
	fi
fi

# Omega: Daily budget remaining (7d only)
if [ -n "$seven_day_budget" ]; then
	omega_color=""

	# Color based on daily budget status
	# Positive = budget remaining today, negative = borrowed from future days
	if [ "$seven_day_budget" -lt -10 ] 2>/dev/null; then
		omega_color="$RED"      # Critical: borrowed >10% from future
	elif [ "$seven_day_budget" -lt 5 ] 2>/dev/null; then
		omega_color="$ORANGE"   # Warning: low daily budget or negative
	fi
	# else: healthy daily budget remaining (white)

	if [ -n "$omega_color" ]; then
		printf ' %b %b%s%%%b' "$ICON_OMEGA" "$omega_color" "$seven_day_budget" "$RESET"
	else
		printf ' %b %s%%' "$ICON_OMEGA" "$seven_day_budget"
	fi
fi

# Session elapsed
if [ -n "$elapsed_str" ]; then
	printf ' %b %s' "$ICON_ELAPSED" "$elapsed_str"
fi

# Weekly active
if [ -n "$weekly_str" ]; then
	printf ' %b %s' "$ICON_WEEKLY" "$weekly_str"
fi

# Runways and resets (color-coded, decimal precision)
# Replaced symbol-based display with color-only for cleaner look and smooth transitions.
# Old symbol logic (≪ < > ≫) commented out below for reference.

if [ -n "$five_hour_runway" ] && [ -n "$five_hour_reset" ] && [ -n "$five_hour_pace_ratio" ]; then
	# Show superscript only when runway < reset (won't make it at current pace)
	# Color based on pace ratio: white ≤0.8, orange 0.8-1.2, red >1.2

	runway_lt_reset=$(echo "$five_hour_runway < $five_hour_reset" | bc -l)

	if [ "$runway_lt_reset" -eq 1 ]; then
		# Runway < reset: show warning with superscript
		five_hour_color=""
		if [ "$(echo "$five_hour_pace_ratio > 1.2" | bc -l)" -eq 1 ]; then
			five_hour_color="$RED"      # critical: pace >1.2× sustainable
		elif [ "$(echo "$five_hour_pace_ratio > 0.8" | bc -l)" -eq 1 ]; then
			five_hour_color="$ORANGE"   # warning: pace 0.8-1.2× sustainable
		fi
		# else: white (pace ≤0.8×)

		runway_super=$(to_superscript "$five_hour_runway")
		printf ' %b %b%sh%s%b' "$ICON_RUNWAY" "$five_hour_color" "$five_hour_reset" "$runway_super" "$RESET"
	else
		# Runway >= reset: all good, no superscript needed
		printf ' %b %sh' "$ICON_RUNWAY" "$five_hour_reset"
	fi
fi

if [ -n "$seven_day_runway" ] && [ -n "$seven_day_reset" ] && [ -n "$seven_day_pace_ratio" ]; then
	# Show superscript only when runway < reset (won't make it at current pace)
	# Color based on pace ratio: white ≤0.8, orange 0.8-1.2, red >1.2

	runway_lt_reset=$(echo "$seven_day_runway < $seven_day_reset" | bc -l)

	if [ "$runway_lt_reset" -eq 1 ]; then
		# Runway < reset: show warning with superscript
		seven_day_color=""
		if [ "$(echo "$seven_day_pace_ratio > 1.2" | bc -l)" -eq 1 ]; then
			seven_day_color="$RED"      # critical: pace >1.2× sustainable
		elif [ "$(echo "$seven_day_pace_ratio > 0.8" | bc -l)" -eq 1 ]; then
			seven_day_color="$ORANGE"   # warning: pace 0.8-1.2× sustainable
		fi
		# else: white (pace ≤0.8×)

		runway_super=$(to_superscript "$seven_day_runway")
		printf ' %b%sd%s%b' "$seven_day_color" "$seven_day_reset" "$runway_super" "$RESET"
	else
		# Runway >= reset: all good, no superscript needed
		printf ' %sd' "$seven_day_reset"
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

printf '\n'
