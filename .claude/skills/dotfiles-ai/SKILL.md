---
name: dotfiles-ai
description: Use when owner says "set up this Mac", "bootstrap this Mac", "match the laptop", "make this feel like mine", "/dotfiles-ai", or runs on a fresh macOS install. Reads ~/.setup/dotfiles-ai.md, auto-detects profile (workstation/server) by hardware model, executes phases idempotently, pauses at the 4 manual gates with deeplinks + iPhone notification, runs the doctor verify suite, prints the celebration card. Persists state at ~/.setup/dotfiles-ai/state/ so re-runs resume from the last completed step. Visual layer in ~/.setup/dotfiles-ai/ui.sh (Tokyo Night palette, face glyphs, box drawing).
---

# dotfiles-ai

Owner-environment bootstrap orchestrator. Source of truth is `~/.setup/dotfiles-ai.md`. This skill is the launcher + UX.

## Activation

Trigger phrases (any of):
- `/dotfiles-ai`
- "set up this Mac"
- "bootstrap this Mac"
- "match the laptop"
- "make this feel like mine"
- "run dotfiles-ai"

## Sub-commands

| Form | Action |
|---|---|
| `/dotfiles-ai` | Dry-run first (prints plan + runs verify probes only). Owner types `go` to execute, `q` to quit. |
| `/dotfiles-ai resume` | Skip done steps, retry pending ones. |
| `/dotfiles-ai doctor` | Read-only verify pass. Print drift. No changes. |
| `/dotfiles-ai reset <step-key>` | Delete one marker so that step re-runs. |
| `DOTFILES_AI_SOUND=0 ...` | Silence the milestone sounds. |

## How to orchestrate

1. **Source the UI layer**: `. ~/.setup/dotfiles-ai/ui.sh` so all output uses the box-drawn Tokyo Night style. Fall back to plain echo if the file is missing (fresh-bootstrap edge case before Phase 4 clones dotfiles).
2. **Detect profile** via `system_profiler SPHardwareDataType` Model Name → `workstation` (MacBook/iMac) or `server` (Mac mini/Mac Studio). Export as `DOTFILES_AI_PROFILE`.
3. **Read** `~/.setup/dotfiles-ai.md` end-to-end. Parse phases. Build the execution plan filtered by profile (some phases are condition-gated).
4. **First run is dry-run by default**: print the full plan in a `ui_header` block, summarize manual gates, ask owner to type `go`.
5. **On `go`**: iterate phases in order. For each:
   - Read marker file at `~/.setup/dotfiles-ai/state/<step-key>.done`. If present AND its stored verify-block SHA matches the current SHA, skip with `ui_step ok "(already done)"`.
   - Else: print `ui_phase_start`, run the `action:` block (if auto) or print the `instructions:` and call `ui_gate_pause` (if manual), then run the `verify:` block.
   - On verify pass: write marker file with `date +%s\n<verify-sha>`. Append to `manifest.txt`.
   - On verify fail with `on-fail` block: print the diagnostic, ask owner: retry / skip-with-warning / abort.
6. **Tally**: write `~/.setup/dotfiles-ai/state/last-run.json` with `auto_steps`, `manual_gates`, `packages`, `files_synced`, `duration` for the celebration card.
7. **Call `ui_celebration`** if all phases green. Otherwise print the warnings summary.

## Manual-gate UX (the load-bearing pattern)

When a phase is `mode: manual-gate`:

1. Print `ui_gate_pause` with the deeplink URL (also `open "$url"` to jump owner into the System Settings pane).
2. Send an iOS notification via `osascript -e 'display notification ...'` so owner can walk away.
3. **Probe FIRST**: if the verify probe already passes (e.g., owner enabled the feature in a prior run, or it's iCloud-auto-carried), skip the manual gate entirely. `ui_step ok "(already satisfied)"`.
4. Otherwise: wait for owner input. Use AskUserQuestion with options:
   - `done` → re-run verify probe. On pass: write marker. On fail: print actual diagnostic, loop.
   - `skip` → write `<key>.skipped` marker + line to `warnings.log` + flag in final report. Continue.
   - `abort` → stop the run. State preserved for next `resume`.

## State semantics

- `~/.setup/dotfiles-ai/state/<step-key>.done` — single line: `<unix-timestamp> <verify-block-sha>`
- `~/.setup/dotfiles-ai/state/manifest.txt` — append-only: `<step-key>\t<status>\t<timestamp>`
- `~/.setup/dotfiles-ai/state/warnings.log` — append-only: `<step-key>\t<reason>\t<timestamp>`
- `~/.setup/dotfiles-ai/state/last-run.json` — `{auto_steps, manual_gates, packages, files_synced, duration}` from most-recent successful celebration

All gitignored (dotfiles repo has `status.showUntrackedFiles no`).

## What to do when invoked on a fresh Mac (~/.setup/ doesn't exist yet)

Chicken-and-egg edge case: on a brand-new Mac, the dotfiles repo isn't cloned yet, so `~/.setup/dotfiles-ai.md` doesn't exist locally. Path:

1. If `~/.setup/dotfiles-ai.md` is missing, fetch it from GitHub:
   ```bash
   mkdir -p ~/.setup
   curl -fsSL https://raw.githubusercontent.com/Vvkmnn/dotfiles/claude/dotfiles-ai/.setup/dotfiles-ai.md \
     -o ~/.setup/dotfiles-ai.md
   ```
2. Likewise for the UI layer:
   ```bash
   mkdir -p ~/.setup/dotfiles-ai
   curl -fsSL https://raw.githubusercontent.com/Vvkmnn/dotfiles/claude/dotfiles-ai/.setup/dotfiles-ai/ui.sh \
     -o ~/.setup/dotfiles-ai/ui.sh
   chmod +x ~/.setup/dotfiles-ai/ui.sh
   ```
3. After Phase 4 (dotfiles clone), the files are present locally and the runbook is the canonical source.

The owner is the only one who can `/dotfiles-ai` on the mini (or any Mac). They confirm `go`, sit through 4 manual gates, walk away during the auto phases. Walk-and-trust pattern.

## Non-goals (don't do these)

- Don't modify the existing interactive `~/.setup/setup.sh` — it stays as the legacy guided path.
- Don't touch the `eve` standard user account on the mini (Eve's concern, separate scope).
- Don't write to dotfiles tracked files outside the dotfiles-ai paths (no global config edits, no `~/.gitconfig` rewrites — those existed before).
- Don't run on a Linux machine — Tahoe-targeted. Fail-fast in Phase 0 if not macOS arm64.
- Don't bypass manual gates with sudo tricks — they exist because macOS forces them.

## Companion files (all in dotfiles)

- `~/.setup/dotfiles-ai.md` — the runbook (this skill reads it)
- `~/.setup/Resources/Brewfile.server` — server-profile package set
- `~/.setup/dotfiles-ai/ui.sh` — visual primitives
- `~/.setup/Resources/Brewfile` — existing workstation Brewfile (unchanged)
- `~/.setup/macos.sh` — existing defaults script (called by Phase 11, unchanged)

## See also

- `~/.github/README.md` — owner's full dotfiles README (bare-clone instructions, conflict-resolver, launchagent install loop)
- `~/.config/tmux/claude-session-restore.sh` — visual palette source (lines 67-71)
- `~/dev/eve/docs/DECISIONS.md` ADR-010 — Screen Sharing + Tailscale + Jump Desktop + Guacamole remote-access stack (Eve scope, complementary)

Model: Claude Opus 4.7 1M (Anthropic, May 2026)
