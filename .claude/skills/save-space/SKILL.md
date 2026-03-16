---
name: save-space
author: Vvkmnn
description: Systematic disk space cleanup - recover 10-50GB by targeting highest-impact items first
---

# Disk Space Recovery

Use this skill when disk usage exceeds 70% or you need to free up significant space quickly.

## How to Run This Skill

1. **Baseline** - Record starting `df` AND `diskutil apfs list` (both matter, see APFS section)
2. **Blitz** - Run blitz mode first for instant 3-8GB (zero risk, no decisions)
3. **Assess** - Run assessment commands in parallel (they're independent). Include project dirs (Work/Projects/Dev) for backups and build artifacts
4. **Propose** - Present a ranked table of targets >500MB with sizes and risk levels
5. **Confirm** - Get user approval before deletions (especially sudo)
6. **Execute** - Delete in tiers, starting with biggest wins
7. **Empty Trash** - Always check `du -sh ~/.Trash` and empty after deletions. Deleted files don't free space until Trash is emptied
8. **Track** - After each batch, run `df -h /System/Volumes/Data` and report delta. Note: `df` may NOT drop if a TM snapshot exists — this is expected, not a failure
9. **Snapshots** - Delete old TM snapshots LAST (after all other cleanup). **This is critical**: every file deleted while a snapshot exists becomes "purgeable" but NOT freed. The snapshot deletion is what releases ALL accumulated space at once. Provide sudo command for user. Warn: if `df` hasn't moved despite deleting GBs, this is why
10. **Verify** - Final `df` and `diskutil apfs list` check

**Focus on targets >500MB.** Items under 500MB are rarely worth the effort unless doing a final sweep after all big targets are exhausted.

**sudo commands**: Claude cannot run sudo. Provide the exact commands and tell the user to run them in their terminal.

**Shell gotcha**: `find` may be aliased to `fd` (from Homebrew). Use `command find` for POSIX find behavior. Paths with brackets (e.g., `[Gmail].mbox`) need quoting — avoid glob expansion with `du -sh path/*`, use `command find path -maxdepth 1 -type d | while read d; do du -sh "$d"; done` instead.

---

## Blitz Mode (3-8GB, zero risk)

Check sizes first, then delete. All auto-rebuild on next use:

```bash
# Check sizes before deleting
echo "=== Blitz Mode Targets ==="
du -sh ~/.cache/uv ~/.npm/_npx ~/.npm/_cacache ~/.cache/puppeteer ~/.cache/prisma 2>/dev/null
du -sh ~/.cache/chrome-devtools-mcp 2>/dev/null
du -sh ~/.bun/install ~/Library/pnpm ~/.claude/debug 2>/dev/null
du -sh ~/Library/Application\ Support/Slack/Service\ Worker 2>/dev/null
du -sh ~/Library/Application\ Support/Code/CachedData 2>/dev/null
du -sh ~/Library/Application\ Support/Code/CachedExtensionVSIXs 2>/dev/null
du -sh ~/Library/Application\ Support/discord/logs ~/Library/Application\ Support/discord/Cache ~/Library/Application\ Support/discord/Code\ Cache 2>/dev/null
du -sh ~/Library/Application\ Support/Google/GoogleUpdater/crx_cache 2>/dev/null
du -sh ~/Library/Caches/Google ~/Library/Caches/Homebrew 2>/dev/null
du -sh ~/Library/Caches/Steam ~/Library/Caches/node-gyp 2>/dev/null
du -sh ~/Library/Application\ Support/Steam/appcache 2>/dev/null
```

Then delete:

```bash
# Package manager caches
rm -rf ~/.cache/uv ~/.npm/_npx ~/.npm/_cacache ~/.cache/puppeteer ~/.cache/prisma
rm -rf ~/.cache/chrome-devtools-mcp ~/.cache/pip
rm -rf ~/.bun/install && mkdir -p ~/.bun/install
rm -rf ~/Library/pnpm  # Full nuke — pnpm store prune often has 0 effect
rm -rf ~/.claude/debug  # Debug logs, can grow to 800MB+
brew cleanup --prune=all && brew autoremove

# Electron app caches (rebuild on app open)
rm -rf ~/Library/Application\ Support/Slack/Service\ Worker
rm -rf ~/Library/Application\ Support/Code/CachedData
rm -rf ~/Library/Application\ Support/Code/CachedExtensionVSIXs
rm -rf ~/Library/Application\ Support/discord/logs ~/Library/Application\ Support/discord/Cache ~/Library/Application\ Support/discord/Code\ Cache

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
# Disk state (THREE views — all matter)
df -h /System/Volumes/Data
diskutil apfs list | grep -E "Capacity In Use|Capacity Not Allocated" | head -4
tmutil listlocalsnapshots /

# Home directory breakdown
du -sh ~/* 2>/dev/null | sort -hr | head -15

# Hidden folders (dev tools, caches)
du -sh ~/.[^.]* 2>/dev/null | sort -hr | head -15

# Library subdirectories
for d in ~/Library/*/; do du -sh "$d" 2>/dev/null; done | sort -hr | head -15

# Applications by size
du -sh /Applications/* 2>/dev/null | sort -hr | head -15

# Project directories — scan for backups and build artifacts
du -sh ~/Work/*/ ~/Projects/*/ ~/Dev/*/ 2>/dev/null | sort -hr | head -20

# Large files (>500MB)
command find ~ -type f -size +500M 2>/dev/null -exec du -sh {} \; | sort -hr | head -15

# Downloads and Trash (ALWAYS check Trash — files aren't freed until emptied)
du -sh ~/Downloads ~/Temp ~/.Trash 2>/dev/null

# iOS device backups
du -sh ~/Library/Application\ Support/MobileSync/Backup 2>/dev/null

# Mail (often 5-20GB but mostly not actionable — see Mail section)
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

### Time Machine Local Snapshots (5-30GB+)

**Often the single biggest win — and the most invisible.** Snapshots hold references to ALL deleted files since the snapshot was created. This means every other cleanup step (caches, backups, build artifacts) may not show up in `df` until old snapshots are deleted.

**Critical ordering**: Delete snapshots LAST, after all other cleanup. This ensures the snapshot references to deleted files are released. A snapshot created before cleanup holds references to everything you deleted — removing it releases all that space at once.

**APFS purgeable gotcha**: `df` may show minimal improvement after deletions because APFS marks freed-but-snapshot-referenced space as "purgeable" rather than "free." The space only truly frees when the referencing snapshot is deleted. This can make it look like cleanup didn't work when it actually did.

```bash
# List all snapshots
tmutil listlocalsnapshots /

# Check APFS container to see purgeable vs truly free
diskutil apfs list | grep -E "Capacity In Use|Capacity Not Allocated" | head -4

# Delete old ones (keep most recent) - USER MUST RUN THESE
# sudo tmutil deletelocalsnapshots <date>
# Repeat for each old snapshot date
```

**Preventing snapshot creep — the #1 recurring space problem:**

Local snapshots are TM's safety net between external backups. They only prune after a successful backup to the external drive. If the external drive isn't plugged in regularly, snapshots accumulate silently and can consume 10-30G+ within weeks. This has been the single largest cause of unexplained disk growth across multiple cleanup sessions.

**How it works in macOS Sequoia/Tahoe:** Snapshot creation frequency follows the backup frequency setting (changed from older macOS where snapshots were always hourly):
- Every Hour → ~168 snapshots/week (10-20G+)
- Every Day → ~7 snapshots/week (3-7G)
- Every Week → ~1 snapshot/week (1-2G)
- Manually → 0 snapshots

**Recommended: "Automatically Every Week" + plug in external drive weekly.** This creates only ~1 local snapshot between plug-ins. When the drive connects, TM backs up automatically and prunes the snapshot. Minimal disk cost, forget-proof, auto-prunes.

**The failure mode (has happened twice):** User sets Weekly but leaves the external drive unplugged for a month+. Snapshots accumulate, hold references to all deleted files as "purgeable" space, and `df` shows disk usage climbing even after cleaning caches. Fix: plug in the drive (triggers backup + prune), or delete snapshots manually with `sudo tmutil deletelocalsnapshots <date>`.

**Diagnosis checklist when disk space keeps climbing:**
1. `tmutil listlocalsnapshots /` — if stale snapshots exist, this is likely the cause
2. `tmutil destinationinfo` — check if TM destination is connected/reachable
3. `tmutil latestbackup` — when was the last successful backup? If weeks ago, snapshots are accumulating
4. Fix: plug in external drive and let backup complete, OR delete snapshots manually

**`tmutil disablelocal` is deprecated** — throws `Unrecognized verb` on modern macOS. The only way to stop automatic snapshots is System Settings > General > Time Machine > Options > Backup Frequency > Manually. macOS Tahoe only offers: Manually, Every Hour, Every Day, Every Week (no Monthly option).

**On-demand snapshots for risky installs (`quicksave`):** Before installing anything outside the App Store or running `npm install`/`pip install` on untrusted packages:
```bash
quicksave        # creates APFS snapshot (alias for sudo tmutil snapshot)
quicksave -l     # list existing snapshots
quicksave -d     # delete all snapshots to reclaim space
```
Creates a local APFS snapshot recoverable from Recovery Mode. Read-only after creation (malware running post-snapshot can't tamper with it). macOS auto-reclaims these as disk fills.

**Compromise recovery strategy:**
- Local snapshots are NOT reliable for compromise recovery (live on the same disk, can be tampered with by privileged malware)
- External TM backup is the trustworthy restore point — especially if the drive was unplugged during the compromise window
- For confirmed compromise: clean install via Recovery Mode + selective data restore from TM (not full TM restore, which would restore the malware too)
- `quicksave` before risky installs gives a pre-compromise restore point accessible from Recovery Mode

### Project Backups and Old Copies (5-50GB)

Scan project directories for old backups, copies, and exported artifacts. These are often the single largest user-created space hog and easy to miss:

```bash
# Scan all project directories for large items
du -sh ~/Work/*/ ~/Projects/*/ ~/Dev/*/ 2>/dev/null | sort -hr | head -20

# Look for backup/copy patterns
command find ~/Work ~/Projects ~/Dev -maxdepth 3 -type d \( -name "*.backup" -o -name "*.bak" -o -name "*-backup" -o -name "*-old" -o -name "*-copy" -o -name "dist" -o -name "build" \) 2>/dev/null | while read d; do du -sh "$d"; done | sort -hr | head -10
```

Common offenders: project `.backup` dirs with bundled ML models, exported `dist/` folders with compiled assets, old project copies made before major refactors. Ask before deleting — user may want to handle these manually.

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

# iOS DeviceSupport - debug symbols (~4GB per iOS version connected)
du -sh ~/Library/Developer/Xcode/iOS\ DeviceSupport 2>/dev/null
# rm -rf ~/Library/Developer/Xcode/iOS\ DeviceSupport

# Old simulators
xcrun simctl delete unavailable 2>/dev/null

# SwiftUI preview caches
xcrun simctl --set previews delete all 2>/dev/null

# Simulator and Xcode logs
rm -rf ~/Library/Logs/CoreSimulator
rm -rf ~/Library/Caches/com.apple.dt.Xcode
```

### iOS Simulator Runtimes (20-150GB — biggest potential dev hog)

Each simulator runtime is 2.5-15GB. Multiple Xcode upgrades accumulate old runtimes silently. This is the single most-reported surprise on developer forums.

```bash
# Check installed runtimes (each one is multi-GB)
du -sh /Library/Developer/CoreSimulator/Profiles/Runtimes/* 2>/dev/null
du -sh /Library/Developer/CoreSimulator/Images 2>/dev/null

# Check simulator devices
du -sh ~/Library/Developer/CoreSimulator/Devices 2>/dev/null

# Delete unavailable/old simulators
xcrun simctl delete unavailable

# Remove old runtimes via Xcode: Settings > Platforms > delete old versions
```

If zero results on runtimes, the machine is clean — this is a good sign, not a missed target.

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

### Mail (5-20GB) — Often Not Actionable

```bash
du -sh ~/Library/Mail 2>/dev/null
```

**Reality check**: Mail size is mostly your synced email (IMAP/Gmail "All Mail"). Erasing Deleted Items and Junk Mail rarely makes a significant dent because the bulk is in `[Gmail].mbox/All Mail.mbox` — your actual email archive synced from the server.

**What actually helps:**
- Mailbox > Erase Deleted Items (All Accounts) — minor, clears local deleted cache
- Mailbox > Erase Junk Mail — minor
- **Remove unused email accounts** from Mail.app — biggest win, stops syncing entirely
- **Delete old emails from Gmail server** (in browser) — reduces what syncs locally
- **Switch to browser-only email** — removes Mail storage entirely

**What doesn't help**: Deleting local Mail files — Mail.app re-downloads everything from the server on next sync. Don't waste time here unless removing an account entirely.

To investigate what's using space inside Mail:
```bash
# Use command find (not fd) due to bracket paths like [Gmail].mbox
command find ~/Library/Mail/V10 -maxdepth 3 -type d -name "*.mbox" | while read d; do du -sh "$d"; done | sort -hr | head -10
```

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
- Discord logs + Cache + Code Cache (~200-500MB)

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

# Check if a package auto-reinstalls (LazyVim extras / ensure_installed):
# grep -r "package_name" ~/.config/nvim/
# If listed in config, Mason will re-download it on next Neovim open.
# This makes deletion safe but temporary — remove from config too if unwanted.

# Check last-used timestamps to find stale packages:
# stat -f "%Sm - %N" ~/.local/share/nvim/mason/packages/*/bin/* 2>/dev/null | sort

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

- **TM snapshots are the #1 recurring space problem**: If disk keeps growing despite cleanup, check `tmutil listlocalsnapshots /` FIRST. The external TM drive must be plugged in regularly (matching the backup frequency) or snapshots accumulate indefinitely. This has caused 10-30G+ of unexplained growth across multiple sessions. Fix: plug in drive (auto-prunes after backup) or `quicksave -d` to delete all snapshots manually
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
- **Trash must be emptied**: Deleting files (even `rm -r` from Finder) may send to Trash instead of freeing space. Always check `du -sh ~/.Trash` and empty with `rm -r ~/.Trash/*` after bulk deletions
- **`find` aliased to `fd`**: On systems with `fd` installed, `find` may be aliased. Use `command find` for POSIX behavior. Bracket paths like `[Gmail].mbox` also break glob expansion — quote carefully
- **Multiple APFS containers**: Macs with external drives (especially TM SSDs) have multiple APFS containers. Menu bar disk widgets may show the wrong container's %. Always verify with `diskutil apfs list` and match the container to the physical disk
- **Mail cleanup is mostly cosmetic**: Synced IMAP/Gmail accounts re-download mail. "Erase Deleted Items" and "Erase Junk" only help if there's actually accumulated junk. The bulk of Mail storage is "All Mail" which can't be reduced without removing the account or server-side deletion
- **Mason packages auto-reinstall**: LazyVim's `ensure_installed` and extras configs re-download deleted Mason packages on next Neovim open. To permanently remove, also remove from `~/.config/nvim/` config
- **pnpm store prune is useless**: `npx pnpm store prune` often reports "Removed 0 packages" even with 3.4GB store. Use `rm -rf ~/Library/pnpm` instead — packages reinstall on demand
- **TM snapshot blocks ALL space recovery**: Deleting files while a snapshot exists doesn't free space — it becomes "purgeable" held by the snapshot. Delete the snapshot LAST after all other cleanup to release everything at once. This is the single most impactful step
- **iCloud resync after macOS updates**: CloudKit cache (4GB+), CloudDocs session (5-7GB), and FileProvider (3GB) can balloon after major updates. This is temporary (24-48h) — don't delete CloudDocs or FileProvider, they rebuild worse if nuked
- **App Store apps need sudo to delete**: `rm -rf /Applications/Pages.app` fails with permission denied. Use `sudo mas uninstall <app-id>` (install mas via `brew install mas`) or `sudo rm -rf`
- **Duplicate iWork apps after macOS updates**: macOS updates can install "Creator Studio" versions of Pages/Keynote alongside old ones. Check with `mas list | grep -iE "pages|keynote"` — the newer version has bundle ID `com.apple.Pages`, the old one has `com.apple.iWork.Pages`
- **macOS Install Data (3.5GB)**: Left over after macOS updates. Safe to delete with `sudo rm -rf "/System/Volumes/Data/macOS Install Data"` after successful update. "Locked Files" subfolder may need SIP disable. Alternative: wait — macOS cleans it up eventually
- **"Put hard disks to sleep" removed from UI**: In macOS Tahoe, this setting is gone from System Settings > Battery > Options. Use `sudo pmset -a disksleep 0` instead. Only affects spinning HDDs, no battery impact on SSDs
- **Disk full = macOS crashes**: macOS needs ~10-15% free for swap, iCloud sync, and system operations. Below that, expect freezes, app crashes, and kernel panics. If at >80%, treat cleanup as urgent
- **~/.claude/debug grows silently**: Debug log directory can accumulate thousands of files (800MB+). Safe to nuke entirely — `rm -rf ~/.claude/debug`
- **CloudKit cache balloons post-update**: `~/Library/Caches/CloudKit/com.apple.bird` can hit 4GB+ during iCloud resync after macOS updates. It's temporary — don't manually delete, it rebuilds and extends the sync. Let it settle over 24-48h
- **Enable "Optimize Mac Storage" for iCloud**: System Settings > Apple ID > iCloud > iCloud Drive > toggle on. Keeps only recent files locally, offloads rest to cloud. Essential on 256GB Macs

---

## Reference

### APFS vs df

`df` and `diskutil apfs list` report different numbers:
- **`df`** shows actual consumed space - what you feel day-to-day
- **`diskutil apfs list`** includes APFS metadata, snapshots, and purgeable space
- APFS % is always higher than df %. Both are correct for different purposes

**Multiple APFS containers**: Macs with external drives (Time Machine SSDs, etc.) have multiple APFS containers. Each reports its own capacity/usage. Menu bar disk widgets (iStatistica, Stats, etc.) may show the wrong container — a TM drive at 80% instead of the internal data volume at 66%. Always verify which container you're looking at:
```bash
# Show all containers with their physical disks
diskutil apfs list | grep -E "Container|Capacity|Physical Store"
# Match container to physical disk to know which is internal vs external
```

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
