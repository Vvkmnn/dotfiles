# yabai — known issues (this box)

## Wrong-space jump on ctrl-arrow / trackpad swipe / manual navigation

**Symptom.** When navigating spaces (via `ctrl+left/right`, trackpad 3-finger swipe, or
`ctrl+cmd+j/k`), sometimes the destination isn't what you asked for — you land on a space
that has a window, not the space adjacent to where you were. It happens **intermittently**,
not every time. Manual space picking via Mission Control (Expose) does NOT reproduce it.

**First captured evidence** — 2026-07-09 in `~/.local/state/yabai/debug.log`:

```
01:19:22  space_changed  now=5    from_recent=6
01:19:28  space_changed  now=568  from_recent=5    ← bounce through a hidden space
01:19:29  space_changed  now=7    from_recent=568  ← 1s later
...
01:20:03  space_changed  now=3    from_recent=5
01:20:04  space_changed  now=568  from_recent=3    ← same bounce pattern
01:20:06  space_changed  now=3    from_recent=568
```

Numbers 1–8 are yabai space **indexes** (match Mission Control). `568` is a yabai internal
**space ID** — some hidden space (candidates: sticky-window origin space, fullscreen space,
Mission Control transient). The single-second gap between two `space_changed` events fits
"one navigation → chain of two OS-level space switches" perfectly.

## Hypotheses (status)

| # | Hypothesis | Status |
|---|---|---|
| 1 | macOS `AppleSpacesSwitchOnActivation` = ON (default) drags to app's home space when an app is activated | **Untested.** Default is ON. Would explain Expose-manual-pick working (bypasses activation chain). Fix: `defaults write NSGlobalDomain AppleSpacesSwitchOnActivation -bool false` |
| 2 | `mouse_follows_focus on` (`~/.config/yabai/yabairc:91`) — yabai moves mouse to focused window, macOS interprets as user activity, chains a follow-up space switch | **Untested.** Reversible: `yabai -m config mouse_follows_focus off`. If bounces stop, that was it. |
| 3 | Claude window `is-sticky: true` (id=5886 as of first log) — sticky windows appear on all spaces and might pull focus during transitions | Partial fix applied (Dock → Options → Assign To → None). Existing sticky attribute persists until Claude quit + relaunched. |
| 4 | macOS auto-rearrange spaces (`com.apple.dock mru-spaces`) | **Ruled out.** Currently `= 0` (off). |
| 5 | Custom yabai signal firing on space_changed | **Ruled out.** No signal in current yabairc modifies focus/space on space_changed (only sketchybar trigger + debug logger). Historical signal disabled at yabairc:60-67 for a similar symptom — comment there says: *"Causes random space switching on empty spaces — leaves focus undefined."* |

## To gather more data next time

Debug logger writes to `~/.local/state/yabai/debug.log` — signal block at end of
`~/.config/yabai/yabairc`, script at `~/.config/yabai/debug-log.sh`.

Immediately after a wrong-space jump:

```sh
tail -30 ~/.local/state/yabai/debug.log
```

Look for **two `space_changed` events within ~1 second** of each other. The second one's
`from_recent=` is the hidden intermediate space (like 568). Cross-reference with:

```sh
# Full window state — find which app owns that space by index or internal id
yabai -m query --windows | jq 'map({id, app, space, sticky: ."is-sticky", floating: ."is-floating"}) | group_by(.space)'
```

## Related plan

`~/.claude/plans/this-is-aprt-of-sparkling-charm.md` — item ⑥ (empty-space diagnose) is
the meta-tracker for this class of symptom. This file is the concrete evidence log.
