---
name: update-dotfiles
author: Vvkmnn
description: Use when user says "update dotfiles", "commit dotfiles", "sync dotfiles", "push dotfiles", or asks to save/backup their config. Manages bare git repo at ~/.dotfiles with logical commits, security checks, and config discovery.
version: 0.4.0
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
| Claude Code | `claude` | `.claude/CLAUDE.md`, `PAST.md`, `FUTURE.md`, `settings.json`, `statusline.sh`, `rules/*`, `hooks/*`, `skills/*`, `mcp/MCP.md`, `mcp/config.json` (encrypted), `mcp/mcp.json.bak` (encrypted), `.claudeignore`, `.gitignore` |
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
| `.claude/mcp/mcp.json.bak` | MCP tokens backup | OK — git-crypt encrypted |
| `.claude/mcp/config.json` | mcp-proxy tokens | OK — git-crypt encrypted |
| `.claude/settings.json` | May reference API config | Inspect before staging |
| `.docker/config.json` | Docker Hub auth tokens | NEVER stage (untracked) |
| `.npmrc` | npm auth token | NEVER stage (untracked) |
| `.config/ngrok/ngrok.yml` | ngrok auth token | NEVER stage (untracked) |
| `.ssh/config` | Machine-specific paths | Don't track (Colima refs to /Volumes) |

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
- `~/Library/LaunchAgents/` — check but do NOT track auto-generated plists (machine-specific paths confuse fresh installs)
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

This is the "you help me remember" loop — paired with `dotfiles-setup` (discover/set up).

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
  - `.utcp_config.json` — code-mode MCP servers with tokens
  - `.claude.json` — Claude Code config (may have native mcpServers)
  - `.claude/mcp/mcp.json.bak` — portable MCP backup (all servers)
  - `.claude/mcp/config.json` — mcp-proxy config with API tokens
- New machine: `git-crypt unlock ~/dotfiles.key`
- Verify: `dotfiles show HEAD:.utcp_config.json | head -1` → `GITCRYPT` header

### MCP Backup (`mcp.json.bak`)

**Source of truth** for all MCP server definitions in Claude's native `mcpServers` format.

**On every dotfiles update**, capture and merge servers from:
1. `~/.utcp_config.json` (code-mode UTCP — primary, always used)
2. `.claude.json` `mcpServers` section (native MCPs — rare, backup if configured)

```bash
# Merge UTCP servers into backup (existing entries take precedence for real tokens)
jq -s '
  .[0].mcpServers as $existing |
  [.[1].manual_call_templates[] |
    .config.mcpServers | to_entries[] |
    {key: .key, value: (
      if .value.transport == "http" then
        {type: "url", url: .value.url} +
        (if .value.headers then {headers: .value.headers} else {} end)
      else
        {type: "stdio", command: .value.command, args: .value.args} +
        (if .value.env then {env: .value.env} else {} end)
      end
    )}
  ] | from_entries as $utcp |
  {mcpServers: ($utcp + $existing)}
' ~/.claude/mcp/mcp.json.bak ~/.utcp_config.json > /tmp/merged-mcp.json \
  && mv /tmp/merged-mcp.json ~/.claude/mcp/mcp.json.bak
```

**On new machine**, decrypt and register servers in `~/.utcp_config.json` for code-mode.

See `~/.claude/mcp/MCP.md` for full server inventory (36 servers).

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
