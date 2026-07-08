#!/usr/bin/env bash
# Tiny append-only logger called from yabai signals.
# Usage: debug-log.sh <event-name> [detail1 detail2 ...]
# Writes to ~/.local/state/yabai/debug.log with wall-clock timestamp.
# Silent on error so yabai's signal chain is never broken by a broken logger.

LOG_DIR="$HOME/.local/state/yabai"
LOG_FILE="$LOG_DIR/debug.log"

mkdir -p "$LOG_DIR" 2>/dev/null || exit 0

event="${1:-unknown}"
shift 2>/dev/null || true
printf '%s  %-24s  %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$event" "$*" >> "$LOG_FILE" 2>/dev/null || true
