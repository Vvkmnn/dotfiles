# statusline mod

One row. Claude Code always draws its prompt footer (`⏸ manual mode on · …`) and a status-line
script can only sit above it, so this mod draws `~/.claude/statusline.sh` into that footer row,
after the mode words and after Claude's own hint. The script stays the single source of the line
(its demo and selftest still apply); the mod feeds it the payload from the mods API and turns its
colours into Text elements.

```
⏸ manual mode on · -- INSERT -- (shift+tab to cycle) · 1 feedback draft · ॐ Fᵀ⁺ high + thinking  ? 6 waiting · ψ 89% context  λ 21% (15% fable) used  τ 6d 11h to reset · π 31 files uncommitted on v-macos  $ 355 estimated
```

Claude's words are never dropped: the engine hands the hint site a `hint` string that reads the
whole drawn line (`-- INSERT --`, the shortcuts hint, `esc to interrupt`, its pills), and the mod
draws it first, dim, then ` · `, then the script's line, which shrinks to what is left. The engine's
own node (`await next(e)`) cannot be kept beside ours: it is opaque and takes a whole row, so a tree
that includes it always wraps to two rows (probed 2026-11-04 at 186 columns). The one loss is the
pills' box styling: their text stays, their frame does not.

The footer's `isDraft` and `isWorking` reach the script as `CLAUDE_STATUSLINE_STATE`, so ॐ is red
only when the pane is flagged waiting *and* idle; while you type or Claude works the pane flag is
stale and ॐ keeps its colour.

Debug: start a session with `CLAUDE_STATUSLINE_DEBUG=<file>` and every render writes the hint
site's props, the state, the columns and the last line to that file.

## Upstream

Learned from [midudev/better-claude](https://github.com/midudev/better-claude) (MIT), `plugins/sub-meter`
and `plugins/token-meter` at commit `249f0f6` (2026-11-02): the `PromptHint` and `SessionMode` render
sites, the footer's width accounting, `session.measure` as the push signal, and the `claude plugin test`
harness. To pull their updates: `git -C <clone> diff 249f0f6..HEAD -- plugins/sub-meter plugins/token-meter`
and port what applies. Everything here is custom for this setup; nothing is copied verbatim.

## Install

`CLAUDE_CODE_PLUGIN_DIRS=/Users/v/.claude/mods/statusline` in the `env` of `~/.claude/settings.json`,
with the `statusLine` key removed (otherwise the script draws its own row above as well). Sessions
pick it up on their next start. `claude --safe-mode` turns it off.

## Check

`claude plugin validate ~/.claude/mods/statusline` lists what it hooks and calls.
`claude plugin test ~/.claude/mods/statusline` runs `hooks/register.test.ts`.
