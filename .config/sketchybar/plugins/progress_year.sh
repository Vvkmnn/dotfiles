#!/usr/bin/env sh

# Year progress indicator
# Shows year number (e.g., 25) and progress through year

# Get year (short form)
YEAR=$(date '+%y')

# Calculate progress through year
DAY_OF_YEAR=$(date '+%j')
# Check for leap year
CURRENT_YEAR=$(date '+%Y')
if [ $((CURRENT_YEAR % 4)) -eq 0 ] && { [ $((CURRENT_YEAR % 100)) -ne 0 ] || [ $((CURRENT_YEAR % 400)) -eq 0 ]; }; then
    DAYS_IN_YEAR=366
else
    DAYS_IN_YEAR=365
fi

# Calculate percentage (0-100)
PROGRESS=$((DAY_OF_YEAR * 100 / DAYS_IN_YEAR))

# Old implementations (commented out)
# 2-position track: if [ $PROGRESS -le 50 ]; then TRACK="●─"; else TRACK="━●"; fi
# Dot separator: sketchybar --set progress_year label="Y${YEAR}·${PROGRESS}%"

# New: Context + superscript percentage (Y25⁹⁷)
# Convert percentage digits to superscript
PROGRESS_SUPER=$(echo "$PROGRESS" | sed 's/0/⁰/g; s/1/¹/g; s/2/²/g; s/3/³/g; s/4/⁴/g; s/5/⁵/g; s/6/⁶/g; s/7/⁷/g; s/8/⁸/g; s/9/⁹/g')
sketchybar --set progress_year label="Y${YEAR}${PROGRESS_SUPER}"