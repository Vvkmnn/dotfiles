#!/usr/bin/env bash
# orbit.sh <left|right|breathe>
#
# Move the focused window to another space, preferring an EMPTY space:
#   left / right - first empty walking in that direction, wrap at the ends
#   breathe      - closest empty in either direction (ties: right wins)
# Fallback when no empty space exists anywhere: the space with the fewest windows.
# Skips native-fullscreen spaces. Never creates a new space.
#
# On Tahoe (no scripting-addition), --focus flag on window-move focuses the window
# but does not switch the display; we follow with an explicit space --focus.

set -euo pipefail

mode="${1:?usage: $0 <left|right|breathe>}"

current=$(yabai -m query --spaces --space | jq -r '.index')

# Count only "real tiled" windows per space, not floating popups / sticky ("assigned to all desktops")
# / hidden / minimized ones — yabai's .windows array counts all of those and misclassifies visually-empty
# spaces as non-empty. Two queries (all spaces + all windows), joined in jq.
windows_json=$(yabai -m query --windows)
spaces_json=$(yabai -m query --spaces)

indices=(); counts=(); current_pos=-1
while IFS=' ' read -r idx cnt; do
    indices+=("$idx")
    counts+=("$cnt")
    if (( idx == current )); then current_pos=$(( ${#indices[@]} - 1 )); fi
done < <(jq -r --argjson w "$windows_json" '
    map(select(."is-native-fullscreen" == false))
    | sort_by(.index)
    | .[] as $s
    | ($w | map(select(.space == $s.index
                       and ."is-floating" == false
                       and ."is-sticky"   == false
                       and ."is-hidden"   == false
                       and ."is-minimized" == false)) | length) as $cnt
    | "\($s.index) \($cnt)"
' <<< "$spaces_json")

n=${#indices[@]}
if (( n <= 1 )); then exit 0; fi
if (( current_pos < 0 )); then exit 0; fi

target=""

case "$mode" in
    left|right)
        step=1
        if [[ "$mode" == "left" ]]; then step=-1; fi
        for (( offset = 1; offset < n; offset++ )); do
            pos=$(( (current_pos + step * offset + n) % n ))
            if (( counts[pos] == 0 )); then
                target=${indices[$pos]}
                break
            fi
        done
        ;;
    breathe)
        best_dist=99999
        best_i=-1
        for i in "${!indices[@]}"; do
            if (( i == current_pos )); then continue; fi
            if (( counts[i] != 0 )); then continue; fi
            di=$(( indices[i] > current ? indices[i] - current : current - indices[i] ))
            if (( di < best_dist )) || { (( di == best_dist )) && (( indices[i] > current )); }; then
                best_dist=$di
                best_i=$i
            fi
        done
        if (( best_i >= 0 )); then target=${indices[$best_i]}; fi
        ;;
    *)
        echo "usage: $0 <left|right|breathe>" >&2
        exit 2
        ;;
esac

# Fallback: no empty available -> pick space with fewest windows (not current)
if [[ -z "$target" ]]; then
    min_n=99999
    min_i=-1
    for i in "${!indices[@]}"; do
        if (( i == current_pos )); then continue; fi
        if (( counts[i] < min_n )); then
            min_n=${counts[i]}
            min_i=$i
        fi
    done
    if (( min_i >= 0 )); then target=${indices[$min_i]}; fi
fi

if [[ -z "$target" ]] || (( target == current )); then exit 0; fi

yabai -m window --space "$target"
yabai -m space --focus "$target"
