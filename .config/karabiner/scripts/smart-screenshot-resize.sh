#!/bin/bash
#
# Screenshot + Auto-Resize for Claude Code
# ==========================================
#
# DESCRIPTION:
# Takes screenshot to temp file, resizes to 700px max dimension, copies to clipboard.
# No leftover files - temp file cleaned up immediately after clipboard copy.
#
# USAGE:
# - No parameter: Fullscreen screenshot
# - -i parameter: Interactive area selection
#
# KEYBOARD SHORTCUTS (configured in Karabiner-Elements):
# - right_cmd alone      → Fullscreen screenshot + auto-resize to 700px
# - ctrl + right_cmd     → Area screenshot + auto-resize to 700px
# - shift + right_cmd    → Screenshot options menu (video/other options)
# - right_cmd + space    → Paste (Ctrl+V for Claude Code terminal)
#
# WHY THIS APPROACH:
# - Screenshot to file is synchronous (no race condition with clipboard)
# - Resize happens before clipboard, so image is ready instantly
# - Temp files auto-cleaned (no artifacts left behind)
# - 700px allows 10-12 screenshots in Claude Code conversation
#
# SETUP ON NEW COMPUTER:
# ----------------------
#
# 1. Install pngpaste:
#    brew install pngpaste
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
#                "to": [{"key_code": "v", "modifiers": ["left_control"]}],
#                "type": "basic"
#            },
#            {
#                "from": {"key_code": "right_command", "modifiers": {"optional": ["any"]}},
#                "to": [{"key_code": "right_command"}],
#                "to_if_alone": [{"shell_command": "~/.config/karabiner/scripts/smart-screenshot-resize.sh"}],
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
# - ctrl+right_cmd not working: Ensure specific modifier rules (shift, ctrl) come BEFORE
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

MAX_DIM=700
TMP_FILE="/tmp/screenshot-$$.png"
IMPBCOPY="$HOME/.config/karabiner/scripts/impbcopy"

# Take screenshot to file (synchronous - no race condition)
# -i for interactive area selection, -x for fullscreen
if [ "$1" = "-i" ]; then
    screencapture -i "$TMP_FILE"
else
    screencapture -x "$TMP_FILE"
fi

# Resize and copy to clipboard if screenshot succeeded
if [ -f "$TMP_FILE" ]; then
    sips --resampleHeightWidthMax "$MAX_DIM" "$TMP_FILE" --out "$TMP_FILE" >/dev/null 2>&1
    "$IMPBCOPY" "$TMP_FILE"
    rm -f "$TMP_FILE"
fi
