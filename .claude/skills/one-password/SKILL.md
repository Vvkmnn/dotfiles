---
name: one-password
description: >
  Use when 1Password needs setting up, understanding, or FIXING on any fleet machine or browser —
  fresh-machine bootstrap, `ssh-add -l` shows "no identities", git push falls back to a password,
  Safari/Firefox/Chrome extension drift or version-skew, git-crypt won't unlock, or you need to
  know which vault item holds which key. Documents how 1Password is wired across THIS fleet and how
  to restore it — the SSH agent, the git-crypt key, the Apple ID, and the browser extensions.
version: 1.0.0
---

# one-password — 1Password, first-class across the fleet

1Password is the fleet's single source of trust: the SSH keys, the git-crypt key that unlocks the
encrypted dotfiles, the Apple ID for headless Xcode, and app/MCP secrets. This skill is the map of
**how it's wired here** plus the **recovery runbook** for when it drifts — which it does, because
several pieces are Keychain-protected GUI toggles macOS won't let a script enforce.

> **Prior art reviewed** (house rule: research existing skills before writing one). The community 1P
> skills — `kcmadden/claude-code-1password-skill`, skillregistry.io/skill/1password, 1Password's own
> docs — all cover **secrets only** (`op read`/`op run`/`op inject`, `.env.tpl`, MCP injection) and
> deliberately skip SSH keys, git signing, and browser-extension management. This skill adopts their
> progressive-disclosure structure and **fills that gap** for this fleet. Their material lives in
> `references/op-commands.md`; the fleet-specific wiring + recovery is the new part.

## What 1Password holds here (the manifest)

| What | Where in 1P | Used for |
|------|-------------|----------|
| SSH keys (per machine) | ED25519 items, e.g. `1password_25519` | github auth + git, served via the SSH agent — never on disk |
| git-crypt key | `Dotfiles` document | `op document get Dotfiles` → unlock encrypted dotfiles (MCP config, fonts, `.utcp_config`) |
| Apple ID | `Apple` login | `op run -- xcodes …` for headless Xcode installs |

Manifest of record: `~/.ai/README.md:82-90`. Each fleet Mac registers its **own** ED25519 key to
github (seen as `vbookneo (1Password)`, `vBookM3`, …) — per-machine keys are individually revocable.
A legacy `1password_rsa` may also appear in the agent; it is **not** registered on github (dead weight
there) — retire it only after confirming nothing else uses it.

## The SSH agent — the #1 thing that breaks

- **Socket:** `~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock` (1P's universal id,
  no secret). Served by the **1Password desktop app** — if the app isn't running, the socket file
  lingers but nothing answers.
- **Wired in** `~/.zshenv` (sourced by EVERY shell, including the non-login `zsh -c` that `vj`/`vssh`
  open — so it can't live in `.zshrc`/`.zprofile`).
- **THE GOTCHA (cost a whole session):** macOS pre-sets `SSH_AUTH_SOCK` to its *own* launchd agent —
  a socket that is VALID but EMPTY. So a guard like `[[ -S "$SSH_AUTH_SOCK" ]]` **always passes**, the
  1P export never runs, `ssh-add -l` says "no identities", and github SSH signs against the empty
  agent → **every push fails** (silent fallback to gh-HTTPS or a password). The fix is to gate on the
  **session**, not the socket: `[[ -n "$SSH_CONNECTION" ]] || export SSH_AUTH_SOCK=…1p sock…` — a
  LOCAL shell has no `$SSH_CONNECTION` → force the 1P socket; an INBOUND `ssh -A` session has it SET →
  keep the forwarded agent (so a headless box signs with the operator's laptop 1P). `$SSH_CONNECTION`
  beats `$SSH_TTY` because it's set even for a non-interactive `ssh -A host 'git push'` (no pty).
- **Requires (manual, once per machine):** 1P ▸ Settings ▸ Developer ▸ **"Use the SSH agent" ON**,
  and the app set to stay running (Settings ▸ General ▸ "Keep in menu bar" + "Start at login").

### Diagnose in 5 seconds
```
ssh-add -l                          # keys listed = healthy;  "no identities" = wrong socket
echo $SSH_AUTH_SOCK                  # should be the 1P Group-Container path, NOT /var/run/…launchd…
SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" ssh-add -l
                                     # bypasses the env to test the agent directly:
                                     #   keys = 1P is fine, the env var is the bug (fix ~/.zshenv)
                                     #   "refused" = 1P desktop app not running
```

## The `op` CLI — auth transport

Signed-in check: `op whoami`. On this fleet `op` is used as **auth transport**, not vault scripting:
`op run -- xcodes …` (Apple ID) and `op document get Dotfiles` (git-crypt key). For the secret-
reference patterns (`op read op://…`, `op run --env-file`, `op inject`, `.env.tpl`) see
**`references/op-commands.md`** — those are the community-skill patterns, useful if/when MCP tokens move to
runtime injection instead of git-crypt.

## Browsers — honest about what's automatable

- **Safari** (the buggy one you had to hand-update): the extension is a **separate Mac App Store app**,
  `1Password for Safari` (id **1569813296**) — and **1Password 8's main app is NOT on the App Store**
  (only the deprecated v7 + this extension). So the split (direct-download main app + App-Store
  extension) is forced by 1P's distribution. They **skew** and break (e.g. main 8.12.26 vs ext 8.12.21).
  Keep both current: the main app auto-updates itself; turn App-Store auto-update ON + run
  `mas upgrade 1569813296`. Re-enable in Safari ▸ Extensions after a MAJOR update (~60s, ~once/macOS
  major — Apple's design, unavoidable).
- **Mullvad Browser** (Firefox-based; Chrome + Mullvad are the installed non-Safari browsers —
  Firefox was removed). The 1P add-on is AMO `1password-x-password-manager`, guid
  `{d634138d-c276-4fc8-924b-40a0ea21d284}`. Force-install *is* possible via a `policies.json`
  (`ExtensionSettings` → `force_installed`) — but Mullvad only reads it from
  `…/Mullvad Browser.app/Contents/Resources/distribution/`, **inside the /Applications bundle**,
  which a Mullvad update overwrites and which isn't a tracked dotfile. So force-install is fragile
  here; a **manual install from AMO persists in the profile across updates** and is the pragmatic
  path. (Adding any extension to a privacy browser is a fingerprinting surface — a deliberate trade-off.)
- **Chrome**: no force-install without MDM → open the 1Password Chrome Web Store page and click
  **Add** once. Persists in the profile.

## Manual gates — macOS won't let these be scripted (detect, don't pretend)

Biometric enrolment · Developer ▸ "Use the SSH agent" + "Integrate with CLI" · browser "Unlock using
1Password" connection · Chrome + Safari extension enable · App Store sign-in. These toggles are
Keychain-protected with no `defaults`/MDM path on a personal Mac, so **drift is DETECTED by
`~/.ai/setup doctor`, never prevented.** The doctor probes: `ssh-add -l` shows the key · `op whoami`
works · 1P app running · extension present per browser · main-app vs Safari-ext version skew.

## Recovery

Broken agent, git-crypt won't unlock, missing extension, fresh machine → **`references/recovery.md`**.
