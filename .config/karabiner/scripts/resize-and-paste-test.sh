#!/bin/bash
#
# Resize + Paste for Claude Code (TEST VERSION - NOT IN USE)
# ===========================================================
#
# NOTE: This approach is on hold. Currently using smart-screenshot-resize.sh
# which resizes on screenshot (right_cmd alone), not on paste.
#
# This script checks clipboard for image, resizes to 700px if found, then pastes.
# Would allow normal screenshots with right_cmd, only resizes when pasting.
#
# REQUIRED: pngpaste, impbcopy
# STATUS: Testing discovered pngpaste not finding images on clipboard.
#         Needs investigation before re-enabling.
#
MAX_DIM=700
TMP_FILE="/tmp/clipboard-resize-$$.png"
IMPBCOPY="$HOME/.config/karabiner/scripts/impbcopy"
LOG="/tmp/resize-paste-test.log"

echo "$(date): Resize-paste TEST started" >> "$LOG"

# Check if clipboard has image
if pngpaste -b >/dev/null 2>&1; then
    echo "$(date): Image detected on clipboard" >> "$LOG"

    # Extract, resize, and replace on clipboard
    if pngpaste "$TMP_FILE" 2>> "$LOG"; then
        echo "$(date): Image extracted" >> "$LOG"

        if sips --resampleHeightWidthMax "$MAX_DIM" "$TMP_FILE" --out "$TMP_FILE" >> "$LOG" 2>&1; then
            echo "$(date): Resized to ${MAX_DIM}px" >> "$LOG"

            if "$IMPBCOPY" "$TMP_FILE" 2>> "$LOG"; then
                echo "$(date): SUCCESS - Resized image back on clipboard" >> "$LOG"
            else
                echo "$(date): ERROR - impbcopy failed" >> "$LOG"
            fi
        else
            echo "$(date): ERROR - sips resize failed" >> "$LOG"
        fi

        rm -f "$TMP_FILE"
    else
        echo "$(date): ERROR - pngpaste extraction failed" >> "$LOG"
    fi
else
    echo "$(date): No image on clipboard, passing through" >> "$LOG"
fi

# Paste with Ctrl+V
echo "$(date): Pasting with Ctrl+V" >> "$LOG"
osascript -e 'tell application "System Events" to keystroke "v" using control down'
