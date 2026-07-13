# /plan - Intelligent Architecture Planning with Hybrid Intelligence

---
argument-hint: "[feature/task description] [--scope=feature|project|architecture] [--model=opus|claude|auto]"
---

## Overview
Revolutionary architecture planning system combining Opus-level deep reasoning with comprehensive MCP integration and hybrid Claude 4 intelligence. Automatically switches to optimal models for complex planning and strategic decision-making with optional Claude for massive context analysis.

## Usage
```bash
/plan [feature/task description] [--scope=feature|project|architecture] [--model=opus|claude|auto]
```

## Hybrid Intelligence Architecture

### 1. Claude Repository Context Loading
```bash
# Massive context window for complete project understanding
gemini: "analyze @. repository for current architecture and patterns"
gemini: "review @docs/ @CLAUDE.md for existing plans and decisions"
gemini: "scan @src/ @lib/ for implementation patterns and constraints"
```

### 2. Opus Strategic Planning (Auto-Switch)
```bash
# Deep reasoning for complex architectural decisions
- Multi-dimensional analysis of approaches and trade-offs
- Comprehensive risk assessment and mitigation strategies
- Scalability and performance impact modeling
- Security and compliance requirement integration
```

### 3. Claude Implementation Strategy
```bash
# Sophisticated execution planning and optimization
- Step-by-step implementation roadmap
- Integration point identification and validation
- Quality gate and testing strategy
- Team coordination and delivery planning
```

## Process

### Phase 1: Context Intelligence Gathering (Claude-Powered)
1. **Complete Project Analysis**
   ```bash
   gemini: "analyze entire @. codebase for architecture patterns and constraints"
   gemini: "review @package.json @requirements.txt for technology stack"
   gemini: "scan @docs/ @README.md for project context and requirements"
   gemini: "examine @tests/ for existing testing patterns and coverage"
   ```

2. **Historical Decision Context**
   ```bash
   # Obsidian MCP: Previous planning decisions
   mcp__obsidian__obsidian_complex_search: {
     "glob": ["*.md", { "var": "path" }],
     "and": [
       { "regexp": ["## Plan:", { "var": "content" }] },
       { "regexp": ["Architecture|Design", { "var": "content" }] }
     ]
   }
   
   # GitHub MCP: Repository history and decisions
   mcp__github__search_code: "TODO|FIXME|NOTE"
   ```

### Phase 2: Strategic Planning (Opus Intelligence)
1. **Automated Model Selection**
   ```xml
   <planning_strategy>
     <context>Complete project state and feature requirements</context>
     <objective>Optimal architecture plan with multiple approaches</objective>
     <thinking>Deep analysis of trade-offs, scalability, and complexity</thinking>
     <model_selection>Auto-switch to Opus for complex architectural decisions</model_selection>
     <validation>Comprehensive risk and feasibility assessment</validation>
   </planning_strategy>
   ```

2. **Multi-Dimensional Analysis**
   ```bash
   # Opus reasoning for complex planning
   - Approach comparison: Fast vs Scalable vs Optimized
   - Technology evaluation: Stack compatibility and trade-offs
   - Security assessment: Threat modeling and compliance
   - Performance modeling: Scalability and resource requirements
   - Team impact: Skill requirements and delivery timeline
   ```

### Phase 3: Implementation Strategy (Claude + MCP Integration)
1. **Detailed Execution Planning**
   ```bash
   # Sequential-thinking MCP: Complex implementation logic
   mcp__sequential-thinking__sequentialthinking: "Break down implementation steps"
   
   # Context7 MCP: Best practice validation
   mcp__context7__get-library-docs: Technology-specific implementation guides
   
   # Linear MCP: Project management integration
   mcp__linear__create_issue: Automatic issue creation for plan steps
   ```

2. **Quality and Validation Strategy**
   ```bash
   # Integration with other commands
   - /test strategy: Comprehensive testing approach
   - /check integration: Quality gates and validation
   - /sync coordination: Multi-worktree development planning
   ```

## Command Options

### `--scope=feature` - Feature-Level Planning
**Fast Planning Mode:**
- Sonnet-powered analysis for straightforward features
- Quick approach comparison and recommendation
- Integration with existing architecture patterns
- Focused implementation steps

### `--scope=project` - Project-Level Architecture
**Comprehensive Planning Mode:**
- Automatic Opus model activation for deep analysis
- Multi-approach evaluation with detailed trade-offs
- Cross-cutting concern integration
- Long-term scalability and maintenance planning

### `--scope=architecture` - System Architecture Planning
**Strategic Planning Mode:**
- Opus + Claude hybrid intelligence for complex systems (Claude optional for massive context)
- Enterprise-level scalability and security planning
- Technology stack evaluation and migration planning
- Performance and reliability modeling

### `--model=auto` - Intelligent Model Selection (Default)
**Adaptive Intelligence:**
```bash
# Automatic model selection based on complexity
Simple features → Sonnet (fast, efficient)
Complex features → Claude (balanced reasoning)
Architecture decisions → Opus (deep analysis)
Large codebases → Claude Opus (deep analysis) with optional Claude for massive context
```

## MCP Server Integration

### Project Management & Documentation
```bash
# Linear MCP: Issue and project tracking
mcp__linear__list_projects: Link planning to existing projects
mcp__linear__create_issue: Auto-create implementation tasks

# Obsidian MCP: Knowledge management
mcp__obsidian__obsidian_append_content: "Planning/$feature.md"
mcp__obsidian__obsidian_complex_search: Historical decision patterns

# GitHub MCP: Repository integration
mcp__github__create_issue: Implementation tracking
mcp__github__search_code: Existing pattern analysis
```

### Research & Intelligence
```bash
# Perplexity MCP: Latest best practices research
mcp__perplexity__perplexity_ask: "Latest architectural patterns for {technology}"

# Brave Search MCP: Technology research
mcp__brave-search__brave_web_search: "Performance benchmarks {approach}"

# Context7 MCP: Documentation and guides
mcp__context7__get-library-docs: Industry standard implementations
```

### Development Environment
```bash
# Apple MCP: Local development integration
mcp__apple-mcp__notes: "Architecture Plan: $feature"
mcp__apple-mcp__reminders: "Review architecture decision in 1 month"

# tmux MCP: Development session preparation
mcp__tmux__create-session: "architecture-$feature"
```

## Advanced Planning Features

### Intelligent Approach Analysis
```markdown
## Plan: [Feature] - [YYYY-MM-DD]

### Requirements Analysis (Claude-Powered)
- **Functional**: Core feature requirements from codebase analysis
- **Non-Functional**: Performance, security, scalability from project context
- **Constraints**: Technology stack, team skills, timeline from repository
- **Integration**: Existing system touchpoints from architecture analysis

### Approach Matrix (Opus-Evaluated)
| Approach | Complexity | Performance | Scalability | Maintainability | Risk |
|----------|------------|-------------|-------------|-----------------|------|
| **Fast** | O(n) | Good | Limited | High | Low |
| **Scalable** | O(log n) | Better | High | Medium | Medium |
| **Optimized** | O(1) | Best | Maximum | Low | High |

### Technology Impact Assessment
- **Dependencies**: New vs existing libraries
- **Security**: Threat model and compliance impact
- **Performance**: Benchmark targets and regression testing
- **Team**: Skill requirements and learning curve
```

### Container & Infrastructure Planning
```yaml
# Container orchestration planning
planning:
  containers:
    development:
      image: "node:18-alpine"
      environment:
        - FEATURE_FLAG_${FEATURE}=true
      resources:
        limits:
          memory: "1Gi"
          cpu: "500m"
    
    testing:
      extends: development
      command: "npm run test:feature:${FEATURE}"
      environment:
        - NODE_ENV=test
    
    production:
      extends: development
      environment:
        - NODE_ENV=production
        - FEATURE_ROLLOUT=${FEATURE}=gradual
```

### Cross-Command Integration Planning
```bash
# Comprehensive workflow planning
/plan integration:
  - /test: Define test strategy and coverage targets
  - /check: Establish quality gates and validation criteria
  - /sync: Plan multi-worktree development workflow
  - /commit: Define commit strategy and PR structure
```

## Quality Gates & Success Criteria

### Planning Quality Metrics
- **Completeness**: All approaches evaluated with trade-offs
- **Feasibility**: Technical and resource constraints validated
- **Risk Assessment**: Potential issues identified with mitigations
- **Integration**: Compatibility with existing architecture verified
- **Documentation**: Clear implementation roadmap documented

### MCP Integration Validation
- **Research Complete**: Latest best practices incorporated
- **Project Management**: Issues and tracking configured
- **Documentation**: Knowledge base updated with decisions
- **Team Coordination**: Notifications and collaboration setup

## Output Formats

### Feature Planning Template
```markdown
## Plan: [Feature] - [YYYY-MM-DD]

### Context (Claude Analysis)
- Repository state and existing patterns
- Technology stack and constraints
- Team capacity and timeline

### Requirements (Comprehensive)
- Functional requirements with acceptance criteria
- Non-functional requirements with metrics
- Integration requirements with touchpoints
- Compliance and security requirements

### Approaches (Opus Evaluation)
1. **Rapid Prototype** - Quick validation approach
2. **Production Ready** - Scalable implementation
3. **Future Proof** - Long-term optimized solution

### Recommendation (Strategic Decision)
**Selected**: [Approach] because [detailed reasoning]

### Implementation Roadmap
- [ ] Phase 1: Foundation and core functionality
- [ ] Phase 2: Integration and testing
- [ ] Phase 3: Optimization and deployment
- [ ] Phase 4: Monitoring and iteration

### Success Criteria
- **Performance**: P99 latency < 200ms
- **Reliability**: 99.9% uptime SLA
- **Security**: OWASP Top 10 compliance
- **Quality**: 90% test coverage

### Risk Mitigation
| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Technical debt | High | Medium | Refactoring sprint |
| Performance regression | Medium | Low | Benchmark testing |
| Security vulnerability | High | Low | Security review |
```

## Integration with Other Commands

### Seamless Workflow Preparation
- **`/test`**: Testing strategy defined in planning phase
- **`/check`**: Quality gates established during planning
- **`/sync`**: Multi-worktree coordination planned
- **`/commit`**: Implementation milestones and PR strategy

## Success Criteria

### Planning Excellence
- [ ] **Comprehensive Analysis**: All approaches evaluated with trade-offs
- [ ] **Strategic Decision**: Optimal approach selected with clear reasoning
- [ ] **Implementation Ready**: Detailed roadmap with clear steps
- [ ] **Risk Managed**: Potential issues identified with mitigations
- [ ] **Quality Assured**: Success criteria and validation defined

### MCP Coordination Success
- [ ] **Research Integrated**: Latest best practices incorporated
- [ ] **Documentation Complete**: Knowledge base updated with decisions
- [ ] **Project Management**: Issues and tracking configured
- [ ] **Team Aligned**: Clear communication and coordination plan

---

**Philosophy**: Planning prevents poor performance. Intelligence informs intuition. Research reduces risk. Documentation drives decisions. Collaboration creates consensus.