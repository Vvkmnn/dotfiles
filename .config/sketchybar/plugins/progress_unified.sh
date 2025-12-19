#!/usr/bin/env sh

# Unified progress indicator: day-of-year timeline with current time
# Format: 353━━━●──354 17:13

# Get current day of year
DAY_OF_YEAR=$(date '+%j')
# Remove leading zeros
DAY_OF_YEAR=$((10#$DAY_OF_YEAR))

# Calculate next day (handle year boundary)
CURRENT_YEAR=$(date '+%Y')
if [ $((CURRENT_YEAR % 4)) -eq 0 ] && { [ $((CURRENT_YEAR % 100)) -ne 0 ] || [ $((CURRENT_YEAR % 400)) -eq 0 ]; }; then
    DAYS_IN_YEAR=366
else
    DAYS_IN_YEAR=365
fi

if [ $DAY_OF_YEAR -eq $DAYS_IN_YEAR ]; then
    NEXT_DAY=1
else
    NEXT_DAY=$((DAY_OF_YEAR + 1))
fi

# Calculate progress through day
HOUR=$(date '+%-H')
MINUTE=$(date '+%-M')
MINUTES_INTO_DAY=$((HOUR * 60 + MINUTE))
PROGRESS=$((MINUTES_INTO_DAY * 100 / 1440))

# Render 5-position track for smooth progress
DOT_POS=$((PROGRESS / 20))
if [ $DOT_POS -gt 4 ]; then
    DOT_POS=4
fi

TRACK=""
for i in 0 1 2 3 4; do
    if [ $i -eq $DOT_POS ]; then
        TRACK="${TRACK}●"
    elif [ $i -lt $DOT_POS ]; then
        TRACK="${TRACK}━"
    else
        TRACK="${TRACK}─"
    fi
done

# Get current time in 24-hour format
TIME=$(date '+%H:%M')

# Set label: 353━━━●──354 17:13
sketchybar --set progress_unified label="${DAY_OF_YEAR}${TRACK}${NEXT_DAY} ${TIME}"