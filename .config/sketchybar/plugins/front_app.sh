#!/usr/bin/env sh

FRONT_APP=$(yabai -m query --windows --window | jq -r '.app')
[[ $FRONT_APP = "" ]] && FRONT_APP=$(osascript -e 'tell application "System Events" to name of first application process whose frontmost is true')

case $FRONT_APP in
  "Finder") ICON="" ;;
  "Safari") ICON="" ;;
  "Terminal") ICON="" ;;
  "Wezterm") ICON="" ;;
  "Code") ICON="" ;;
  "Windsurf") ICON="" ;;
  "Mail") ICON="" ;;
  "Messages") ICON="" ;;
  "Music") ICON="" ;;
  "Spotify") ICON="" ;;
  "Obsidian") ICON="" ;;
  "Zen Browser") ICON="" ;;
  "Discord") ICON="ﭮ" ;;
  "System Settings") ICON="" ;;
  *) ICON="" ;;
esac

sketchybar --set $NAME icon=$ICON label="$FRONT_APP" icon.drawing=on
