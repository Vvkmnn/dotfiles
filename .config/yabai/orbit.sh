#!/usr/bin/env bash
# orbit.sh <left|right|breathe>
#
# Move the focused window to another space, preferring an EMPTY space:
#   left / right - first empty walking in that direction, wrap at the ends
#   breathe      - closest empty in either direction (ties: right wins)
# Fallback when no empty space exists anywhere: create a new empty space on the current display
# (space --create works sans scripting-addition on Tahoe; we never destroy). Skips fullscreen spaces.
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

# Query-only mode: print the index of the first truly-empty space (tiled-count 0), or
# nothing if every space is occupied. Shared "empty" definition for the Screen Sharing
# signal so it means the same thing here and in the keybind. Moves no windows.
if [[ "$mode" == "--empty-index" ]]; then
    for i in "${!indices[@]}"; do
        if (( counts[i] == 0 )); then printf '%s\n' "${indices[$i]}"; exit 0; fi
    done
    exit 0
fi

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

# Fallback: no empty space anywhere -> create one on the current display. Adding a space
# renumbers indices across displays, so identify the new space by its stable id (diff against
# the pre-create snapshot) rather than assuming it's the highest index.
if [[ -z "$target" ]]; then
    before_ids=$(jq -c '[.[].id]' <<< "$spaces_json")
    yabai -m space --create
    target=$(yabai -m query --spaces \
        | jq -r --argjson before "$before_ids" \
            'map(select(.id as $id | $before | index($id) | not)) | .[0].index // empty')
fi

if [[ -z "$target" ]] || (( target == current )); then exit 0; fi

yabai -m window --space "$target"
yabai -m space --focus "$target"
