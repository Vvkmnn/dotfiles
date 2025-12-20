#!/bin/zsh --no-rcs

cache="$alfred_workflow_cache"
progress="${cache}/progress.txt"
args=""

if [[ "${sequentially:-0}" -eq 1 ]]; then
    args="-s"
fi

cleanup() {
    echo >&2 "Trapped... Cleaning up background process"
    jobs -p | xargs killall >&2
    # $ jobs -p
    # [1]  + 49501 suspended (tty output)  script -q /dev/null networkquality 2>&1 |
    #              suspended (tty output)  tee >(cat >"progress.txt") > /dev/null
    # $ jobs -p | xargs killall
    # [1]  + 49757 terminated  script -q /dev/null networkquality 2>&1 |
    #        49758 terminated  tee >(cat >"progress.txt") > /dev/null
}
trap cleanup EXIT

echo >&2 "Running Speedtest"
script -q /dev/null networkquality $args 2>&1 | tee >(cat >"$progress") >/dev/null &
osascript -e 'tell application id "com.runningwithcrayons.Alfred" to run trigger "ui_speedtest" in workflow "com.zeitlings.internet.speedtest"'
