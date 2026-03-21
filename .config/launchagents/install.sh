#!/bin/bash
# Install custom LaunchAgents — replaces __HOME__ with actual home directory
# Usage: ~/.config/launchagents/install.sh
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/Library/LaunchAgents"
mkdir -p "$DEST"

for template in "$SRC"/*.plist; do
    name="$(basename "$template")"
    target="$DEST/$name"
    sed "s|__HOME__|$HOME|g" "$template" > "$target"
    echo "installed $name"

    # Load into launchd (unload first if already loaded)
    label="${name%.plist}"
    launchctl bootout "gui/$(id -u)/$label" 2>/dev/null || true
    launchctl bootstrap "gui/$(id -u)" "$target"
    echo "  loaded $label"
done

echo "done — $(ls "$SRC"/*.plist | wc -l | tr -d ' ') agents installed"
