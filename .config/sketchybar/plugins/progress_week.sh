#!/usr/bin/env sh

# Week progress indicator
# Shows ISO week number (e.g., 51) and progress through week

# Get ISO week number
WEEK=$(date '+%V')

# Get day of week (1=Monday, 7=Sunday)
DAY_OF_WEEK=$(date '+%u')

# Get current hour and minute
HOUR=$(date '+%-H')
MINUTE=$(date '+%-M')

# Calculate minutes into week (Monday 00:00 = 0)
MINUTES_INTO_WEEK=$(( (DAY_OF_WEEK - 1) * 1440 + HOUR * 60 + MINUTE ))

# Total minutes in week
TOTAL_MINUTES=10080  # 7 * 24 * 60

# Calculate percentage (0-100)
PROGRESS=$((MINUTES_INTO_WEEK * 100 / TOTAL_MINUTES))

# Old implementations (commented out)
# 2-position track: if [ $PROGRESS -le 50 ]; then TRACK="●─"; else TRACK="━●"; fi
# Dot separator: sketchybar --set progress_week label="W${WEEK}·${PROGRESS}%"

# New: Context + superscript percentage (W51⁵³)
PROGRESS_SUPER=$(echo "$PROGRESS" | sed 's/0/⁰/g; s/1/¹/g; s/2/²/g; s/3/³/g; s/4/⁴/g; s/5/⁵/g; s/6/⁶/g; s/7/⁷/g; s/8/⁸/g; s/9/⁹/g')
sketchybar --set progress_week label="W${WEEK}${PROGRESS_SUPER}"