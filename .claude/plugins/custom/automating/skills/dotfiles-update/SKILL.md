---
name: dotfiles-update
description: Use when user says "update dotfiles", "commit dotfiles", "sync dotfiles", "push dotfiles", or asks to save/backup their config. Manages bare git repo at ~/.dotfiles with proper commit format and security checks.
version: 0.1.0
---

# Dotfiles Update

## Repository Setup

**Type:** Bare git repo
**Location:** `~/.dotfiles/` (git-dir) with work tree `~/`
**Branch:** `v-macos-macbook`
**Command:** `dotfiles` alias or `/usr/bin/git --git-dir=/Users/v/.dotfiles/ --work-tree=/Users/v`

## Workflow

### Step 1: Check Status
```bash
dotfiles status
```

**Expected states:**
- Clean: "nothing to commit" → Report clean, ask if user wants to push
- Changes: List of modified/added/deleted files → Continue to Step 2
- nvim submodule shows `(modified content)` or `(new commits)`: Check if needs updating (see Step 1.5)

### Step 1.5: Check nvim Submodule Status

If `.config/nvim` shows modified:
```bash
cd ~/.config/nvim && git status --short
```

**Expected:**
- `.claude/settings.local.json` modified: Local-only changes, safe to ignore
- Other files modified: User has uncommitted nvim config changes
- Clean but shows in dotfiles status: Submodule pointer needs updating

**Actions:**
- If clean → Update submodule pointer (continue to Step 2)
- If dirty → Ask user: "nvim has uncommitted changes. Commit them first?"
  - If yes → Help commit to nvim repo, then update pointer
  - If no → Skip nvim submodule for now

### Step 2: Categorize Changes

Group changed files into categories:

| Category | Files |
|----------|-------|
| Claude Code | `.claude/*` (rules, settings, commands, hooks) |
| Setup | `.setup/*` (brew.sh, fonts.sh, macos.sh, Brewfile) |
| Shell | `.alias`, `.functions`, `.profile`, `.rc`, `.shell`, `.bashrc`, `.zshrc`, `.zshenv`, `.zimrc`, `.p10k.zsh` |
| Configs | `.config/*` (ghostty, tmux, sketchybar, karabiner, fish, kitty, alacritty, wezterm, lazygit) |
| WM | `.skhdrc`, `.yabairc`, `.config/yabai/*` |
| Editor | `.vimrc`, VSCode/Windsurf in `Library/Application Support/` |
| Git | `.gitconfig`, `.gitmessage`, `.gitignore`, `.gitattributes` |
| Alfred | `.alfred/*` |

### Step 3: Security Check

Before staging, verify:
1. `.npmrc` is NOT in changed files (contains npm auth token)
2. No files matching `*token*`, `*secret*`, `*credential*`, `*password*`
3. `.utcp_config.json` changes are fine (encrypted via git-crypt)

If security issue found → STOP and alert user.

### Step 4: Stage Changes
```bash
dotfiles add -u  # Stage all tracked file changes
```

For new files user wants to track:
```bash
dotfiles add <specific-file>
```

### Step 5: Generate Commit Message

**Format:**
```
TYPE(dotfiles): Short description

Category1:
- Specific change
- Another change

Category2:
- More changes
```

**Types:**
- `FEAT`: New config/feature added
- `CHORE`: Maintenance, cleanup, sync
- `FIX`: Bug fix or correction
- `QUICKSAVE`: Fast save without detailed message

**Example:**
```
CHORE(dotfiles): Sync config updates

Claude Code:
- Update rules/test.md with testing guidelines
- Update settings.json

Configs:
- Update Karabiner keybindings
- Update Sketchybar plugins
```

### Step 6: Commit
```bash
dotfiles commit -m "$(cat <<'EOF'
TYPE(dotfiles): Description

Category:
- Changes
EOF
)"
```

### Step 7: Report Status
```bash
dotfiles log -1 --oneline  # Show commit
dotfiles status            # Confirm clean
```

Inform user: "Committed as [hash]. Ready to push with `dotfiles push`"

## Special Cases

### Updating Brewfile
If user asks to update packages:
```bash
brew bundle dump --file=~/.setup/Resources/Brewfile --force
dotfiles add .setup/Resources/Brewfile
```

### nvim Submodule Management

**Understanding the setup:**
- `.config/nvim` is a git submodule pointing to `https://github.com/Vvkmnn/v.nvim.git`
- Often shows modified due to `.claude/settings.local.json` (local-only file)
- Actual config changes need to be committed to the nvim repo separately

**Workflow for updating nvim:**

1. **Check what's modified:**
   ```bash
   cd ~/.config/nvim && git status
   ```

2. **If only `.claude/settings.local.json`:**
   - This is local-only, ignore it
   - No need to update submodule pointer

3. **If other files changed:**
   ```bash
   # Inside ~/.config/nvim
   git add <changed-files>
   git commit -m "FEAT(nvim): Description of changes"
   git push origin main  # or appropriate branch
   ```

4. **Update dotfiles submodule pointer:**
   ```bash
   # Back in home directory
   dotfiles add .config/nvim
   # This records the new commit hash in dotfiles
   ```

5. **Include in dotfiles commit:**
   ```
   CHORE(dotfiles): Update nvim submodule

   Editor:
   - Update nvim submodule to latest (commit: abc1234)
   ```

**Quick command sequence:**
```bash
# 1. Commit nvim changes
cd ~/.config/nvim && git add . && git commit -m "..." && git push

# 2. Update pointer in dotfiles
cd ~ && dotfiles add .config/nvim

# 3. Include in next dotfiles commit
```

### Karabiner
- Has its own `.git` directory (separate version control)
- Changes to `.config/karabiner/karabiner.json` are tracked by dotfiles
- The separate .git is intentional, don't remove

### Git-Crypt
- Key location: `/Users/v/Documents/key`
- Encrypted file: `.utcp_config.json`
- Verify encryption: `dotfiles show HEAD:.utcp_config.json` should show `GITCRYPT` header

## Quick Reference

| Action | Command |
|--------|---------|
| Status | `dotfiles status` |
| Stage all | `dotfiles add -u` |
| Stage specific | `dotfiles add <file>` |
| Commit | `dotfiles commit -m "..."` |
| Push | `dotfiles push` |
| Log | `dotfiles log --oneline -5` |
| Diff | `dotfiles diff` |
