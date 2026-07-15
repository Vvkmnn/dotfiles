---
name: fleet-handoff
description: Use when relaying between Claudes on different fleet machines (m4 hub ↔ m3 ↔ a18, macOS) — when the owner says "handoff", "what do you want to say to <the m4 / a18 / m3 / another member of the fleet>", "any message for <machine>", "ask the other claude", "relay to <machine>", "paste this there", "add it to my clipboard", or when you need another machine's Claude to run something (push, commit, dump config, install, diff state). ALWAYS render the message in the chip→chip format below and pbcopy it. The owner is the transport between machines — a message that isn't on the clipboard didn't get handed off.
---

# fleet-handoff

Cross-machine Claude↔Claude coordination. Fleet machines can't talk directly; the
**owner is the transport** — they carry your message to the other machine's Claude and its
reply back. Your job: a clean, paste-ready payload in ONE consistent format, every time.

Name machines by **chip + OS** — `m4` (headless hub) · `m3` · `a18`, macOS — never device
nicknames or hostnames. This skill is public; the chip is enough to reason about a machine
(RAM tier, headless/Touch-ID role) without publishing the roster. Real hostnames appear
ONLY inside commands that must connect (`ssh vminim4 …`) — functional, not identifying.

## The rule

Whenever you need another machine's Claude to act — or the owner says "handoff", **"what do
you want to say to <machine>"**, "any message for <machine>", "relay", "ask the other claude",
"add it to my clipboard":

1. Write the message in the **chip→chip format** (below) — always this format.
2. **`pbcopy` it — automatically.** Printing without copying = a failed handoff.
3. Tell the owner: `✓ copied (<n> lines) — paste into <chip>'s Claude`.
4. When they paste the reply back, act on it; if it spawns another ask, pbcopy the next one.
   The loop closes only when you've said what you'll do with the reply.

## The chip→chip format (use this EVERY time)

```
<from-chip> → <to-chip>  ·  <one-line subject>

CONTEXT — why this, with proof: a commit SHA, file:line, or real command output.
DO      — exact, copy-pasteable commands (runnable verbatim on the target).
AFTER   — how to verify + what I'll do with the reply (closes the loop).
```

- **Chip header** (`m4 → a18`) orients the receiving Claude instantly and carries no device identity.
- **Proof** (a commit SHA, an `mdls`/`grep` line, command output) makes the ask trustworthy, not hand-wavy.
- **Exact commands** — runnable verbatim. Point at shared artifacts (commit / branch / `file:line`);
  don't paste full context — the repo is the shared state, not the clipboard.
- **Return action** — "then I'll pull + restart" — so the handoff loop actually closes.

## pbcopy reliably (learned the hard way)

ALWAYS a **quoted heredoc** — never `printf`/`echo` with nested quotes. An apostrophe or a
`"` in the text silently breaks the command and copies nothing:

```bash
pbcopy <<'HANDOFF_EOF'
...message — any quotes / apostrophes / $ are safe inside a quoted heredoc...
HANDOFF_EOF
echo "✓ copied ($(pbpaste | wc -l | tr -d ' ') lines)"
```

The quoted delimiter `'HANDOFF_EOF'` = no expansion, no escaping. Verify with `pbpaste | wc -l`.
Re-run any time — pbcopy is idempotent.

## Full-manual fallback — relay the raw tmux screen when the clipboard path is dead

Universal Clipboard needs the machines proximate + one Apple ID, and **mosh can't carry
OSC52** — so a `pbcopy` *inside* a mosh/ssh session lands on the remote's clipboard (or
nowhere), not the owner's. When that fails — or the owner just wants it by hand — turn the
terminal UI into plain selectable text and copy it natively (verified, tmux 3.7):

```bash
tmux capture-pane -p                 # visible pane → plain text on stdout
tmux capture-pane -pS -              # + entire scrollback (all the pane remembers)
tmux capture-pane -pS -2000          # last 2000 lines (bounded)
tmux capture-pane -pt <sess:win.pane>   # a specific pane, not the active one
```

Get it across — cheapest first:
1. **Native selection.** `capture-pane -p` prints raw text into the current pane; select it with
   the terminal's own mouse/keyboard copy. Works even when every clipboard integration is dead —
   it's just on-screen text now, nothing to forward.
2. **Taildrop the file** (no clipboard, any distance, reaches the headless m4):
   ```bash
   tmux capture-pane -pS - > /tmp/screen.txt && vsend /tmp/screen.txt <chip>
   ```
3. **Local clipboard, if it works:** `tmux capture-pane -p | pbcopy` — only when you're *local*,
   not inside a mosh/ssh session (that's the case where it silently fails).

The owner runs these by hand sometimes — keep them exact and dependency-free. (A `vgrab` verb
could wrap #1; propose it, don't assume it exists.)

## Transports, in order

1. **pbcopy → Universal Clipboard** — primary for pasting into another machine's Claude (human-gated by design).
2. **`vsend` (Taildrop)** — files / captured screens / images across the tailnet, incl. the headless m4 (no GUI clipboard).
3. **Manual `capture-pane`** — the always-works floor when the two above fail.

Clipboard handoff stays useful even with the Tailscale mesh up: "have the other Claude do X"
without granting cross-machine exec — human-gated is a feature, not a gap.

## Anti-patterns

- Printing the handoff but NOT copying it → pbcopy every time.
- `printf` with `'"'"'` escaping → breaks on quotes. Heredoc only.
- Device nicknames in the message → chip+OS (`m4`/`m3`/`a18`); real hostnames only inside connect-commands.
- `pbcopy` inside a mosh session, assuming it reached the owner → it didn't; use the `capture-pane` manual path.
- Dumping full file contents → link the commit / branch / `file:line` instead.
- Vague asks ("check your fonts") → exact commands + the proof behind the ask.
- Forgetting the return action → always say what you'll do with the reply.
