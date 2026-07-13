# .ai — shared AI machine setup

```
   ╭──────────────────────────────────────────────────────────╮
   │   point a strong AI at this repo · unlock 1Password · run │
   ╰──────────────────────────────────────────────────────────╯

     ①  install one capable AI CLI/app  → Codex or Claude
     ②  point it at this repo           → reads tool adapter → ~/.ai
     ③  sign into 1Password             → the one human secrets gate
              │
              │   AI works, unattended:
              │   brew + xcodes · dotfiles → $HOME · git-crypt unlock
              ▼
     ④  ☕  walk away                    (one 2FA code + one sudo, up front)
              │
              ▼
     ⑤  come back → exact restart and manual-permission steps
     ⑥  restart
              │
              ▼
   ╭──────────────────────────────────────────────────────────╮
   │   [^_^]   a beautiful, ready, owner-parity environment    │
   ╰──────────────────────────────────────────────────────────╯
```

## Mission

**Point Codex, Claude, ChatGPT, or another capable AI at this dotfiles repo on a
fresh Mac, do the expected interventions early, walk away, and come back to a
working owner-parity environment.**

This folder is the shared source of truth. Tool-specific folders are adapters:
they should point here, not duplicate the runbook.

## Human-intervention contract

Interventions are **minimal, expected, and early**:

- **Apple ID / iCloud sign-in** for Xcode and device continuity
- **Unlock 1Password** for GitHub SSH, git-crypt, and Apple-ID credentials
- **One sudo password** cached and kept alive during setup
- **One Apple 2FA code** for `xcodes`, when Xcode is not already installed
- **Manual macOS privacy gates** after install: Accessibility, Input Monitoring,
  Screen Recording, notifications, and system extensions

After those, setup should run unattended. If a mid-run prompt appears, log it in
`ISSUES.md`.

## Principles

- **AI, not vendor lock-in.** Shared rules live here; Codex/Claude adapters stay
  thin.
- **Automatable only.** Use Homebrew formulae/casks and `xcodes`; avoid MAS-only
  apps in the unattended path.
- **One sudo + keep-alive.** Never scatter password prompts through a run.
- **Idempotent.** Every phase must be safe to rerun after a crash.
- **Fetch fresh before reasoning.** Avoid stale iCloud or old local branches.
- **No raw secrets or runtime state.** Use `op` and git-crypt deliberately; do
  not track OAuth tokens, SQLite state, sessions, histories, or caches.
- **Simple until pain proves otherwise.** Add skills/hooks/profiles only after a
  repeated workflow earns them.

## Map

| File | Role |
|---|---|
| `README.md` | shared charter, contracts, secrets, setup map |
| `codex.md` | Codex TUI/App daily-use policy and setup |
| `chatgpt.md` | ChatGPT macOS/iOS integration, remote control, appshots |
| `fleet.md` | shared multi-machine and multi-AI handoff contract |
| `codex/config.toml` | safe Codex template; setup merges selected keys locally |
| `setup` | one command: `~/.ai/setup [packages·fonts·services·xcode·macos·remote·codex·gate·doctor]` |
| `ISSUES.md` | failures and gotchas across machine setups |
| `vProfile.mobileconfig` | manual macOS notification/profile gate |

`~/.setup/` is frozen reference. Do not run random old setup scripts when
`~/.ai/setup` has a phase for the job.

## Secrets

Sign into 1Password and let commands fetch what they need. Nothing secret is
checked into the repo unless it is intentionally git-crypt encrypted.

| 1Password item | Type | Used by |
|---|---|---|
| `1password_25519` | SSH Key | GitHub and inter-Mac SSH via 1Password SSH agent |
| `Dotfiles` | Document (`dotfiles.key`) | `git-crypt unlock` for encrypted dotfiles |
| `Apple` | Login | `xcodes` headless Xcode install |

Codex-specific local files such as `~/.codex/auth.json`, SQLite DBs, logs,
history, sessions, plugin cache, and app runtime state are machine-local and
must stay untracked.

Claude's installed-plugin registry, marketplace checkout, cache, and timestamped
marketplace state are also machine-local. Reproduce integrations through setup
and tracked settings instead of committing generated plugin state.

## Backups

`~/.ai/backup` — one command, run it before any sweeping git operation. Bundles the
FULL repo history (all refs; git-crypt files stay ciphertext — secret-safe) to the
iCloud shelf and keeps the last 5:

    iCloud Drive → Dotfiles/
      Backups/<machine>/    per-machine bundles + pre-merge snapshots (this command)
      Build/                fleet-unification working area (transient)
      git-crypt-key-…       local key copy — CANONICAL copy lives in 1Password

Restore anywhere: `git clone <bundle> x && cd x && git-crypt unlock <key>`.

## Fresh Mac flow

1. Install any capable AI CLI/app you plan to use: Codex, Claude, or another tool.
2. Point the AI at this repo; tool adapters lead back to `~/.ai`.
3. Unlock 1Password and run the bare-repo/git-crypt cold start.
4. Run `~/.ai/setup`; use `~/.ai/setup codex` after Codex is installed.
5. Grant macOS gates from `~/.ai/setup gate`.
6. If Claude is installed, restart it after the Codex phase and run
   `/codex:setup --disable-review-gate` once to verify the official Claude↔Codex
   bridge while preserving selective, on-demand review.
7. Restart the Mac, then run `~/.ai/setup doctor` and `codex doctor --all`.

For Codex specifics, read `codex.md`. For ChatGPT macOS/iOS integration, read
`chatgpt.md`. For Claude/Codex work across machines, read `fleet.md`.
