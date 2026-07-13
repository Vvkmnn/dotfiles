---
name: apple-handoff
description: Use when coordinating with a Claude on ANOTHER machine in the fleet (vBook ↔ vNeo ↔ mini) — when the owner says "handoff", "give me the handoff", "ask the other claude", "relay to the laptop/mini", "paste this there", "add it to my clipboard", or when you need a different machine's Claude to run something (commit files, dump config, install, diff state). ALWAYS pbcopy the handoff message so the owner can paste it into the other machine's Claude via macOS Universal Clipboard / Handoff. The owner is the transport between machines — you never reach the other machine directly, so a message that isn't on the clipboard didn't get handed off.
---

# apple-handoff

Cross-machine Claude↔Claude coordination via the clipboard. Fleet machines can't talk
directly; the **owner is the transport** — they paste your message into the other
machine's Claude, and paste its reply back. Your job: make every handoff a clean,
paste-ready clipboard payload, every time.

## The rule

Whenever you need another machine's Claude to act, or the owner says "handoff" /
"ask the other claude" / "relay" / "add it to my clipboard":

1. Write a lean handoff message (format below).
2. **`pbcopy` it — always, automatically.** Don't just print it and assume it
   transferred. Printing without copying = a failed handoff (this has bitten us).
3. Tell the owner: `✓ copied (<n> lines) — paste into <machine>'s Claude`.
4. When they paste the reply back, act on it. If it spawns another ask, pbcopy the
   next handoff. The loop closes only when you state what you'll do with the reply.

## pbcopy reliably (learned the hard way)

ALWAYS use a **quoted heredoc** — never `printf`/`echo` with nested quotes. An
apostrophe ("vNeo's") or a `"` in the text silently breaks the command and copies
nothing:

```bash
pbcopy <<'HANDOFF_EOF'
...message, any quotes/apostrophes/$ are safe here...
HANDOFF_EOF
echo "✓ copied ($(pbpaste | wc -l | tr -d ' ') lines)"
```

The quoted delimiter `'HANDOFF_EOF'` means no expansion and no escaping. Always verify
with `pbpaste | wc -l`. If the owner says "add it to my clipboard" again, just re-run —
pbcopy is idempotent.

## Message format (lean + referential)

Short, and point to **shared artifacts** (git commit hash, branch, `file:line`) rather
than pasting full context — the repo is the shared state, not the clipboard.

```
<source> → <target>: <one-line ask>

<why / proof>   concrete evidence: file:line, commit hash, command output (mdls, grep).
<commands>      exact, copy-pasteable steps for the other Claude to run.
<return>        what you'll do when they reply, so the loop closes.
```

- **Direction header** (`vNeo → vBook`) orients the receiving Claude immediately.
- **Proof** (a real `mdls`/`grep` line, a commit SHA) makes the ask trustworthy, not hand-wavy.
- **Exact commands** — the other Claude should be able to run them verbatim.
- **Return action** — "then I'll pull + install + restart" — closes the handoff loop.

## Why clipboard (not SSH/Tailscale)

Until the fleet mesh (Tailscale) is up, the owner's macOS Universal Clipboard / Handoff
is the only path between machines. Even after, clipboard handoff stays useful for "have
the other Claude do X" without granting cross-machine exec — it's human-gated by design,
which is a feature.

## Anti-patterns

- Printing the handoff in chat but NOT copying it → the owner can't easily grab it. pbcopy every time.
- `printf` with `'"'"'` escaping → breaks on quotes. Heredoc only.
- Dumping full file contents → link the commit/branch/`file:line` instead.
- Vague asks ("check your fonts") → give exact commands + the proof behind the ask.
- Forgetting the return action → always say what you'll do with the reply.
