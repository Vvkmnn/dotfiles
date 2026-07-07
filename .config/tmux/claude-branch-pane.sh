#!/bin/bash
# ============================================================================
# claude-branch-pane.sh — Branch Claude conversation into a new tmux window
# ============================================================================
#
# What it does:
#   1. Detects the Claude pane (active pane, or errors if not in one)
#   2. Sends /branch to fork the conversation
#   3. Captures the resume UUID from /branch output via tmux capture-pane
#   4. Opens the ORIGINAL session in a new tmux window (next to current)
#
# Result:
#   - Current window: becomes the BRANCH (experimental/divergent conversation)
#   - New window: resumes the ORIGINAL (pre-branch conversation, focused)
#
# Entry points:
#   prefix + B          — tmux keybinding (tmux.conf), sends /branch + opens window
#   /branch-claude      — Claude skill (~/.claude/skills/branch-claude/SKILL.md),
#                          backgrounds a delayed call with --deferred flag
#
# Usage:
#   bash claude-branch-pane.sh              # from tmux keybinding (prefix + B)
#   bash claude-branch-pane.sh --deferred   # from Claude skill (skip send-keys)
#   bash claude-branch-pane.sh --pane %13   # with explicit pane ID (from run-shell -b)
#
# Why capture-pane instead of ~/.config/tmux/claude_sessions mapping:
#   The mapping file (written by session-start.js) can have stale entries when
#   windows move between sessions or the hook doesn't fire. Capturing the UUID
#   directly from /branch output is always correct — it's the source of truth.
#
# Dependencies:
#   - tmux (obviously)
#   - Claude Code CLI (claude -r for resume)
#
# Related files:
#   - ~/.config/tmux/tmux.conf              — bind-key B
#   - ~/.claude/skills/branch-claude/       — /branch-claude skill
#   - ~/.config/tmux/claude_jump.sh         — bind-key b (jump to last prompt)
#   - ~/.config/tmux/claude-session-restore.sh — tmux-resurrect integration
#   - ~/.claude/hooks/session-start.js      — writes claude_sessions mapping
# ============================================================================

DEFERRED=false
TARGET=""

# Parse arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --deferred) DEFERRED=true ;;
        --pane) TARGET="$2"; shift ;;
    esac
    shift
done

# --- Pane targeting ---
# If pane ID passed from binding (fixes run-shell -b stripping % from #{pane_id}),
# use it directly. Otherwise detect from current pane.
if [ -z "$TARGET" ]; then
    TARGET=$(tmux display-message -p '#{pane_id}')
fi

# Claude Code sets process.title to its version number (e.g., "2.1.77").
pane_cmd=$(tmux display-message -t "$TARGET" -p '#{pane_current_command}' 2>/dev/null)
if ! [[ "$pane_cmd" =~ ^[0-9] ]]; then
    tmux display-message "Not in a Claude pane — switch to one first"
    exit 0
fi

CWD=$(tmux display-message -t "$TARGET" -p '#{pane_current_path}')

# --- Send /branch ---
# In keybinding mode, inject the /branch command into the Claude pane.
# In deferred mode (skill), the skill handles sending /branch separately.
if [ "$DEFERRED" = false ]; then
    tmux send-keys -t "$TARGET" "/branch" Enter
fi

# --- Capture resume ID from /branch output ---
# /branch prints: "To resume the original: claude -r <uuid>"
# Poll up to 5s (10 × 0.5s) for the UUID to appear in captured pane output.
# Claude may need time to process /branch if it was busy.
RESUME_ID=""
for _ in 1 2 3 4 5 6 7 8 9 10; do
    sleep 0.5
    RESUME_ID=$(tmux capture-pane -t "$TARGET" -p -S -200 | grep -oE 'claude -r [a-f0-9-]{36}' | tail -1 | awk '{print $NF}')
    [ -n "$RESUME_ID" ] && break
done

if [ -z "$RESUME_ID" ]; then
    tmux display-message "Could not find resume ID from /branch output"
    exit 0
fi

# --- Open original in new window ---
# new-window -a: insert after current window (not at end)
# -c "$CWD": inherit working directory for correct project context
# || exec $SHELL: if claude -r fails (expired session), drop to shell instead of closing
tmux new-window -a -c "$CWD" "claude -r $RESUME_ID || exec $SHELL"
