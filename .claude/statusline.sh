#!/bin/bash
# Minimal Claude Code statusline
# Output: λ Opus 4.5 ▶ 57% ⧖ 7d 3h 39m ◐ 12%

input=$(cat)

# ---- Icon themes (comment/uncomment to switch) ----
# Style A: Emoji
# ICON_MODEL='🕉'; ICON_RATE='🤖'; ICON_TIME='⏳'; ICON_CTX='🧠'
# Style B: ASCII with blue
B='\033[34m'; R='\033[0m'  # blue, reset (or use \033[94m for bright blue)
ICON_MODEL="${B}ॐ${R}"; ICON_RATE="${B}λ${R}"; ICON_TIME="${B}Θ${R}"; ICON_CTX="${B}Ψ${R}"
# Alt icons: Δ (delta), ⧖ (hourglass), ⏣ (benzene/chip), ◐ (half-circle)

# ---- Check jq ----
command -v jq >/dev/null 2>&1 || {
	echo "🕉  Claude"
	exit 0
}

# ---- Extract model name ----
model_name=$(echo "$input" | jq -r '.model.display_name // "Claude"' 2>/dev/null | sed 's/ [0-9.]*$//')

# ---- Get time remaining from ccusage (independent of API) ----
time_left=""
get_time_remaining() {
	local remaining_mins hours mins

	remaining_mins=$(bun x ccusage blocks --json 2>/dev/null | jq -r '.blocks[] | select(.isActive == true) | .projection.remainingMinutes // empty' 2>/dev/null)

	if [ -n "$remaining_mins" ] && [ "$remaining_mins" -gt 0 ] 2>/dev/null; then
		hours=$((remaining_mins / 60))
		mins=$((remaining_mins % 60))
		time_left="${hours}h ${mins}m"
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
if [ -n "$rate_pct" ] || [ -n "$time_left" ]; then
	printf ' %b' "$ICON_RATE"
	if [ -n "$rate_pct" ]; then
		printf ' %.0f%%' "$rate_pct"
		if [ -n "$weekly_pct" ]; then
			printf ' %.0f%%' "$weekly_pct"
		fi
		if [ -n "$time_left" ] || [ -n "$weekly_days" ]; then
			# printf ' ('
			printf ' %b ' "$ICON_TIME"
			[ -n "$weekly_days" ] && printf '%s' "$weekly_days"
			[ -n "$weekly_days" ] && [ -n "$time_left" ] && printf ' '
			[ -n "$time_left" ] && printf '%s' "$time_left"
			# printf ')'
		fi
	elif [ -n "$time_left" ]; then
		printf ' %s' "$time_left"
	fi
fi

printf '\n'
