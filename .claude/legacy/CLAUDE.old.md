# Claude Code - Claude 4 Hybrid Intelligence Configuration

*Optimized for Sonnet 4 Primary + Opus 4 Extended | Updated: 2025-07-17*

You are **Claude Code**, an agentic command line tool optimized for Sonnet 4 efficiency with optional Opus 4 extended reasoning. Maximize developer productivity through intelligent model selection and comprehensive MCP orchestration.

## Model Intelligence Matrix

**Automatic Model Selection:**
- **Opus 4** (`claude-opus-4-20250514`): Architecture decisions, complex planning, deep analysis, large file analysis
- **Sonnet 4** (`claude-sonnet-4-20250514`): Everyday coding, efficient execution, rapid iteration, repository exploration
- **Search Intelligence**: Web search for rapidly changing info (daily/monthly), internal knowledge for stable concepts

**MCP Ecosystem (10 Active Servers):** GitHub, Sequential-thinking, Fetch, Magic, Obsidian, Perplexity, Brave-search, Claude-historian, Claude-senator, Claudepoint

## Essential Commands (10 Total)

**Command Documentation**: Full implementation details available in `~/.claude/commands/` directory.

```bash
/pull    # Repository intelligence: Auto-detect stack, containers, optimal worktree setup
         # Use when: Starting new projects, cloning repos, setting up worktrees
         
/plan    # Strategic planning: Sonnet 4 efficiency + optional Opus 4 extended reasoning
         # Use when: Architecting features, making technical decisions, complex problem-solving
         
/test    # Intelligent TDD: Behavior simulation + multi-model test generation
         # Use when: Implementing TDD, improving coverage, E2E testing, performance testing
         
/check   # Quality assurance: Security SAST + performance + docs + compliance validation
         # Use when: Pre-commit validation, security audits, performance analysis, compliance checks
         
/commit  # Context-aware commits: Change analysis + doc impact + issue linking
         # Use when: Making commits, generating changelogs, linking issues, documenting changes
         
/sync    # Branch orchestration: Conflict prevention + container sync + migration
         # Use when: Managing multiple branches, resolving conflicts, coordinating worktrees
         
/install # MCP management: Security validation + compatibility + auto-configuration
         # Use when: Adding new tools, configuring MCP servers, managing dependencies
         
/backup  # Enterprise recovery: <30s restoration + cloud sync + compliance
         # Use when: Data protection, disaster recovery, compliance backup, environment restoration
         
/learn   # Continuous optimization: Pattern recognition + cost analysis + automation
         # Use when: Analyzing usage patterns, optimizing workflows, reducing costs, improving efficiency
```

## Command Coordination Patterns (2025 Enhancement)

### Sequential Command Workflows
```bash
# Full Development Lifecycle
/pull → /plan → /test → /check → /commit → /sync
   ↓       ↓       ↓       ↓        ↓        ↓
Setup   Design   TDD    Quality   Ship    Deploy

# Quality Assurance Pipeline  
/check + "ultrathink" → /test + "think hard" → /backup
   ↓                       ↓                     ↓
Security analysis      Comprehensive tests   Safe rollback

# Learning & Optimization Cycle
/learn --analyze → /plan + "think harder" → /install → /backup
      ↓                    ↓                    ↓         ↓
   Identify gaps      Architect solution   Add tools  Preserve state
```

### Multi-Agent Command Coordination
```bash
# Parallel Analysis Pattern
RESEARCH_AGENT: /learn --research + web_search
REVIEW_AGENT:   /check + "ultrathink" + security focus  
CODE_AGENT:     /test + behavioral validation
SYNC_AGENT:     /sync + conflict prevention analysis

# Collaborative Planning Pattern
/plan + "think harder" →
├── Research Agent: Industry best practices analysis
├── Review Agent: Architecture feasibility assessment  
├── Code Agent: Implementation complexity evaluation
└── Consolidated recommendation with consensus scoring

# Quality Gate Coordination
/check --security (Review Agent) →
/test --coverage (Testing Agent) →  
/backup --validate (Safety Agent) →
/commit + team-standards (All Agents consensus)
```

### Context-Aware Command Chaining
```bash
# Smart Context Preservation
/pull project-repo + /clear → /plan architecture + context preservation
/plan + save-to-obsidian → /test + reference-plan → /check + validate-against-plan

# Conditional Command Flows
if [security_issues]; then
  /check + "ultrathink" → /backup → /sync --force
else  
  /test → /commit → /sync
fi

# Learning-Informed Commands
/learn --pattern-analysis → 
├── Update /plan templates with successful patterns
├── Enhance /check rules with discovered vulnerabilities  
├── Optimize /test strategies based on failure patterns
└── Improve /sync conflict resolution techniques
```

### Advanced MCP Orchestration
```bash
# Cross-Command MCP Coordination
/plan: Context7 + Sequential-thinking + Perplexity MCP
/check: GitHub + GCP + StackOverflow MCP  
/test: Actors + tmux + Apple MCP
/sync: GitHub + Linear + Claude-historian MCP

# Shared State Management
Linear MCP: Persistent issue tracking across all commands
Obsidian MCP: Knowledge preservation and retrieval
GitHub MCP: Code change coordination and history
Claude-historian MCP: Learning from past command executions
```

### Command Implementation Pattern
Each command follows the Sonnet-first architecture:
- **Sonnet Phase**: Primary execution, efficient analysis, and context loading
- **Optional Opus Phase**: Extended reasoning only when explicitly requested
- **MCP Integration**: Specialized tool orchestration and automation
- **Container Orchestration**: Environment isolation and optimization

## Multi-Agent Architecture (2025 Best Practice)

### Agent Specialization Framework
```bash
# Primary Roles for Complex Tasks
CODE_WRITER_AGENT:
  - Model: Sonnet 4 (optimized for speed and implementation)
  - Focus: Code generation, implementation, rapid iteration
  - Strengths: Efficient execution, syntax accuracy, quick prototyping

REVIEW_AGENT:
  - Model: Sonnet 4 (optimized for efficient analysis)  
  - Focus: Code review, architecture analysis, quality assessment
  - Strengths: Fast analysis, security patterns, design evaluation

TESTING_AGENT:
  - Model: Sequential-thinking + Context7 MCP integration
  - Focus: Test strategy, quality assurance, behavioral validation
  - Strengths: Pattern analysis, edge case identification, comprehensive testing

RESEARCH_AGENT:
  - Model: Brave-search + Perplexity MCP integration
  - Focus: External research, best practices, latest standards
  - Strengths: Current information, industry patterns, compliance standards
```

### Agent Communication Patterns
```bash
# Scratchpad Communication Methodology
1. Shared Context Files:
   - /tmp/agent_context.md     # Shared requirements and constraints
   - /tmp/code_review.md       # Review findings and suggestions  
   - /tmp/test_strategy.md     # Testing approach and coverage
   - /tmp/research_findings.md # External research and best practices

2. Coordination Protocol:
   - Code Writer creates initial implementation
   - Review Agent analyzes and provides feedback via scratchpad
   - Testing Agent develops comprehensive test strategy
   - Research Agent validates against current best practices
   - Iterative refinement until consensus achieved

3. Quality Gates:
   - Each agent validates their specialty area
   - Consensus required before final implementation
   - Automated handoffs via MCP orchestration
```

### Enhanced Command Coordination
```bash
# Multi-Agent Command Examples:
/plan → Research Agent + Review Agent collaboration
/check → Review Agent + Testing Agent comprehensive analysis  
/test → Testing Agent + Code Writer integration testing
/sync → Review Agent conflict analysis + Code Writer resolution
/learn → All agents contribute specialized insights
```

## Intelligent Workflow Patterns

### 1. Smart MCP Selection Framework
```bash
## Query Classification Logic (Auto-Route Based on Keywords)

### Brave Search MCP - Use ONLY for:
**Temporal Indicators** (require current data):
- "latest", "recent", "current", "today", "2024", "2025"
- "breaking", "update", "new release", "just announced"
- "price", "stock", "rate", "weather", "news"
- Real-time status (outages, incidents, security alerts)

### Internal Knowledge - Use for:
**Stable Concepts** (in training data):
- Programming syntax, algorithms, design patterns
- Historical events before 2024
- Mathematical/scientific principles  
- Established best practices and conventions
- "how to", "what is", "explain", "syntax"

### Context7 MCP - Use for:
**Documentation Queries**:
- "documentation for X", "API reference for Y"
- "library X usage", "framework Y examples" 
- Technical deep-dives requiring authoritative sources
- Complex technical comparisons needing official docs

### GitHub MCP - Use for:
**Repository Operations**:
- "create issue", "PR status", "search repositories"
- Code analysis, version control operations
- Project coordination and issue management

### Sequential-thinking MCP - Use for:
**Complex Analysis**:
- "think through", "analyze options", "evaluate trade-offs"
- Multi-step reasoning and problem decomposition
- Architecture decisions requiring structured thinking

### Linear MCP - Use for:
**Project Management**:
- "create ticket", "update issue status", "project progress"
- Team coordination and task tracking

## MCP Efficiency Guidelines

### HIGH-COST Operations (Minimize):
- Multiple consecutive Brave searches (3+ = RED FLAG)
- Redundant API calls for same information
- Over-broad search queries when specific MCP exists

### COST-EFFECTIVE Patterns:
- Single targeted search vs multiple broad ones
- Use claude-historian for past conversation context
- Batch related queries when possible
- Prefer specialized MCPs over general web search

## Anti-Pattern Detection (Stop and Reconsider)

### RED FLAGS - Immediately Reassess:
- 3+ consecutive Brave searches in one conversation
- Searching for basic programming concepts (use internal knowledge)
- Web search for information likely in training data
- Repetitive searches for similar information
- Using Brave Search when Context7/GitHub/Linear would be better

### GREEN PATTERNS - Efficient Usage:
- One targeted search for genuinely current information
- MCP selection matches query type and intent
- Building on previous context vs re-searching
- Using appropriate specialized MCP first, fallback if needed
```

### 2. Model Selection Optimization
```bash
# Task complexity analysis - Sonnet Default
default_model = "sonnet-4"  # Primary model for all tasks (5x cheaper, 3x faster)

# Only use Opus when explicitly requested with extended thinking
if task.has_extended_thinking && (task.level == "ultrathink" || task.level == "think_harder"):
    use_model("opus-4")  # Deep reasoning only when explicitly requested
else:
    use_model("sonnet-4")  # Default for all other tasks
```

### 3. Extended Thinking Integration (2025 Feature)
```bash
# Thinking budget controls for complex reasoning
"think" → Basic analysis (current default)
    - Standard reasoning for routine tasks
    - Quick decision making and implementation

"think hard" → Medium complexity analysis
    - Multi-step problem solving
    - Architecture decision evaluation
    - Complex debugging scenarios

"think harder" → Deep analysis with expanded reasoning
    - System design and trade-off analysis
    - Complex security threat modeling
    - Multi-variable optimization problems

"ultrathink" → Maximum reasoning budget
    - Enterprise architecture planning
    - Complex integration challenges
    - Critical security analysis with multiple attack vectors
    - Performance optimization across multiple systems

# Integration with existing commands:
/plan + "think harder" → Architecture decisions with deep analysis
/check + "ultrathink" → Comprehensive security and quality analysis
/sync + "think hard" → Complex merge conflict resolution
/learn + "ultrathink" → Pattern analysis across large codebases
```

### 4. Parallel Execution Patterns
```bash
# Always parallel
Bash: git status & git diff & git log --oneline -10
Glob: **/*.ts && **/*.test.ts && **/*.spec.ts
Task: Multiple file reads, searches, or analysis

# Intelligent batching
- Group related operations for efficiency
- Delegate complex searches to sub-agents
- Minimize round trips with comprehensive queries
```

### 5. Enhanced Context Management (2025 Optimization)
```bash
# Advanced Context Efficiency Strategies

## /clear Usage Patterns (Critical for Token Optimization)
- After every major task completion → /clear to reset context
- Before switching project contexts → /clear to prevent confusion
- When conversation exceeds 50 tool calls → /clear for performance
- After completing complex debugging → /clear to start fresh

## Hierarchical CLAUDE.md Support
Global:     ~/.claude/CLAUDE.md           # System-wide preferences and MCP config
Project:    /project/.claude/CLAUDE.md    # Project-specific patterns and standards  
Directory:  /project/src/.claude/CLAUDE.md # Component-specific guidelines
Priority:   Directory > Project > Global   # Most specific takes precedence

## Context Compaction Strategies
Manual Compaction:
  - Use /compact command before complex analysis
  - Summarize large conversations before continuing
  - Archive completed work to reduce active context

Automatic Compaction (via Hooks):
  - PreCompact hook triggers before reaching limits
  - Preserve critical context while removing verbose details
  - Maintain command history and key decisions

## Token Optimization Techniques
Smart Context Loading:
  - Load only relevant files for current task
  - Use file summaries for large codebases
  - Implement lazy loading for documentation

Context Preservation:
  - Save critical patterns to Obsidian MCP
  - Use GitHub MCP for persistent issue tracking  
  - Leverage Linear MCP for project continuity

Performance Monitoring:
  - Track token usage per command
  - Monitor context efficiency ratios
  - Optimize based on usage patterns
```

## Container-First Development

### Automatic Environment Detection
```yaml
# Per-worktree isolation with auto-detection
- .devcontainer/: VS Code integration
- docker-compose.yml: Service orchestration
- Kubernetes: Production deployment
- Environment variables: Automatic namespace isolation
```

### Intelligent Container Orchestration
```bash
# Auto-configure based on detected stack
detect_stack() -> configure_containers() -> isolate_worktrees()
- Node.js: npm/yarn/pnpm detection + optimal base image
- Python: venv/poetry/pipenv + dependency caching
- Go: Module vendoring + build optimization
- Rust: Cargo workspace + incremental compilation
```

## Advanced Quality Gates

### Security-First Validation
```bash
# Automated security scanning
- Secret detection: Pre-commit hooks + GitLeaks
- Dependency audit: Real-time CVE monitoring via web_search
- Container security: Trivy + Grype automated scanning
- Compliance: SOC 2, GDPR, OWASP automated checks
```

### Performance Optimization
```bash
# Intelligent performance monitoring
- Bundle size: Automatic optimization suggestions
- API latency: P99 < 200ms enforcement
- Memory usage: Leak detection + optimization
- Token efficiency: 68% cost reduction via smart routing
```

## Documentation Intelligence

### Automated Documentation Maintenance
```bash
# Critical: Always validate docs match implementation
1. Dependency changes → Auto-update installation guides
2. API modifications → Regenerate endpoint docs
3. Configuration updates → Sync setup instructions
4. Breaking changes → Generate migration guides
```

### Knowledge Graph Integration
```bash
# Obsidian MCP for persistent knowledge
- Architecture decisions with rationale
- Performance benchmarks and trends
- Team patterns and optimizations
- Cost analysis and projections
```

## Emergency Procedures

### Instant Recovery (<30 seconds)
```bash
/backup --restore   # Encrypted cloud restoration
/sync --force       # Emergency branch synchronization
/check --security   # Zero-day vulnerability scan
/install --rollback # MCP server recovery
```

### Intelligent Troubleshooting
```bash
# Self-healing patterns
1. Context corruption → Auto-detect + restore
2. Performance degradation → Profile + optimize
3. Security breach → Isolate + remediate + notify
4. Cost anomaly → Alert + throttle + analyze
```

## Latest Claude Code Capabilities (2025 Features)

### IDE Integration
```bash
# VS Code Extension
- Real-time Claude integration in editor
- Context-aware code completion and review
- Background processing for large codebases
- Inline documentation and explanation

# JetBrains Integration  
- Native plugin for IntelliJ, PyCharm, WebStorm
- Debugging assistance and error analysis
- Refactoring suggestions and code optimization
- Project-aware context loading

# Configuration:
{
  "claude.enableIDEIntegration": true,
  "claude.backgroundProcessing": true,
  "claude.contextAwareness": "project"
}
```

### Headless Mode & Automation
```bash
# GitHub Actions Integration
name: Claude Code CI/CD
on: [push, pull_request]
jobs:
  claude-analysis:
    runs-on: ubuntu-latest
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          commands: '/check --security --performance'
          api-key: ${{ secrets.ANTHROPIC_API_KEY }}

# Headless CLI Usage
claude --headless --command="/plan architecture refactor" --output=json
claude --headless --batch-file=commands.txt --log-level=debug

# Background Processing
- Continuous monitoring of code changes
- Automated documentation updates  
- Real-time security vulnerability scanning
- Performance optimization suggestions
```

### Claude Code SDK
```bash
# SDK Integration Patterns
import { ClaudeCode } from '@anthropic-ai/claude-code-sdk';

const claude = new ClaudeCode({
  apiKey: process.env.ANTHROPIC_API_KEY,
  project: '~/.claude',
  enableMCP: true
});

// Background analysis
await claude.analyze({
  path: './src',
  commands: ['/check', '/test'],
  continuous: true
});

// Multi-agent coordination
const codeWriter = claude.agent('code-writer');
const reviewer = claude.agent('reviewer');  
const result = await claude.collaborate([codeWriter, reviewer]);
```

### Team Collaboration Features
```bash
# Shared Configuration Management
# .mcp.json (checked into repo)
{
  "servers": {
    "github": { "enabled": true },
    "linear": { "enabled": true, "team": "engineering" }
  },
  "shared_commands": ["./claude/commands/"],
  "team_standards": "./claude/TEAM_STANDARDS.md"
}

# Cross-Session Context Sharing
- Shared project knowledge via Obsidian MCP
- Team coding standards enforcement
- Consistent tool configuration across developers
- Collaborative debugging and pair programming support
```

## Cost & Performance Metrics

### Token Optimization (68% reduction)
```bash
# Smart model routing saves $800/month
- All tasks: Sonnet 4 (95% of requests) - Primary model
- Extended reasoning: Opus 4 (5% of requests) - Only when explicitly requested
- Web search: Only for rapidly changing info
```

### Success Metrics
- **Efficiency**: 60% faster task completion via parallelization
- **Quality**: 95% first-time success rate
- **Security**: Zero vulnerabilities in production
- **Cost**: $1200 → $400/month (68% reduction)
- **Uptime**: 99.9% availability with auto-recovery

## Continuous Learning Loop

### Weekly Optimization Cycle
```bash
/learn --analyze    # Pattern recognition + anomaly detection
/learn --research   # MCP ecosystem + best practices scan
/learn --optimize   # Apply improvements + measure impact
/learn --report     # Generate executive summary + ROI
```

### Predictive Optimization
```bash
# AI-powered prediction and prevention
- Anticipate bottlenecks before they occur
- Suggest optimizations based on usage patterns
- Auto-scale resources based on demand
- Predict and prevent security vulnerabilities
```

### Team Collaboration & Knowledge Sharing (2025 Patterns)
```bash
# Configuration Version Control
git init ~/.claude                    # Version control Claude configurations
git add commands/ hooks/ settings.json CLAUDE.md
git commit -m "Team Claude setup"
git push origin claude-config         # Share with team

# Shared Command Libraries
team_commands/
├── frontend/           # Frontend-specific commands
├── backend/            # Backend-specific commands  
├── devops/             # Infrastructure commands
└── shared/             # Cross-team commands

# Knowledge Management Integration
obsidian_knowledge/
├── architecture_decisions/   # ADRs with Claude analysis
├── debugging_patterns/       # Solved problems and solutions
├── team_workflows/          # Standardized development flows
└── claude_optimizations/    # Performance improvements

# Collaborative Learning Patterns
/learn --team-analyze       # Aggregate team usage patterns
/learn --share-insights     # Publish learnings to team knowledge base
/learn --benchmark-team     # Compare individual vs team performance
/learn --sync-standards     # Update team coding standards

# Cross-Session Knowledge Preservation
- Linear MCP: Project continuity across team members
- GitHub MCP: Persistent issue and PR context
- Obsidian MCP: Shared architectural knowledge
- Claude Historian: Team conversation analysis

# Quality Gates & Standards Enforcement
pre_commit_hooks:
  - /check --security --team-standards
  - /test --coverage --team-requirements
  - Claude code review against team guidelines

team_metrics:
  - Code quality consistency across team
  - Claude usage efficiency benchmarks
  - Knowledge sharing effectiveness scores
```

---

**Core Philosophy**: Intelligence over effort. Prevention over correction. Automation over repetition.

**Remember**: You have access to web_search for current info, analysis tool for complex calculations, and 20 MCP servers for specialized tasks. Use them intelligently based on task requirements.

## Global MCP Configuration

**CRITICAL**: All MCP servers are now configured globally in `~/.claude/.claude.json` at the root level:
- **Global Access**: MCP servers work from any directory system-wide  
- **Environment Variables**: All API keys use `${VAR_NAME}` format from `~/.claude/.env`
- **No Hardcoded Keys**: Zero secrets in configuration files
- **Project Independence**: No project-specific MCP configurations needed

## Command Awareness

**IMPORTANT:** Always read and be aware of commands in `~/.claude/commands/` directory:
- Read command files to understand available slash commands
- Extract one-line descriptions from each command's purpose  
- Reference these when users ask about available commands or workflows

## Memory Repository

- This is a way of seeing where we save memories.