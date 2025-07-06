# Learn

Analyze conversation history and research best practices to recommend updates to CLAUDE.md and commands.

## Usage

```
/learn
```

## Process

### 1. Current Setup Analysis
- Read and analyze CLAUDE.md structure
- Review all commands in /commands/
- Check hooks configuration in settings.json
- Examine MCP server setup and usage
- Identify patterns in recent workflows

### 2. Conversation Analysis
- Review recent conversation history
- Extract successful patterns
- Identify pain points or repeated issues
- Note workflow improvements made

### 3. Online Research
- Search for latest Claude Code updates
- Find new best practices from community
- Check official documentation changes
- Discover emerging patterns and tools

### 4. MCP Server Discovery
- Search for MCP servers relevant to current work
- Find servers for identified workflow gaps
- Check MCP registry and community repos
- Evaluate server quality and maintenance
- Test compatibility with current setup

### 5. Gap Analysis
- Compare current setup to best practices
- Find missing functionality
- Identify outdated patterns
- Check for redundancies

### 6. Generate Recommendations
- Prioritize by impact and effort
- Provide specific implementation steps
- Include reasoning for each change
- Suggest testing approach
- Recommend cost optimizations

## Output Format

```markdown
## Learn Report - [YYYY-MM-DD]

### Conversation Insights
- Pattern: [What was learned]
- Improvement: [Suggested change]

### MCP Server Recommendations
Based on recent work with [topics]:
- [ ] **[server-name]**: [purpose] 
  - Install: `npm install -g @modelcontextprotocol/[name]`
  - Use case: [specific workflow improvement]
  - Impact: [time/quality improvement]

### Cost Optimization
- Current usage pattern: [analysis]
- Optimization: [specific change]
- Projected savings: [X%]

### Command Updates
- [ ] New: /[command] - [purpose]
- [ ] Update: /[command] - [change needed]
- [ ] Remove: /[command] - [reason]

### CLAUDE.md Recommendations
- [ ] Add: [Section/content]
- [ ] Update: [Section/change]
- [ ] Remove: [Redundant part]

### Workflow Improvements
- [ ] Pattern: [current] → [improved]
- [ ] Efficiency: [time saved]

### Priority Actions
1. [Highest impact, lowest effort]
2. [High impact, moderate effort]
3. [Nice to have improvements]
```

## Example

```
User: /learn

Claude: Analyzing conversation history and researching best practices...

## Learn Report - 2025-07-06

### Conversation Insights
- Pattern: Frequently using multi-agent workflows
- Improvement: Add dedicated /parallel command for multi-agent setup

- Pattern: Repeated token optimization questions
- Improvement: Add token usage to standard output format

### MCP Server Recommendations
Based on recent work with API development:
- [ ] **@modelcontextprotocol/server-postgres**: Database operations
  - Install: `npm install -g @modelcontextprotocol/server-postgres`
  - Use case: Direct SQL queries, schema management
  - Impact: 50% faster database debugging

- [ ] **@modelcontextprotocol/server-fetch**: Enhanced web fetching
  - Install: `npm install -g @modelcontextprotocol/server-fetch`
  - Use case: API testing, web scraping
  - Impact: Better than built-in WebFetch

### Cost Optimization
- Current usage pattern: 80% Opus for simple tasks
- Optimization: Switch to Sonnet except for /plan
- Projected savings: 75% reduction in API costs

### Command Updates
- [ ] New: /parallel - Setup multi-agent workflow
- [ ] Update: /plan - Add token estimate to output
- [ ] Update: /tdd - Include property-based testing

### CLAUDE.md Recommendations
- [ ] Add: Session continuation with --continue flag
- [ ] Update: Multi-agent section with parallel setup script
- [ ] Add: Token optimization examples with benchmarks

### Priority Actions
1. Implement /parallel command for multi-agent setup
2. Add --continue flag documentation
3. Update token optimization section with concrete examples
```

## Best Practices

- Run periodically (weekly/after major sessions)
- Focus on actionable improvements
- Prioritize user workflow patterns
- Keep recommendations specific
- Test suggestions before implementing

## When to Run

- After completing major features
- When encountering repeated issues
- Before starting new projects
- Weekly maintenance check
- After Claude Code updates