# Cleanup Phase — Directory & File Reference

Extracted from cleanup-claude v1.0.0 (archived). Every deletion needs per-path user approval.

## Directory Reference

| Directory | Purpose | Auto-generated? | Safe to delete? |
|-----------|---------|-----------------|-----------------|
| backups/ | .claude.json backups | Yes | Keep recent 3 |
| debug/ | Session debug logs | Yes | Yes — regenerates |
| shell-snapshots/ | Shell state for crash recovery | Yes | Yes — regenerates |
| paste-cache/ | Clipboard paste history | Yes | Yes |
| file-history/ | Native checkpoint store (powers /rewind) | Yes | Prune old only — recovery value |
| session-env/ | Per-session environment | Yes | Old ones stale |
| telemetry/ | Failed event logs | Yes | Yes |
| projects/ | Session transcripts + native memory dirs | Yes | Prune old transcripts; KEEP memory/ subdirs |
| todos/ / tasks/ | Task state | Yes | Old ones stale |
| plans/ | Plan files | Semi | Keep pending; archive done |
| plugins/ | Marketplace + plugin cache (can reach 500MB+) | Yes | cache/ flushable (refresh phase); keep registry files |
| status/ | Rate limits, activity | Yes | Keep current |
| image-cache/ | Pasted images | Yes | Old ones |
| rules/ skills/ commands/ hooks/ agents/ | YOUR config | No | KEEP |
| legacy/ archive/ skills/.archive/ | Archived reference | No | Keep (that's the point) |
| mcp/ | Proxy config + inventory | No | KEEP (rotate logs only) |

## File Reference

| File | Purpose | Safe to delete? |
|------|---------|-----------------|
| .claude.json | MCP endpoints + session state + oauth | NO |
| settings.json / settings.local.json | Config | NO |
| CLAUDE.md / README.md / docs/CHANGELOG.md / docs/CONFIG.md | Yours | NO |
| history.jsonl | Prompt history | Truncate old if huge |
| .last-maintenance / .last-update-result.json | Maintenance state | NO (current mechanism) |
| security_warnings_state_*.json | Per-session one-shots | Yes — orphaned |
| daily_budget.json / stats-cache.json | Caches | Regenerate |
| *.backup, *.bak*, *.log (stale), .DS_Store | Debris | Yes |
| mcp/proxy-error.log | Access log (misrouted stderr) | Truncate; rotation configured separately |

## Recovery

| Problem | Solution |
|---------|----------|
| Deleted essential config | ~/.claude/backups/ or dotfiles git (`git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout -- <path>`) |
| Broke settings.json | `claude doctor`, fix manually |
| Lost a skill | skills/.archive/ or dotfiles git history |
| Lost file edits | /rewind (native, backed by file-history/) |
