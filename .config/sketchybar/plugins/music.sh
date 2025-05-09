#!/usr/bin/env sh

# Uses both Music app and Spotify based on what's active
MUSIC_APP=""

# Check which app is running and active
if pgrep -x "Music" >/dev/null && osascript -e 'tell application "Music" to get player state' >/dev/null 2>&1; then
  MUSIC_APP="Music"
elif pgrep -x "Spotify" >/dev/null && osascript -e 'tell application "Spotify" to get player state' >/dev/null 2>&1; then
  MUSIC_APP="Spotify"
fi

if [[ $MUSIC_APP != "" ]]; then
  # Get track info
  if [[ $MUSIC_APP == "Music" ]]; then
    STATE=$(osascript -e 'tell application "Music" to get player state')
    if [[ $STATE == "playing" ]]; then
      TRACK=$(osascript -e 'tell application "Music" to get name of current track')
      ARTIST=$(osascript -e 'tell application "Music" to get artist of current track')
      ICON=""
      ICON_COLOR="0xffb48ead"
    else
      TRACK="Not Playing"
      ARTIST=""
      ICON=""
      ICON_COLOR="0xff81a1c1"
    fi
  else  # Spotify
    STATE=$(osascript -e 'tell application "Spotify" to get player state')
    if [[ $STATE == "playing" ]]; then
      TRACK=$(osascript -e 'tell application "Spotify" to get name of current track')
      ARTIST=$(osascript -e 'tell application "Spotify" to get artist of current track')
      ICON=""
      ICON_COLOR="0xffa3be8c"
    else
      TRACK="Not Playing"
      ARTIST=""
      ICON=""
      ICON_COLOR="0xff81a1c1"
    fi
  fi

  # Format for display
  if [[ $TRACK != "Not Playing" && $ARTIST != "" ]]; then
    LABEL="$TRACK - $ARTIST"
  else
    LABEL="$TRACK"
  fi

  # Update sketchybar
  sketchybar --set $NAME icon=$ICON icon.color=$ICON_COLOR label="$LABEL"
else
  sketchybar --set $NAME icon= icon.color=0xff4c566a label="" background.drawing=off
fi
