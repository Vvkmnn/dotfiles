#!/usr/bin/env sh

# Month progress indicator
# Shows month number (e.g., 12) and progress through month

# Get month number
MONTH=$(date '+%-m')

# Get current day of month
DAY_OF_MONTH=$(date '+%-d')

# Calculate days in current month (macOS)
DAYS_IN_MONTH=$(date -v1d -v+1m -v-1d '+%d')

# Calculate percentage (0-100)
PROGRESS=$((DAY_OF_MONTH * 100 / DAYS_IN_MONTH))

# Old implementations (commented out)
# 2-position track: if [ $PROGRESS -le 50 ]; then TRACK="●─"; else TRACK="━●"; fi
# Dot separator: sketchybar --set progress_month label="M${MONTH}·${PROGRESS}%"

# New: Context + superscript percentage (M12⁶¹)
PROGRESS_SUPER=$(echo "$PROGRESS" | sed 's/0/⁰/g; s/1/¹/g; s/2/²/g; s/3/³/g; s/4/⁴/g; s/5/⁵/g; s/6/⁶/g; s/7/⁷/g; s/8/⁸/g; s/9/⁹/g')
sketchybar --set progress_month label="M${MONTH}${PROGRESS_SUPER}"