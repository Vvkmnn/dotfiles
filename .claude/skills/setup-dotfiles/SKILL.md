---
name: setup-dotfiles
description: Use when owner says "set up this Mac", "bootstrap this Mac", "match the laptop", "make this feel like mine", "/setup-dotfiles", or runs on a fresh macOS install. Front door is the self-contained ~/.ai/setup (inline package list + curated macOS defaults; phases packages·fonts·services·xcode·macos·gate·doctor). Manual gates (TCC, system-extension approvals, config-profile installs, appearance toggles like Reduce Transparency) are relayed IN-CHAT by the driving LLM — open the pane, owner flips it, verify with a probe (NOT the legacy iPhone-ping/read-loop). Every step is idempotent — safe to re-run after interruption, after a dotfiles pull, or any time as a drift check. Profile auto-detected by $USER. ~/.setup/ is frozen reference (see ~/.setup/README.md); ~/.ai/setup never sources it.
---

# setup-dotfiles

Owner-environment bootstrap orchestrator. **Source of truth: the self-contained `~/.ai/setup`** (inline package list + macOS defaults). `~/.setup/AI.md` is the cold-start runbook (the repo-internal steps `setup` can't do); `~/.setup/` is otherwise frozen reference. This skill drives `~/.ai/setup` and relays its manual gates in-chat.

> **The two skills.** `setup-dotfiles` (this one) = **discover + set up** a machine. `update-dotfiles` = **update + improve** (capture live drift back into `~/.ai/setup` + `ISSUES.md`). When you fix something live that the setup wouldn't reproduce, that's an `update-dotfiles` job.

## Activation

Trigger phrases (any of):
- `/setup-dotfiles`
- "set up this Mac"
- "bootstrap this Mac"
- "match the laptop"
- "make this feel like mine"
- "run setup-dotfiles"

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
6. **Sub-command**: `/setup-dotfiles doctor` — just runs `bash ~/.setup/ai/doctor.sh`. Exit 0/1/2 (clean/warnings/failures). No actions.

## Manual-gate UX — LLM-driven (primary)

A gate is a step macOS forbids a script from doing: grant TCC (Accessibility/Input
Monitoring), approve a system extension, install a config profile, toggle Reduce
Transparency, hide notification previews, sign into iCloud. **You (the driving LLM) are the
gate runner** — there's a person in the session with you:

1. **Explain** what the gate is for (one line).
2. **Open the pane**: `open "<deeplink>"` (or `open ~/.ai/vProfile.mobileconfig` for the profile).
3. **Wait** for the owner to flip it (they say "done").
4. **Verify with a probe** where possible — `defaults read com.apple.universalaccess reduceTransparency` (==1), `profiles list | grep vProfile`. If it didn't take, say so.

This replaces the old iPhone-ping flow. Worked example from 2026-06-27: Reduce Transparency —
`defaults write` is silently refused on Tahoe, so it MUST be a relayed gate, verified by probe.

### Gates `~/.ai/setup` opens (phase_gate)
- **Accessibility / Input Monitoring** — yabai, skhd, sketchybar, Karabiner
- **System extensions** — Karabiner, Mullvad, AdGuard (when prompted)
- **Reduce Transparency** — Accessibility ▸ Display ON (solid/"filled" menu bar; TCC-blocked)
- **vProfile** — install `~/.ai/vProfile.mobileconfig` (notification sound off, visual only)
- **Show previews → Never** — Notifications pane (hide content; not profile-able on macOS)
- **Wallpaper** — Aerial

Cold-start gates still live in `AI.md` (git-crypt key, iCloud settle, Tailscale OAuth,
Remote Login, Continuity, sudo).

### Legacy (optional): `ai_gate` / `gate.sh`
`~/.setup/ai/gate.sh`'s `ai_gate` (deeplink → iPhone notification → `read` done/skip/abort
loop) is the **unattended-owner** path — useful only when NO LLM is driving. Reference, not
default. Don't wire it into `~/.ai/setup` (which stays self-contained).

## Maintenance / drift-capture (the update loop)

When you fix something live that `~/.ai/setup` wouldn't reproduce on a fresh machine,
**capture it** — that's what keeps the fleet consistent:
1. Fix it live.
2. **Capture inline** in `~/.ai/setup` (package · default · phase) — the source of truth.
3. **Log the why** in `~/.ai/ISSUES.md` (dated bullet).
4. Relay any resulting gate in-chat.

One-shot drift audit (both directions):
```bash
# installed but NOT in the manifest
comm -23 <(brew list --cask|sort) <(grep -oE '^cask "[^"]+"' ~/.ai/setup|sed 's/cask "//;s/"//'|sort)
comm -23 <(brew leaves|sort)      <(grep -oE '^brew "[^"]+"' ~/.ai/setup|sed 's/brew "//;s/"//;s#.*/##'|sort)
# referenced-by-config but MISSING (surfaces as console noise on shell init)
zsh -lic exit 2>&1 | grep -iE 'warning|not found'
mise ls | grep -i missing
```
This is the `update-dotfiles` skill's job; `~/.ai/setup doctor` also flags gaps.

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
