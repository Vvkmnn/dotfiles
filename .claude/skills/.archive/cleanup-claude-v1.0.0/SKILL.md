---
name: cleanup-claude
author: Vvkmnn
description: Use when confused about ~/.claude contents, to understand what files/folders are for, or to safely clean up accumulated artifacts. Explains before deleting.
version: 1.0.0
---

# Cleanup Claude - Understand & Clean ~/.claude

## Purpose

When ~/.claude feels cluttered or confusing, this skill:
1. Explains what each directory/file is for
2. Identifies what's auto-generated vs manually created
3. Shows what's safe to delete vs essential config
4. Cleans up carefully with explanations
5. Never deletes without explaining first

## Directory Reference

| Directory | Purpose | Auto-generated? | Safe to delete? |
|-----------|---------|-----------------|-----------------|
| `backups/` | Weekly .claude.json backups | Yes (via c/cl/cc) | Keep recent 3 |
| `debug/` | Session debug logs | Yes, per session | Yes - regenerates |
| `shell-snapshots/` | Shell state for crash recovery | Yes, per session | Yes - regenerates |
| `paste-cache/` | Clipboard paste history | Yes | Yes - just cache |
| `file-history/` | File change history | Yes | Yes, but useful for recovery |
| `session-env/` | Per-session environment | Yes | Yes - old sessions stale |
| `telemetry/` | Failed event logs | Yes | Yes - no value |
| `projects/` | File path index per project | Yes | Yes - rebuilds on use |
| `todos/` | Todo snapshots | Yes | Yes - old ones stale |
| `plans/` | Plan mode archives | Yes | Maybe - contains work history |
| `plugins/` | Plugin cache & registry | Yes | Prune cache/, keep registry |
| `status/` | Rate limits, activity tracking | Yes | Keep current, prune _old |
| `sessions/` | Temp session files | Yes | Yes |
| `rules/` | Your instruction rules | No - manual | Keep |
| `skills/` | Your skills | No - manual | Keep |
| `commands/` | Your commands | No - manual | Keep |
| `hooks/` | Your hooks | No - manual | Keep |
| `legacy/` | Archived old config | No - manual | Archive reference |
| `archive/` | Archived old content | No - manual | Reference only |

## File Reference

| File | Purpose | Safe to delete? |
|------|---------|-----------------|
| `.claude.json` | Main config (MCPs, credentials) | NO - essential |
| `settings.json` | Tool permissions, hooks, prefs | NO - essential |
| `settings.local.json` | Local overrides | NO - essential |
| `CLAUDE.md` | Your global instructions | NO - essential |
| `FUTURE.md` | Your notes (if exists) | NO - yours |
| `PAST.md` | Your notes (if exists) | NO - yours |
| `.claudeignore` | Context exclusions | NO - useful config |
| `history.jsonl` | Conversation history | Grows - can truncate old |
| `*.backup` | Old backups | Yes if proper backup exists |
| `security_warnings_state_*.json` | Per-session warning state | Yes - orphaned after session |
| `.DS_Store` | macOS metadata | Yes |
| `*.log` | Old logs | Yes |
| `*.bak*` | Old backup files | Yes if superseded |

## Cleanup Protocol

### Phase 1: Understand Current State

```bash
# Size overview
du -sh ~/.claude/
du -sh ~/.claude/*/ 2>/dev/null | sort -hr | head -10

# What's taking space?
echo "=== Largest directories ==="
du -sh ~/.claude/debug ~/.claude/shell-snapshots ~/.claude/projects ~/.claude/file-history 2>/dev/null
```

### Phase 2: Identify Candidates

**Always safe to delete (auto-regenerates):**
```bash
# Check sizes before deciding
du -sh ~/.claude/debug/
du -sh ~/.claude/shell-snapshots/
du -sh ~/.claude/paste-cache/
ls ~/.claude/telemetry/1p_failed_events_*.json 2>/dev/null | wc -l
```

**Check dates - old = stale:**
```bash
# Debug logs - newest and oldest
ls -lt ~/.claude/debug/ | head -3
ls -lt ~/.claude/debug/ | tail -3

# Shell snapshots - newest and oldest
ls -lt ~/.claude/shell-snapshots/ | head -3
ls -lt ~/.claude/shell-snapshots/ | tail -3
```

**Orphaned session files:**
```bash
ls ~/.claude/security_warnings_state_*.json 2>/dev/null
```

**Redundant backups:**
```bash
ls -la ~/.claude/*.backup ~/.claude/*.bak* ~/.claude/hooks/*.bak* 2>/dev/null
```

### Phase 3: Explain Before Deleting

For each candidate, explain:
1. **What it is** - purpose of the file/directory
2. **Why it's safe** - auto-generated, superseded, or orphaned
3. **What happens if deleted** - regenerates, or gone forever
4. **Ask permission** - never delete without confirmation

### Phase 4: Clean (with confirmation)

**Tier 1 - Auto-generated cache (safe, big savings):**
```bash
rm -rf ~/.claude/debug/
rm -rf ~/.claude/shell-snapshots/
rm -rf ~/.claude/paste-cache/
rm -f ~/.claude/telemetry/1p_failed_events_*.json
```

**Tier 2 - Orphaned/redundant:**
```bash
rm -f ~/.claude/security_warnings_state_*.json
rm -f ~/.claude/*.backup
rm -f ~/.claude/*.bak*
rm -f ~/.claude/hooks/*.bak*
rm -f ~/.claude/*.log
rm -f ~/.claude/.DS_Store
```

**Tier 3 - Old content (archive or delete):**
```bash
# Move to archive instead of deleting
mkdir -p ~/.claude/archive/$(date +%Y-%m)
mv ~/.claude/OLD_FILE ~/.claude/archive/$(date +%Y-%m)/
```

### Phase 5: Verify

```bash
# New size
du -sh ~/.claude/

# Essential config intact
ls ~/.claude/CLAUDE.md ~/.claude/settings.json ~/.claude/.claude.json

# Backups working
ls ~/.claude/backups/
```

## Auto-Backup System

The `_claude_config_backup()` function in `~/.functions` automatically:
- Backs up `.claude.json` weekly when using `c()`, `cl()`, or `cc()`
- Keeps 3 rotating backups in `~/.claude/backups/`
- Runs silently in background, no overhead

```bash
# Check backup status
ls -la ~/.claude/backups/
cat ~/.claude/backups/.last-backup  # Unix timestamp of last backup
```

## What NOT to Delete

| Item | Why |
|------|-----|
| `.claude.json` | MCP configs, API settings - breaks Claude |
| `settings.json` | Permissions, hooks - loses all config |
| `CLAUDE.md` | Your instructions - loses customization |
| `rules/` | Your rules - loses guidance |
| `skills/` | Your skills - loses capabilities |
| `hooks/` (active .js) | Your hooks - loses automation |
| `commands/` | Your commands - loses shortcuts |
| `backups/` (recent) | Recovery option - keep last 3 |

## Recovery

| Problem | Solution |
|---------|----------|
| Deleted essential config | Restore from `~/.claude/backups/` |
| No backup exists | Check Time Machine or git if dotfiles tracked |
| Broke settings.json | `claude doctor` to validate, fix manually |
| Lost custom rules | Check `~/.claude/legacy/` or `~/.claude/archive/` |

## Quick Commands

```bash
# See what's using space
du -sh ~/.claude/*/ 2>/dev/null | sort -hr

# Safe quick cleanup (cache only)
rm -rf ~/.claude/{debug,shell-snapshots,paste-cache}

# Check backup health
ls -la ~/.claude/backups/

# Orphan hunt
ls ~/.claude/security_warnings_state_*.json ~/.claude/*.backup ~/.claude/*.bak* 2>/dev/null
```
