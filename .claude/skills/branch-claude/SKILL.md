---
name: branch-claude
author: Vvkmnn
description: Branch the current Claude conversation and open the original in a new tmux window. This session becomes the branch; the original resumes in the new window with focus.
version: 0.2.0
---

# Branch Claude to New Window

Branch the current conversation and resume the original in an adjacent tmux window.

This is the Claude skill counterpart to `prefix + B` (tmux keybinding). Both use the same
underlying script at `~/.config/tmux/claude-branch-pane.sh`.

## How it works

1. Sends `/branch` to the current pane (via tmux send-keys)
2. Captures the resume UUID from `/branch` output (via tmux capture-pane)
3. Opens `claude -r <uuid>` in a new tmux window next to the current one

The resume ID is captured directly from `/branch` output — no dependency on the
`claude_sessions` mapping file, which can have stale entries.

## Prerequisites

- Must be running inside tmux (`$TMUX` env var set)
- Claude Code CLI available in PATH

## Steps

1. **Background the branch script** (fires ~2s after this skill returns):
   ```bash
   nohup bash -c '
     sleep 2
     bash ~/.config/tmux/claude-branch-pane.sh
   ' &>/dev/null &
   ```

   The 2s delay gives time for this skill to finish and return control to the prompt.
   The script then sends `/branch`, captures the resume ID, and opens the new window.

2. **Tell the user**: "Branching in ~2s. This session becomes the branch. The original will open in a new window to the right."

## Related

- `~/.config/tmux/claude-branch-pane.sh` — shared script (keybinding + skill)
- `~/.config/tmux/tmux.conf:191` — `bind-key B` (tmux keybinding entry point)
- `~/.config/tmux/claude_jump.sh` — `bind-key b` (jump to last Claude prompt)
