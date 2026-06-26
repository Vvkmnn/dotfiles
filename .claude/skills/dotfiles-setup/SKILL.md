---
name: dotfiles-setup
description: Use when owner says "set up this Mac", "bootstrap this Mac", "match the laptop", "make this feel like mine", "/dotfiles-setup", or runs on a fresh macOS install. Reads ~/.setup/AI.md and executes phases in order, pausing at manual gates with deeplinks + iPhone notification. Every step is idempotent — safe to re-run after interruption, after dotfiles pull, or any time as a drift check. Profile (workstation/server) auto-detected by $USER. Helpers: ~/.setup/ai/ux.sh (visual), ai/gate.sh (manual gates), ai/doctor.sh (verify).
---

# dotfiles-setup

Owner-environment bootstrap orchestrator. Source of truth: `~/.setup/AI.md`. This skill is just the launcher.

## Activation

Trigger phrases (any of):
- `/dotfiles-setup`
- "set up this Mac"
- "bootstrap this Mac"
- "match the laptop"
- "make this feel like mine"
- "run dotfiles-setup"

## The front door: `~/.ai/setup`

**The automatable install/config is consolidated in `~/.ai/setup`** — a single
self-contained bash command (`packages · fonts · services · xcode · macos · gate · doctor`;
inline package list + curated macOS defaults). **Prefer it over re-running AI.md's inline bash.**
Read `~/.ai/README.md` first — it's the charter + the 1Password secrets manifest.

- **Fresh Mac (cold):** do AI.md **P0–P7** (the part `setup` can't — it lives *in* the repo:
  fetch → Homebrew → deploy bare repo → git-crypt unlock; see the fresh-Mac edge case below),
  then run `~/.ai/setup` for packages/fonts/services/macos.
- **Already deployed (drift / re-run):** just `~/.ai/setup` (idempotent).
- **Verify any time:** `~/.ai/setup doctor`.

`AI.md` remains the **full runbook** for cold-start + the deeper manual gates `setup` doesn't
cover (Tailscale P14, Remote Login P16, Continuity P17.5). The legacy phase-by-phase path
(reading AI.md top-to-bottom + sourcing `.setup/ai/*.sh`) still works and is documented below.

## How to orchestrate (legacy phase-by-phase — for cold-start + deeper gates)

1. **Source helpers** if present: `. ~/.setup/ai/ux.sh` and `. ~/.setup/ai/gate.sh` for visual + gate orchestration. Fall back to plain `echo` + inline `open`+`read` loops if missing (fresh-bootstrap, before P4).
2. **Detect profile**: `case "$USER" in eve) p=server ;; *) p=workstation ;; esac` and `export DOTFILES_AI_PROFILE=$p`.
3. **Read `~/.setup/AI.md` top to bottom**. It contains every phase inline as bash + manual-gate instructions.
4. **Execute phases in order** (P0 → P19). For each phase:
   - If the phase has a profile condition, check it first; skip if not matching.
   - **Run the bash directly**. Don't pre-check "have I done this" — the commands are idempotent (`brew bundle` skips installed, `defaults write` no-ops on match, `git clone` exits if dir exists, etc.).
   - On a `[GATE]` phase: prefer `ai_gate "<name>" "<deeplink>" "<verify_cmd>" "<help>"` from `gate.sh`. It probes verify first (silent skip if already satisfied), opens the deeplink, sends notification, and runs the done/skip/abort loop.
   - On non-gate failure: surface the actual diagnostic and offer retry/skip/abort.
5. **No state markers, no manifest.** Idempotency in the actions is the resume mechanism.
6. **Sub-command**: `/dotfiles-setup doctor` — just runs `bash ~/.setup/ai/doctor.sh`. Exit 0/1/2 (clean/warnings/failures). No actions.

## Manual-gate UX

When AI.md flags a phase **[GATE]**, source `gate.sh` and call `ai_gate`:

```bash
. ~/.setup/ai/gate.sh
ai_gate "<name>" "<deeplink_or_empty>" "<verify_cmd>" "<help_line_1>" "<help_line_2>"
```

`ai_gate` handles all five steps:

1. **Pre-checks** the verify cmd; if it already passes, returns silently with "(already satisfied)" — no point making the owner click for nothing.
2. **Opens** the deeplink (if given) via `open`.
3. **Notifies** via `osascript display notification` + Messages-to-iPhone if `AI_GATE_IPHONE` env var is set.
4. **Prints** the orange-bordered box with help text.
5. **Loops** on owner input: `done` re-runs verify, `skip` warns and returns 1, `abort` returns 2.

If `gate.sh` is missing (pre-P4 fresh bootstrap), fall back to a minimal inline equivalent — `open` + `read -p "done? "` + re-run verify.

The 7 manual gates in AI.md:

- **P0.7** git-crypt key transfer (AirDrop from laptop)
- **P10** iCloud sync settle wait
- **P13** TCC checklist (single batched System Settings trip)
- **P14** Tailscale OAuth
- **P16** Remote Login toggle
- **P17.5** 9 Continuity sub-gates (mostly iPhone-side; owner pre-completes in parallel)
- **P12** sudo password for pmset (server) / yabai SA P17 (workstation) — pre-cached via `sudo -v`

## Fresh-Mac edge case (~/.setup/AI.md doesn't exist yet)

The dotfiles repo gets cloned in P4. Before that, AI.md isn't on disk. To bootstrap from cold:

```bash
mkdir -p ~/.setup
curl -fsSL https://raw.githubusercontent.com/Vvkmnn/dotfiles/v-macos-macbook/.setup/AI.md -o ~/.setup/AI.md
```

Then proceed from P0. After P4 lands the cloned repo, AI.md gets overwritten with the canonical tracked version (identical content if branches are in sync).

## Non-goals

- Don't modify the existing interactive `~/.setup/setup.sh` (legacy guided path stays).
- Don't touch the `eve` standard user account (separate scope).
- Don't write to dotfiles tracked files outside what AI.md's phases specify.
- Don't run on Linux. Tahoe-targeted. Fail-fast at P0.
- Don't bypass manual gates with sudo tricks. They exist because macOS forces them.
- **Don't create a separate runbook file.** AI.md is the runbook.

## Companion files

- `~/.setup/AI.md` — the runbook (this skill reads it)
- `~/.setup/ai/ux.sh` — visual primitives (Tokyo Night palette, boxes, faces, celebration)
- `~/.setup/ai/gate.sh` — manual-gate orchestration helper (`ai_gate <name> <deeplink> <verify>`)
- `~/.setup/ai/doctor.sh` — standalone verify suite (P18); `bash ~/.setup/ai/doctor.sh` any time
- `~/.setup/Resources/Brewfile` — workstation profile package set
- `~/.setup/Resources/Brewfile.server` — server profile package set
- `~/.setup/macos.sh` — `defaults write` script invoked by P11
- `~/.setup/brew.sh` — legacy Brewfile wrapper (still runnable standalone)

## See also

- `~/.github/README.md` — full dotfiles README (bare-clone, conflict-resolver, launchagent loop)
- `~/dev/eve/docs/DECISIONS.md` ADR-010 — Screen Sharing + Tailscale + Jump Desktop + Guacamole remote-access stack (Eve scope, complementary)
