# MCP Server Configuration

> Portable MCP config: `~/.claude/mcp/mcp.json` (git-crypt encrypted)
> Full config: `~/.claude.json` (git-crypt encrypted)
> Legacy reference: `~/.utcp_config.json` (git-crypt encrypted, deprecated)

## Active Servers

### Core Tools

| Server | Package | Purpose | Needs Key |
|--------|---------|---------|-----------|
| `tmux` | `tmux-mcp` | Terminal session management, long-running commands | No |
| `memory` | `@modelcontextprotocol/server-memory` | Persistent key-value memory across sessions | No |
| `sequential-thinking` | `@modelcontextprotocol/server-sequential-thinking` | Step-by-step reasoning for complex problems | No |
| `fetch` | `@anthropics/fetch-mcp` | HTTP requests to URLs | No |

### Search & Research

| Server | Package | Purpose | Needs Key |
|--------|---------|---------|-----------|
| `brave-search` | `@anthropics/brave-search-mcp` | Web search via Brave API | Yes |
| `duckduckgo` | `duckduckgo-mcp-server` | Web search (no key needed) | No |
| `arxiv` | `arxiv-mcp-server` | Academic paper search and retrieval | No |
| `hackernews` | `mcp-hn` | Hacker News stories and discussions | No |
| `stackoverflow` | `stackoverflow-mcp` | Stack Overflow Q&A search | No |
| `rss` | `mcp-server-rss` | RSS feed reading | No |

### Development

| Server | Package | Purpose | Needs Key |
|--------|---------|---------|-----------|
| `github` | `@anthropics/github-mcp` | GitHub repos, issues, PRs, code search | Yes |
| `notion` | `@notionhq/notion-mcp-server` | Notion pages and databases | Yes |
| `google-drive` | `@anthropics/gdrive-mcp` | Google Drive file access | Yes (OAuth) |
| `supabase` | `@anthropics/supabase-mcp` | Supabase database operations | Yes |
| `firecrawl` | `firecrawl-mcp` | Web scraping and crawling | Yes |
| `railway` | `@anthropics/railway-mcp` | Railway deployment management | Yes |
| `apify` | `@anthropics/apify-mcp` | Web automation and scraping | Yes |

### Browser & UI

| Server | Package | Purpose | Needs Key |
|--------|---------|---------|-----------|
| `chrome-devtools` | `@anthropics/chrome-devtools-mcp` | Chrome browser automation | No |
| `magic` | `@anthropics/magic-mcp` | UI component generation | Yes |

### System Integration

| Server | Package | Purpose | Needs Key |
|--------|---------|---------|-----------|
| `applescript` | `@anthropics/applescript-mcp` | macOS automation (Reminders, Notes, Calendar, Mail) | No |
| `cclsp` | `cclsp` | Language server protocol integration | No |
| `openapi` | `openapi-mcp` | OpenAPI spec exploration | No |

### Claude Code Ecosystem

| Server | Package | Purpose | Needs Key |
|--------|---------|---------|-----------|
| `claude-historian-mcp` | `claude-historian-mcp` | Search past Claude Code sessions | No |
| `claude-senator` | `claude-senator` | Permission and safety checks | No |
| `claude-praetorian` | `claude-praetorian` | Security scanning | No |
| `context7` | `@upstash/context7-mcp` | Context management | Yes |

### Content & Media

| Server | Package | Purpose | Needs Key |
|--------|---------|---------|-----------|
| `yt-dlp` | `yt-dlp-mcp` | YouTube video/audio download | No |
| `reddit` | `reddit-mcp` | Reddit browsing (WebFetch blocked for reddit) | Yes |
| `1mcpserver` | `1mcpserver` | General purpose utilities | No |

## Server Status

- **Working**: Most servers functional after native MCP migration (2026-02-01)
- **Needs Setup**: `railway` (token not configured)
- **Deprecated**: code-mode UTCP proxy (see PAST.md)

## Adding New Servers

1. Add to `~/.claude.json` under `mcpServers`
2. Document here with purpose and key requirement
3. Restart Claude Code (`/mcp` to verify)

## Troubleshooting

- **Server not connecting**: Check `/mcp` output, verify package installed
- **Auth errors**: Verify API key in encrypted config
- **Tool not found**: Native MCP lazy-loads tools >10K tokens, use specific tool names
