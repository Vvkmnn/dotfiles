# MCP Server Inventory

> Updated: 2026-03-18
> Config: `~/.claude/mcp/config.json` (proxy server definitions)
> Endpoints: `~/.claude.json` (Claude Code HTTP connections)
> Credentials backup: `~/.claude/mcp/credentials.txt`
> Logs: `~/.claude/mcp/proxy-error.log`

## Architecture

All servers run through `mcp-proxy` gateway on `localhost:9090`. Each server is an npm/uvx package spawned as a stdio subprocess. Claude Code connects to `http://localhost:9090/<server>/mcp`.

**Restart proxy:** `pkill -f mcp-proxy && ~/.claude/mcp/bin/mcp-proxy --config ~/.claude/mcp/config.json &`

**After config changes:** Restart proxy AND restart Claude Code (tools load at session start).

### Previous Architecture (before 2026-02-01)

All MCP servers were proxied through code-mode UTCP (`@utcp/code-mode-mcp`). Config lived in `~/.utcp_config.json` (git-crypt encrypted). Backup of that era: `~/.claude/mcp/mcp.json.bak` (git-crypt encrypted, 36 servers). Native MCP with mcp-proxy replaced UTCP for better performance (+8.6% accuracy, 85% token reduction via lazy loading). Lost features: `call_tool_chain`, `register_manual`, `search_tools`. `~/.utcp_config.json` kept as reference.

## Active Servers (24 of 26)

### Search & Social
| Server | Package | Auth | Notes |
|--------|---------|------|-------|
| reddit | `reddit-mcp-server` | OAuth client_id + secret | 60-100 req/min. Creds from reddit.com/prefs/apps |
| twitter | `@practicaltools/twitter-mcp-server` | Apify token (shared) | 11 tools via Apify scraping. Free ~50k results/month |
| hackernews | `@devabdultech/hn-mcp-server` | None | |
| stackoverflow | `@notalk-tech/stackoverflow-mcp` | None | 300 req/day |
| duckduckgo | `duckduckgo-mcp-server` | None | Fallback search |

### Web & Content
| Server | Package | Auth | Notes |
|--------|---------|------|-------|
| brave_search | `@brave/brave-search-mcp-server` | API key | Free: 1 req/sec |
| fetch | `mcp-fetch-server` | None | URL -> markdown, unlimited |
| firecrawl | `firecrawl-mcp` | API key | JS-rendered pages. 500 one-time free credits |
| rss | `@iflow-mcp/rss-reader-server` | None | |

### Research
| Server | Package | Auth | Notes |
|--------|---------|------|-------|
| paper_search | `paper-search-mcp` (uvx) | None (optional keys for higher rate limits) | 22+ sources: arXiv, PubMed, Google Scholar, Semantic Scholar, Crossref, OpenAlex, SSRN, bioRxiv, dblp, CORE, Europe PMC, and more. Replaces standalone arxiv. 817 stars, 95% reliability |
| fred | `fred-mcp-server` | FRED API key (free) | 800k+ Federal Reserve economic time series. GDP, inflation, employment, rates |

### Media
| Server | Package | Auth | Notes |
|--------|---------|------|-------|
| youtube | `@kirbah/mcp-youtube` | YouTube Data API v3 key | Search, transcripts, trending. 10k units/day free |
| yt_dlp | `@kevinwatt/yt-dlp-mcp` | None | Download transcripts/metadata. Complements youtube |

### Productivity
| Server | Package | Auth | Notes |
|--------|---------|------|-------|
| notion | `@notionhq/notion-mcp-server` | Integration token | |
| google_drive | `@piotr-agier/google-drive-mcp` | OAuth tokens | ~/.config/google-drive-mcp/ |
| github | `@modelcontextprotocol/server-github` | PAT | Also via gh CLI |
| memory | `@modelcontextprotocol/server-memory` | None | Knowledge graph |

### System & Automation
| Server | Package | Auth | Notes |
|--------|---------|------|-------|
| tmux | `tmux-mcp` | None | |
| applescript | `@peakmojo/applescript-mcp` | None | macOS automation |
| chrome_devtools | `chrome-devtools-mcp` | None | |
| apify | `@apify/actors-mcp-server` | API token | Shared token with twitter server |

### AI & Dev Tools
| Server | Package | Auth | Notes |
|--------|---------|------|-------|
| sequential_thinking | `@modelcontextprotocol/server-sequential-thinking` | None | |
| magic_ui | `@magicuidesign/mcp` | None | |
| anki | `@ankimcp/anki-mcp-server` | None | Needs Anki desktop running |

### Unconfigured (2 servers — need API keys to activate)

| Server | What's Needed |
|--------|---------------|
| supabase | Access token + project ref from supabase.com dashboard |
| railway | API token from railway.app/account/tokens |

### Retired (available if needed)

| Server | Package | Notes |
|--------|---------|-------|
| arxiv | `arxiv-mcp-server` (uvx) | Replaced by paper_search which includes arXiv + 20 more sources. Re-add with: `"arxiv": {"command": "uvx", "args": ["arxiv-mcp-server", "--storage-path", "/Users/v/.arxiv-papers"]}` |

## Changes Log

### 2026-03-18
- Added `paper-search-mcp` (22+ academic sources in one server, replaces standalone arxiv)
- Added `fred-mcp-server` (Federal Reserve economic data, 800k+ time series)
- Retired standalone `arxiv` (now covered by paper_search)
- Created `study-claude` skill + `study-researcher` agent for research workflows

### 2026-03-17
- Reddit: `reddit-mcp-buddy` -> `reddit-mcp-server` (old package blocked by Reddit API changes)
- Twitter: `agent-twitter-client-mcp` -> `@practicaltools/twitter-mcp-server` (cookie/credential auth broken, switched to Apify)
- YouTube: Added `@kirbah/mcp-youtube` (new)
- Firecrawl: API key configured
- Apify: API key configured

### 2026-02-01
- Migrated from code-mode UTCP proxy to native MCP with mcp-proxy gateway

## Troubleshooting

- **404 from proxy**: Server crashed on startup. Check proxy-error.log for "Connecting" loops
- **Stuck "Connecting"**: Kill all proxy processes, restart fresh. Stale state causes this
- **Tools missing in Claude Code**: Restart Claude Code after proxy changes
- **Twitter auth issues**: Now uses Apify, no direct Twitter auth needed
- **Reddit 403**: Uses OAuth now, not unauthenticated scraping
