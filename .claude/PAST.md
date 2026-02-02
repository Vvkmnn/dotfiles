# Configuration History & Archived Settings

## Model Settings

### 2025-12-26: Changed from `opusplan` to `default`

**Previous:** `"model": "opusplan"`
**Current:** `"model": "default"`

**Reason:** Token optimization
- opusplan forces Opus for all planning sessions
- With default mode set to "plan", every session was using Opus
- Result: 1.1B cache read tokens on Opus vs 671M on Sonnet
- Savings: ~40% reduction in per-token cost

**To switch back to Opus for planning:**
```json
"model": "opusplan"
```

**Other model options:**
- `"default"` - Use system default (currently Sonnet 4.5)
- `"sonnet"` - Always use Sonnet 4.5
- `"opus"` - Always use Opus 4.5
- `"haiku"` - Always use Haiku 4.5
- `"opusplan"` - Use Opus for plan mode, default for execute mode

## Plugin Settings

### 2025-12-26: Disabled claude-mem

**Changed:** `"claude-mem@thedotmack": false`

**Reason:** Massive token overhead
- Plugin size: 14MB
- Cache cost: ~42,000 tokens per session
- 78% of total plugin bloat
- Represents 42k of 54k total cache tokens

**What claude-mem does:**
- Semantic search across past Claude Code sessions
- Cross-session memory ("did we solve this before?")
- Stores observations in SQLite database

**Alternatives:**
- Built-in `~/.claude/stats-cache.json` for usage tracking
- Session transcripts in `~/.claude/projects/*/` for history
- claude-historian-mcp (lighter weight MCP server alternative)

**To re-enable when needed:**
```json
"claude-mem@thedotmack": true
```

Or via command:
```bash
# Enable temporarily
claude plugins enable claude-mem@thedotmack

# Disable again
claude plugins disable claude-mem@thedotmack
```

---

## Configuration Snapshots

### 2025-12-26: Pre-optimization baseline

Backup: `~/.claude/settings.json.backup-20251226`

**Stats:**
- 33 enabled plugins
- ~54k cache tokens per session
- Model: opusplan
- Daily Opus usage: 200-400k tokens

**Expected post-optimization:**
- 32 enabled plugins
- ~12k cache tokens per session
- Model: default (Sonnet)
- Daily Opus usage: 60-120k tokens (when manually switched to Opus)

**Savings: ~78% reduction in cache overhead, ~70% reduction in overall token usage**

---

## MCP Server Settings

### 2026-02-01: Migrated from code-mode to native MCP

**Previous:** All MCP servers proxied through code-mode UTCP (`@utcp/code-mode-mcp`)
**Current:** Native MCP servers in `~/.claude.json` (git-crypt encrypted)

**Reason:** Native MCP Tool Search provides better performance
- 85% token reduction with lazy loading (10K threshold)
- +8.6% accuracy improvement on Opus 4.5
- No reconnection bugs ([Issue #20684](https://github.com/anthropics/claude-code/issues/20684))
- Simpler architecture (one less MCP server layer)

**Lost features:**
- `call_tool_chain` - TypeScript tool chaining in single execution
- `register_manual` - Dynamic server registration without restart
- `search_tools` - Manual tool search (replaced by native tool search)

**Preserved:**
- `~/.utcp_config.json` kept as reference (git-crypt encrypted)
- Backup at `~/.claude/backups/.claude.json.20260201-pre-native-mcp`

**To rollback:**
```bash
cp ~/.claude/backups/.claude.json.20260201-pre-native-mcp ~/.claude.json
# Restart Claude Code
```

**Sources:**
- [Anthropic Tool Search Docs](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-search-tool)
- [MCP Tool Search Guide](https://www.atcyrus.com/stories/mcp-tool-search-claude-code-context-pollution-guide)

---

### 2026-01-08: Removed archived Apple MCPs

**Removed:**
- `apple-core` → `bunx apple-mcp@latest` (supermemoryai/apple-mcp)
- `apple-mail` → `apple-mail-mcp`

**Reason:** Consolidation and maintenance status
- `supermemoryai/apple-mcp` was archived January 1, 2026 (read-only, no updates)
- Both MCPs were timing out on operations
- `apple-mail` was redundant - AppleScript MCP already handles Mail
- AppleScript MCP (`@peakmojo/applescript-mcp`) covers all apps:
  - Reminders (list, create with priority, due dates)
  - Notes (full CRUD, folders)
  - Calendar (events, date ranges)
  - Mail (search, send, organize)
  - Messages, Contacts, Maps

**Current setup:**
- Single MCP: `@peakmojo/applescript-mcp`
- Skill file: `~/.claude/skills/apple-tools.md` (AppleScript templates)

**Active alternatives if needed:**
- Reminders + Calendar: [FradSer/mcp-server-apple-events](https://github.com/FradSer/mcp-server-apple-events) (Swift-compiled, v1.0.1)
- Notes: [henilcalagiya/mcp-apple-notes](https://github.com/henilcalagiya/mcp-apple-notes) (Full CRUD, v0.1.0)
- Mail: [s-morgan-jeffries/apple-mail-mcp](https://github.com/s-morgan-jeffries/apple-mail-mcp) (Python)

**To restore archived MCPs (not recommended):**
```json
{
  "name": "apple-core",
  "call_template_type": "mcp",
  "config": {
    "mcpServers": {
      "apple-mcp": {
        "command": "bunx",
        "args": ["--no-cache", "apple-mcp@latest"],
        "transport": "stdio"
      }
    }
  }
}
```
