# MCP Server Configuration

> **Backup**: `~/.claude/mcp/mcp.json.bak` (git-crypt encrypted, 36 servers)
> **Active runtime**: `~/.utcp_config.json` (code-mode UTCP proxy, git-crypt encrypted)

## Backup Strategy

`mcp.json.bak` is the single source of truth for MCP server definitions. It contains all servers in Claude's native `mcpServers` format for portability.

**On dotfiles update**, the skill captures servers from:
1. `~/.utcp_config.json` (code-mode UTCP — primary, always used)
2. `.claude.json` `mcpServers` section (native MCPs — rare, backed up if configured)

Existing backup entries take precedence (they have real tokens). New servers from either source are merged in.

**On new machine**, decrypt with `git-crypt unlock`, then register servers in `~/.utcp_config.json` for code-mode. Native `mcpServers` in `.claude.json` is not the default workflow.

## Active Servers (36)

### Core Tools

| Server | Package | Purpose | Key |
|--------|---------|---------|-----|
| `tmux` | `tmux-mcp` | Terminal session management | No |
| `memory` | `@modelcontextprotocol/server-memory` | Persistent key-value memory | No |
| `sequential-thinking` | `@modelcontextprotocol/server-sequential-thinking` | Step-by-step reasoning | No |
| `fetch` | `mcp-fetch-server` | HTTP requests to URLs | No |

### Search & Research

| Server | Package | Purpose | Key |
|--------|---------|---------|-----|
| `brave-search` | `@brave/brave-search-mcp-server` | Web search via Brave API | Yes |
| `duckduckgo` | `duckduckgo-mcp-server` | Web search (no key) | No |
| `arxiv` | `arxiv-mcp-server` | Academic paper search | No |
| `hackernews` | `@devabdultech/hn-mcp-server` | Hacker News stories | No |
| `stackoverflow` | `@notalk-tech/stackoverflow-mcp` | Stack Overflow Q&A | No |
| `rss` | `@iflow-mcp/rss-reader-server` | RSS feed reading | No |

### Development

| Server | Package | Purpose | Key |
|--------|---------|---------|-----|
| `github` | `@modelcontextprotocol/server-github` | GitHub repos, issues, PRs | Yes |
| `notion` | `@notionhq/notion-mcp-server` | Notion pages and databases | Yes |
| `google-drive` | `@piotr-agier/google-drive-mcp` | Google Drive file access | OAuth |
| `supabase` | `@supabase/mcp-server-supabase` | Supabase database ops | Yes |
| `firecrawl` | `firecrawl-mcp` | Web scraping and crawling | Yes |
| `railway` | `@railway/mcp-server` | Railway deployment | Yes |
| `apify` | `@apify/actors-mcp-server` | Web automation | Yes |
| `vercel` | Remote URL | Vercel platform MCP | OAuth |
| `clickhouse` | Remote URL | ClickHouse cloud MCP | OAuth |

### Browser & UI

| Server | Package | Purpose | Key |
|--------|---------|---------|-----|
| `chrome-devtools` | `chrome-devtools-mcp` | Chrome browser automation | No |
| `magic` | `@magicuidesign/mcp` | UI component generation | Yes |

### System Integration

| Server | Package | Purpose | Key |
|--------|---------|---------|-----|
| `applescript` | `@peakmojo/applescript-mcp` | macOS automation | No |
| `cclsp` | `cclsp` | Language server protocol | No |
| `openapi` | `openapi-mcp` | OpenAPI spec exploration | No |
| `chatgpt-mcp` | `chatgpt-mcp` | ChatGPT integration | No |
| `anki` | `@ankimcp/anki-mcp-server` | Anki flashcard management | No |

### Claude Code Ecosystem

| Server | Package | Purpose | Key |
|--------|---------|---------|-----|
| `claude-historian-mcp` | `claude-historian-mcp` | Search past sessions | No |
| `claude-senator` | `claude-senator` (local) | Permission and safety checks | No |
| `claude-praetorian` | `claude-praetorian` | Security scanning | No |
| `context7` | `@upstash/context7-mcp` | Library documentation | Yes |

### Content & Media

| Server | Package | Purpose | Key |
|--------|---------|---------|-----|
| `yt-dlp` | `@kevinwatt/yt-dlp-mcp` | YouTube download | No |
| `reddit` | `reddit-mcp-buddy` | Reddit browsing | No |
| `twitter` | `agent-twitter-client-mcp` | Twitter/X integration | Cookies |
| `1mcpserver` | `@particlefuture/1mcpserver` | General utilities | No |

### Documentation (Remote URL)

| Server | URL | Purpose | Key |
|--------|-----|---------|-----|
| `cloudflare-docs` | `docs.mcp.cloudflare.com` | Cloudflare documentation | OAuth |
| `cloudflare-observability` | `observability.mcp.cloudflare.com` | Cloudflare observability | OAuth |

## Server Status

- **Needs Setup**: `railway`, `firecrawl`, `supabase`, `apify` (tokens not configured)
- **Needs OAuth**: `vercel`, `cloudflare-docs`, `cloudflare-observability`, `clickhouse`
- **Needs Cookies**: `twitter` (AUTH_METHOD=cookies)

## Adding New Servers

1. Add to `~/.utcp_config.json` via code-mode registration
2. Run dotfiles update — skill auto-captures into `mcp.json.bak`
3. Document purpose and key requirement here
4. Restart Claude Code (`/mcp` to verify)

## Troubleshooting

- **Server not connecting**: Check `/mcp` output, verify package installed
- **Auth errors**: Verify API key in encrypted config
- **Tool not found**: Native MCP lazy-loads tools >10K tokens, use specific tool names
