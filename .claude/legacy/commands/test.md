# /test - Intelligent Test-Driven Development

---
argument-hint: "[--analyze] [--generate] [--coverage] [--e2e] [--performance]"
---

## Overview
Revolutionary TDD implementation combining Claude's advanced reasoning for complex test strategy and human behavior simulation with Opus 4's large-scale test analysis capabilities.

## Usage
```bash
/test [--analyze] [--generate] [--coverage] [--e2e] [--performance]
```

## Hybrid Intelligence Workflow

### 1. Opus Analysis Phase (Large-Scale Understanding)
```bash
# Opus 4 handles massive file analysis
- Analyze existing tests: "@tests/" and "@spec/"
- Repository structure: "@src/" for testable components  
- Package analysis: "@package.json" for test frameworks
- Configuration review: "@jest.config.js", "@vitest.config.ts"
```

### 2. Sonnet Strategy Phase (Efficient Execution)
```bash
# Sonnet 4 provides efficient test implementation
- Test-driven development workflow execution
- Human behavior simulation implementation
- Edge case test generation
- Coverage validation and reporting
```

### 3. MCP Integration
- **Playwright MCP**: Browser automation and E2E testing
- **GitHub MCP**: CI/CD integration and test result tracking
- **Sequential-thinking MCP**: Complex test logic reasoning
- **Apple MCP**: Local testing environment integration
- **tmux MCP**: Test runner orchestration

## Process

### Phase 1: Repository Analysis (Opus-Powered)
1. **Large-Scale Test Discovery**
   ```bash
   opus: "analyze @tests/ @spec/ @__tests__/ and catalog all existing tests"
   opus: "review @src/ and identify untested components"
   opus: "check @package.json for testing frameworks and scripts"
   ```

2. **Coverage Gap Analysis**
   ```bash
   opus: "compare @src/ structure with @tests/ to identify coverage gaps"
   gemini: "analyze @jest.coverage.json or similar for quantitative gaps"
   ```

### Phase 2: Test Strategy Design (Claude Intelligence)
1. **TDD Workflow Planning**
   - RED → GREEN → REFACTOR cycle optimization
   - Test pyramid strategy (unit → integration → E2E)
   - Human behavior simulation requirements
   - Performance regression prevention

2. **Advanced Test Patterns**
   ```xml
   <test_strategy>
     <context>Current testing maturity and coverage</context>
     <objective>Comprehensive test suite with human behavior simulation</objective>
     <thinking>Step-by-step TDD approach with edge case coverage</thinking>
     <mcp_integration>Playwright for E2E, GitHub for CI automation</mcp_integration>
     <validation>Coverage thresholds and quality gates</validation>
   </test_strategy>
   ```

### Phase 3: Intelligent Test Generation
1. **Opus Template Generation**
   ```bash
   # Generate comprehensive test boilerplate
   gemini: "create test templates for @src/components/ using project patterns"
   gemini: "generate test data fixtures based on @src/types/"
   ```

2. **Claude Advanced Logic**
   - Human behavior simulation scenarios
   - Complex edge case testing
   - Performance regression tests
   - Accessibility testing integration

### Phase 4: Container-Aware Test Environment
1. **Environment Detection**
   - Auto-detect test containers in docker-compose.yml
   - Configure test databases and services
   - Set up isolated test environments per worktree

2. **CI/CD Integration**
   ```bash
   # GitHub MCP integration
   - Configure GitHub Actions test workflows
   - Set up test result reporting and badges
   - Implement automated quality gates
   ```

## Command Options

### `--analyze` - Comprehensive Test Analysis
**Hybrid Workflow:**
1. **Opus**: Analyze entire test suite with `@tests/` 
2. **Claude**: Identify patterns, gaps, and improvement opportunities
3. **Output**: Detailed test quality report with recommendations

### `--generate` - Intelligent Test Generation  
**Hybrid Workflow:**
1. **Opus**: Generate test templates based on `@src/` analysis
2. **Claude**: Add sophisticated test logic and edge cases
3. **Output**: Complete test files ready for implementation

### `--coverage` - Coverage Analysis & Improvement
**Hybrid Workflow:**
1. **Opus**: Parse coverage reports and identify uncovered code
2. **Claude**: Prioritize coverage improvements and design test strategy
3. **MCP Integration**: GitHub for coverage tracking and reporting

### `--e2e` - End-to-End Test Setup
**Hybrid Workflow:**
1. **Opus**: Analyze UI components and user flows
2. **Claude**: Design human behavior simulation scenarios
3. **Playwright MCP**: Implement browser automation tests

### `--performance` - Performance Regression Testing
**Hybrid Workflow:**
1. **Opus**: Analyze performance-critical code paths
2. **Claude**: Design performance test scenarios and thresholds
3. **Container Integration**: Set up performance testing environments

## Human Behavior Simulation

### Advanced User Journey Testing
```javascript
// Claude-generated sophisticated test scenarios
describe('Human Behavior Simulation', () => {
  it('simulates impatient user rapid clicking', async () => {
    // Test rapid successive clicks and race conditions
  });
  
  it('simulates user multitasking with tab switching', async () => {
    // Test focus/blur events and state preservation
  });
  
  it('simulates slow network conditions', async () => {
    // Test loading states and timeout handling
  });
});
```

### Edge Case Coverage
- Network failures and retry logic
- Concurrent user actions and race conditions
- Browser compatibility and accessibility
- Mobile device simulation and touch events

## Container Integration

### Test Environment Isolation
```yaml
# Docker Compose test services
services:
  test-db:
    image: postgres:15
    container_name: "${PROJECT_NAME}-${WORKTREE_NAME}-test-db"
    environment:
      - POSTGRES_DB=${PROJECT_NAME}_test
    ports:
      - "${TEST_DB_PORT:-5433}:5432"
```

### Performance Testing Containers
```yaml
services:
  performance-test:
    build: .
    environment:
      - NODE_ENV=test
      - PERFORMANCE_MODE=true
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
```

## Quality Gates

### Automated Validation
- **Minimum Coverage**: 80% line coverage, 70% branch coverage
- **Performance Thresholds**: Response time < 200ms for critical paths
- **Accessibility**: WCAG 2.1 AA compliance for UI components
- **Security**: No hardcoded secrets or vulnerabilities in test code

### MCP Validation Pipeline
1. **GitHub MCP**: Run tests in CI/CD and validate quality gates
2. **Playwright MCP**: Execute E2E tests and visual regression checks
3. **Sequential-thinking MCP**: Analyze test failure patterns and suggest fixes

## Integration with Other Commands

### Seamless Workflow Integration
- **`/check`**: Validate test quality and coverage as part of QA
- **`/commit`**: Include test status in commit message generation
- **`/sync`**: Coordinate test environments across worktrees
- **`/plan`**: Include testing strategy in architecture planning

## Best Practices

### Hybrid Intelligence Optimization
- **Start with Opus** for large-scale test analysis and template generation
- **Use Claude** for sophisticated test logic and human behavior simulation
- **Leverage MCP servers** for specialized testing tools and automation
- **Document patterns** for reuse across projects

### Test-Driven Development Excellence
- **Write tests first** before implementing features
- **Focus on behavior** rather than implementation details
- **Simulate real users** with human behavior patterns
- **Automate everything** with container and CI/CD integration

### Container-First Testing
- **Isolate test environments** per worktree and feature
- **Use consistent test data** with containerized databases
- **Enable parallel testing** with container orchestration
- **Monitor performance** in realistic container environments

## Error Handling

### Robust Test Execution
```bash
# Graceful failure handling
if ! test_command_succeeds; then
    log_failure_details
    suggest_remediation_steps
    continue_with_next_tests
fi
```

### MCP Server Fallbacks
- Fallback to local testing if Playwright MCP unavailable
- Alternative CI providers if GitHub MCP fails
- Local test runners if container services are down

## Success Criteria

- [ ] **Comprehensive Coverage**: >80% line coverage, >70% branch coverage
- [ ] **Human Behavior**: Realistic user interaction simulation
- [ ] **Performance**: Regression testing with automated thresholds
- [ ] **Container Integration**: Isolated test environments per worktree
- [ ] **CI/CD Automation**: Automated testing pipeline with quality gates
- [ ] **Hybrid Intelligence**: Optimal use of Opus analysis + Sonnet execution

---

**Philosophy**: Test behavior, not implementation. Simulate humans, not happy paths. Automate everything, fail fast, learn quickly.