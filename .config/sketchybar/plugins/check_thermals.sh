#!/usr/bin/env sh

# Quick thermal check for MacBook Air 2024
echo "=== MacBook Air 2024 Thermal Status ==="
echo

# Get current readings
source "$HOME/.config/sketchybar/plugins/macmon_shared.sh"
MACMON_DATA=$(get_macmon_data)

if [ "$MACMON_DATA" != "{}" ]; then
    CPU_TEMP=$(echo "$MACMON_DATA" | jq -r '.temp.cpu_temp_avg' 2>/dev/null | cut -d. -f1)
    GPU_TEMP=$(echo "$MACMON_DATA" | jq -r '.temp.gpu_temp_avg' 2>/dev/null | cut -d. -f1)
    POWER=$(echo "$MACMON_DATA" | jq -r '.sys_power' 2>/dev/null | cut -d. -f1)
    
    echo "CPU Temperature: ${CPU_TEMP}°C"
    echo "GPU Temperature: ${GPU_TEMP}°C"
    echo "System Power: ${POWER}W"
    echo
    
    # Thermal state assessment
    if [ "$CPU_TEMP" -lt 70 ]; then
        echo "Status: Cool (unusual for fanless Air under any load)"
    elif [ "$CPU_TEMP" -lt 85 ]; then
        echo "Status: Normal (typical for fanless design)"
    elif [ "$CPU_TEMP" -lt 95 ]; then
        echo "Status: Warm (approaching thermal throttling)"
    else
        echo "Status: HOT (thermal throttling active)"
    fi
    
    echo
    echo "Note: MacBook Air 2024 is fanless and normally runs 75-85°C under load"
fi
