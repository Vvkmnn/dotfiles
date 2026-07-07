#!/bin/bash
# Weather for sketchybar — cached wttr.in with nerd font icons + Kanagawa colors.
# Auto-detects location by IP. 30-min cache TTL.
CACHE="$HOME/.cache/sketchybar-weather"
TTL=1800

# Serve from cache if fresh
if [ -f "$CACHE" ]; then
    age=$(( $(date +%s) - $(stat -f %m "$CACHE") ))
    if [ "$age" -lt "$TTL" ]; then
        source "$CACHE"
        sketchybar --set weather icon="$ICON" label="$LABEL" icon.color="$COLOR" label.color="$COLOR"
        exit 0
    fi
fi

# Fetch condition and temp
raw=$(curl -sf --connect-timeout 3 --max-time 5 'wttr.in/?format=%C|%t' 2>/dev/null)
if [ -z "$raw" ]; then
    [ -f "$CACHE" ] && source "$CACHE" && sketchybar --set weather icon="$ICON" label="$LABEL" icon.color="$COLOR" label.color="$COLOR"
    exit 0
fi

condition="${raw%%|*}"
temp="${raw##*|}"
temp="${temp#+}"  # strip leading +

# Lowercase condition (bash 3.2 compatible)
cond=$(echo "$condition" | tr '[:upper:]' '[:lower:]')

# Day/night detection
hour=$(date +%-H)
is_day=$(( hour >= 6 && hour < 20 ))

# MDI filled weather icons (same SFMono Nerd Font, F0590 range)
I_THUNDER=$'\U000F0593'
I_SNOW=$'\U000F0598'
I_SLEET=$'\U000F0598'
I_HEAVYRAIN=$'\U000F0596'
I_RAIN=$'\U000F0597'
I_FOG=$'\U000F0591'
I_OVERCAST=$'\U000F0590'
I_CLOUD_DAY=$'\U000F0595'
I_CLOUD_NIGHT=$'\U000F0594'
I_CLEAR_DAY=$'\U000F0599'
I_CLEAR_NIGHT=$'\U000F0F33'

# Map to nerd font icon + Kanagawa color
case "$cond" in
    *thunder*)                    ICON="$I_THUNDER"; COLOR="0xffFF5D62" ;;
    *snow*|*blizzard*)            ICON="$I_SNOW"; COLOR="0xffDCD7BA" ;;
    *sleet*|*ice*)                ICON="$I_SLEET"; COLOR="0xffA3D4D5" ;;
    *heavy*rain*|*torrential*)    ICON="$I_HEAVYRAIN"; COLOR="0xff7E9CD8" ;;
    *rain*|*drizzle*|*shower*)    ICON="$I_RAIN"; COLOR="0xff7FB4CA" ;;
    *fog*|*mist*|*haze*)          ICON="$I_FOG"; COLOR="0xff727169" ;;
    *overcast*)                   ICON="$I_OVERCAST"; COLOR="0xff938AA9" ;;
    *cloud*|*partly*)
        if [ "$is_day" -eq 1 ]; then ICON="$I_CLOUD_DAY"; COLOR="0xffE6C384"
        else ICON="$I_CLOUD_NIGHT"; COLOR="0xff938AA9"; fi ;;
    *clear*|*sunny*)
        if [ "$is_day" -eq 1 ]; then ICON="$I_CLEAR_DAY"; COLOR="0xffE6C384"
        else ICON="$I_CLEAR_NIGHT"; COLOR="0xffDCD7BA"; fi ;;
    *)
        if [ "$is_day" -eq 1 ]; then ICON="$I_CLEAR_DAY"; COLOR="0xffDCD7BA"
        else ICON="$I_CLEAR_NIGHT"; COLOR="0xffDCD7BA"; fi ;;
esac

LABEL="$temp"

# Cache as sourceable variables
printf 'ICON="%s"\nLABEL="%s"\nCOLOR="%s"\n' "$ICON" "$LABEL" "$COLOR" > "$CACHE"

sketchybar --set weather icon="$ICON" label="$LABEL" icon.color="$COLOR" label.color="$COLOR"
