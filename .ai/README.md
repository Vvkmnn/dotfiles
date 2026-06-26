# .ai — agent-driven machine setup

```
   ╭──────────────────────────────────────────────────────────╮
   │   point claude at this repo  ·  walk away  ·  come home    │
   ╰──────────────────────────────────────────────────────────╯

     ①  curl -fsSL https://claude.ai/install.sh | bash
     ②  point claude at this repo     → reads ~/.claude/CLAUDE.md → ~/.ai
     ③  sign into 1Password           → the one human gate
              │
              │   claude works, unattended:
              │   brew + xcodes  ·  dotfiles → $HOME  ·  git-crypt unlock
              ▼
     ④  ☕  walk away                  (one 2FA code + one sudo, up front)
              │
              ▼
     ⑤  come back → claude prints the exact restart steps, and why
     ⑥  restart
              │
              ▼
   ╭──────────────────────────────────────────────────────────╮
   │   [^_^]   a beautiful, ready, bug-free environment         │
   ╰──────────────────────────────────────────────────────────╯
```

## Mission

**Point Claude at this dotfiles repo on a fresh Mac, do a few expected
interventions early, walk away — and come back to a working, owner-parity
environment.**

That is the entire purpose of this folder. Everything here is judged against it:
if a step needs a click in the middle, or only works when an agent improvises,
it has failed the mission.

## The human-intervention contract

Interventions are **minimal, expected, and early** — front-loaded at the start,
never scattered through the run:

- **(early)** Apple ID / iCloud sign-in
- **(early)** Unlock **1Password** — it then serves the GitHub SSH key, the
  git-crypt key (`Personal → Dotfiles → dotfiles.key`), and Apple-ID creds
- **(early)** One **sudo** password — cached and kept alive for the whole run

After those, it runs unattended to a working environment. If you're being asked
for input *mid-run*, something violated this contract — log it in `ISSUES.md`.

## Design principles (learned the hard way — see ISSUES.md)

- **Automatable only.** The auto path is `brew` formulae + casks + **`xcodes`**
  for Xcode. **Never MAS-only apps** (Apple blocks headless App Store installs;
  `mas install` forces per-app auth) — they break "walk away." iWork etc. are
  optional and live outside the automated path.
- **One sudo + keep-alive** — never repeated password prompts.
- **Idempotent** — safe to re-run after a crash; every step skips what's done.
- **Fetch fresh from origin** before reasoning about the repo — never a stale or
  iCloud-cached copy (that mistake cost us a whole wrong plan; see ISSUES.md).
- **For the agent: execute the runbook, don't improvise.** No ad-hoc raw
  `brew`/`sudo` commands when a script/phase exists for it.
- **Discoverable.** The always-loaded `~/.claude/CLAUDE.md` points here; this is
  the entry. Errors and gotchas go in `ISSUES.md` so they're not re-hit.

## Map

| File | Role |
|---|---|
| `setup` | **the one command** — `~/.ai/setup [packages·fonts·services·xcode·macos·gate·doctor]`. Self-contained: inline package list + curated macOS defaults live in it. |
| `README.md` | this charter — mission, rules, secrets manifest, map |
| `ISSUES.md` | what broke & why, across setups — read before re-trying anything |

`~/.setup/` is **frozen reference** (the laptop's fuller `macos.sh` + `Brewfile` + per-tool scripts) — for inspiration/maintenance, not run by `setup`. Rule: **vendor only what has no working cask** (e.g. SF Mono Nerd Font → `.assets/fonts`, git-crypt); everything with a real cask stays a cask.

## Secrets (1Password — the one human gate)

Sign into 1Password and the rest is pulled; nothing on disk, no tokens in the repo.

| 1Password item | Type | Used by |
|---|---|---|
| `1password_25519` | SSH Key | GitHub + inter-Mac SSH (1Password SSH agent) |
| `Dotfiles` | Document (`dotfiles.key`) | `git-crypt unlock` → decrypts `.claude/mcp/*`, `.utcp_config.json`, `.claude.json`, `.assets/fonts/*` |
| `Apple` | Login (email + password) | `xcodes` → Xcode (one 2FA code, unavoidable) |

`op` injects per-command (`op run`, SSH agent) — keys never touch disk.

## How a fresh Mac gets set up

1. Install Claude Code: `curl -fsSL https://claude.ai/install.sh | bash`
2. Point Claude at this repo; it reads `~/.claude/CLAUDE.md` → comes here.
3. Early gates: Apple ID, **unlock 1Password**, one **sudo**.
4. Cold-start (Homebrew · deploy bare repo · `git-crypt unlock`) — see `~/.setup/AI.md`.
5. `~/.ai/setup` — installs packages, fonts, services, defaults. Walk away.
6. Grant TCC (Accessibility / Input Monitoring) when prompted; **restart** (menu-bar autohide + font cache).
7. `~/.ai/setup doctor` verifies. Gotchas → `ISSUES.md`.
