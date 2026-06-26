# SECRETS.md — what 1Password must hold for a clean bootstrap

The **only human gate for secrets is "sign into 1Password."** Everything the setup
needs comes from these items. Sign in, and the runbook (`ai.sh` / AGENTS.md) pulls
the rest — no keys on disk, no tokens in the repo.

## The manifest

| 1Password item | Type | Field(s) | Used by | Status |
|---|---|---|---|---|
| `1password_25519` | SSH Key | (served by 1Password SSH agent) | GitHub auth + inter-Mac SSH | ✓ present; pubkey registered on GitHub |
| `Dotfiles` | Document | file `dotfiles.key` | `git-crypt unlock` (AI.md P7 / `ai.sh`) | ✓ present |
| `github.com (vvkmnn)` | Login | username / password / 2FA | GitHub web fallback | ✓ present |
| **`Apple`** | Login | `username` (Apple-ID email), `password` | `xcodes` → Xcode, App Store | **➜ create this (only gap)** |

## To finish: add the `Apple` item (one-time, ~30s)

In the **1Password app** → New Item → **Login**:
- **Title:** exactly `Apple`
- **username:** your Apple-ID email
- **password:** your Apple-ID password
- Vault: **Personal**

That's the only secret not already in 1Password. (You enter it yourself — I never
handle your Apple password.)

## How the runbook consumes these

- **SSH:** the 1Password SSH agent serves `1password_25519` to `git`/`ssh` via the
  `IdentityAgent` line in `~/.ssh/config`. Nothing on disk.
- **git-crypt:** `op document get "Dotfiles" --out-file <tmp>` → `git-crypt unlock`
  → shred (AI.md P7). Decrypts `.claude/mcp/*`, `.utcp_config.json`, etc.
- **Apple/Xcode:** `ai.sh` exports `XCODES_USERNAME`/`XCODES_PASSWORD` from
  `op item get "Apple"` → `xcodes install --latest` (headless). A one-time **2FA
  code** is still required (Apple policy — unavoidable).

## The clean flow this enables

```
Point Claude at the repo
  → it reads ~/.claude/CLAUDE.md → ~/.ai/
  → asks you to SIGN INTO 1PASSWORD   ← the one gate
  → pulls SSH key, git-crypt key, Apple ID from 1Password
  → installs everything (brew + xcodes), unlocks secrets, configures
  → you enter a 2FA code + one sudo password early, then walk away
  → restart → working, clean machine
```
