#!/bin/bash
# Minimal Claude Code statusline
# Output: λ Opus 4.5 ▶ 57% ⧖ 39m 3h 7d ◐ 12%

input=$(cat)

# ---- Icon themes (comment/uncomment to switch) ----
# Style A: Emoji
# ICON_MODEL='🕉'; ICON_RATE='🤖'; ICON_TIME='⏳'; ICON_CTX='🧠'
# Style B: ASCII with blue
B='\033[34m'; R='\033[0m'  # blue, reset (or use \033[94m for bright blue)
ICON_MODEL="${B}ॐ${R}"; ICON_RATE="${B}λ${R}"; ICON_ELAPSED="${B}Δ${R}"; ICON_TIME="${B}Θ${R}"; ICON_CTX="${B}Ψ${R}"
# Alt icons: Δ (delta), ⧖ (hourglass), ⏣ (benzene/chip), ◐ (half-circle)

# ---- Check jq ----
command -v jq >/dev/null 2>&1 || {
	echo "🕉  Claude"
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

# ---- Get time remaining from ccusage (independent of API) ----
time_mins=""
time_hours=""
time_days=""
elapsed_hours=""
elapsed_mins=""
get_time_remaining() {
	local ccusage_json remaining_mins start_time start_epoch now_epoch elapsed_total
	local days hours mins

	ccusage_json=$(bun x ccusage blocks --json 2>/dev/null)

	# Get remaining time
	remaining_mins=$(echo "$ccusage_json" | jq -r '.blocks[] | select(.isActive == true) | .projection.remainingMinutes // empty' 2>/dev/null)

	if [ -n "$remaining_mins" ] && [ "$remaining_mins" -gt 0 ] 2>/dev/null; then
		days=$((remaining_mins / 1440))
		hours=$(((remaining_mins % 1440) / 60))
		mins=$((remaining_mins % 60))

		[ "$mins" -gt 0 ] && time_mins="${mins}m"
		[ "$hours" -gt 0 ] && time_hours="${hours}h"
		[ "$days" -gt 0 ] && time_days="${days}d"
	fi

	# Get elapsed time from first activity (not window start)
	start_time=$(echo "$ccusage_json" | jq -r '.blocks[] | select(.isActive == true) | .startTime // empty' 2>/dev/null)
	block_id=$(echo "$ccusage_json" | jq -r '.blocks[] | select(.isActive == true) | .id // empty' 2>/dev/null)

	if [ -n "$start_time" ] && [ -n "$block_id" ]; then
		cache_file="/tmp/claude_first_activity_${block_id}.cache"
		first_activity=""

		# Check cache
		if [ -f "$cache_file" ]; then
			first_activity=$(cat "$cache_file" 2>/dev/null)
		else
			# Find first activity in this billing block (expensive, so cache it)
			window_start="${start_time%%.*}"
			first_activity=$(find ~/.claude/projects -name "*.jsonl" -type f -newermt "${window_start/T/ } UTC" -exec head -1 {} \; 2>/dev/null | \
				jq -r "select(.timestamp >= \"${start_time}\") | .timestamp" 2>/dev/null | sort | head -1)

			# Cache for future calls
			if [ -n "$first_activity" ]; then
				echo "$first_activity" > "$cache_file"
			fi
		fi

		# Calculate elapsed from first activity
		if [ -n "$first_activity" ]; then
			start_epoch=$(date -j -u -f "%Y-%m-%dT%H:%M:%S" "${first_activity%%.*}" "+%s" 2>/dev/null)
			now_epoch=$(date "+%s")
			if [ -n "$start_epoch" ] && [ "$now_epoch" -gt "$start_epoch" ]; then
				elapsed_total=$(( (now_epoch - start_epoch) / 60 ))
				hours=$((elapsed_total / 60))
				mins=$((elapsed_total % 60))
				[ "$hours" -gt 0 ] && elapsed_hours="${hours}h"
				[ "$mins" -gt 0 ] && elapsed_mins="${mins}m"
			fi
		fi
	fi
}

# ---- Get rate limit % from API (independent of time) ----
rate_pct=""
weekly_pct=""
weekly_days=""
get_rate_limit() {
	local creds token usage

	creds=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null) || return
	token=$(echo "$creds" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
	[ -z "$token" ] && return

	usage=$(curl -s --max-time 2 "https://api.anthropic.com/api/oauth/usage" \
		-H "Authorization: Bearer $token" \
		-H "anthropic-beta: oauth-2025-04-20" 2>/dev/null)

	[ -z "$usage" ] && return

	# Check for error response
	echo "$usage" | jq -e '.error' >/dev/null 2>&1 && return

	rate_pct=$(echo "$usage" | jq -r '.five_hour.utilization // empty' 2>/dev/null)
	weekly_pct=$(echo "$usage" | jq -r '.seven_day.utilization // empty' 2>/dev/null)

	# Calculate days until weekly reset
	weekly_reset=$(echo "$usage" | jq -r '.seven_day.resets_at // empty' 2>/dev/null)
	if [ -n "$weekly_reset" ]; then
		reset_epoch=$(date -j -u -f "%Y-%m-%dT%H:%M:%S" "${weekly_reset%%.*}" "+%s" 2>/dev/null)
		now_epoch=$(date "+%s")
		if [ -n "$reset_epoch" ] && [ "$reset_epoch" -gt "$now_epoch" ]; then
			days_remaining=$(((reset_epoch - now_epoch + 86399) / 86400))
			weekly_days="${days_remaining}d"
		fi
	fi
}

# ---- Get context % from transcript file ----
context_pct=""
get_context() {
	local transcript_path latest_tokens
	local MAX_CONTEXT=200000

	transcript_path=$(echo "$input" | jq -r '.transcript_path // empty' 2>/dev/null)
	[ -z "$transcript_path" ] || [ ! -f "$transcript_path" ] && return

	latest_tokens=$(tail -20 "$transcript_path" 2>/dev/null | jq -r 'select(.message.usage) | .message.usage | ((.input_tokens // 0) + (.cache_read_input_tokens // 0))' 2>/dev/null | tail -1)

	if [ -n "$latest_tokens" ] && [ "$latest_tokens" -gt 0 ]; then
		context_pct=$((latest_tokens * 100 / MAX_CONTEXT))
	else
		context_pct=0
	fi
}

# ---- Fetch data (independent calls) ----
get_time_remaining
get_rate_limit
get_context

# ---- Render single line ----
printf '%b %s' "$ICON_MODEL" "$model_name"

# Context field (always show)
printf ' %b %d%%' "$ICON_CTX" "${context_pct:-0}"

# Session field: 🤖 rate% weekly% (time) - show whatever is available
if [ -n "$rate_pct" ] || [ -n "$time_mins" ] || [ -n "$time_hours" ] || [ -n "$time_days" ]; then
	printf ' %b' "$ICON_RATE"
	if [ -n "$rate_pct" ]; then
		printf ' %.0f%%' "$rate_pct"
		if [ -n "$weekly_pct" ]; then
			printf ' %.0f%%' "$weekly_pct"
		fi
		# Show elapsed time first
		if [ -n "$elapsed_hours" ] || [ -n "$elapsed_mins" ]; then
			printf ' %b' "$ICON_ELAPSED"
			[ -n "$elapsed_hours" ] && printf ' %s' "$elapsed_hours"
			[ -n "$elapsed_mins" ] && printf ' %s' "$elapsed_mins"
		fi
		# Then show remaining time
		if [ -n "$time_mins" ] || [ -n "$time_hours" ] || [ -n "$time_days" ] || [ -n "$weekly_days" ]; then
			printf ' %b' "$ICON_TIME"
			# Output in order: mins, hours, days
			[ -n "$time_mins" ] && printf ' %s' "$time_mins"
			[ -n "$time_hours" ] && printf ' %s' "$time_hours"
			[ -n "$time_days" ] && printf ' %s' "$time_days"
			[ -n "$weekly_days" ] && printf ' %s' "$weekly_days"
		fi
	elif [ -n "$time_mins" ] || [ -n "$time_hours" ] || [ -n "$time_days" ]; then
		printf ' %b' "$ICON_TIME"
		[ -n "$time_mins" ] && printf ' %s' "$time_mins"
		[ -n "$time_hours" ] && printf ' %s' "$time_hours"
		[ -n "$time_days" ] && printf ' %s' "$time_days"
	fi
fi

printf '\n'
