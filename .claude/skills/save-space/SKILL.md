---
name: save-space
description: Systematic disk space cleanup - recover 10-50GB by targeting highest-impact items first
---

# Disk Space Recovery

Use this skill when disk usage exceeds 70% or you need to free up significant space quickly.

## How to Run This Skill

1. **Blitz** - Run blitz mode first for instant 3-8GB (zero risk, no decisions)
2. **Assess** - Run assessment commands in parallel (they're independent)
3. **Propose** - Present a ranked table of targets >500MB with sizes and risk levels
4. **Confirm** - Get user approval before deletions (especially sudo)
5. **Execute** - Delete in tiers, starting with biggest wins
6. **Track** - After each batch, run `df -h /System/Volumes/Data` and report delta from starting point
7. **Verify** - Final `df` and `diskutil apfs list` check

**Focus on targets >500MB.** Items under 500MB are rarely worth the effort unless doing a final sweep after all big targets are exhausted.

**sudo commands**: Claude cannot run sudo. Provide the exact commands and tell the user to run them in their terminal.

---

## Blitz Mode (3-8GB, zero risk)

Check sizes first, then delete. All auto-rebuild on next use:

```bash
# Check sizes before deleting
echo "=== Blitz Mode Targets ==="
du -sh ~/.cache/uv ~/.npm/_npx ~/.cache/puppeteer ~/.cache/prisma 2>/dev/null
du -sh ~/.cache/chrome-devtools-mcp 2>/dev/null
du -sh ~/.bun/install 2>/dev/null
du -sh ~/Library/Application\ Support/Slack/Service\ Worker 2>/dev/null
du -sh ~/Library/Application\ Support/Code/CachedData 2>/dev/null
du -sh ~/Library/Application\ Support/Code/CachedExtensionVSIXs 2>/dev/null
du -sh ~/Library/Application\ Support/discord/logs 2>/dev/null
du -sh ~/Library/Application\ Support/Google/GoogleUpdater/crx_cache 2>/dev/null
du -sh ~/Library/Caches/Google ~/Library/Caches/Homebrew 2>/dev/null
du -sh ~/Library/Caches/Steam ~/Library/Caches/node-gyp 2>/dev/null
du -sh ~/Library/Application\ Support/Steam/appcache 2>/dev/null
```

Then delete:

```bash
# Package manager caches
rm -rf ~/.cache/uv ~/.npm/_npx ~/.cache/puppeteer ~/.cache/prisma
rm -rf ~/.cache/chrome-devtools-mcp ~/.cache/pip
rm -rf ~/.bun/install && mkdir -p ~/.bun/install
brew cleanup -s
npx pnpm store prune 2>/dev/null

# Electron app caches (rebuild on app open)
rm -rf ~/Library/Application\ Support/Slack/Service\ Worker
rm -rf ~/Library/Application\ Support/Code/CachedData
rm -rf ~/Library/Application\ Support/Code/CachedExtensionVSIXs
rm -rf ~/Library/Application\ Support/discord/logs

# Google caches
rm -rf ~/Library/Application\ Support/Google/GoogleUpdater/crx_cache
rm -rf ~/Library/Caches/Google ~/Library/Caches/Homebrew
rm -rf ~/Library/Caches/Steam ~/Library/Caches/node-gyp

# Old Claude Code versions (keep latest)
cd ~/.local/share/claude/versions 2>/dev/null && ls -1 | grep -v "$(ls -t | head -1)" | xargs rm -f; cd -

# Steam cache
rm -rf ~/Library/Application\ Support/Steam/appcache/*

# Check delta
df -h /System/Volumes/Data
```

---

## Assessment

Run these in parallel to find where space is going:

```bash
# Disk state (two views)
df -h /System/Volumes/Data
diskutil apfs list | grep "Capacity In Use By Volumes" | head -1

# Home directory breakdown
du -sh ~/* 2>/dev/null | sort -hr | head -15

# Hidden folders (dev tools, caches)
du -sh ~/.[^.]* 2>/dev/null | sort -hr | head -15

# Library subdirectories
for d in ~/Library/*/; do du -sh "$d" 2>/dev/null; done | sort -hr | head -15

# Applications by size
du -sh /Applications/* 2>/dev/null | sort -hr | head -15

# Time Machine snapshots
tmutil listlocalsnapshots /

# Large files (>500MB)
find ~ -type f -size +500M 2>/dev/null -exec du -sh {} \; | sort -hr | head -15

# Downloads and Trash
du -sh ~/Downloads ~/Temp ~/.Trash 2>/dev/null

# iOS device backups
du -sh ~/Library/Application\ Support/MobileSync/Backup 2>/dev/null

# Mail
du -sh ~/Library/Mail 2>/dev/null

# Application Support deep dive
for d in ~/Library/Application\ Support/*/; do du -sh "$d" 2>/dev/null; done | sort -hr | head -15
```

After assessment, present findings as a ranked table (only items >500MB):

| Target | Size | Risk | Action |
|--------|------|------|--------|
| Time Machine snapshots | 15GB | None | sudo tmutil deletelocalsnapshots |
| ~/Downloads old files | 8GB | Low | Review and delete |
| Xcode.app | 4.7GB | None | sudo rm + switch to CLT |
| ... | ... | ... | ... |

---

## Tier 1: Big Wins (5-20GB each)

### Time Machine Local Snapshots (5-20GB)

Often the single biggest win. Each snapshot can be 5-15GB.

```bash
# List all snapshots
tmutil listlocalsnapshots /

# Delete old ones (keep most recent) - USER MUST RUN THESE
# sudo tmutil deletelocalsnapshots <date>
# Repeat for each old snapshot date
```

### Xcode vs Command Line Tools (4-7GB)

Full Xcode is unnecessary if not doing iOS/macOS GUI development. CLT provides git, clang, make - everything Homebrew and dev workflows need.

```bash
# Check if Xcode is installed
du -sh /Applications/Xcode.app 2>/dev/null

# Remove Xcode, keep CLT - USER MUST RUN THESE:
# sudo rm -rf /Applications/Xcode.app
# rm -rf ~/Library/Developer/Xcode
# rm -rf ~/Library/Developer/CoreSimulator
# rm -rf ~/Library/Developer/XCTestDevices
# rm -rf ~/Library/Caches/com.apple.dt.Xcode
# sudo xcode-select -s /Library/Developer/CommandLineTools

# Verify CLT works after removal:
# xcode-select -p    # Should show /Library/Developer/CommandLineTools
# git --version      # Should work
# clang --version    # Should work
```

Reinstall from App Store if ever needed.

**Even if Xcode is already removed**, leftover developer data may remain:
```bash
# DerivedData - build artifacts, safe to delete (Xcode rebuilds as needed)
du -sh ~/Library/Developer/Xcode/DerivedData 2>/dev/null
rm -rf ~/Library/Developer/Xcode/DerivedData

# Archives - old app builds (safe if already submitted/not needed)
du -sh ~/Library/Developer/Xcode/Archives 2>/dev/null
rm -rf ~/Library/Developer/Xcode/Archives

# iOS DeviceSupport - debug symbols (~4GB per iOS version)
du -sh ~/Library/Developer/Xcode/iOS\ DeviceSupport 2>/dev/null
# rm -rf ~/Library/Developer/Xcode/iOS\ DeviceSupport

# Old simulators
xcrun simctl delete unavailable 2>/dev/null

# Simulator and Xcode logs
rm -rf ~/Library/Logs/CoreSimulator
rm -rf ~/Library/Caches/com.apple.dt.Xcode
```

### Build Artifacts (5-40GB if active)

```bash
# Rust projects - target/ directories
find ~/Projects ~/Dev -name "Cargo.toml" -type f 2>/dev/null | while read f; do
    dir=$(dirname "$f")
    if [ -d "$dir/target" ]; then
        echo "$(du -sh "$dir/target" 2>/dev/null | cut -f1) - $dir"
    fi
done

# Node projects - node_modules (only delete if project is inactive)
find ~/Projects ~/Dev -name "node_modules" -type d -maxdepth 3 2>/dev/null | while read dir; do
    echo "$(du -sh "$dir" 2>/dev/null | cut -f1) - $dir"
done

# Go caches
du -sh ~/go/pkg/mod 2>/dev/null
go clean -cache -n 2>/dev/null | wc -l  # Build cache (show count)
# go clean -cache      # Clears build cache (rebuilds on next compile)
# go clean -modcache   # Clears module cache (re-downloads on next build)

# Rust/Cargo global cache
du -sh ~/.cargo/registry ~/.cargo/git 2>/dev/null
# cargo cache --autoclean  # If cargo-cache installed
# Or manually: rm -rf ~/.cargo/registry/cache ~/.cargo/registry/src

# Python virtual environments in inactive projects
find ~/Projects ~/Dev -name ".venv" -type d -maxdepth 3 2>/dev/null | while read dir; do
    echo "$(du -sh "$dir" 2>/dev/null | cut -f1) - $dir"
done
```

### Large Files + Downloads + Trash (2-10GB)

```bash
# Old installers and archives in Downloads (>30 days old)
find ~/Downloads -type f \( -name "*.dmg" -o -name "*.pkg" -o -name "*.zip" -o -name "*.tar.gz" -o -name "*.iso" \) -mtime +30 -exec du -sh {} \;

# Screen recordings
du -sh ~/Library/Group\ Containers/group.com.apple.screencapture/ScreenRecordings/ 2>/dev/null
ls -lhS ~/Temp/ 2>/dev/null | head -10

# Trash
du -sh ~/.Trash 2>/dev/null
rm -rf ~/.Trash/*
```

---

## Tier 2: Medium Wins (1-5GB each)

### Package Manager Caches (3-10GB)

Already covered in Blitz Mode. If skipped, these are the individual targets:

| Cache | Location | Typical Size |
|-------|----------|--------------|
| Python uv | `~/.cache/uv` | 2-10GB |
| npm npx | `~/.npm/_npx` | 1-5GB |
| pip | `~/.cache/pip` | 200MB-2GB |
| Bun | `~/.bun/install` | 100MB-1GB |
| pnpm store | `~/Library/pnpm` | 2-5GB (prune unreferenced) |
| Go modules | `~/go/pkg/mod` | 500MB-3GB |
| Go build cache | `go clean -cache` | 500MB-2GB |
| Cargo registry | `~/.cargo/registry` | 500MB-3GB |
| Rustup toolchains | `~/.rustup/toolchains` | 500MB-2GB (old versions) |
| Homebrew | `brew cleanup -s` | 200MB-1GB |
| Browser automation | `~/.cache/puppeteer`, `~/.cache/prisma` | 200MB-1GB |

### Chrome Variant Data (1-3GB)

Unused Chrome variants (Dev/Beta/Canary) accumulate profile data even when not actively used:

```bash
# Check which variants have data
du -sh ~/Library/Application\ Support/Google/Chrome\ Dev 2>/dev/null
du -sh ~/Library/Application\ Support/Google/Chrome\ Beta 2>/dev/null
du -sh ~/Library/Application\ Support/Google/Chrome\ Canary 2>/dev/null

# Google Updater cache (often 1GB+, always safe)
rm -rf ~/Library/Application\ Support/Google/GoogleUpdater/crx_cache

# Remove data for unused variants
# rm -rf ~/Library/Application\ Support/Google/Chrome\ Dev
```

### Unused/Duplicate Applications (1-5GB)

```bash
du -sh /Applications/* 2>/dev/null | sort -hr | head -20
```

Common candidates:
- **Duplicate apps**: Same app from both App Store and direct download (e.g., CleanMyMac)
- **Archiver apps**: Multiple archive tools when one suffices
- **Screen recording**: Multiple overlapping tools
- **Browsers**: Multiple Chrome variants (~1.2GB each)
- **Abandoned editors**: Cursor, Zed, Windsurf if not actively used

### iOS Device Backups (1-50GB)

```bash
du -sh ~/Library/Application\ Support/MobileSync/Backup 2>/dev/null
# If using iCloud backup, local backups are redundant
# rm -rf ~/Library/Application\ Support/MobileSync/Backup/*
```

### Mail (5-20GB)

```bash
du -sh ~/Library/Mail 2>/dev/null
```

If large, open Mail.app and:
- Mailbox > Erase Deleted Items (All Accounts)
- Mailbox > Erase Junk Mail
- Consider archiving old mailboxes to external storage

### AI Model Files (500MB-2GB)

AI tools often download large model files:

```bash
# Check for AI/ML model caches
du -sh ~/Library/Application\ Support/superwhisper 2>/dev/null
du -sh ~/.ollama/models 2>/dev/null
du -sh ~/Library/Application\ Support/LM\ Studio 2>/dev/null
du -sh ~/.cache/huggingface 2>/dev/null
du -sh ~/.keras 2>/dev/null
```

Delete model files only for tools you no longer use.

### Photos Optimization

If Photos library is large, enable "Optimize Mac Storage" in:
System Settings > Apple ID > iCloud > Photos

This keeps only recent/viewed photos locally, others stay in iCloud. Can free 10-50GB depending on library size.

---

## Tier 3: Sweep (0.2-1.5GB each)

### Electron App Caches (0.5-1.5GB)

Already covered in Blitz Mode. These rebuild when the app opens:
- Slack Service Worker (~500MB)
- VS Code CachedData + CachedExtensionVSIXs (~400MB)
- Discord logs (~100MB)

### Abandoned Dev Tool Directories (0.2-1GB)

Use discovery, don't hardcode names:

```bash
# Find large hidden dirs in home
du -sh ~/.[^.]* 2>/dev/null | sort -hr | head -20

# Also check .local/share
du -sh ~/.local/share/*/ 2>/dev/null | sort -hr | head -10
```

Common candidates: `.opencode`, `.gemini`, `.codex`, `.windsurf`, `.cursor`, `.zed`, `.nvm.bak`, `.claude-mem`, `.chrome-debug-profile`, `.m2` (Maven), `.gradle`

Delete only after confirming the tool is no longer used.

### System/User Caches (0.5-2GB)

```bash
# User caches (safe)
rm -rf ~/Library/Caches/Homebrew
rm -rf ~/Library/Caches/Google
rm -rf ~/Library/Caches/Steam
rm -rf ~/Library/Caches/node-gyp
rm -rf ~/Library/Caches/colima

# CrashReporter logs (safe, just old crash dumps)
du -sh ~/Library/Logs/DiagnosticReports 2>/dev/null
rm -rf ~/Library/Logs/DiagnosticReports

# Log files
du -sh ~/Library/Logs 2>/dev/null
# rm -rf ~/Library/Logs/*
```

### Old Application Versions (0.5-1GB)

```bash
# Claude Code - keep only latest
cd ~/.local/share/claude/versions 2>/dev/null
ls -lt | head -2  # Check current version
ls -1 | grep -v "$(ls -t | head -1)" | xargs rm -f

# Neovim Mason - audit large LSP packages
du -sh ~/.local/share/nvim/mason/packages/* 2>/dev/null | sort -hr | head -10
# Common large ones: clangd (~350MB), ltex-ls (~300MB), codelldb (~135MB)
# Remove unused: rm -rf ~/.local/share/nvim/mason/packages/<name>
```

### Application Support Deep Dive

```bash
for d in ~/Library/Application\ Support/*/; do du -sh "$d" 2>/dev/null; done | sort -hr | head -15
```

Known safe to clean:
- `Google/GoogleUpdater/crx_cache` - 1GB+, always safe
- `Steam/appcache` - cache only

Leave alone:
- `com.apple.wallpaper` - macOS managed
- `CloudDocs` - iCloud sync
- `MobileSync` - covered in iOS backups section

### Docker on External Storage

If Docker runs via Colima with `COLIMA_HOME` on an external SSD, images are NOT on the main disk. `docker system prune` only frees external storage.

Check for stale old Colima instances on main SSD:

```bash
# Check for old instance
du -sh ~/.config/colima 2>/dev/null

# If migrated to external SSD, remove old one
# COLIMA_HOME=~/.config/colima colima stop 2>/dev/null
# COLIMA_HOME=~/.config/colima colima delete --force 2>/dev/null
# rm -rf ~/.config/colima ~/Library/Caches/colima
```

If Docker is on main SSD: `docker system prune -a -f` can free 2-10GB.

---

## System Level (Requires Manual Action)

### /private/var/folders (2-5GB)

**WARNING: Do NOT manually delete /private/var/folders.** This can render Macs unbootable.

Safe alternative: **Safe Mode boot** triggers macOS cleanup of these caches.
- Apple Silicon: Shut down > Hold power button > Select Safe Mode > Boot > Restart normally
- Clears caches older than 3 days and rebuilds system temp files safely

### CleanMyMac

Run after completing manual cleanup for system-level items that Claude can't access:
- System cache files
- Application logs
- Browser caches (system-level)
- iOS device backups
- Broken downloads
- Mail attachments and downloads

---

## Pitfalls

Common mistakes and gotchas from past cleanup sessions:

- **`pnpm` not in PATH**: Use `npx pnpm store prune` instead of `pnpm store prune`
- **Sparse files inflate sizes**: Colima/VM datadisks appear huge via `stat` or `ls -l` but actual disk usage is tiny. Always verify with `du -sh`
- **Docker on external SSD**: If `COLIMA_HOME` points to external storage, `docker system prune` frees space there, not on main SSD
- **`/private/var/folders`**: Never manually delete. Use Safe Mode boot instead - manual deletion can brick the Mac
- **APFS vs df discrepancy**: `diskutil apfs list` always shows higher % than `df` because it includes snapshots and purgeable space. Both numbers are correct for different purposes
- **sudo operations**: Claude cannot run sudo. Provide exact commands for the user to paste into their terminal
- **Small targets waste time**: Don't chase items under 500MB when multi-GB targets remain. Move to Tier 3 sweep only after Tier 1 and 2 are done
- **Time Machine creates new snapshots**: After deleting snapshots, TM may create new ones. Check again after a few hours if % seems unchanged
- **Purgeable space blocking installs**: If apps refuse to install despite "available" space, APFS purgeable space isn't being reclaimed. Force it: `dd if=/dev/zero of=~/bigfile.tmp bs=20m; rm ~/bigfile.tmp` - this fills the disk forcing APFS to purge, then removes the temp file
- **Rust 1.88+ auto GC**: Cargo 1.88+ has automatic garbage collection of old registry/cache entries. On older versions, use `cargo cache --autoclean` (install with `cargo install cargo-cache`)

---

## Reference

### APFS vs df

`df` and `diskutil apfs list` report different numbers:
- **`df`** shows actual consumed space - what you feel day-to-day
- **`diskutil apfs list`** includes APFS metadata, snapshots, and purgeable space
- APFS % is always higher than df %. Both are correct for different purposes

### Safety Rules

**Always safe to delete:**
- Package manager caches (`~/.cache/uv`, `~/.npm/_npx`, `~/.bun/install`, `~/.cache/pip`, `~/.cargo/registry/cache`)
- Build artifacts (`target/`, `build/`, `dist/`, `.venv` in inactive projects)
- Browser automation caches (Puppeteer, Playwright, chrome-devtools-mcp)
- Old application versions (keep latest only)
- Electron app caches (Slack Service Worker, VS Code CachedData)
- Google Updater crx_cache
- Old Time Machine snapshots (keep most recent)
- Trash contents
- Xcode DerivedData

**Requires consideration:**
- `node_modules/` - only if project is inactive
- Application support data - check if app is actively used
- Chrome variant data - only for unused variants
- Xcode.app - only if CLT is sufficient for workflow
- iOS backups - only if using iCloud backup
- AI model files - only for tools no longer used
- Neovim Mason packages - verify you don't use the LSP
- Mail - make sure old emails aren't needed

**Never delete:**
- Active project source code
- `~/.ssh/` - SSH keys
- `~/.aws/` - AWS credentials
- Active `COLIMA_HOME` directory (check `echo $COLIMA_HOME`)
- `~/.claude/` (except legacy backups)
- `/private/var/folders` manually (use Safe Mode boot)
- `/private/var/db`, `/private/var/vm` - system critical

### Expected Recovery

| Tier | Typical Range | Depends On |
|------|---------------|------------|
| Blitz Mode | 3-8GB | How long since last cleanup |
| Tier 1 (Big Wins) | 10-30GB | TM snapshots, Xcode, active projects |
| Tier 2 (Medium) | 3-15GB | Chrome variants, unused apps, iOS backups, Mail |
| Tier 3 (Sweep) | 1-5GB | Abandoned tools, caches |
| System Level | 2-10GB | /var/folders, CleanMyMac findings |
| **Total possible** | **15-50GB** | |

### Maintenance Schedule

**Monthly**: Blitz Mode (package caches, Electron caches, old versions)
**Quarterly**: Full audit including Tier 2 (apps, Chrome, iOS backups, Mail)
**As needed**: Time Machine snapshots, CleanMyMac, Safe Mode boot
**After major work**: Clean build artifacts when switching projects
