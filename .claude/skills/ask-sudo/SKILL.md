---
name: ask-sudo
description: >
  Use when a command needs sudo but there's no interactive terminal — e.g. running a privileged
  command (Homebrew casks, system installs, `mas`) from Claude Code's Bash tool, which has no tty
  and fails with "a terminal is required to read the password." Pops a native macOS GUI password
  dialog via SUDO_ASKPASS + osascript so sudo works without a terminal. Builds on `need_sudo()` in
  `~/.ai/setup`.
version: 1.0.0
---

# ask-sudo — GUI sudo from a no-tty context

Claude Code's Bash tool (and any non-interactive shell) has **no controlling terminal**, so a plain
`sudo` fails: *"sudo: a terminal is required to read the password."* The fix is a **GUI askpass
helper** — a tiny script that pops a native password dialog via `osascript`, wired to sudo through
`SUDO_ASKPASS` + `sudo -A`. The fleet's canonical implementation is **`need_sudo()` at
`~/.ai/setup:73`**; this skill is the pattern, its gotchas, and the log we keep growing.

> **Prior art reviewed** (house rule: research existing skills/patterns first, note it). The
> osascript-`SUDO_ASKPASS` approach is well-trodden ([hybridhacker](https://hybridhacker.com/ask-for-sudo-password-in-graphical-mode-on-macos-x.html),
> [proinsias TIL](https://proinsias.github.io/til/Mac-Ask-user-for-password-via-gui/), various
> gists). The coarser alternative — `osascript … with administrator privileges` — runs the *whole
> command* as root via a system auth prompt (no sudo timestamp, whole-command elevation). We use
> `SUDO_ASKPASS` because it caches a real sudo credential and keeps commands running as the user.
> No existing skill covered this fleet's wiring or the failure modes below, so this fills the gap.

## The pattern (minimal)
```bash
ap="$(mktemp)"
cat > "$ap" <<'EOF'
#!/bin/bash
osascript -e "display dialog \"$ASKPASS_MSG\" default answer \"\" with hidden answer with icon caution" -e 'text returned of result' 2>/dev/null
EOF
chmod +x "$ap"
ASKPASS_MSG="$(scutil --get ComputerName): sudo needed to <reason>. Authenticate to continue." \
  SUDO_ASKPASS="$ap" sudo -A -v      # GUI prompt → caches the sudo credential
rm -f "$ap"
```

## Name the reason (the improvement that created this skill)
A blank *"authenticate to continue"* is spooky and trains bad habits — you should always know *what*
you're authorizing. **Name it in the dialog** (`… sudo needed to install Homebrew casks …`).
`need_sudo()` now takes an optional reason arg + shows machine name + reason; pass one from callers:
`need_sudo "install Homebrew casks"`. (Pass the reason via an env var and strip `"` from it, so a
reason string can never break out of the AppleScript literal.)

## Gotchas we actually hit — the log we keep growing
- **The harness blocks *silent* sudo, allows *askpass*** (2026-07, verified live): Claude Code's Bash
  tool rejects bare `sudo`, `sudo -n`, and `sudo -k` with *"sudo commands require manual execution"* —
  but **allows `sudo -A` with a `SUDO_ASKPASS` helper**, because the GUI dialog is a real human gate.
  So from the Bash tool: ALWAYS `sudo -A` + the helper; never mix a silent `sudo -n`/`sudo -k` into
  the same command or the whole command is blocked. Proof: `SUDO_ASKPASS=… sudo -A whoami` → `root`.
- **`tty_tickets`** (2026-07): `sudo -v` caches the credential *for the current tty*. A child
  process that calls sudo *internally* (e.g. `mas`) runs where it can't see that ticket → still
  fails "a terminal is required." Fix: run the target **under** `sudo -A <cmd>` directly; don't rely
  on a pre-cached `sudo -v` carrying into a child's own sudo call.
- **`mas` can't be elevated this way** (2026-07): `mas upgrade` calls sudo internally (fails as
  above), and `sudo -A mas upgrade` (mas *as root*) fails with *"No downloads initiated"* — root has
  no per-user App Store session. **mas install/upgrade genuinely needs the user's own interactive
  terminal** (or the App Store GUI). Detect the skew headlessly (`mas outdated`); fix it manually.
- **Cancel = abort**: if the user cancels the dialog, osascript returns empty → `sudo -A` fails →
  the caller must `die`, never proceed blindly on unelevated state.

## Improve-me
Each new sudo-from-no-tty case that teaches us something: add it to the gotchas log above AND fold
the fix into `need_sudo()` (`~/.ai/setup:73`). The skill and that function evolve together — that's
the point of having both.
