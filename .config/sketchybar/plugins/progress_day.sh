#!/usr/bin/env sh

# Day progress indicator
# Shows day of month (e.g., 19) and progress through day

# Get day of month
DAY=$(date '+%-d')

# Get current hour and minute
HOUR=$(date '+%-H')
MINUTE=$(date '+%-M')

# Calculate minutes into day
MINUTES_INTO_DAY=$((HOUR * 60 + MINUTE))

# Total minutes in day
TOTAL_MINUTES=1440  # 24 * 60

# Calculate percentage (0-100)
PROGRESS=$((MINUTES_INTO_DAY * 100 / TOTAL_MINUTES))

# Old implementations (commented out)
# 2-position track: if [ $PROGRESS -le 50 ]; then TRACK="●─"; else TRACK="━●"; fi
# Dot separator: sketchybar --set progress_day label="D${DAY}·${PROGRESS}%"

# New: Context + superscript percentage (D19⁷⁵)
PROGRESS_SUPER=$(echo "$PROGRESS" | sed 's/0/⁰/g; s/1/¹/g; s/2/²/g; s/3/³/g; s/4/⁴/g; s/5/⁵/g; s/6/⁶/g; s/7/⁷/g; s/8/⁸/g; s/9/⁹/g')
sketchybar --set progress_day label="D${DAY}${PROGRESS_SUPER}"