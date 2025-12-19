#!/usr/bin/env bash

# Compact Codex usage indicator for weekly and 5-hour windows

ITEM_NAME="${NAME:-codex_usage}"
TARGET="${1:-combined}"
SESSION_DIR="$HOME/.codex/sessions"

# Palette reused from bar configuration
COLOR_NORMAL="0xffD8DCDE"
COLOR_WARN="0xffFFA500"
COLOR_CRIT="0xffE74C3C"
COLOR_DIM="0xff606060"

pick_color() {
    local percent="$1"
    if [ "$percent" = "--" ]; then
        echo "$COLOR_DIM"
    elif [ "$percent" -lt 60 ]; then
        echo "$COLOR_NORMAL"
    elif [ "$percent" -lt 85 ]; then
        echo "$COLOR_WARN"
    else
        echo "$COLOR_CRIT"
    fi
}

hide_item() {
    sketchybar --set "$ITEM_NAME" \
        icon.drawing=off \
        label.drawing=off \
        padding_left=0 \
        padding_right=0
    exit 0
}

set_placeholder() {
    local label="$1"
    local color
    color=$(pick_color "--")
    sketchybar --set "$ITEM_NAME" label="$label" label.color="$color" icon.color="$color"
    exit 0
}

if [ ! -d "$SESSION_DIR" ] || ! command -v jq >/dev/null 2>&1; then
    if [ "$TARGET" = "combined" ]; then
        set_placeholder "W--D--"
    else
        set_placeholder "--"
    fi
fi

# Hide if no codex usage today
if ! find "$SESSION_DIR" -type f -name "*.jsonl" -mtime 0 2>/dev/null | grep -q .; then
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
    if [ "$TARGET" = "combined" ]; then
        set_placeholder "W--D--"
    else
        set_placeholder "--"
    fi
fi

PRIMARY_USED=$(echo "$LATEST_DATA" | awk '{print $1}')
SECONDARY_USED=$(echo "$LATEST_DATA" | awk '{print $2}')

# Validate raw values
if [ -z "$PRIMARY_USED" ] || [ -z "$SECONDARY_USED" ] || [ "$PRIMARY_USED" = "null" ] || [ "$SECONDARY_USED" = "null" ]; then
    if [ "$TARGET" = "combined" ]; then
        set_placeholder "W--D--"
    else
        set_placeholder "--"
    fi
fi

PRIMARY_INT=$(printf "%.0f" "$PRIMARY_USED" 2>/dev/null)
SECONDARY_INT=$(printf "%.0f" "$SECONDARY_USED" 2>/dev/null)

if ! [ "$PRIMARY_INT" -ge 0 ] 2>/dev/null || ! [ "$SECONDARY_INT" -ge 0 ] 2>/dev/null; then
    if [ "$TARGET" = "combined" ]; then
        set_placeholder "W--D--"
    else
        set_placeholder "--"
    fi
fi

case "$TARGET" in
    combined|both|compact)
        MAX_INT=$PRIMARY_INT
        [ "$SECONDARY_INT" -gt "$MAX_INT" ] && MAX_INT=$SECONDARY_INT
        COLOR=$(pick_color "$MAX_INT")
        LABEL="W${SECONDARY_INT}% D${PRIMARY_INT}%"
        sketchybar --set "$ITEM_NAME" icon.color="$COLOR" label="$LABEL" label.color="$COLOR"
        ;;
    primary|5h|five|5H)
        COLOR=$(pick_color "$PRIMARY_INT")
        sketchybar --set "$ITEM_NAME" icon.color="$COLOR" label="D${PRIMARY_INT}%" label.color="$COLOR"
        ;;
    secondary|week|weekly|7d|7D)
        COLOR=$(pick_color "$SECONDARY_INT")
        sketchybar --set "$ITEM_NAME" icon.color="$COLOR" label="W${SECONDARY_INT}%" label.color="$COLOR"
        ;;
    *)
        MAX_INT=$PRIMARY_INT
        [ "$SECONDARY_INT" -gt "$MAX_INT" ] && MAX_INT=$SECONDARY_INT
        COLOR=$(pick_color "$MAX_INT")
        LABEL="W${SECONDARY_INT}%D${PRIMARY_INT}%"
        sketchybar --set "$ITEM_NAME" icon.color="$COLOR" label="$LABEL" label.color="$COLOR"
        ;;
esac
