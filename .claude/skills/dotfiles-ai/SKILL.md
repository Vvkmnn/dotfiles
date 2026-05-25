---
name: dotfiles-ai
description: Use when owner says "set up this Mac", "bootstrap this Mac", "match the laptop", "make this feel like mine", "/dotfiles-ai", or runs on a fresh macOS install. Reads ~/.setup/AI.md and executes phases in order, pausing at manual gates with deeplinks + iPhone notification. Every step is idempotent — safe to re-run after interruption, after dotfiles pull, or any time as a drift check. Profile (workstation/server) auto-detected by $USER. Visual layer in ~/.setup/ai/ui.sh.
---

# dotfiles-ai

Owner-environment bootstrap orchestrator. Source of truth: `~/.setup/AI.md`. This skill is just the launcher.

## Activation

Trigger phrases (any of):
- `/dotfiles-ai`
- "set up this Mac"
- "bootstrap this Mac"
- "match the laptop"
- "make this feel like mine"
- "run dotfiles-ai"

## How to orchestrate

1. **Source the UI layer** if present: `. ~/.setup/ai/ui.sh` for Tokyo Night box-drawn output. Fall back to plain echo if missing (fresh-bootstrap, before P4).
2. **Detect profile**: `case "$USER" in eve) p=server ;; *) p=workstation ;; esac` and `export DOTFILES_AI_PROFILE=$p`.
3. **Read `~/.setup/AI.md` top to bottom**. It contains every phase inline as bash + manual-gate instructions. No separate runbook file.
4. **Execute phases in order** (P0 → P19). For each phase:
   - If the phase has a profile condition, check it first; skip if profile doesn't match.
   - **Run the bash directly**. Don't pre-check "have I done this" — the commands are idempotent (`brew bundle` skips installed, `defaults write` no-ops on match, `git clone` exits if dir exists, etc.).
   - On a manual gate: `open` the deeplink, send an iOS notification via `osascript -e 'tell app "Messages" to send "<gate-name>" to buddy "<owner-iphone-number>"'`, then `AskUserQuestion` with options `done` / `skip` / `abort`.
   - On `done`: re-run the phase's verify line. If it fails, surface the actual diagnostic and loop. If it passes, advance.
   - On `skip`: print warning, continue.
   - On `abort`: stop. Re-running the skill resumes from where it stopped because all prior phases are idempotent no-ops.
5. **No state markers, no manifest, no resume database.** Idempotency in the actions is the resume mechanism.
6. **Sub-command**: `/dotfiles-ai doctor` — read AI.md's "P18 — Doctor" verify suite and run only those probes. Exit 0/1/2 (clean/warnings/failures). No actions.

## Manual-gate UX

When AI.md flags a phase **[GATE]**:

1. Print a `ui_gate_pause` box if ui.sh is sourced, otherwise plain text.
2. `open "$deeplink"` to jump owner into the System Settings pane.
3. `osascript -e 'display notification "<gate>" with title "dotfiles-ai" sound name "Glass"'`. If `osascript -e 'tell app "Messages"'` to iPhone number is configured, fire that too.
4. **Probe first**: if the verify line already passes (carried via iCloud or set in a prior run), skip the gate with "(already satisfied)" — no point making the owner click for nothing.
5. Otherwise: `AskUserQuestion` with `done` / `skip` / `abort`.

The manual gates in AI.md as of writing:

- **P0.7** git-crypt key transfer (AirDrop from laptop)
- **P10** iCloud sync settle wait
- **P13** TCC checklist (single batched System Settings trip)
- **P14** Tailscale OAuth
- **P16** Remote Login toggle
- **P17.5** 9 Continuity sub-gates (mostly iPhone-side; owner pre-completes in parallel)

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
- `~/.setup/Resources/Brewfile` — workstation profile package set
- `~/.setup/Resources/Brewfile.server` — server profile package set
- `~/.setup/ai/ui.sh` — visual primitives (Tokyo Night)
- `~/.setup/macos.sh` — `defaults write` script invoked by P11
- `~/.setup/brew.sh` — legacy Brewfile wrapper (still runnable standalone)

## See also

- `~/.github/README.md` — full dotfiles README (bare-clone, conflict-resolver, launchagent loop)
- `~/dev/eve/docs/DECISIONS.md` ADR-010 — Screen Sharing + Tailscale + Jump Desktop + Guacamole remote-access stack (Eve scope, complementary)
