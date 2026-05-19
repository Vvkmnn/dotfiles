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

## MCP Server Settings

### 2026-03-17: MCP Server Fixes and Additions

**Changes:**
- **Reddit**: Switched from `reddit-mcp-buddy` (blocked by Reddit API changes) to `reddit-mcp-server` with OAuth credentials (client_id + client_secret from reddit.com/prefs/apps)
- **Twitter/X**: Switched from `agent-twitter-client-mcp` (cookie/credential auth both broken) to `@practicaltools/twitter-mcp-server` via Apify. Uses existing Apify token — free tier covers ~50k searches/month
- **YouTube**: Added `@kirbah/mcp-youtube` with YouTube Data API v3 key. Complements yt_dlp (search vs transcript extraction)
- **Firecrawl**: Added API key (free tier, 500 credits one-time)
- **Apify**: Added API key (free tier, $5/month credits)
- **Supabase/Railway**: Left with placeholder keys (not currently used)

**Architecture:** All MCP servers route through `mcp-proxy` gateway on localhost:9090. Config: `~/.claude/mcp/config.json`. Claude Code connects via `~/.claude.json` HTTP entries.

**Reference:** `~/.claude/mcp/MCP.md` — full server inventory
**Credentials backup:** `~/.claude/mcp/credentials.txt`

**To restore old Twitter:** See credentials.txt for cookie and credential auth configs. Cookie auth works but expires frequently. Credential auth returns error 34 on new accounts.

---

## Plugin Settings

### 2026-03-17: Max 20x Optimization (63 -> 27 plugins)

**Previous:** 63 plugins enabled, model unset, git instructions on
**Current:** 27 plugins enabled, model: "opus", includeGitInstructions: false, filesystem Read denies added

**Changes applied:**
- Disabled 36 plugins (15 Trail of Bits, 7 redundant, 14 zero-usage workflow)
- Added `model: "opus"` (fixes switch-claude 20x detection)
- Added `includeGitInstructions: false` (~2k token savings, covered by commit-commands plugin)
- Added Read denies for `~/.ssh/*`, `~/.aws/*`, `~/.env*`, `~/.gnupg/*`
- Updated `orchestrate.md` with Language Skills invoke triggers
- Kept ralph-loop (6 sessions/5 projects confirmed), code-simplifier (2 sessions confirmed)
- Kept python-development, javascript-typescript (fixed root cause of non-invocation in orchestrate.md)

**Evidence:** Direct JSONL search across 794 session files (historian search has gaps — zero results doesn't mean zero usage).

**Reference:** `~/.claude/analysis/PLUGINS_DISABLED.md` — full catalog with re-enable guidance
**Plan:** `plans/groovy-pondering-flamingo.md`

**To restore:** Backup not needed — set any plugin back to `true` in settings.json. See PLUGINS_DISABLED.md for what each does.

---

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

---

## Community Research

### 2026-02-02: Best-in-Class Claude Code Setup Comparison

**Sources analyzed:**
- Reddit r/ClaudeAI (V4 guide, 25 tips, 6-month retrospective posts)
- GitHub awesome-claude-skills, VoltAgent, Trail of Bits, obra/superpowers
- Dev blogs, Hacker News, Medium articles on Claude Code optimization

**Current setup vs community best practices:**

| Feature | Our Setup | Community Best | Status |
|---------|-----------|----------------|--------|
| `mcpToolSearch: "always"` | ✓ | ✓ 85% context reduction | Done |
| Custom keybindings | ✓ 7 shortcuts | ✓ V4 feature | Done |
| Comprehensive hooks | ✓ 5 types | ✓ Core workflow | Done |
| superpowers plugin | ✓ | ✓ 27.9k stars | Done |
| continuous-learning-v2 | ✓ | More advanced than Claudeception | Done |
| claude-historian MCP | ✓ | ✓ Session memory | Done |
| Privacy env vars | ✓ Added | ✓ | Done |

**New additions (2026-02-02):**
- Added to `~/.profile`:
  ```sh
  export CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1
  export DISABLE_TELEMETRY=1
  export DISABLE_ERROR_REPORTING=1
  ```

**Evaluated but skipped:**

| Tool | Reason Skipped |
|------|----------------|
| claude-mem | Already tried, RAM issues (see 2025-12-26 entry) |
| SuperClaude Framework | Heavy overlap with superpowers |
| Claude-Flow | Overkill unless doing swarm orchestration |
| ccusage | Optional cost tracking, install later if needed |
| Maestro | Only if running 5+ parallel sessions |

**Key community insights:**
- Boris (Claude Code creator) runs "surprisingly vanilla" setup
- Plugin stacking burns ~8k tokens on tool definitions before first prompt
- Skill hot-reload (v2.1+): Skills in `~/.claude/skills/` auto-reload
- Custom compaction: `/compact Focus on X` tells Claude what to preserve
- `context: fork` in skill frontmatter for isolated sub-agent context

**Resources discovered:**
- [SkillsMP](https://skillsmp.com/) - 71K+ community skills
- [skills.sh](https://skills.sh) - Skill browser
- [Trail of Bits](https://github.com/trailofbits/skills) - 23 security plugins
- [ccusage](https://ccusage.com/) - Cost tracking CLI
- [AgentDepot](https://agentdepot.dev) - Searchable skills/plugins directory

**Conclusion:** Setup already top-tier. Main gaps were privacy vars (now added).
