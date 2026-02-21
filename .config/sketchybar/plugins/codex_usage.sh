#!/usr/bin/env bash

# Compact Codex usage indicator for weekly and 5-hour windows

ITEM_NAME="${NAME:-codex_usage}"
LOGO_ITEM="${LOGO_ITEM:-codex_logo}"
TARGET="${1:-combined}"
SESSION_DIR="$HOME/.codex/sessions"
HISTORY_FILE="$HOME/.codex/history.jsonl"
RECENT_MINUTES=15

# Palette reused from bar configuration
COLOR_NORMAL="0xffD8DCDE"
COLOR_WARN="0xffFFA500"
COLOR_CRIT="0xffE74C3C"
COLOR_DIM="0xff606060"
COLOR_FIXED="0xffFFFFFF"

# Dynamic coloring disabled for now; keep thresholds above for easy restore.
# pick_color() {
#     local percent="$1"
#     if [ "$percent" = "--" ]; then
#         echo "$COLOR_DIM"
#     elif [ "$percent" -lt 60 ]; then
#         echo "$COLOR_NORMAL"
#     elif [ "$percent" -lt 85 ]; then
#         echo "$COLOR_WARN"
#     else
#         echo "$COLOR_CRIT"
#     fi
# }

show_item() {
    sketchybar --set "$ITEM_NAME" \
        icon.drawing=off \
        label.drawing=on \
        padding_left=3 \
        padding_right=6
    sketchybar --set "$LOGO_ITEM" drawing=on
}

hide_item() {
    sketchybar --set "$ITEM_NAME" \
        icon.drawing=off \
        label.drawing=off \
        padding_left=0 \
        padding_right=0
    sketchybar --set "$LOGO_ITEM" drawing=off
    exit 0
}

set_placeholder() {
    local label="$1"
    show_item
    sketchybar --set "$ITEM_NAME" label="$label" label.color="$COLOR_FIXED"
    exit 0
}

if [ ! -d "$SESSION_DIR" ] || ! command -v jq >/dev/null 2>&1; then
    hide_item
fi

NOW_EPOCH=$(date +%s)
HISTORY_MTIME=$(stat -f %m "$HISTORY_FILE" 2>/dev/null)
HISTORY_AGE_MIN=999999
if [ -n "$HISTORY_MTIME" ]; then
    HISTORY_AGE_MIN=$(( (NOW_EPOCH - HISTORY_MTIME) / 60 ))
fi

# Hide if no codex usage recently
if [ ! -f "$HISTORY_FILE" ] || [ "$HISTORY_AGE_MIN" -gt "$RECENT_MINUTES" ]; then
    hide_item
fi

LATEST_DATA=""

while IFS='|' read -r _ filepath; do
    [ -z "$filepath" ] && continue
    TOKEN_LINE=$(jq -r '
        select(.type == "event_msg" and .payload.type == "token_count") |
        [.payload.rate_limits.primary.used_percent,
         .payload.rate_limits.secondary.used_percent] | @tsv
    ' "$filepath" 2>/dev/null | tail -n1)
    if [ -n "$TOKEN_LINE" ]; then
        LATEST_DATA="$TOKEN_LINE"
        break
    fi

done < <(find "$SESSION_DIR" -type f -name "*.jsonl" -exec stat -f "%m|%N" {} \; | sort -rn)

if [ -z "$LATEST_DATA" ]; then
    hide_item
fi

PRIMARY_USED=$(echo "$LATEST_DATA" | awk '{print $1}')
SECONDARY_USED=$(echo "$LATEST_DATA" | awk '{print $2}')

if [ -z "$PRIMARY_USED" ] || [ -z "$SECONDARY_USED" ] || [ "$PRIMARY_USED" = "null" ] || [ "$SECONDARY_USED" = "null" ]; then
    hide_item
fi

PRIMARY_INT=$(printf "%.0f" "$PRIMARY_USED" 2>/dev/null)
SECONDARY_INT=$(printf "%.0f" "$SECONDARY_USED" 2>/dev/null)

if ! [ "$PRIMARY_INT" -ge 0 ] 2>/dev/null || ! [ "$SECONDARY_INT" -ge 0 ] 2>/dev/null; then
    hide_item
fi

case "$TARGET" in
    combined|both|compact)
        MAX_INT=$PRIMARY_INT
        [ "$SECONDARY_INT" -gt "$MAX_INT" ] && MAX_INT=$SECONDARY_INT
        LABEL="${PRIMARY_INT}% ${SECONDARY_INT}%"
        show_item
        sketchybar --set "$ITEM_NAME" label="$LABEL" label.color="$COLOR_FIXED"
        ;;
    primary|5h|five|5H)
        show_item
        sketchybar --set "$ITEM_NAME" label="${PRIMARY_INT}%" label.color="$COLOR_FIXED"
        ;;
    secondary|week|weekly|7d|7D)
        show_item
        sketchybar --set "$ITEM_NAME" label="${SECONDARY_INT}%" label.color="$COLOR_FIXED"
        ;;
    *)
        MAX_INT=$PRIMARY_INT
        [ "$SECONDARY_INT" -gt "$MAX_INT" ] && MAX_INT=$SECONDARY_INT
        LABEL="${PRIMARY_INT}% ${SECONDARY_INT}%"
        show_item
        sketchybar --set "$ITEM_NAME" label="$LABEL" label.color="$COLOR_FIXED"
        ;;
esac
