# Claude Code - Production Configuration

## Quick Reference
**Environment**: macOS Darwin 24.5.0 | **Directory**: `/Users/v/.claude` | **Integration**: Neovim + Hooks + MCP

🧪 **HOOK TEST EDIT** - Testing jump to top of file - cursor should be here!

### Essential Commands
```bash
# Start Neovim with socket for integration
vl  # Alias for: nvim --listen /tmp/nvim

# Claude Code operations
claude --help
claude mcp list
claude config list
```

### Speed Optimizations
- Use `/clear` between task contexts (AI becomes unpredictable with long contexts)
- Thinking modes: `think` < `think hard` < `think harder` < `ultrathink`
- Stage changes early: `git add` after each logical unit
- Parallel Claude instances in separate terminals for different tasks
- **Hook precision**: Edits jump to exact line numbers for immediate review [TESTING]

## Architecture & Integration

### Neovim Integration (Active)
```bash
# Setup: Start listening Neovim in separate terminal
vl  # Alias for: nvim --listen /tmp/nvim

# Automatic file opening via hooks configured in:
# /Users/v/.config/claude/settings.json
```

**Hook Behavior:**
- **Start**: Checks for `/tmp/nvim` socket, reminds to start `vl` if needed
- **Tool Result**: Auto-opens edited files in Neovim via `nvim --server /tmp/nvim --remote-send ":e $FILE<CR>"`
- **Feedback**: Use `:ClaudeFeedback` in Neovim to add tasks to CLAUDE.md

### MCP Servers (Production)
- **github**: Repository operations, issue management, PR creation
- **time**: Date/time utilities (America/Montreal timezone)  
- **sequential-thinking**: Advanced reasoning for complex problems
- **obsidian**: Knowledge base integration via WebSocket
- **memory-bank**: Persistent memory across sessions
- **playwright/puppeteer**: Browser automation and testing
- **desktop-commander**: System automation and commands
- **magic**: Development tools and utilities

### Directory Structure
```
.claude/
├── CLAUDE.md              # This file - auto-loaded context
├── settings.json          # Permissions, environment, hooks config
├── commands/              # Custom slash commands (/debug, /review, /ship)
│   ├── debug.md          # Systematic debugging workflow
│   ├── review.md         # Code review checklist  
│   └── ship.md           # Deployment workflow
├── README.md             # MCP server documentation & setup
├── .env.example          # Environment template
└── setup-mcp-servers.sh # Automated MCP installation
```

## Development Workflow (TDD-First)

### 1. Analysis & Planning
- **Be specific**: Communicate as with senior engineer
- **Provide context**: Define exact requirements and constraints
- **Use BMAD method**: Analyst → Architect → Developer → QA phases
- **Break down**: Large features into epics → user stories → tasks

### 2. Test-Driven Development (Essential)
```bash
# TDD cycle - AI "eats up" TDD, most effective against hallucination
1. Write failing test
2. Implement minimal code to pass
3. Refactor and improve
4. Verify with full test suite
```

### 3. Code Quality Gates
- **Pre-commit hooks**: Auto-formatting, linting, security checks
- **Security**: Never commit secrets, use env vars, validate inputs
- **Performance**: Profile bottlenecks, optimize algorithms, cache when appropriate
- **Documentation**: Update when adding complexity or changing APIs

### 4. Review & Integration
- **Automatic file opening**: All edits appear in Neovim for review
- **Git workflow**: Frequent staging, clear commit messages, focused changes
- **Multi-agent**: Use separate Claude instances for implementation vs review

## Code Standards

### General Principles
- **Clarity over cleverness**: Write code others can understand
- **Follow existing patterns**: Mimic style, use established libraries
- **Fail fast**: Validate early, handle errors gracefully
- **Security first**: Never expose secrets, sanitize inputs, principle of least privilege

### Language-Specific
```bash
# Auto-formatting via hooks (PostToolUse)
*.lua    → stylua
*.py     → black  
*.ts,js  → prettier
*.go     → gofmt
```

### Architecture Guidelines
- **Separation of concerns**: Single responsibility, loose coupling
- **Configuration over convention**: Use environment variables, config files
- **Idempotent operations**: Commands can be run multiple times safely
- **Graceful degradation**: System works with reduced functionality if components fail

## Advanced Features

### Custom Slash Commands
```bash
/debug    # Systematic issue analysis and resolution
/review   # Comprehensive code review checklist
/ship     # Safe deployment workflow with rollback plan
```

### Thinking Strategies
- **Complex problems**: Use `ultrathink` for deep analysis
- **Sequential reasoning**: Leverage sequential-thinking MCP server
- **Context priming**: Load relevant project context before requests
- **Parallel processing**: Multiple Claude instances for different aspects

### Hidden Benefits
- **Visual integration**: Drag images/mockups for UI generation
- **Strategic abstraction**: Focus on intent while Claude handles execution
- **General agent**: Treat as universal agent, not just coding tool
- **Jupyter integration**: Read/write notebooks, interpret outputs including images

## Automation & CI/CD

### Pre-commit Configuration
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
  - repo: https://github.com/psf/black
    rev: 23.3.0
    hooks:
      - id: black
  - repo: https://github.com/pre-commit/mirrors-prettier
    rev: v3.0.0
    hooks:
      - id: prettier
        types_or: [javascript, jsx, ts, tsx, json, yaml, markdown]
```

### Environment Variables
```bash
# Production environment setup
export GITHUB_PERSONAL_ACCESS_TOKEN='your-token'
export ANTHROPIC_API_KEY='your-key'
export MAGIC_API_KEY='your-key'  
export OBSIDIAN_VAULT_PATH="$HOME/Documents/vault"
export CLAUDE_CODE_ENABLE_TELEMETRY='0'
export DISABLE_TELEMETRY='1'

# Development/debugging
export CLAUDE_CODE_MCP_DEBUG='1'
export SERENA_PATH="$HOME/Documents/dev/serena"
```

## Troubleshooting & Optimization

### Performance
- **Context management**: Use `/clear` frequently, monitor context indicator
- **Voice dictation**: Use tools like Superwhisper for long prompts
- **Terminal shortcuts**: Configure Shift+Enter via `/terminal-setup`
- **Git worktrees**: Parallel development streams for complex projects

### Common Issues
```bash
# MCP debugging
claude --mcp-debug

# Permission bypass (development only)
claude --dangerously-skip-permissions

# Hook debugging  
# Check /Users/v/.config/claude/settings.json
# Verify /tmp/nvim socket exists
ls -la /tmp/nvim

# Manual file opening test
nvim --server /tmp/nvim --remote-send ":e filename<CR>"
```

### Security Checklist
- [ ] No hardcoded secrets in code
- [ ] Environment variables for configuration
- [ ] Input validation and sanitization
- [ ] Principle of least privilege for permissions
- [ ] Regular security updates and dependency checks

## Team Collaboration

### Onboarding Workflow
1. **Setup**: Run `/init` in project directory for custom CLAUDE.md
2. **Environment**: Configure required API keys and variables
3. **Integration**: Install MCP servers via setup script
4. **Testing**: Verify hook integration with sample edits
5. **Documentation**: Add project-specific context and standards

### Best Practices Documentation
- **Version control**: Track Claude configuration changes
- **Knowledge sharing**: Document successful patterns in team wikis
- **Custom commands**: Share slash command libraries across projects
- **Regular updates**: Keep CLAUDE.md current with project evolution

### Multi-Agent Workflows
- **Specialization**: Implementation, review, testing agents with distinct roles
- **Git worktrees**: Separate working directories for concurrent development
- **Review process**: One Claude writes, another reviews for quality and security
- **Documentation**: Dedicated agent for maintaining docs and architectural decisions

---

## Quick Start Checklist
- [ ] Start Neovim listener: `vl` in separate terminal
- [ ] Verify socket: `ls -la /tmp/nvim` 
- [ ] Test integration: Edit any file, verify it opens in Neovim
- [ ] Use feedback: `:ClaudeFeedback` in Neovim to add tasks
- [ ] Clear context: `/clear` between different tasks
- [ ] Custom commands: `/debug`, `/review`, `/ship` for workflows

*Optimized for speed, correctness, and production reliability. Updated: 2025-07-03 | Integration: Active*

<!-- Test edit at bottom - hook should jump here and center view -->
## Test Section - Line Jump Test
This edit is at the very bottom of the file to test the hook's ability to jump to recent changes and center the view properly.

**NEWEST EDIT HERE** - Hook should jump directly to this line and center it!

🔥 INTEGRATION TEST EDIT - 2025-07-04 22:11:03 - Testing hook functionality with live edit!