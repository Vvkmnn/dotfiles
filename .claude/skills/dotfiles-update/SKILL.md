---
name: dotfiles-update
description: Use when user says "update dotfiles", "commit dotfiles", "sync dotfiles", "push dotfiles", or asks to save/backup their config. Manages bare git repo at ~/.dotfiles with logical commits, security checks, and config discovery.
version: 0.2.0
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

### What's Tracked (~1100 files)

| Category | Scope | Key Files |
|----------|-------|-----------|
| Shell | `shell` | `.alias`, `.functions`, `.profile`, `.rc`, `.shell`, `.bashrc`, `.zshrc`, `.zshenv`, `.zimrc`, `.p10k.zsh`, `.fishrc` |
| Claude Code | `claude` | `.claude/CLAUDE.md`, `PAST.md`, `FUTURE.md`, `settings.json`, `keybindings.json`, `statusline.sh`, `rules/*`, `commands/*`, `hooks/*`, `plugins/*` |
| Karabiner | `karabiner` | `.config/karabiner/karabiner.json`, `KARABINER.md`, `scripts/*`, `automatic_backups/*` |
| Sketchybar | `sketchybar` | `.config/sketchybar/sketchybarrc`, `plugins/*` |
| WM | `wm` | `.skhdrc`, `.yabairc`, `.config/yabai/*` |
| Terminal | `terminal` | `.config/ghostty/*`, `.config/tmux/*`, `.config/kitty/*`, `.config/alacritty/*`, `.config/wezterm/*` |
| Editor | `editor` | `.vimrc`, `.config/nvim` (submodule), `Library/Application Support/Code/*` |
| Git | `git` | `.gitconfig`, `.gitmessage`, `.gitignore`, `.gitattributes`, `.globalgitignore`, `.gitmodules` |
| Alfred | `alfred` | `.alfred/*` (~400 files: prefs, workflows, themes) |
| Setup | `setup` | `.setup/*` (brew.sh, fonts.sh, macos.sh, Brewfile, etc.) |
| Docker | `docker` | `.docker/*` |
| Fish | `fish` | `.config/fish/*`, `.config/fisher/*`, `.config/omf/*` |
| Meta | `dotfiles` | `.github/README.md`, `.logo`, `.theme`, `.assets/*`, `.utcp_config.json` |

## Workflow

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
| `.claude/settings.json` | May reference API config | Inspect before staging |
| `.docker/config.json` | May contain registry auth | Inspect before staging |

**Verify git-crypt:** `dotfiles show HEAD:.utcp_config.json | head -1` → should show `GITCRYPT`

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

**Ask:** "Found N untracked config files in [dirs]. Want to review them for tracking?"

### Phase 6: Report

```bash
dotfiles log --oneline -5
dotfiles status
```

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
- Encrypted: `.utcp_config.json`
- New machine: `git-crypt unlock ~/dotfiles.key`
- Verify: `dotfiles show HEAD:.utcp_config.json` → `GITCRYPT` header

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
