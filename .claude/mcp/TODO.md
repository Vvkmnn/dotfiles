# MCP Proxy Migration

## Context

Ghostty keeps crashing due to memory pressure from ~111 MCP server processes (36 servers × 3 Claude sessions). TBXark/mcp-proxy aggregates all servers behind a single HTTP endpoint so all sessions share one set of processes.

## Status

- [x] Binary installed at `~/.claude/mcp/bin/mcp-proxy` (v0.43.2, Go, Apple Silicon)
- [x] Create proxy config file (`~/.claude/mcp/config.json`, 24 servers)
- [x] Set up LaunchAgent (`com.claude.mcp-proxy`)
- [x] Add to Claude Code — replaced 27 stdio entries in `~/.claude.json` with 24 HTTP entries
- [x] Removed dead servers: openapi (broken bin), cclsp (needs config), 1mcpserver (deleted from npm)
- [x] code-mode already removed (mcpServers was migrated directly, not via code-mode bridge)
- [x] Test and verify — 20/24 proxy servers respond 200, 4 have placeholder credentials (twitter, firecrawl, supabase, railway/apify)

## Step 1: Create config

**File:** `~/.claude/mcp/config.json`

TBXark config docs: https://github.com/TBXark/mcp-proxy/blob/master/docs/CONFIGURATION.md

Format:
```json
{
  "mcpProxy": {
    "baseURL": "http://localhost:9090",
    "addr": ":9090",
    "type": "sse"
  },
  "mcpServers": {
    "server_name": {
      "command": "npx",
      "args": ["-y", "package-name"],
      "env": { "KEY": "value" }
    }
  }
}
```

### Servers to include (14 stdio + 4 HTTP passthrough)

**Stdio servers (proxy spawns these once, all sessions share):**

| Name | Command | Env vars |
|------|---------|----------|
| notion | `npx -y @notionhq/notion-mcp-server` | NOTION_TOKEN |
| context7 | `npx -y @upstash/context7-mcp --api-key <key>` | (key in args) |
| tmux | `npx -y tmux-mcp --shell-type=zsh` | — |
| chrome_devtools | `npx chrome-devtools-mcp@latest` | — |
| github | `npx -y @modelcontextprotocol/server-github` | GITHUB_PERSONAL_ACCESS_TOKEN |
| brave_search | `npx -y @brave/brave-search-mcp-server --transport stdio` | BRAVE_API_KEY |
| fetch | `npx mcp-fetch-server` | — |
| applescript | `npx @peakmojo/applescript-mcp` | — |
| memory | `npx -y @modelcontextprotocol/server-memory` | — |
| sequential_thinking | `npx -y @modelcontextprotocol/server-sequential-thinking` | — |
| stackoverflow | `npx -y @notalk-tech/stackoverflow-mcp` | — |
| google_drive | `npx -y @piotr-agier/google-drive-mcp` | HOME, XDG_CONFIG_HOME, GOOGLE_DRIVE_OAUTH_CREDENTIALS, GOOGLE_DRIVE_TOKEN_PATH |
| reddit | `npx -y reddit-mcp-buddy` | — |
| hackernews | `npx -y @devabdultech/hn-mcp-server` | — |

**HTTP passthrough (no process, just proxied):**

| Name | URL |
|------|-----|
| vercel | https://mcp.vercel.com |
| cloudflare_docs | https://docs.mcp.cloudflare.com/mcp |
| cloudflare_observability | https://observability.mcp.cloudflare.com/mcp |
| clickhouse | https://mcp.clickhouse.cloud/mcp |

**Env var values:** All tokens/keys are in `~/.utcp_config.json` — extract from there when building config.

### Servers NOT included (removed)

supabase (broken), railway, apify, anki, magic_ui, yt_dlp, arxiv, chatgpt, twitter, 1mcpserver, openapi, cclsp, claude_senator (missing), duckduckgo (redundant with brave), claude_historian (plugin handles it), claude_praetorian (plugin), firecrawl (no API key configured)

## Step 2: Create LaunchAgent

**File:** `~/Library/LaunchAgents/com.claude.mcp-proxy.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.claude.mcp-proxy</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/v/.claude/mcp/bin/mcp-proxy</string>
        <string>--config</string>
        <string>/Users/v/.claude/mcp/config.json</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/Users/v/.claude/mcp/proxy.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/v/.claude/mcp/proxy-error.log</string>
</dict>
</plist>
```

Load with: `launchctl load ~/Library/LaunchAgents/com.claude.mcp-proxy.plist`

## Step 3: Add to Claude Code

```bash
# Add as user-scoped HTTP server (shared across all sessions/projects)
claude mcp add --transport sse --scope user mcp-proxy http://localhost:9090/sse
```

## Step 4: Disable code-mode

In `~/.claude.json`, rename `mcpServers.code-mode` to `mcpServers._code-mode_disabled` (or remove it). This stops code-mode from spawning all 36 utcp servers per session.

Keep `~/.utcp_config.json` as backup — don't delete it.

## Step 5: Verify

```bash
# Check proxy is running
curl -s http://localhost:9090/sse | head -5

# Count MCP processes (should be ~14 total, not ~111)
ps aux | grep -E "mcp|MCP" | grep -v grep | wc -l

# Check memory
sysctl vm.swapusage

# In Claude Code, verify tools are available
# /mcp should show all 18 servers' tools
```

## Rollback

If proxy doesn't work:
1. Stop proxy: `launchctl unload ~/Library/LaunchAgents/com.claude.mcp-proxy.plist`
2. Re-enable code-mode: rename `_code-mode_disabled` back to `code-mode` in `~/.claude.json`
3. Restart Claude Code sessions

## References

- TBXark/mcp-proxy: https://github.com/TBXark/mcp-proxy
- Config docs: https://github.com/TBXark/mcp-proxy/blob/master/docs/CONFIGURATION.md
- Config converter: https://tbxark.github.io/mcp-proxy
- Crash investigation: `~/.claude/plans/merry-sniffing-wolf.md`
