#!/bin/bash
#
# Screenshot + Auto-Resize for Claude Code
# ==========================================
#
# DESCRIPTION:
# Takes screenshot to temp file, resizes to 700px max dimension, copies to clipboard.
# Shows notification with dimensions via terminal-notifier.
# No leftover files - temp files cleaned up immediately after clipboard copy.
#
# USAGE:
# - No parameter: Fullscreen screenshot
# - -i parameter: Interactive area selection
#
# KEYBOARD SHORTCUTS (configured in Karabiner-Elements):
# - right_cmd alone      → Fullscreen screenshot + auto-resize to 700px + notification
# - ctrl + right_cmd     → Area screenshot + auto-resize to 700px + notification
# - shift + right_cmd    → Screenshot options menu (video/other options)
# - right_cmd + space    → Paste (Ctrl+V for Claude Code terminal)
#
# MECHANISM:
# Uses to_after_key_up + rcmd_solo variable instead of to_if_alone.
# to_if_alone is canceled by mouse/trackpad events during the key hold,
# which silently breaks screenshots when switching windows. to_after_key_up
# fires on every physical key release regardless of mouse events.
# The rcmd_solo variable (set on press, cleared by spacebar/paste rule)
# prevents screenshot when right_cmd was used as a modifier for paste.
#
# WHY THIS APPROACH:
# - Screenshot to file is synchronous (no race condition with clipboard)
# - Resize to separate file avoids sips in-place corruption risk
# - Temp files auto-cleaned (no artifacts left behind)
# - 700px allows 10-12 screenshots in Claude Code conversation
# - Notification confirms capture with dimensions (runs in background)
#
# DEPENDENCIES:
# - terminal-notifier (brew install terminal-notifier)
# - pngpaste (brew install pngpaste) — for verification/testing
# - impbcopy (compiled below) — clipboard copy
# - Karabiner-Elements v15.4+ (per-event conditions in to_after_key_up)
#
# SETUP ON NEW COMPUTER:
# ----------------------
#
# 1. Install pngpaste and terminal-notifier:
#    brew install pngpaste terminal-notifier
#
# 2. Compile impbcopy (clipboard copy tool):
#    Create /tmp/impbcopy.m with this content:
#    ---
#    #import <Foundation/Foundation.h>
#    #import <Cocoa/Cocoa.h>
#    #import <unistd.h>
#
#    BOOL copy_to_clipboard(NSString *path) {
#        NSImage * image;
#        if([path isEqualToString:@"-"]) {
#            NSFileHandle *input = [NSFileHandle fileHandleWithStandardInput];
#            image = [[NSImage alloc] initWithData:[input readDataToEndOfFile]];
#        } else {
#            image = [[NSImage alloc] initWithContentsOfFile:path];
#        }
#        BOOL copied = false;
#        if (image != nil) {
#            NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
#            [pasteboard clearContents];
#            NSArray *copiedObjects = [NSArray arrayWithObject:image];
#            copied = [pasteboard writeObjects:copiedObjects];
#        }
#        return copied;
#    }
#
#    int main(int argc, char * const argv[]) {
#        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
#        if(argc<2) {
#            printf("Usage:\n\nCopy file to clipboard:\n ./impbcopy path/to/file\n\n"
#                   "Copy stdin to clipboard:\n cat /path/to/file | ./impbcopy -");
#            return EXIT_FAILURE;
#        }
#        NSString *path= [NSString stringWithUTF8String:argv[1]];
#        BOOL success = copy_to_clipboard(path);
#        [pool release];
#        return (success?EXIT_SUCCESS:EXIT_FAILURE);
#    }
#    ---
#
#    Then compile:
#    mkdir -p ~/.config/karabiner/scripts
#    clang -Wall -g -O3 -ObjC -framework Foundation -framework AppKit \
#      -o ~/.config/karabiner/scripts/impbcopy /tmp/impbcopy.m
#
# 3. Copy this script to ~/.config/karabiner/scripts/smart-screenshot-resize.sh
#    chmod +x ~/.config/karabiner/scripts/smart-screenshot-resize.sh
#
# 4. Install Karabiner-Elements:
#    brew install --cask karabiner-elements
#
# 5. Add to ~/.config/karabiner/karabiner.json under profiles[].complex_modifications.rules:
#    IMPORTANT: Order matters! Specific modifiers MUST come before "optional: any" rule.
#    {
#        "description": "Right Command: Alone=Screenshot+Resize (700px) | +Space=Paste | Ctrl+Cmd=Area Screenshot | Shift+Cmd=Screenshot Options",
#        "manipulators": [
#            {
#                "from": {"key_code": "right_command", "modifiers": {"mandatory": ["shift"]}},
#                "to": [{"key_code": "5", "modifiers": ["left_command", "left_shift"]}],
#                "type": "basic"
#            },
#            {
#                "from": {"key_code": "right_command", "modifiers": {"mandatory": ["control"]}},
#                "to": [{"shell_command": "~/.config/karabiner/scripts/smart-screenshot-resize.sh -i"}],
#                "type": "basic"
#            },
#            {
#                "from": {"key_code": "spacebar", "modifiers": {"mandatory": ["right_command"]}},
#                "to": [
#                    {"set_variable": {"name": "rcmd_solo", "value": 0}},
#                    {"key_code": "v", "modifiers": ["left_control"]}
#                ],
#                "type": "basic"
#            },
#            {
#                "from": {"key_code": "right_command", "modifiers": {"optional": ["any"]}},
#                "to": [
#                    {"set_variable": {"name": "rcmd_solo", "value": 1}},
#                    {"key_code": "right_command", "lazy": true}
#                ],
#                "to_after_key_up": [
#                    {"shell_command": "~/.config/karabiner/scripts/smart-screenshot-resize.sh",
#                     "conditions": [{"type": "variable_if", "name": "rcmd_solo", "value": 1}]},
#                    {"set_variable": {"name": "rcmd_solo", "value": 0}}
#                ],
#                "type": "basic"
#            }
#        ]
#    }
#
# TESTING:
# --------
# Fullscreen screenshot:
# 1. Press right_cmd alone (should hear camera sound)
# 2. Press right_cmd + space to paste into terminal
# 3. Verify image appears and is resized:
#    pngpaste /tmp/test.png && sips -g pixelWidth -g pixelHeight /tmp/test.png | grep pixel && rm /tmp/test.png
#    (Should show: pixelWidth: 700 or less)
#
# Area screenshot:
# 1. Press ctrl + right_cmd (crosshair cursor appears)
# 2. Drag to select area (should hear camera sound)
# 3. Press right_cmd + space to paste
# 4. Verify resized: (same command as above, should show: pixelWidth: 700 or less)
#
# Screenshot options:
# 1. Press shift + right_cmd (macOS screenshot toolbar appears with Record/Screenshot/Options)
#
# TROUBLESHOOTING:
# ----------------
# - Script not running: Check Karabiner config path matches script location
# - Image not resized: Verify impbcopy exists and is executable
# - No screenshot: Check macOS screenshot permissions for Karabiner
# - ctrl + right_cmd not working: Ensure specific modifier rules (shift, ctrl) come BEFORE
#   the general "optional: any" rule in karabiner.json. Karabiner processes top-to-bottom.
# - Check script permissions: ls -lh ~/.config/karabiner/scripts/smart-screenshot-resize.sh
#   (Should show -rwxr-xr-x or similar)
#
# ADJUSTING RESIZE DIMENSION:
# ---------------------------
# Change MAX_DIM below:
# - 700px: 10-12 screenshots in Claude (current)
# - 1092px: 6-8 screenshots (higher quality)
# - 1568px: 3-4 screenshots (Claude's auto-scale threshold)
#
# RESEARCH SOURCES:
# -----------------
# - Justin Searls: https://justin.searls.co/posts/simultaneously-save-and-copy-screenshots-on-the-mac/
# - Simon Willison: https://til.simonwillison.net/macos/impaste
# - Karabiner Issues: https://github.com/pqrs-org/Karabiner-Elements/issues/4199
#
################################################################################

export PATH="/usr/bin:/opt/homebrew/bin:$PATH"

MAX_DIM=1568   # legible: keeps dense text readable AND under Claude's downscale (1568 / 2576px on Opus 4.8); 700 was too small.
TMP_FILE="/tmp/screenshot-$$.png"
RESIZED_FILE="${TMP_FILE%.png}-resized.png"
IMPBCOPY="$HOME/.config/karabiner/scripts/impbcopy"
SENDER="org.pqrs.Karabiner-Elements.Settings"

# Take screenshot to file (synchronous - no race condition)
# -i for interactive area selection, -x for fullscreen
if [ "$1" = "-i" ]; then
    screencapture -i "$TMP_FILE"
else
    screencapture -x "$TMP_FILE"
fi

# Resize, copy to clipboard, notify
if [ -f "$TMP_FILE" ]; then
    if sips --resampleHeightWidthMax "$MAX_DIM" "$TMP_FILE" --out "$RESIZED_FILE" >/dev/null 2>&1; then
        # Read dimensions and file size
        OW=$(sips -g pixelWidth "$TMP_FILE" | awk '/pixelWidth/{print $2}')
        OH=$(sips -g pixelHeight "$TMP_FILE" | awk '/pixelHeight/{print $2}')
        W=$(sips -g pixelWidth "$RESIZED_FILE" | awk '/pixelWidth/{print $2}')
        H=$(sips -g pixelHeight "$RESIZED_FILE" | awk '/pixelHeight/{print $2}')
        SIZE=$(stat -f%z "$RESIZED_FILE")
        if [ "$SIZE" -ge 1048576 ]; then
            SIZE_FMT="$(( SIZE / 1048576 )) MB"
        else
            SIZE_FMT="$(( SIZE / 1024 )) KB"
        fi
        if [ "$1" = "-i" ]; then MODE="Area"; else MODE="Fullscreen"; fi
        "$IMPBCOPY" "$RESIZED_FILE"
        # native notification, BACKGROUNDED (&) so it never delays the paste — drops the
        # terminal-notifier dependency. (Cross-context vj/vr routing lands later, the fast way:
        # the vj wrapper sets a Karabiner var → a fleet-gated rule passes the target as an arg,
        # so no per-screenshot osascript title-read is ever in the hot path.)
        osascript -e "display notification \"$MODE → clipboard (⌃V into Claude) · ${W}×${H}\" with title \"Screenshot\" sound name \"Tink\"" >/dev/null 2>&1 &
    else
        terminal-notifier \
            -title "Screenshot failed" \
            -message "sips resize error" \
            -sender "$SENDER" \
            -timeout 5 &
    fi
    rm -f "$TMP_FILE" "$RESIZED_FILE"
fi
