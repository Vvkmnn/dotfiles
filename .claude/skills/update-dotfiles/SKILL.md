---
name: update-dotfiles
author: Vvkmnn
description: Use when user says "update dotfiles", "commit dotfiles", "sync dotfiles", "push dotfiles", "update docs and dotfiles", "add to docs and dotfiles", "docs and dotfiles", or asks to save/backup their config — and whenever Claude itself proposes updating dotfiles OR docs. Runs a DOCS-FIRST pass (accurate function docstrings/comments in the code you just changed, then relevant project docs — README/CHANGELOG/memory), THEN the dotfiles commit. Manages the bare git repo at ~/.dotfiles with logical commits, security checks, config discovery, and a plan-artifact/launch-daemon capture pass so recent machine-config work is reproducible on fresh machines.
version: 0.5.0
---

# Dotfiles Update

## Repository

**Type:** Bare git repo (`~/.dotfiles/` git-dir, `~/` work tree)
**Remote:** `git@github.com:Vvkmnn/dotfiles.git`
**Command:** `dotfiles` alias or `/usr/bin/git --git-dir=/Users/v/.dotfiles/ --work-tree=/Users/v`

### Branches (one per machine)

| Branch | Machine | Notes |
|--------|---------|-------|
| `master` | — | Default/base, shared README |
| `v-macos-macbook` | MacBook | **Current machine** |
| `v-macos-studio` | Mac Studio | |
| `v-macos` | Generic macOS | |
| `v-debian` | Debian | |
| `v-debian-wsl` | WSL | |

Always commit to the current branch. Never switch branches without asking.

### What's Tracked (~1136 files)

| Category | Scope | Key Files |
|----------|-------|-----------|
| Shell | `shell` | `.alias`, `.functions`, `.minimal`, `.profile`, `.rc`, `.shell`, `.bashrc`, `.zshrc`, `.zshenv`, `.zimrc`, `.p10k.zsh`, `.fishrc`, `.hushlogin` |
| Claude Code | `claude` | `.claude/CLAUDE.md`, `README.md`, `docs/*` (CHANGELOG, CONFIG), `settings.json`, `keybindings.json`, `statusline.sh`, `rules/*`, `hooks/*`, `skills/*`, `agents/*`, `workflows/*`, `mcp/config.json` (encrypted), `mcp/bin/start-proxy.sh`, `mcp/com.claude.mcp-proxy.plist.template`, `.claudeignore`, `.gitignore` |
| Karabiner | `karabiner` | `.config/karabiner/karabiner.json`, `KARABINER.md`, `scripts/*`, `assets/complex_modifications/*`, `automatic_backups/*` |
| Sketchybar | `sketchybar` | `.config/sketchybar/sketchybarrc`, `plugins/*`, `helpers/*.swift` |
| WM | `wm` | `.skhdrc`, `.yabairc`, `.config/yabai/*` |
| Terminal | `terminal` | `.config/ghostty/*`, `.config/tmux/*`, `.config/kitty/*`, `.config/alacritty/*`, `.config/wezterm/*` |
| Editor | `editor` | `.vimrc`, `.config/nvim` (submodule), `Library/Application Support/Code/*` |
| Git | `git` | `.gitconfig`, `.gitmessage`, `.gitignore`, `.gitattributes`, `.globalgitignore`, `.gitmodules` |
| GH | `gh` | `.config/gh/config.yml` (no tokens — `hosts.yml` is separate) |
| Alfred | `alfred` | `.alfred/*` (~400 files) — **DEPRECATED: Raycast replaced it; NOT in use, kept for reference only** |
| Raycast | `raycast` | `.config/raycast/raycast.rayconfig` (encrypted free-tier export; import via Raycast "Import Settings & Data") |
| Setup | `setup` | **`.ai/*` (LIVE: setup · README · ISSUES · vProfile.mobileconfig)** + `.setup/*` (frozen reference) |
| Docker | `docker` | `.docker/*` |
| Fish | `fish` | `.config/fish/*`, `.config/fisher/*`, `.config/omf/*` |
| Meta | `dotfiles` | `.github/README.md`, `.logo`, `.theme`, `.assets/*`, `.utcp_config.json` |

## Workflow

### Phase 0: Docs first (do BEFORE staging anything)

When the trigger mentions "docs" (e.g. "update docs and dotfiles"), OR any code changed this session,
sweep docs before the commit — the commit should capture accurate docs, not stale ones:

1. **Function docs** — for every function/block you touched, confirm its docstring/header comment still
   matches what the code does (params, return, behaviour, gotchas). Fix drift; a wrong comment is worse
   than none. Don't add docs to code you didn't change.
2. **Project docs** — update whatever the change makes stale: a module README, `~/.claude/docs/CHANGELOG.md`,
   the project's memory (`~/.claude/projects/<slug>/memory/` + `MEMORY.md` index) for non-obvious learnings
   or hard-won gotchas, and `~/.github/README.md` tree counts if `.claude/` structure changed (see Phase 6).
3. **Then** proceed to the dotfiles commit below — the doc edits ride in the same logical commit(s) as the
   code they document (same scope), or their own `DOCS(scope):`/`CHORE(scope):` commit if standalone.

Skip only if nothing changed and the ask is a pure sync. "docs and dotfiles" always runs this phase.

### Phase 1: Analyze

```bash
# Run in parallel
dotfiles status
dotfiles diff --stat
dotfiles log --oneline -15
```

**States:**
- Clean → Skip to Phase 5 (Discovery)
- Changes → Continue to Phase 2
- nvim submodule modified → See Special Cases

### Phase 2: Security Audit

**Before proposing ANY commits, scan for risks:**

```bash
dotfiles diff --name-only | grep -iE '(token|secret|credential|password|\.env|\.pem|\.key|npmrc)'
```

| File | Risk | Action |
|------|------|--------|
| `.npmrc` | npm auth token | NEVER stage |
| `.env*` | Environment secrets | NEVER stage |
| `*.pem`, `*.key`, `*.p12` | Certificates | NEVER stage |
| `.utcp_config.json` | MCP tokens | OK — git-crypt encrypted |
| `.claude/mcp/config.json` | mcp-proxy tokens | OK — git-crypt encrypted |
| `.claude/settings.json` | May reference API config | Inspect before staging |
| `.docker/config.json` | Docker Hub auth tokens | NEVER stage (untracked) |
| `.npmrc` | npm auth token | NEVER stage (untracked) |
| `.config/ngrok/ngrok.yml` | ngrok auth token | NEVER stage (untracked) |
| `.ssh/config` | Machine-specific paths | Don't track (Colima refs to /Volumes) |

**Verify git-crypt (HEAD):** `dotfiles show HEAD:.utcp_config.json | head -1` → should show `GITCRYPT`
**Verify git-crypt (STAGED — the check that matters pre-commit):** `dotfiles show :path` applies the SMUDGE filter and prints decrypted plaintext — a grep for GITCRYPT there fails even when encryption is perfect (learned 2026-07-06). Use the raw object instead:
```bash
BLOB=$(dotfiles ls-files -s .claude/mcp/config.json | awk '{print $2}')
dotfiles cat-file blob "$BLOB" | head -c 9   # must print \0GITCRYPT
```

**Display flagged files prominently. STOP if any risk found.**

### Phase 3: Group into Logical Commits

**Grouping rules:**
- Changes in one category → one commit with that category's scope
- Changes across multiple categories → separate commit per category
- Trivial scattered changes (1 file each, 3+ categories) → combine as `QUICKSAVE(dotfiles)`

Use the **Scope** column from the table above. Examples:
- Karabiner config + script → `FIX(karabiner): Description`
- Shell aliases + functions → `FEAT(shell): Description`
- Mixed tmux + ghostty → `CHORE(terminal): Description`
- Everything changed a little → `QUICKSAVE(dotfiles): Sync config updates`

### Phase 4: Sequential Approval

Present each commit group ONE AT A TIME:

```
COMMIT 1/N: TYPE(scope): Short description
──────────────────────────────────────────────
Files:
  - path/to/file1
  - path/to/file2

Message:
  TYPE(scope): Subject line here

  - Specific change detail
  - Another change detail
```

**Ask user** (AskUserQuestion with options):
- **Approve** → stage and commit
- **Edit message** → user provides new message
- **Skip** → move to next group
- **Abort** → stop entirely

**Execute:**
```bash
dotfiles add <specific-files>
dotfiles commit -m "$(cat <<'EOF'
TYPE(scope): Subject line

- Detail
EOF
)"
```

**Repeat for each group.**

### Phase 5: Config Discovery

**After committing, suggest untracked configs the user may want to track.**

```bash
# Check common locations for untracked files
for dir in ~/.config/ghostty ~/.config/tmux ~/.config/karabiner \
           ~/.config/sketchybar ~/.config/lazygit ~/.config/yabai \
           ~/.config/btop ~/.config/starship; do
  [ -d "$dir" ] && untracked=$(dotfiles ls-files --others "$dir" 2>/dev/null | wc -l | tr -d ' ') \
    && [ "$untracked" -gt 0 ] && echo "$dir: $untracked untracked"
done
```

**Also check for:**
- New apps in `~/.config/` not yet tracked
- Changes to `~/Library/Application Support/` (VS Code, Cursor)
- New shell dotfiles (`.tool-versions`, `.mise.toml`, etc.)
- `~/Library/LaunchAgents/` — do NOT track auto-generated or third-party plists (Google/Alfred/brew/CleanMyMac/Steam) or a live hand-authored plist verbatim (its absolute `/Users/<you>/…` paths break a fresh install). DO capture each hand-authored **load-bearing** daemon (`com.user.*`, `com.claude.*` — e.g. the tmux `lambda.sh` save-loop) as a machine-agnostic **`.plist.template`** (paths → `$HOME`). See Phase 5c for the sweep that catches these.
- Sketchybar `helpers/*.swift` sources (track source, not compiled binaries)

**Ask:** "Found N untracked config files in [dirs]. Want to review them for tracking?"

### Phase 5b: Manifest drift — keep `~/.ai/setup` honest

The owner doesn't always remember to capture new apps/tools (that's the point of this skill).
On any dotfiles commit, run the two-direction drift audit and offer to fold gaps into the
manifest BEFORE committing:

```bash
# (A) installed but NOT in the manifest → candidates to add
comm -23 <(brew list --cask|sort) <(grep -oE '^cask "[^"]+"' ~/.ai/setup|sed 's/cask "//;s/"//'|sort)
comm -23 <(brew leaves|sort)      <(grep -oE '^brew "[^"]+"' ~/.ai/setup|sed 's/brew "//;s/"//;s#.*/##'|sort)
# (B) referenced-by-config but MISSING (shell-init noise = a fresh-machine break)
zsh -lic exit 2>&1 | grep -iE 'warning|not found'
mise ls | grep -i missing
```

- **Capture into `~/.ai/setup`** (the LIVE manifest), never `.setup/` (frozen reference).
- Annotate by owner-relevance; don't blindly add — skip one-off/experimental installs, ask.
- Things mise-managed (node·python·cmake) or shipped by a cask (tailscale CLI) do NOT belong
  as separate `brew` lines. MAS-only apps need owner sign-off (App Store gate).
- Log non-obvious root causes in `~/.ai/ISSUES.md`. `~/.ai/setup doctor` also flags gaps.

This is the "you help me remember" loop — paired with `setup-dotfiles` (discover/set up).

### Phase 5c: Plan-artifact capture — did recent work actually LAND?

Machine-config work spread across sessions produces artifacts that live OUTSIDE the files a
plain `diff` surfaces — launchd daemons in `~/Library/LaunchAgents/`, standalone scripts,
`defaults write` keys, WM configs. A plan can read "done" while its runner was never tracked.

> Canonical miss (2026-07): the tmux save-loop was reworked into `~/.config/tmux/lambda.sh`,
> driven by `~/Library/LaunchAgents/com.user.tmux-save.plist` — both untracked. The dotfiles
> even held a committed *older* `tmux-save-guard.sh`, so the tree looked consistent while the
> LIVE λ daemon + script + the `machine_badge.sh` that calls them were all uncommitted. A fresh
> checkout would run the stale design and start no daemon at all.

**Run this whenever dotfiles are updated — including any time Claude proposes or merely mentions
"update dotfiles" / "updating dotfiles", not just on an explicit request.**

1. Enumerate recent machine-config / dotfiles plans (heuristic: last ~13 by mtime); keep the
   ones about machine config, setup, tmux, wm/yabai, sketchybar, karabiner, launchd, fleet:
   ```bash
   ls -t ~/.claude/plans/*.md | head -13
   ```
2. For each relevant plan, list the artifacts it PRODUCED — scripts, plists/daemons, `defaults`
   keys, new config files — and confirm each is tracked (empty output = a gap):
   ```bash
   dotfiles ls-files <path>
   ```
3. Sweep the external stores a diff won't show:
   ```bash
   # hand-authored daemons (com.user.* / com.claude.*) — is each captured as a template?
   ls ~/Library/LaunchAgents/com.user.*.plist ~/Library/LaunchAgents/com.claude.*.plist 2>/dev/null
   # a tracked file deleted on disk = a likely rename/rework whose new file is untracked
   dotfiles status --porcelain=v1 -uno | grep '^ D'
   # what each daemon actually runs — verify that target script is tracked
   grep -A1 ProgramArguments ~/Library/LaunchAgents/com.user.*.plist 2>/dev/null
   ```
4. Capture each gap so BOTH the repo and a fresh machine can RECREATE it — being *aware* isn't
   enough, the setup must be reproducible. Capture differs by daemon type:
   - **Hand-authored daemon** (`com.user.*`, `com.claude.*` — e.g. tmux `lambda.sh` save-loop):
     track the **script** + a machine-agnostic **`.plist.template`** (paths → `$HOME`), AND
     record the install step in `~/.ai/setup` so `setup-dotfiles` loads it on a new machine:
     ```bash
     # repo renders the __HOME__ token at install time (see mcp/*.plist.template)
     sed 's#__HOME__#'"$HOME"'#g' ~/.config/tmux/com.user.tmux-save.plist.template \
       > ~/Library/LaunchAgents/com.user.tmux-save.plist
     launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.user.tmux-save.plist
     ```
   - **brew-managed daemon** (yabai/skhd/sketchybar): do NOT track its plist — it's regenerated
     by `brew services start <name>`; capture THAT as the setup step instead.
   - **`defaults write` keys / one-off scripts**: fold into `~/.ai/setup` (the curated
     macOS-defaults + script list), not just the dotfiles tree.

   A plan is "done" only when its artifacts AND their recreation recipe are captured. Verify with
   a dry-run mental checkout: *"fresh machine → clone → git-crypt unlock → `~/.ai/setup` → does
   this daemon come back on its own?"* If no, the recipe is incomplete. This makes both the repo
   AND `setup-dotfiles`/`~/.ai/setup` aware of every daemon and how to stand it up on any machine.

### Phase 6: Report

```bash
dotfiles log --oneline -5
dotfiles status
```

**README staleness check:** If commits touched `.claude/` (rules, skills, hooks, mcp) or category structure changed, verify `~/.github/README.md` tree counts still match reality (10 rules, 29 skills, 6 hooks, 36 servers, ~1136 files). Suggest update if stale.

Report: "Committed as [hashes]. Push with `dotfiles push`"

## Commit Message Style

**Primary source: `dotfiles log --oneline -15`.** Always read and match.

**Format:**
```
TYPE(scope): Subject (max 50 chars, imperative, capitalized, no period)

Category:
- Specific change
- Another change
```

**Types (UPPERCASE for dotfiles repo):**
- `FEAT` — New config, feature, or tracked file
- `FIX` — Bug fix or correction
- `CHORE` — Maintenance, cleanup, sync
- `QUICKSAVE` — Fast save, minor mixed changes

**Subject rules:**
- Imperative mood: "Add", "Fix", "Update" not "Added", "Fixes"
- Specific and searchable: `FIX(karabiner): Replace to_if_alone with to_after_key_up` not `FIX: Update config`
- NEVER mention Claude, AI, LLM, copilot, or AI tooling

## Special Cases

### Karabiner
- All files tracked through dotfiles — no separate repo
- `scripts/` has `smart-screenshot-resize.sh`, `impbcopy` (compiled binary), test scripts
- `automatic_backups/` has dated snapshots (Karabiner-managed)
- Stage specific: `dotfiles add ~/.config/karabiner/<file>`

### nvim Submodule
- `.config/nvim` → submodule pointing to `github.com/Vvkmnn/v.nvim.git`
- `.claude/settings.local.json` in nvim is local-only, ignore
- Other changes: commit to nvim repo first, then `dotfiles add .config/nvim`

### Brewfile
```bash
brew bundle dump --file=~/.setup/Resources/Brewfile --force
dotfiles add ~/.setup/Resources/Brewfile
```

### Git-Crypt
- Key: `/Users/v/Documents/key` (also in 1Password)
- Encrypted files (see `.gitattributes`):
  - `.utcp_config.json` — retired code-mode config, kept encrypted for reference
  - `.claude/mcp/config.json` — mcp-proxy config with API + Bearer tokens
  - (`.claude.json` is gitignored, NOT tracked — regenerated by `claude /login`; `mcp.json.bak` retired 2026-07-06)
- New machine: `git-crypt unlock ~/dotfiles.key`
- Verify: `dotfiles show HEAD:.utcp_config.json | head -1` → `GITCRYPT` header

### MCP config (`mcp/config.json`) — RETIRED: `mcp.json.bak`

**Source of truth** is now `~/.claude/mcp/config.json` (git-crypt encrypted): the TBXark mcp-proxy definitions, 14 active + 12 parked under `disabledServers`. Full inventory + fleet table + machine-2 bootstrap: `docs/CONFIG.md` MCP section.

> RETIRED 2026-07-06: `mcp.json.bak` (the code-mode/UTCP-era 36-server merge backup) was deleted — UTCP was replaced by mcp-proxy on 2026-02-01, so the merge-from-`~/.utcp_config.json` workflow that lived here was dead. The encrypted blob remains in git history if ever needed. The old jq merge script is preserved in that history; nothing captures into a `.bak` on dotfiles update anymore — `config.json` is edited directly and committed (git-crypt keeps it encrypted at rest).

See `~/.claude/docs/CONFIG.md` (MCP section) for full server inventory (14 active / 12 parked).

### mcp-proxy

`TBXark/mcp-proxy` (Go) — NOT the brew `mcp-proxy` (`sparfenyuk/mcp-proxy`, Python — different project entirely).

```bash
go install github.com/TBXark/mcp-proxy@latest
mkdir -p ~/.claude/mcp/bin
cp "$(go env GOPATH)/bin/mcp-proxy" ~/.claude/mcp/bin/
```

## Quick Reference

| Action | Command |
|--------|---------|
| Status | `dotfiles status` |
| Diff | `dotfiles diff -- <file>` |
| Tracked files | `dotfiles ls-files ~` |
| Untracked in dir | `dotfiles ls-files --others <dir>` |
| Stage specific | `dotfiles add <file>` |
| Stage all tracked | `dotfiles add -u` |
| Commit | `dotfiles commit -m "..."` |
| Push | `dotfiles push` |
| Log | `dotfiles log --oneline -10` |
| Branch | `dotfiles branch -a` |
