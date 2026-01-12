#!/bin/bash
# High-performance Claude Code statusline
# Output: ॐ O Ψ 55% λ 40% 30% Δ 2h 15m Σ 8.5h Θ 8|4h 9|6d
#
# Error handling: Log errors but always show something (even if incomplete)
set -o pipefail
trap 'log_error "Script failed at line $LINENO"' ERR
#
# ============================================================================
# FORMAT BREAKDOWN
# ============================================================================
# ॐ O Ψ 55% λ 40% 30% Δ 2h 15m Σ 8.5h Θ 8|4h 9|6d
# │ │ │     │  │    │        │    │    │
# │ │ │     │  │    │        │    │    └── 7d: runway|reset (days)
# │ │ │     │  │    │        │    └── 5h: runway|reset (hours, floored)
# │ │ │     │  │    │        └── weekly active total (45m → 8.5h → 1.8d)
# │ │ │     │  │    └── session elapsed (resets after 30 min inactivity)
# │ │ │     │  └── 7d used %
# │ │ │     └── 5h used %
# │ │ └── context %
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
# - Context %: transcript file
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

# ---- Get context % from transcript ----
context_pct=""
get_context() {
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
# Calculates TRUE wall-clock usage (matches Anthropic's view) by merging all timestamps globally
refresh_weekly_activity() {
	local state_file="$HOME/.claude/status/weekly_activity.json"
	local lockfile="$HOME/.claude/status/weekly_activity.lock"
	local window_end reset_epoch window_start_epoch window_start
	local state prev_window file mtime cached_mtime new_state

	# Prevent concurrent updates
	if [ -f "$lockfile" ]; then
		return 0
	fi
	touch "$lockfile" 2>/dev/null || return 0

	# Get billing window
	window_end=$(cat "$HOME/.claude/status/rate_limit.json" 2>/dev/null | jq -r '.seven_day.resets_at // empty' 2>/dev/null)
	if [ -z "$window_end" ]; then
		rm -f "$lockfile"
		return 0
	fi

	# Calculate window start
	reset_epoch=$(date -j -u -f "%Y-%m-%dT%H:%M:%S" "${window_end%%.*}" "+%s" 2>/dev/null)
	window_start_epoch=$((reset_epoch - 7*24*60*60))
	window_start=$(date -u -r $window_start_epoch +%Y-%m-%dT%H:%M:%S 2>/dev/null)

	# Load existing state
	state='{}'
	[ -f "$state_file" ] && state=$(cat "$state_file" 2>/dev/null || echo '{}')

	# Check if billing window changed (reset)
	prev_window=$(echo "$state" | jq -r '.window_start // empty' 2>/dev/null)
	if [ "$prev_window" != "$window_start" ]; then
		state='{"file_states":{},"global_timestamps":[]}'
	fi

	# Step 1: Collect timestamps from modified files only
	local new_timestamps_file=$(mktemp)
	for file in ~/.claude/projects/*/*.jsonl; do
		[ ! -f "$file" ] && continue

		mtime=$(stat -f %m "$file" 2>/dev/null || echo 0)
		cached_mtime=$(echo "$state" | jq -r --arg f "$file" '.file_states[$f].mtime // empty' 2>/dev/null)

		# Only extract timestamps from modified files
		if [ "$cached_mtime" != "$mtime" ]; then
			jq -r 'select(.timestamp) | .timestamp' "$file" 2>/dev/null >> "$new_timestamps_file"
		fi
	done

	# Step 2: Merge with cached global timestamps, filter by window, deduplicate, sort
	local merged_timestamps=$(mktemp)
	{
		echo "$state" | jq -r '.global_timestamps[]?' 2>/dev/null
		cat "$new_timestamps_file" 2>/dev/null
	} | awk -v start="$window_start" '$0 >= start' | sort -u > "$merged_timestamps"

	# Step 3: Calculate wall-clock activity from merged stream
	local total_sec=0 prev_epoch=""
	while read -r ts; do
		curr_epoch=$(date -j -u -f "%Y-%m-%dT%H:%M:%S" "${ts%%.*}" "+%s" 2>/dev/null)
		if [ -n "$prev_epoch" ] && [ -n "$curr_epoch" ]; then
			gap=$((curr_epoch - prev_epoch))
			if [ "$gap" -lt 180 ] && [ "$gap" -ge 0 ]; then
				total_sec=$((total_sec + gap))
			fi
		fi
		prev_epoch="$curr_epoch"
	done < "$merged_timestamps"

	local total_min=$((total_sec / 60))

	# Step 4: Build new state with global timestamps and updated file mtimes
	new_state='{"file_states":{}}'
	for file in ~/.claude/projects/*/*.jsonl; do
		[ ! -f "$file" ] && continue
		mtime=$(stat -f %m "$file" 2>/dev/null || echo 0)
		new_state=$(echo "$new_state" | jq --arg f "$file" --argjson m "$mtime" \
			'.file_states[$f] = {mtime: $m}' 2>/dev/null)
	done

	# Add global timestamps array
	local timestamps_json=$(jq -R -s 'split("\n") | map(select(length > 0))' < "$merged_timestamps")
	new_state=$(echo "$new_state" | jq --argjson ts "$timestamps_json" \
		'.global_timestamps = $ts' 2>/dev/null)

	# Save state atomically
	local now_epoch=$(date +%s)
	new_state=$(echo "$new_state" | jq --arg ws "$window_start" --argjson t "$total_min" --argjson e "$now_epoch" \
		'. + {window_start: $ws, total_activity_min: $t, last_update_epoch: $e, last_update: now | todate}' 2>/dev/null)
	echo "$new_state" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"

	# Cleanup
	rm -f "$new_timestamps_file" "$merged_timestamps" "$lockfile"
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

		# Trigger background refresh if stale (>5min) and not already running
		if [ "$update_age" -gt 300 ] && [ ! -f "$lockfile" ]; then
			# Spawn detached background job
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
			seven_day_reset=$(awk "BEGIN {printf \"%.1f\", $seconds_until / 86400}")
			seven_day_reset=${seven_day_reset%.0}
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

				# Sustainable pace (%/d)
				local sustainable_pace=$(awk "BEGIN {printf \"%.2f\", (100 - $weekly_pct) / $seven_day_reset}")
				# Pace ratio (current / sustainable)
				seven_day_pace_ratio=$(awk "BEGIN {printf \"%.2f\", $burn_rate / $sustainable_pace}")
			fi
		fi
	fi
}

get_daily_budget() {
	local current_7d="$1"
	local days_until_reset="$2"

	# Calculate where we SHOULD be at this point in the 7d window
	local days_elapsed=$(awk "BEGIN { printf \"%.2f\", 7.0 - $days_until_reset }")
	local ideal_position=$(awk "BEGIN { printf \"%.1f\", ($days_elapsed / 7.0) * 100 }")

	# Budget = ideal position - actual position
	# Positive = under budget (ahead of pace)
	# Negative = over budget (behind ideal, need break)
	local budget=$(awk "BEGIN { printf \"%.0f\", $ideal_position - $current_7d }")

	# If over budget, calculate hours of break needed
	# Ideal advances at: 100% / 7d = 14.286%/day = 0.595%/hour
	local break_hours=""
	if [ "$budget" -lt 0 ] 2>/dev/null; then
		local deficit=$(awk "BEGIN { printf \"%.1f\", -1 * $budget }")
		break_hours=$(awk "BEGIN { printf \"%.0f\", $deficit / 0.595 }")
	fi

	# Output: budget hours_needed (space-separated for parsing)
	echo "$budget $break_hours"
}

# ---- Fetch all data ----
get_context
get_rate_limit
get_session_elapsed
get_weekly_active
get_runways

# Get daily budget (7d only - 5h resets too frequently for daily tracking)
seven_day_budget=""
seven_day_break_hours=""
if [ -n "$weekly_pct" ] && [ -n "$seven_day_reset" ]; then
	read seven_day_budget seven_day_break_hours <<< "$(get_daily_budget "$weekly_pct" "$seven_day_reset")"
fi

# ---- Render statusline ----
printf '%b %s' "$ICON_MODEL" "$model_name"

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

# Omega: Position vs ideal pace (7d only)
if [ -n "$seven_day_budget" ]; then
	omega_color=""
	break_display=""

	# Add break hours if over budget
	if [ -n "$seven_day_break_hours" ]; then
		break_display="[${seven_day_break_hours}h]"
	fi

	# Color based on deficit vs ideal
	if [ "$seven_day_budget" -lt -10 ] 2>/dev/null; then
		omega_color="$RED"      # Critical: >10% over ideal
	elif [ "$seven_day_budget" -lt 0 ] 2>/dev/null; then
		omega_color="$ORANGE"   # Warning: slightly over ideal
	fi
	# else: on pace or ahead (white)

	if [ -n "$omega_color" ]; then
		printf ' %b %b%s%% %s%b' "$ICON_OMEGA" "$omega_color" "$seven_day_budget" "$break_display" "$RESET"
	else
		printf ' %b %s%% %s' "$ICON_OMEGA" "$seven_day_budget" "$break_display"
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
	# Determine color based on pace ratio (current burn rate vs sustainable pace)
	five_hour_color=""
	if [ "$(echo "$five_hour_pace_ratio > 1.5" | bc -l)" -eq 1 ]; then
		five_hour_color="$RED"      # critical: burning >1.5× sustainable rate
	elif [ "$(echo "$five_hour_pace_ratio > 1.0" | bc -l)" -eq 1 ]; then
		five_hour_color="$ORANGE"   # warning: burning >1.0× sustainable rate
	fi
	# else: on track (pace <= sustainable), no color (white)

	# Add superscript runway time
	runway_super=$(to_superscript "$five_hour_runway")
	printf ' %b %b%sh%s%b' "$ICON_RUNWAY" "$five_hour_color" "$five_hour_reset" "$runway_super" "$RESET"
fi

if [ -n "$seven_day_runway" ] && [ -n "$seven_day_reset" ] && [ -n "$seven_day_pace_ratio" ]; then
	# Determine color based on pace ratio (current burn rate vs sustainable pace)
	seven_day_color=""
	if [ "$(echo "$seven_day_pace_ratio > 1.5" | bc -l)" -eq 1 ]; then
		seven_day_color="$RED"      # critical: burning >1.5× sustainable rate
	elif [ "$(echo "$seven_day_pace_ratio > 1.0" | bc -l)" -eq 1 ]; then
		seven_day_color="$ORANGE"   # warning: burning >1.0× sustainable rate
	fi
	# else: on track (pace <= sustainable), no color (white)

	# Add superscript runway time
	runway_super=$(to_superscript "$seven_day_runway")
	printf ' %b%sd%s%b' "$seven_day_color" "$seven_day_reset" "$runway_super" "$RESET"
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
