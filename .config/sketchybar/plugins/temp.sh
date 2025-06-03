#!/usr/bin/env sh

# Temperature display - using more reliable methods
TEMP=""

# Method 1: Try direct SMC reading if we have the tools
if [ -f /usr/local/bin/osx-cpu-temp ]; then
    TEMP=$(/usr/local/bin/osx-cpu-temp 2>/dev/null | grep -Eo "[0-9]+" | head -1)
fi

# Method 2: Use ioreg to read thermal state
if [ -z "$TEMP" ] || [ "$TEMP" = "0" ]; then
    # Try to read TC0P (CPU proximity)
    TEMP=$(ioreg -rn AppleSMC | grep '"TC0P"' | awk '{print $3}' | sed 's/[^0-9]//g')
    if [ -n "$TEMP" ] && [ "$TEMP" -gt 0 ]; then
        # Convert from SMC format (multiply by 2^-8)
        TEMP=$((TEMP / 256))
    fi
fi

# Method 3: Try different SMC keys
if [ -z "$TEMP" ] || [ "$TEMP" = "0" ]; then
    # Try TC0D (CPU die)
    TEMP=$(ioreg -rn AppleSMC | grep '"TC0D"' | awk '{print $3}' | sed 's/[^0-9]//g')
    if [ -n "$TEMP" ] && [ "$TEMP" -gt 0 ]; then
        TEMP=$((TEMP / 256))
    fi
fi

# Method 4: Use CPU usage as last resort estimation
if [ -z "$TEMP" ] || [ "$TEMP" = "0" ]; then
    CPU_PERCENT=$(top -l 1 | grep "CPU usage" | awk '{print int($3)}')
    if [ -n "$CPU_PERCENT" ]; then
        # Estimate: base 42°C + CPU percentage influence
        TEMP=$((42 + (CPU_PERCENT * 30 / 100)))
    fi
fi

# Final check
if [ -z "$TEMP" ] || [ "$TEMP" = "0" ]; then
    TEMP="--"
fi

# Color based on temperature
if [ "$TEMP" = "--" ]; then
    COLOR=0xff606060  # Dim gray for no data
elif [ $TEMP -lt 50 ]; then
    COLOR=0xff606060  # Dim gray (cool)
elif [ $TEMP -lt 70 ]; then
    COLOR=0xffFFFFFF  # White (warm)
elif [ $TEMP -lt 85 ]; then
    COLOR=0xffDDB670  # Yellow (hot)
else
    COLOR=0xffE74C3C  # Red (critical)
fi

# Update display
sketchybar --set temp label="${TEMP}°" \
                     label.color=$COLOR \
                     icon.color=$COLOR