#!/usr/bin/env sh

# Unified progress indicator: day-of-year timeline with current time
# Format: 353━━━●──354 17:13

# === Sunrise/Sunset Lookup (no API) ===
TZ_CITY=$(readlink /etc/localtime | sed 's|.*/zoneinfo/||')
MONTH=$(date +%-m)

# Monthly lookup by city (~15min accuracy)
case "$TZ_CITY" in
    # Australia (Southern Hemisphere - reversed seasons)
    Australia/Sydney|Australia/Melbourne)
        case $MONTH in
            12|1|2) SUNRISE_HOUR=6; SUNSET_HOUR=20 ;;  # Summer
            3|4|5) SUNRISE_HOUR=7; SUNSET_HOUR=18 ;;   # Autumn
            6|7|8) SUNRISE_HOUR=7; SUNSET_HOUR=17 ;;   # Winter
            9|10|11) SUNRISE_HOUR=6; SUNSET_HOUR=19 ;; # Spring
        esac ;;

    # North America - East Coast
    America/New_York|America/Toronto)
        case $MONTH in
            12|1|2) SUNRISE_HOUR=7; SUNSET_HOUR=17 ;;  # Winter
            3|4|5) SUNRISE_HOUR=6; SUNSET_HOUR=19 ;;   # Spring
            6|7|8) SUNRISE_HOUR=6; SUNSET_HOUR=20 ;;   # Summer
            9|10|11) SUNRISE_HOUR=7; SUNSET_HOUR=18 ;; # Autumn
        esac ;;

    # North America - West Coast
    America/Vancouver|America/Los_Angeles)
        case $MONTH in
            12|1|2) SUNRISE_HOUR=8; SUNSET_HOUR=16 ;;
            3|4|5) SUNRISE_HOUR=6; SUNSET_HOUR=19 ;;
            6|7|8) SUNRISE_HOUR=5; SUNSET_HOUR=21 ;;
            9|10|11) SUNRISE_HOUR=7; SUNSET_HOUR=18 ;;
        esac ;;

    # North America - Mountain
    America/Edmonton|America/Calgary)
        case $MONTH in
            12|1|2) SUNRISE_HOUR=8; SUNSET_HOUR=16 ;;
            3|4|5) SUNRISE_HOUR=6; SUNSET_HOUR=19 ;;
            6|7|8) SUNRISE_HOUR=5; SUNSET_HOUR=21 ;;
            9|10|11) SUNRISE_HOUR=7; SUNSET_HOUR=18 ;;
        esac ;;

    # Mexico
    America/Mexico_City)
        case $MONTH in
            12|1|2) SUNRISE_HOUR=7; SUNSET_HOUR=18 ;;
            3|4|5) SUNRISE_HOUR=7; SUNSET_HOUR=19 ;;
            6|7|8) SUNRISE_HOUR=7; SUNSET_HOUR=20 ;;
            9|10|11) SUNRISE_HOUR=7; SUNSET_HOUR=19 ;;
        esac ;;

    # Europe - UK
    Europe/London)
        case $MONTH in
            12|1|2) SUNRISE_HOUR=8; SUNSET_HOUR=16 ;;
            3|4|5) SUNRISE_HOUR=6; SUNSET_HOUR=19 ;;
            6|7|8) SUNRISE_HOUR=5; SUNSET_HOUR=21 ;;
            9|10|11) SUNRISE_HOUR=7; SUNSET_HOUR=17 ;;
        esac ;;

    # Europe - Central (Paris, Berlin, Romania)
    Europe/Paris|Europe/Berlin|Europe/Bucharest)
        case $MONTH in
            12|1|2) SUNRISE_HOUR=8; SUNSET_HOUR=16 ;;
            3|4|5) SUNRISE_HOUR=6; SUNSET_HOUR=19 ;;
            6|7|8) SUNRISE_HOUR=5; SUNSET_HOUR=21 ;;
            9|10|11) SUNRISE_HOUR=7; SUNSET_HOUR=17 ;;
        esac ;;

    # Asia - East (Japan, Korea, China)
    Asia/Tokyo|Asia/Seoul|Asia/Shanghai|Asia/Hong_Kong)
        case $MONTH in
            12|1|2) SUNRISE_HOUR=7; SUNSET_HOUR=17 ;;
            3|4|5) SUNRISE_HOUR=6; SUNSET_HOUR=18 ;;
            6|7|8) SUNRISE_HOUR=5; SUNSET_HOUR=19 ;;
            9|10|11) SUNRISE_HOUR=6; SUNSET_HOUR=17 ;;
        esac ;;

    # Asia - South (India)
    Asia/Kolkata|Asia/Calcutta)
        case $MONTH in
            12|1|2) SUNRISE_HOUR=7; SUNSET_HOUR=18 ;;
            3|4|5) SUNRISE_HOUR=6; SUNSET_HOUR=18 ;;
            6|7|8) SUNRISE_HOUR=6; SUNSET_HOUR=19 ;;
            9|10|11) SUNRISE_HOUR=6; SUNSET_HOUR=18 ;;
        esac ;;

    # Asia - Equatorial (Singapore - minimal variation)
    Asia/Singapore|Asia/Kuala_Lumpur)
        SUNRISE_HOUR=7; SUNSET_HOUR=19 ;;

    # Africa - Equatorial (Accra - minimal variation)
    Africa/Accra)
        SUNRISE_HOUR=6; SUNSET_HOUR=18 ;;

    # Default fallback
    *) SUNRISE_HOUR=6; SUNSET_HOUR=18 ;;
esac

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

# Highlight for the first 10% of each segment
SEGMENTS=7
SEGMENT_MINUTES=$((1440 / SEGMENTS))
SEGMENT_OFFSET=$((MINUTES_INTO_DAY % SEGMENT_MINUTES))
HIGHLIGHT_MINUTES=$((SEGMENT_MINUTES / 10))
TRACK_COLOR="0xffA0A0A0"
if [ "$SEGMENT_OFFSET" -lt "$HIGHLIGHT_MINUTES" ]; then
	TRACK_COLOR="0xffFFFFFF"
fi

# Render 7-position track for smooth progress
DOT_POS=$((PROGRESS * 7 / 100))
if [ $DOT_POS -gt 6 ]; then
    DOT_POS=6
fi

# Calculate which slots get half-moons
SUNRISE_MINUTES=$((SUNRISE_HOUR * 60))
SUNSET_MINUTES=$((SUNSET_HOUR * 60))
SUNRISE_SLOT=$((SUNRISE_MINUTES * 7 / 1440))
SUNSET_SLOT=$((SUNSET_MINUTES * 7 / 1440))

TRACK=""
for i in 0 1 2 3 4 5 6; do
	if [ $i -eq $DOT_POS ]; then
		if [ $i -eq $SUNRISE_SLOT ]; then
			TRACK="${TRACK}◐"  # Sunrise slot
		elif [ $i -eq $SUNSET_SLOT ]; then
			TRACK="${TRACK}◑"  # Sunset slot
		else
			TRACK="${TRACK}●"  # Normal
		fi
	elif [ $i -lt $DOT_POS ]; then
		TRACK="${TRACK}━"
	else
		TRACK="${TRACK}┈"
	fi
done

# Get current time in 24-hour format
TIME=$(date '+%H:%M')

# Set label: 353━━━●──354 17:13
sketchybar --set progress label="${DAY_OF_YEAR}${TRACK}${NEXT_DAY}" label.color="$TRACK_COLOR" \
           --set clock_time label="${TIME}"
