# /check - Comprehensive Quality Assurance

---
argument-hint: "[--security] [--performance] [--docs] [--compliance] [--full] [--fix]"
---

## Overview
Revolutionary quality assurance system integrating all 20 MCP servers, hybrid Claude 4 intelligence, and enterprise-grade validation. Consolidates 7 legacy commands: check.md, docs.md, security-audit.md, perf.md, clean.md, optimize.md, review.md.

## Usage
```bash
/check [--security] [--performance] [--docs] [--compliance] [--full] [--fix]
```

## Hybrid Intelligence Architecture

### 1. Claude Large-Scale Analysis
```bash
# Repository-wide analysis with massive token window
gemini: "analyze @. repository for quality issues across all files"
gemini: "review @package.json @requirements.txt for dependency vulnerabilities"
gemini: "scan @docs/ @README.md for documentation completeness"
```

### 2. Claude Strategic Validation
```bash
# Sophisticated quality assessment and remediation
- Architecture pattern validation
- Security threat modeling
- Performance bottleneck analysis
- Technical debt prioritization
```

### 3. MCP Server Orchestration
All 20 MCP servers coordinated for comprehensive validation:
- **Security**: GitHub, Brave Search, Perplexity for vulnerability research
- **Performance**: GCP, Sequential-thinking for bottleneck analysis
- **Documentation**: Context7, Obsidian for knowledge validation
- **Testing**: Playwright, tmux for automated quality gates
- **Development**: Apple MCP, Figma for design-dev consistency

## Process

### Phase 1: Pre-Commit Quality Gates (Claude-Powered)
1. **Massive Codebase Scan**
   ```bash
   gemini: "scan @. for critical issues: secrets, TODOs, console.logs, hardcoded values"
   gemini: "analyze @src/ @lib/ for code smells and anti-patterns"
   gemini: "review @tests/ for coverage gaps and quality issues"
   ```

2. **Dependency & Configuration Audit**
   ```bash
   gemini: "audit @package.json @Cargo.toml @requirements.txt for vulnerabilities"
   gemini: "validate @.env.example @config/ for security misconfigurations"
   gemini: "check @docker-compose.yml @Dockerfile for container security"
   ```

### Phase 2: Enterprise Security Validation (MCP Integration)
1. **SAST & Vulnerability Scanning**
   ```bash
   # GitHub MCP: Repository security analysis
   mcp__github__search_code: "API_KEY|SECRET|PASSWORD|TOKEN"
   
   # Brave Search MCP: CVE and vulnerability research
   mcp__brave-search__brave_web_search: "CVE-2024 {dependency_name}"
   
   # Perplexity MCP: Latest security intelligence
   mcp__perplexity__perplexity_ask: "latest security vulnerabilities {tech_stack}"
   ```

2. **Container & Infrastructure Security**
   ```bash
   # Detect container security issues
   - Dockerfile best practices validation
   - Base image vulnerability scanning
   - Secret detection in container layers
   - Network security policy validation
   ```

### Phase 3: Performance & Optimization (Claude Intelligence)
1. **Performance Bottleneck Analysis**
   ```xml
   <performance_audit>
     <context>Current application performance profile</context>
     <objective>Identify and prioritize performance optimizations</objective>
     <thinking>Analyze critical paths, database queries, network calls</thinking>
     <mcp_integration>GCP for cloud performance, Sequential-thinking for analysis</mcp_integration>
     <validation>Performance regression prevention</validation>
   </performance_audit>
   ```

2. **Resource Optimization**
   ```bash
   # GCP MCP: Cloud resource analysis
   mcp__gcp-mcp__get-cost-forecast: Predict performance impact costs
   
   # Sequential-thinking MCP: Complex performance reasoning
   mcp__sequential-thinking__sequentialthinking: "Analyze performance bottlenecks"
   ```

### Phase 4: Documentation & Compliance (Hybrid Analysis)
1. **Documentation Completeness**
   ```bash
   # Claude: Large-scale documentation scan
   gemini: "analyze @docs/ @README.md for completeness vs @src/ features"
   
   # Context7 MCP: Best practice documentation patterns
   mcp__context7__get-library-docs: Industry standard documentation examples
   
   # Obsidian MCP: Knowledge graph validation
   mcp__obsidian__obsidian_complex_search: Documentation consistency check
   ```

2. **Compliance Framework Validation**
   - SOC 2 controls implementation check
   - GDPR data handling validation
   - API security standards (OWASP)
   - Accessibility compliance (WCAG 2.1 AA)

## Command Options

### `--security` - Comprehensive Security Audit
**Hybrid Workflow:**
1. **Claude**: Repository-wide secret and vulnerability scan
2. **GitHub MCP**: Code security analysis and dependency audit
3. **Brave/Perplexity MCP**: Latest threat intelligence research
4. **Claude**: Security architecture review and threat modeling

**Validation Checks:**
- Secret detection (API keys, passwords, tokens)
- Dependency vulnerability audit (CVE scanning)
- Container security best practices
- Authentication/authorization implementation
- OWASP Top 10 compliance

### `--performance` - Performance Analysis & Optimization
**Hybrid Workflow:**
1. **Claude**: Performance bottleneck identification across codebase
2. **GCP MCP**: Cloud resource optimization analysis
3. **Sequential-thinking MCP**: Complex performance pattern analysis
4. **Claude**: Optimization strategy and implementation plan

**Performance Gates:**
- Bundle size analysis and optimization
- Database query performance validation
- API response time benchmarks
- Memory usage pattern analysis
- Critical path performance validation

### `--docs` - Documentation Quality Assurance
**Hybrid Workflow:**
1. **Claude**: Documentation completeness vs feature implementation
2. **Context7 MCP**: Industry best practice comparison
3. **Obsidian MCP**: Knowledge consistency validation
4. **Claude**: Documentation strategy and gap analysis

**Documentation Validation:**
- API documentation completeness
- Setup/installation instruction accuracy
- Code comment quality and coverage
- Architecture decision records (ADRs)
- User guide completeness

### `--compliance` - Enterprise Compliance Validation
**Hybrid Workflow:**
1. **Claude**: Compliance framework implementation scan
2. **GitHub MCP**: Policy as code validation
3. **Apple MCP**: Local compliance tool integration
4. **Claude**: Compliance gap analysis and remediation

**Compliance Frameworks:**
- SOC 2 Type II controls
- ISO 27001 information security
- GDPR data protection requirements
- HIPAA healthcare compliance (if applicable)
- Industry-specific regulations

### `--full` - Complete Quality Audit
**Comprehensive Analysis:**
- All security, performance, documentation, and compliance checks
- Cross-cutting concern validation
- Integration testing quality gates
- Deployment readiness assessment

### `--fix` - Automated Remediation
**Intelligent Auto-Fix:**
1. **Claude**: Generate fix templates for common issues
2. **Claude**: Implement sophisticated fixes with context awareness
3. **GitHub MCP**: Create automated pull requests for fixes
4. **Validation**: Re-run checks to confirm fix effectiveness

## Container & Environment Integration

### Development Container Validation
```yaml
# Dev container quality checks
services:
  quality-audit:
    build: .
    command: |
      # Security scanning
      trivy fs . --security-checks vuln,config,secret
      
      # Performance profiling
      clinic doctor -- node app.js
      
      # Code quality
      sonarqube-scanner
    environment:
      - SECURITY_SCAN=true
      - PERFORMANCE_PROFILE=true
```

### CI/CD Pipeline Integration
```bash
# GitHub Actions quality gates
- Security: CodeQL, Dependabot, secret scanning
- Performance: Lighthouse CI, bundle size analysis
- Documentation: Vale, markdownlint, spell checking
- Compliance: Policy as code validation
```

## Quality Gates & Thresholds

### Critical Blocking Issues
- **Security**: No secrets, no critical CVEs, no OWASP violations
- **Performance**: <200ms API response, <5s page load, <50MB bundle
- **Documentation**: 100% API coverage, accurate setup instructions
- **Compliance**: Required framework controls implemented

### Warning Thresholds
- **Technical Debt**: <10% code complexity violations
- **Test Coverage**: >80% line coverage, >70% branch coverage
- **Dependencies**: No outdated major versions
- **Accessibility**: WCAG 2.1 AA compliance for UI components

## MCP Server Coordination

### Security Intelligence Network
```bash
# Multi-source security validation
GitHub MCP → Repository security scanning
Brave Search MCP → CVE and threat research
Perplexity MCP → Latest security intelligence
Apple MCP → Local security tool integration
```

### Performance Analysis Stack
```bash
# Comprehensive performance monitoring
GCP MCP → Cloud performance metrics
Sequential-thinking MCP → Complex bottleneck analysis
tmux MCP → Local performance testing orchestration
Playwright MCP → Frontend performance validation
```

### Documentation & Knowledge Management
```bash
# Documentation quality ecosystem
Context7 MCP → Industry best practices
Obsidian MCP → Knowledge graph validation
GitHub MCP → Documentation CI/CD
Magic MCP → UI documentation consistency
```

## Integration with Other Commands

### Seamless Workflow Coordination
- **`/test`**: Quality validation before test execution
- **`/commit`**: Pre-commit quality gates and validation
- **`/sync`**: Cross-worktree quality consistency
- **`/plan`**: Quality requirements in architecture planning

## Success Criteria

### Quality Metrics
- [ ] **Zero Critical Issues**: No blocking security, performance, or compliance violations
- [ ] **Documentation Complete**: 100% API documentation, accurate setup guides
- [ ] **Performance Validated**: All thresholds met, regression prevention active
- [ ] **Security Assured**: Comprehensive threat model, vulnerability management
- [ ] **Compliance Ready**: Framework requirements satisfied, audit trail complete
- [ ] **Automated Quality**: CI/CD pipeline with quality gates operational

### MCP Integration Success
- [ ] **All 19 Servers**: Successfully coordinated for quality validation
- [ ] **Hybrid Intelligence**: Optimal Claude analysis + strategic execution
- [ ] **Container Aware**: Dev container and production environment validation
- [ ] **Enterprise Ready**: Security, compliance, and governance controls active

---

**Philosophy**: Quality is not optional. Security is paramount. Performance is user experience. Documentation is code sustainability. Compliance is business continuity.