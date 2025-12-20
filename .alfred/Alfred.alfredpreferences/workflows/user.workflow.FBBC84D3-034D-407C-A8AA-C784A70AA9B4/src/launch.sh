#!/bin/zsh --no-rcs

zmodload zsh/datetime

# readonly source="$HOME/$DEV"
readonly source="./src/WindowNavigator.swift"
readonly exec="${source:h}/${source:t:r}"
readonly DEBUG="${alfred_debug:-0}"
readonly header="./src/AccessibilityBridgingHeader.h"
readonly flags=(-suppress-warnings -import-objc-header "$header")
readonly directive=$1
readonly query="$2"

# Utility functions
clock() { echo $EPOCHREALTIME }
stamp() { strftime %H:%M:%S.%3. }
stale() { (($(date -r "$1" +%s) > $(date -r "$2" +%s))) }
tick()  { printf "%.0f" $(( ($(clock) - $1) * 1000 )) }
log()   { [[ $DEBUG -eq 1 ]] && echo >&2 "[$(stamp)] $1" }

[[ $DEBUG -eq 1 ]] && echo >&2 "~"
if command -v xcrun &>/dev/null && xcrun --find swiftc &>/dev/null; then
    if [[ -f $exec ]] && ! $(stale $source $exec); then
        log "[Info] run: binary $exec"
        start=$(clock)
        $exec $directive "$query"
        log "[Info] ran: binary (took: $(tick $start)ms)"
    else
        log "[Info] compile: script $source"
        start=$(clock)
        xcrun swiftc -O "${flags[@]}" "$source" -o $exec & # background compilation
        # xcrun swiftc "${flags[@]}" "$source" -o $exec & # background compilation
        log "[Info] run: script ($(tick $start)ms after compilation started)"
        swift "${flags[@]}" "$source" $directive "$query"  # immediate execution
        log "[Info] ran: script ($(tick $start)ms after compilation started)"
    fi
else
    log "[Info] run: script $source"
    start=$(clock)
    swift "${flags[@]}" "$source" $directive "$query" # fallback to direct execution (slow)
    log "[Info] ran: script (took: $(tick $start)ms"
fi
