# Future Tasks & Ideas

## Legacy (from ~/.claude.old)

Location: `~/.claude/legacy/`

Contains old commands and hooks from July 2025 setup:
- `commands/`: backup, check, commit, install, learn, plan, pull, sync, test
- `hooks/`: notification.js, post-tool-use.js, pre-commit-validation.js, pre-compact.js, pre-tool-use.js, stop.js, subagent-stop.js
- `CLAUDE.old.md`: Previous CLAUDE.md format
- `MCP.md`: Old MCP documentation

Review when time permits - may contain useful patterns to integrate into current plugin-based setup.

---

## Per-Project Setup

### Dora (Code Navigation)

Fast symbol lookup, dependency tracing, reference finding. Set up when exploring a codebase extensively.

```bash
cd ~/project
dora init                    # Creates .dora/
# Edit .dora/config.json with language indexer (see below)
dora index                   # Build initial index
```

**Indexer config** (`.dora/config.json`):

| Language | Config |
|----------|--------|
| TypeScript/JS | `{"commands": {"index": "scip-typescript index --output .dora/index.scip"}}` |
| Python | `{"commands": {"index": "scip-python index --output .dora/index.scip"}}` |
| Rust | `{"commands": {"index": "rust-analyzer scip . --output .dora/index.scip"}}` |
| Lua | `{"commands": {"index": "scip-lua index --output .dora/index.scip"}}` |

**Usage**: `dora symbol <name>`, `dora refs <symbol>`, `dora deps <path>`, `dora map`

**Re-index after significant changes**: `dora index`

---

## Plugins Requiring Setup

### Interface Design (Dammyjay93)

Design system consistency for UI work.

```bash
claude plugin marketplace add Dammyjay93/interface-design
claude plugin install interface-design@Dammyjay93
```

### Snyk MCP (Security Scanning)

Local vulnerability scanning. Requires Snyk account and API token.

1. Get token: https://app.snyk.io/account
2. Add to `~/.utcp_config.json` (code-mode):

```json
{
  "mcpServers": {
    "snyk": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-snyk"],
      "env": {
        "SNYK_TOKEN": "<your-token>"
      }
    }
  }
}
```

---

## External Services (Enable When Needed)

These require accounts/API keys:

| Plugin | Purpose | Setup |
|--------|---------|-------|
| sentry@claude-plugins-official | Error monitoring | Sentry API token |
| vercel@claude-plugins-official | Deployment | Vercel account |
| slack@claude-plugins-official | Team comms | Slack app token |
| figma@claude-plugins-official | Design-to-code | Figma API token |
| stripe@claude-plugins-official | Payments | Stripe API keys |
| huggingface-skills | AI models | HF token |

---

## Domain-Specific (Enable Per Project)

| Plugin | Use Case |
|--------|----------|
| llm-application-dev | LangGraph, RAG, vector search |
| observability-monitoring | Prometheus, Grafana |
| data-engineering | ETL, dbt, Airflow |
| c4-architecture | Architecture diagrams |

---

## code-mode vs Native Claude Code MCP (2026-01-30)

### Current State
- 21 MCP servers aggregated via code-mode (`~/.utcp_config.json`)
- Node 22 wrapper required (`~/.claude/wrappers/npx-node22`) due to isolated-vm@5.x incompatibility with Node 24
- PR #28 submitted to upstream: https://github.com/universal-tool-calling-protocol/code-mode/pull/28

### Analysis

| Factor | code-mode | Native Claude Code MCP |
|--------|-----------|------------------------|
| Token efficiency | 98.7% (TypeScript code execution) | 85% (MCP Tool Search) |
| Process overhead | 1 aggregated process | N separate processes |
| Failure isolation | Single point of failure | Independent per server |
| Multi-tool workflows | Excellent (chain calls in one execution) | Each call is separate round-trip |
| Maintenance | Node version workarounds | None |
| Setup complexity | One config file | Multiple config entries |

### Known Issues (Jan 2026)
Failing servers in current setup: `claude_senator`, `1mcpserver`, `openapi`, `cclsp`

### Decision: Keep code-mode for now
**Reasoning:**
- 98.7% token savings vs 85% is significant for heavy MCP usage
- Multi-step workflows (e.g., Notion + GitHub in one execution) are cleaner
- Node 22 wrapper is working, upstream fix pending

### Periodic Checks

**Check if Node 22 wrapper still needed:**
```bash
npm view @utcp/code-mode peerDependencies.isolated-vm
# If ^6.0.0 or higher: remove wrapper, revert to "npx" in config
```

**Check failing servers:**
```bash
# In Claude Code, run /mcp to see connection status
# Remove or fix: claude_senator, 1mcpserver, openapi, cclsp
```

### When to Reconsider Migration

1. **code-mode maintenance burden increases** - more Node version issues, upstream abandoned
2. **Claude Code native MCP improves** - better tool aggregation, similar token efficiency
3. **Server count drops significantly** - fewer servers = less benefit from aggregation
4. **Multi-tool workflows decrease** - if mostly single-tool calls, native is simpler

### Hybrid Option (if needed later)
Add critical servers to native Claude Code MCP as fallback while keeping code-mode primary:
- `notion`, `github`, `google_drive` - high-value, frequently used
- Provides redundancy if code-mode has issues

---

## Plugin Recommendations (2026-02-02)

### Trail of Bits Security Research

Marketplace added but plugins not installed. Specialized for security research (not typical app security).

```bash
/plugin marketplace add trailofbits/skills  # Already done
```

**Available plugins** (install when doing security research):
- `static-analysis` - CodeQL + Semgrep bindings
- `variant-analysis` - Find code similar to known vulns
- `constant-time-analysis` - Crypto timing side-channels
- `property-based-testing` - Hypothesis-style fuzzing
- `yara-authoring` - Malware detection rules
- `dwarf-expert` - Binary/debug info analysis
- `burpsuite-project-parser` - Web pentesting workflow
- `building-secure-contracts` - Solidity/smart contracts

**Note:** Repo may not follow Claude Code plugin format. Check structure if install fails.

### Additional claude-code-workflows Plugins

Already have: security-scanning, cicd-automation, database-design, python-development, javascript-typescript, systems-programming, backend-development, tdd-workflows, unit-testing.

**Install when needed:**

| Plugin | Use Case |
|--------|----------|
| `debugging-toolkit` | Systematic debugging agents |
| `error-debugging` | Error pattern analysis |
| `git-pr-workflows` | PR creation/review workflows |
| `code-refactoring` | Structured refactoring |

```bash
/plugin install debugging-toolkit@claude-code-workflows
/plugin install error-debugging@claude-code-workflows
/plugin install git-pr-workflows@claude-code-workflows
/plugin install code-refactoring@claude-code-workflows
```

### Cost Tracking (When Needed)

```bash
npm install -g ccusage
ccusage  # Shows cost breakdown per session/project
```

Only relevant for API usage, not subscription.
