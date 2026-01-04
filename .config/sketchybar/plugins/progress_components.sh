#!/usr/bin/env sh
# Progress components: multi-item progress indicator with sunrise/sunset markers
# 7 positions = ~3.43 hours per segment

# === Sunrise/Sunset Calculation with Caching ===
CACHE_FILE="/tmp/sketchybar_sunrise_cache_$(date +%Y%m%d)"

if [ -f "$CACHE_FILE" ]; then
    # Use cached values from today
    source "$CACHE_FILE"
else
    # Calculate new values for today
    # Use seasonal approximation (sunwait not available)
    MONTH=$(date '+%-m')
    if [ $MONTH -ge 3 ] && [ $MONTH -le 9 ]; then
        # Spring/Summer (Mar-Sep)
        SUNRISE_HOUR=6
        SUNRISE_MIN=30
        SUNSET_HOUR=20
        SUNSET_MIN=0
    else
        # Fall/Winter (Oct-Feb)
        SUNRISE_HOUR=7
        SUNRISE_MIN=30
        SUNSET_HOUR=17
        SUNSET_MIN=30
    fi

    # Cache for the day
    echo "SUNRISE_HOUR=$SUNRISE_HOUR" > "$CACHE_FILE"
    echo "SUNRISE_MIN=$SUNRISE_MIN" >> "$CACHE_FILE"
    echo "SUNSET_HOUR=$SUNSET_HOUR" >> "$CACHE_FILE"
    echo "SUNSET_MIN=$SUNSET_MIN" >> "$CACHE_FILE"
fi

# === Day Calculation ===
DAY_OF_YEAR=$(date '+%j')
DAY_OF_YEAR=$((10#$DAY_OF_YEAR))

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

# === Progress Calculation ===
HOUR=$(date '+%-H')
MINUTE=$(date '+%-M')
MINUTES_INTO_DAY=$((HOUR * 60 + MINUTE))
PROGRESS=$((MINUTES_INTO_DAY * 100 / 1440))

# Map to 7 positions (0-6)
DOT_POS=$((PROGRESS * 7 / 100))
if [ $DOT_POS -gt 6 ]; then
    DOT_POS=6
fi

# Calculate sunrise/sunset positions (in minutes, then map to 7 positions)
SUNRISE_MINUTES=$((SUNRISE_HOUR * 60 + SUNRISE_MIN))
SUNSET_MINUTES=$((SUNSET_HOUR * 60 + SUNSET_MIN))
SUNRISE_POS=$((SUNRISE_MINUTES * 7 / 1440))
SUNSET_POS=$((SUNSET_MINUTES * 7 / 1440))

# === Build Track Segments ===
# We need to build segments split by sunrise/sunset positions

# Filled portion before sunrise
FILLED_BEFORE_SUNRISE=""
if [ $DOT_POS -ge $SUNRISE_POS ]; then
    for i in $(seq 0 $((SUNRISE_POS - 1))); do
        if [ $i -le $DOT_POS ]; then
            FILLED_BEFORE_SUNRISE="${FILLED_BEFORE_SUNRISE}━"
        fi
    done
else
    for i in $(seq 0 $((DOT_POS - 1))); do
        FILLED_BEFORE_SUNRISE="${FILLED_BEFORE_SUNRISE}━"
    done
fi

# Sunrise marker/segment - line when passed, circle when not reached
if [ $DOT_POS -ge $SUNRISE_POS ]; then
    SUNRISE_SEGMENT="━"  # Passed - show as orange line
else
    SUNRISE_SEGMENT="○"  # Not reached - show as orange circle
fi

# Filled portion after sunrise (up to sunset or current dot, whichever is earlier)
FILLED_AFTER_SUNRISE=""
if [ $DOT_POS -gt $SUNRISE_POS ]; then
    START=$((SUNRISE_POS + 1))
    # Stop before sunset position (sunset has its own item)
    if [ $DOT_POS -lt $SUNSET_POS ]; then
        END=$DOT_POS
    else
        END=$((SUNSET_POS - 1))
    fi

    for i in $(seq $START $END); do
        if [ $i -eq $DOT_POS ]; then
            FILLED_AFTER_SUNRISE="${FILLED_AFTER_SUNRISE}●"
        else
            FILLED_AFTER_SUNRISE="${FILLED_AFTER_SUNRISE}━"
        fi
    done
elif [ $DOT_POS -eq $SUNRISE_POS ]; then
    FILLED_AFTER_SUNRISE="●"
fi

# Unfilled portion before sunset
UNFILLED_BEFORE_SUNSET=""
if [ $DOT_POS -lt $SUNSET_POS ]; then
    START=$((DOT_POS + 1))
    END=$((SUNSET_POS - 1))
    if [ $START -le $END ]; then
        for i in $(seq $START $END); do
            UNFILLED_BEFORE_SUNSET="${UNFILLED_BEFORE_SUNSET}━"
        done
    fi
fi

# Sunset marker/segment - line when passed, circle when not reached
if [ $DOT_POS -ge $SUNSET_POS ]; then
    SUNSET_SEGMENT="━"  # Passed - show as misty blue line
else
    SUNSET_SEGMENT="○"  # Not reached - show as misty blue circle
fi

# Portion after sunset (filled if past sunset, unfilled otherwise)
UNFILLED_AFTER_SUNSET=""
if [ $DOT_POS -gt $SUNSET_POS ]; then
    # Past sunset - show filled from (SUNSET_POS+1) to DOT_POS
    START=$((SUNSET_POS + 1))
    for i in $(seq $START $DOT_POS); do
        if [ $i -eq $DOT_POS ]; then
            UNFILLED_AFTER_SUNSET="${UNFILLED_AFTER_SUNSET}●"
        else
            UNFILLED_AFTER_SUNSET="${UNFILLED_AFTER_SUNSET}━"
        fi
    done
else
    # Not yet at sunset - show unfilled from (SUNSET_POS+1) to 6
    if [ $SUNSET_POS -lt 6 ]; then
        START=$((SUNSET_POS + 1))
        for i in $(seq $START 6); do
            UNFILLED_AFTER_SUNSET="${UNFILLED_AFTER_SUNSET}━"
        done
    fi
fi

# Get current time
TIME=$(date '+%H:%M')

# === Update All Items ===
sketchybar --set progress_day_left label="${DAY_OF_YEAR} " \
           --set progress_filled_before_sunrise label="$FILLED_BEFORE_SUNRISE" \
           --set progress_sunrise label="$SUNRISE_SEGMENT" \
           --set progress_filled_after_sunrise label="$FILLED_AFTER_SUNRISE" \
           --set progress_unfilled_before_sunset label="$UNFILLED_BEFORE_SUNSET" \
           --set progress_sunset label="$SUNSET_SEGMENT" \
           --set progress_unfilled_after_sunset label="$UNFILLED_AFTER_SUNSET" \
           --set progress_day_right label=" ${NEXT_DAY}" \
           --set clock_time label="${TIME}"
