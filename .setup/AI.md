# AI.md — the AI-driven Mac bootstrap

> Read this first. It explains what the rest of `~/.setup/` is for and how
> Claude takes a fresh Mac to owner-environment-parity.

## In one paragraph

`dotfiles-ai` is a Claude skill that orchestrates a fresh Mac install. It reads
a 19-phase runbook (`dotfiles-ai.md`), auto-detects which profile to apply
based on the user account, runs verifiable shell snippets phase-by-phase,
pauses at manual gates with iPhone notifications, and writes state markers so
re-runs resume from the last completed step instead of repeating work.

## Pieces

```
~/.setup/
├── AI.md                      ← you are here, the primer
├── dotfiles-ai.md             ← the 19-phase runbook (Claude reads this)
├── dotfiles-ai/
│   ├── ui.sh                  ← Tokyo Night palette + box drawing primitives
│   └── state/                 ← resume markers (gitignored)
│       ├── p0.done            ← timestamp + SHA of P0's verify block
│       ├── p1.done
│       └── manifest.txt       ← grep-friendly rollup
├── Resources/
│   ├── Brewfile               ← workstation profile (~80 brew + cask)
│   └── Brewfile.server        ← server profile (~12 brew + 4 cask)
├── brew.sh                    ← legacy: invokes Brewfile (still used by P-phase)
├── fonts.sh                   ← Nerd Fonts install
├── macos.sh                   ← `defaults write` calls (still used by P11)
└── README.md                  ← original ~/.setup runbook (pre-AI era)

~/.claude/skills/dotfiles-ai/
└── SKILL.md                   ← skill metadata; trigger phrases live here
```

## Profiles

**Profile = who the account is for, not what hardware runs it.**

| Profile | User accounts | Brewfile | Includes |
|---|---|---|---|
| `workstation` | Owner: `v` on laptop, `v` on mini admin, `v` on Studio admin | `Resources/Brewfile` | yabai, skhd, sketchybar, karabiner, full GUI app set |
| `server` | Daemon: `eve` on mini, `eve` on Studio | `Resources/Brewfile.server` | git, mosh, tmux, nvim, mise, uv, go, Tailscale, 1Password, Claude — no window manager |

Detection logic (in `dotfiles-ai.md`):

```bash
case "$USER" in
  eve) DOTFILES_AI_PROFILE=server      ;;
  *)   DOTFILES_AI_PROFILE=workstation ;;
esac
```

Override via `export DOTFILES_AI_PROFILE=server` before invoking.

## How to invoke

Three entry points, all equivalent:

```bash
# 1. Claude trigger phrases (read by the SKILL.md description):
"Bootstrap this Mac"
"Set up this Mac"
"Match the laptop"
"Make this feel like mine"

# 2. Slash command:
/dotfiles-ai

# 3. Doctor mode — verify every probe, change nothing:
/dotfiles-ai doctor
```

Claude reads `SKILL.md` to know the trigger phrases, then loads
`dotfiles-ai.md` to execute. The skill is auto-discovered when present in
`~/.claude/skills/dotfiles-ai/`.

## What `state/` is

`~/.setup/dotfiles-ai/state/` is the resume mechanism. Every completed phase
writes a marker:

```
~/.setup/dotfiles-ai/state/p0.done
# Contents:
2026-05-20T14:23:01Z
sha256:a4f9c2... # SHA of P0's verify block at time of completion
```

On re-run, the skill checks each marker:

- **Marker exists + SHA matches** → skip (already done, verify block unchanged)
- **Marker exists + SHA differs** → invalidate, re-run (verify block was edited upstream — fix arrived via `dotfiles pull`)
- **No marker** → run

This is chezmoi-style content-addressed state. The 5 runbook bugs we fixed
on the laptop will invalidate the corresponding markers on next mini pull
and re-run only those phases.

State is **gitignored** (never tracked across machines) — each Mac has its
own. Wipe with `rm -rf ~/.setup/dotfiles-ai/state/` to force a full re-run.
Reset one phase with `/dotfiles-ai reset p12`.

## Manual gates

Some phases require human action — `git-crypt unlock` needs the key,
Accessibility/Full Disk Access need a System Settings click, Tailscale OAuth
needs a browser sign-in. The skill detects these phases, pauses, opens the
relevant System Settings deeplink, and sends an iPhone notification via
`osascript`/Messages so you can walk away from the screen until it's time
to interact.

The 4 known admin/manual gates on the mini server profile:
- **git-crypt key** transfer + unlock (P0.7)
- **iCloud sync** settle wait (P6)
- **TCC checklist** — single batched System Settings trip (P13)
- **Tailscale OAuth** + Remote Login toggle (P14, P16)

Plus the 9 Native Continuity sub-gates in P17.5 (iMessage forwarding,
Phone relay, Continuity Camera, iPhone Mirroring pair, Notes markdown,
Apple Intelligence opt-in, AirDrop regression test, Shortcuts awareness).

## When to edit what

| Want to change | Edit |
|---|---|
| Trigger phrases for Claude | `~/.claude/skills/dotfiles-ai/SKILL.md` |
| A specific phase's action/verify | `~/.setup/dotfiles-ai.md` (phase section) |
| Server profile package list | `~/.setup/Resources/Brewfile.server` |
| Workstation profile package list | `~/.setup/Resources/Brewfile` |
| Visual look (palette, faces, boxes) | `~/.setup/dotfiles-ai/ui.sh` |
| Profile detection logic | `~/.setup/dotfiles-ai.md` § "Profile detection" |
| `defaults write` calls | `~/.setup/macos.sh` (legacy, still invoked by P11) |
| Force re-run of one phase | `rm ~/.setup/dotfiles-ai/state/p<N>.done` or `/dotfiles-ai reset p<N>` |

## Relationship to legacy `~/.setup/` scripts

Pre-AI, `~/.setup/` was a collection of shell scripts (`brew.sh`,
`fonts.sh`, `macos.sh`) invoked manually or via the original
`~/.setup/README.md` runbook. **Those still work standalone.** The AI
runbook doesn't replace them — it composes them. P-phases call into
`brew.sh` and `macos.sh` directly. You can still run those scripts by hand
on a Mac that's not bootstrapping via Claude.

## Why an AI runbook instead of one big shell script

- **Resumable**: state markers mean re-runs are idempotent and fast.
- **Verifiable**: each phase has a `verify:` block; doctor mode runs them all without changing anything.
- **Editable**: bug fixes ride through `dotfiles pull`, invalidate the markers, re-run only affected phases.
- **Manual gates**: a shell script can't pause for a System Settings click — Claude can, and can ping the owner's iPhone when it's time.
- **Profile-aware**: same runbook produces lean server installs or full workstation installs depending on `$USER`.
- **Cross-machine reusable**: laptop, mini admin, mini eve, Studio (Sept 2026), and any future Mac all run the same orchestration.

## See also

- `~/.setup/dotfiles-ai.md` — the runbook itself (open and read top to bottom; it's structured as a doc, not a script)
- `~/.claude/skills/dotfiles-ai/SKILL.md` — skill metadata
- `~/.github/README.md` — the dotfiles repo's GitHub-facing README
- `~/.setup/README.md` — the original pre-AI ~/.setup runbook
