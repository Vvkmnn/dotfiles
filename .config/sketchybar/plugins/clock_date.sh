#!/usr/bin/env sh

# Clock date part with analog clock icon
YEAR=$(date '+%Y')
MONTH=$(printf "%02d" $(date '+%-m'))
DAY=$(printf "%02d" $(date '+%-d'))
HOUR=$(date '+%-H')

# Calculate which clock face to show (12 hour positions)
HOUR_12=$((HOUR % 12))
[ $HOUR_12 -eq 0 ] && HOUR_12=12

# SF Symbols clock faces for each hour
case $HOUR_12 in
    1) CLOCK_ICON="􀐱" ;;  # 1 o'clock
    2) CLOCK_ICON="􀐲" ;;  # 2 o'clock  
    3) CLOCK_ICON="􀐳" ;;  # 3 o'clock
    4) CLOCK_ICON="􀐴" ;;  # 4 o'clock
    5) CLOCK_ICON="􀐵" ;;  # 5 o'clock
    6) CLOCK_ICON="􀐶" ;;  # 6 o'clock
    7) CLOCK_ICON="􀐷" ;;  # 7 o'clock
    8) CLOCK_ICON="􀐸" ;;  # 8 o'clock
    9) CLOCK_ICON="􀐹" ;;  # 9 o'clock
    10) CLOCK_ICON="􀐺" ;; # 10 o'clock
    11) CLOCK_ICON="􀐻" ;; # 11 o'clock
    12) CLOCK_ICON="􀐰" ;; # 12 o'clock
esac

sketchybar --set clock_date label="$YEAR $MONTH $DAY" \
                           icon="$CLOCK_ICON"