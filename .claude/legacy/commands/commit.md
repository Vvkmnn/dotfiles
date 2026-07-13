# /commit - Intelligent Commit Generation with Context Analysis

---
argument-hint: "[description] [--sync-main] [--docs] [--auto-stage] [--worktree-context]"
---

## Overview
Smart commit generation that analyzes changes, creates multiple logical commits, and formats messages using your ~/.gitmessage template.

## Usage
```bash
/commit [description] [--sync-main] [--docs] [--auto-stage] [--worktree-context]
```

## Hybrid Intelligence Architecture

### 1. Context-Aware Change Analysis
```bash
# Analyze conversation and git changes for intelligent commits
- Review current conversation for work context and decisions made
- Analyze what was discussed, researched, or implemented recently  
- Detect file types and modification patterns from git status/diff
- Group related changes by scope and functionality
- Identify commit types with scope (FEAT(auth), FIX(api), DOCS(readme), etc.)
- Plan multiple atomic commits instead of one large commit
- NEVER use bare types - always include scope like FEAT(auth) not FEAT
- NEVER include "Claude Code", "Generated with", or AI tool references
- Include rich metadata: Linear tickets, GitHub issues, research links
- Add performance metrics, breaking changes, security implications
- Reference related PRs, RFCs, architectural decisions, and documentation
```

### 2. Smart Commit Chunking
```bash
# Break changes into logical, atomic commits
- Group related files by functionality and scope
- Separate feature code from tests and documentation
- Create focused commits that are easy to review
- Maintain clear commit boundaries and dependencies
```

### 3. Rich Context & Linking
Enhance commits with comprehensive references:
- **GitHub MCP**: Search and link related issues, PRs, and discussions
- **Linear MCP**: Connect to project tickets and milestones  
- **Issue Detection**: Scan commit content for bug fixes and feature references
- **Documentation Links**: Reference relevant docs, RFCs, and specifications
- **Historical Context**: Link to related commits and previous work

## Process

### Phase 1: Comprehensive Change Analysis (Parallel Intelligence)
1. **Repository State Understanding**
   ```bash
   # Parallel analysis of changes using multiple Bash calls
   git status & git diff --staged & git diff & git log --oneline -10
   
   # Read key files for context
   Read: package.json, README.md, CLAUDE.md (if exists)
   
   # Analyze modification patterns and group logical changes
   Glob: "**/*.ts" "**/*.js" "**/*.md" "**/*.json"
   ```

2. **Documentation Impact Assessment**
   ```bash
   # Critical: Always validate docs against implementation
   - Compare dependencies in package.json with README.md setup instructions
   - Identify missing setup instructions for new tools, libraries, databases
   - Check for outdated installation steps or incorrect descriptions
   - Ensure developer experience matches actual implementation
   - Validate badge versions and requirements match package.json
   ```

3. **Local Repository Style Analysis**
   ```bash
   # FIRST: Learn from existing commit patterns in this repo
   git log --oneline -10  # Analyze recent commit message format
   
   # Adapt to local conventions:
   - Follow existing commit style (FEAT(scope) vs feat(scope))
   - Match message structure and length patterns
   - Respect established scoping conventions
   - Use consistent bullet point formatting
   - Never include AI authoring references
   - Prioritize repository-specific guidelines over generic standards
   ```

### Phase 2: Intelligent Commit Strategy
1. **Logical Change Grouping**
   ```xml
   <commit_strategy>
     <context>Staged changes and repository state</context>
     <objective>Logical, reviewable commits with clear boundaries</objective>
     <thinking>Group related changes, separate concerns, maintain atomicity</thinking>
     <mcp_integration>GitHub for PR strategy, Linear for issue linking</mcp_integration>
     <validation>Security, performance, and documentation impact</validation>
   </commit_strategy>
   ```

2. **Security and Quality Validation**
   ```bash
   # Comprehensive pre-commit analysis
   - Secret detection in changed files
   - Sensitive file flagging (config, keys, tokens)
   - Breaking change identification
   - Performance regression analysis
   - Documentation completeness validation
   ```

3. **Code Quality Gates (Must Pass Before Commit)**
   ```bash
   # Automated quality validation - BLOCKS commit if fails
   
   ## Project Detection & Tool Selection
   auto_detect_project_type() {
     if [[ -f "package.json" ]]; then
       PROJECT_TYPE="nodejs"
       detect_package_manager()  # npm, yarn, pnpm, bun
     elif [[ -f "pyproject.toml" || -f "requirements.txt" ]]; then
       PROJECT_TYPE="python"
       detect_python_tools()    # ruff, black, mypy, flake8
     elif [[ -f "go.mod" ]]; then
       PROJECT_TYPE="go"
     elif [[ -f "Cargo.toml" ]]; then
       PROJECT_TYPE="rust"
     elif [[ -f "composer.json" ]]; then
       PROJECT_TYPE="php"
     fi
   }
   
   ## Quality Gate Execution (Parallel)
   run_quality_gates() {
     # Run all quality checks in parallel using multiple Bash calls
     run_linting() & run_type_checking() & run_build_validation() & 
     run_security_scan() & run_test_validation()
     
     # Wait for all to complete and collect results
     validate_all_gates_passed()
   }
   
   ## Quality Gate Details
   
   ### 1. Linting Validation (REQUIRED)
   - **Node.js**: npm run lint || yarn lint || pnpm lint || bun lint
   - **Python**: ruff check . || flake8 . || pylint src/
   - **Go**: go vet ./... && golint ./...
   - **Rust**: cargo clippy -- -D warnings
   - **TypeScript**: eslint src/ --ext .ts,.tsx
   
   ### 2. Type Checking (REQUIRED for typed languages)
   - **TypeScript**: tsc --noEmit || npm run type-check
   - **Python**: mypy . (if mypy.ini or pyproject.toml has mypy config)
   - **Go**: Built into go build
   - **Rust**: Built into cargo check
   
   ### 3. Build Validation (REQUIRED if build exists)
   - **Node.js**: npm run build || yarn build || pnpm build
   - **Python**: python -m build || pip install -e .
   - **Go**: go build ./...
   - **Rust**: cargo build
   - **Any**: make build (if Makefile exists)
   
   ### 4. Fast Test Validation (OPTIONAL - configurable)
   - **Unit tests only**: Run fast unit tests (< 30s)
   - **Changed files**: Test only files that changed
   - **Skip integration**: Avoid slow integration/e2e tests
   
   ### 5. Security Scan (REQUIRED)
   - **Secret detection**: gitLeaks, truffleHog, or gitleaks
   - **Dependency scan**: npm audit, safety check, cargo audit
   - **SAST**: semgrep, bandit, gosec (basic rules only)
   
   ## Quality Gate Failure Handling
   if quality_gates_fail; then
     echo "❌ COMMIT BLOCKED - Quality gates failed:"
     display_failure_summary()
     echo "🔧 Run these commands to fix issues:"
     suggest_fix_commands()
     echo "💡 Use 'git add' after fixes, then retry /commit"
     exit 1  # Block commit
   fi
   
   ## Quality Gate Success
   if quality_gates_pass; then
     echo "✅ All quality gates passed:"
     display_success_summary()
     echo "📝 Proceeding with commit generation..."
     # Continue to commit message generation
   fi
   ```

### Phase 3: MCP-Coordinated Commit Generation
1. **Context-Aware Message Generation**
   ```bash
   # GitHub MCP: Repository context and issue linking
   mcp__github__search_issues: Link to relevant open issues
   mcp__github__get_pull_request_files: Understand PR context
   
   # Linear MCP: Project management integration
   mcp__linear__list_my_issues: Connect commits to active work
   
   # Obsidian MCP: Knowledge base updates
   mcp__obsidian__obsidian_append_content: Document commit decisions
   ```

2. **Documentation Coordination**
   ```bash
   # Context7 MCP: Best practice validation
   mcp__context7__get-library-docs: Verify setup instructions accuracy
   
   # Apple MCP: Team communication
   mcp__apple-mcp__messages: Coordinate with team on breaking changes
   ```

## Command Options

### `--auto-stage` - Intelligent Staging
**Smart File Selection:**
1. **Analysis**: Analyze all changes for logical grouping
2. **Filtering**: Apply security and quality filters
3. **Safe Staging**: Only stage unproblematic, related changes
4. **Documentation Updates**: Auto-stage required doc updates

**Staging Strategy:**
- Group related functionality changes
- Separate configuration from feature changes
- Flag sensitive files for manual review
- Exclude unrelated or complex changes

### `--docs` - Documentation Impact Analysis
**Comprehensive Documentation Check:**
1. **Dependency Changes**: Compare package.json/requirements.txt with README
2. **Setup Instructions**: Validate installation and configuration steps
3. **API Changes**: Update documentation for interface changes
4. **Feature Documentation**: Ensure new features are documented

**Auto-Documentation Updates:**
```bash
# Identify documentation gaps and suggest updates
- New dependencies → Update installation instructions
- API changes → Update API documentation
- Configuration changes → Update setup guides
- Database changes → Update migration docs
```

### `--sync-main` - Cross-Worktree Coordination
**Intelligent Branch Context:**
1. **Auto-detect**: Current worktree and branch context
2. **Main Integration**: Plan merge strategy and coordination
3. **Container Sync**: Coordinate environment changes
4. **Documentation**: Cross-branch documentation consistency

### `--worktree-context` - Branch-Aware Commits
**Worktree Integration:**
- Detect current worktree from directory structure
- Include branch context in commit metadata
- Coordinate with related worktrees
- Maintain cross-worktree consistency

## Advanced Commit Features

### Context-Aware Message Generation
```bash
# Always include scope in parentheses - never bare types
FIX(auth): Fix JWT token validation bug
FEAT(dashboard): Add user analytics widgets  
DOCS(readme): Update installation instructions
CHORE(package): Bump dependency versions
REFACTOR(api): Extract validation middleware
TEST(utils): Add string helper test suite

### Rich Commit Context
- Core functionality modifications with business impact
- Configuration updates with environment implications
- Documentation updates ensuring accuracy
- Test changes with coverage impact

### Documentation Impact (Critical)
- README.md: Updated installation instructions for new dependencies
- API.md: Added documentation for new authentication endpoints
- SETUP.md: Revised configuration steps for container integration
- CHANGELOG.md: Added breaking change notices

### Context (Repository Awareness)
- Branch: feature-auth (2 commits behind main)
- Related Issues: Resolves #234, References #235
- Breaking Changes: Authentication middleware requires config update
- Performance Impact: +15% auth overhead, within acceptable limits

### Validation (Quality Assurance)
- Security: No secrets detected, auth patterns validated
- Tests: 95% coverage maintained, new tests added
- Performance: Benchmark tests pass, no regressions detected
- Documentation: All setup instructions verified and updated
```

### Automated Documentation Maintenance
```bash
# Documentation update automation
1. **Dependency Tracking**: Auto-update README when package.json changes
2. **API Documentation**: Generate API docs from code comments
3. **Setup Validation**: Test installation instructions against changes
4. **Breaking Changes**: Auto-generate migration guides
```

### Security and Quality Integration
```bash
# Comprehensive validation before commit
1. **Secret Scanning**: Detect API keys, passwords, tokens
2. **Sensitive Files**: Flag configuration, .env, key files
3. **Breaking Changes**: Identify and document API changes
4. **Performance Impact**: Analyze and report performance implications
```

## MCP Server Coordination

### Repository & Project Management
```bash
# GitHub MCP: Rich issue and PR linking
mcp__github__search_issues: Find related bugs, features, and discussions
mcp__github__search_code: Locate similar implementations and patterns  
mcp__github__list_commits: Reference previous related commits
mcp__github__get_pull_request: Link to relevant PR discussions

# Linear MCP: Project context integration
mcp__linear__list_issues: Connect commits to active project work
mcp__linear__get_issue: Extract detailed context and requirements
mcp__linear__list_comments: Include discussion context in commits
```

### Documentation & Knowledge Management
```bash
# Obsidian MCP: Knowledge base maintenance
mcp__obsidian__obsidian_append_content: "Development/Commits/$date.md"
mcp__obsidian__obsidian_patch_content: Update project documentation

# Context7 MCP: Best practice validation
mcp__context7__get-library-docs: Validate documentation against standards
```

### Development Environment
```bash
# Apple MCP: Team coordination
mcp__apple-mcp__messages: "Commit ready for review: $commit_subject"
mcp__apple-mcp__reminders: "Review breaking changes in 1 day"

# tmux MCP: Development session management
mcp__tmux__execute-command: "git log --oneline -5" # Show recent commits
```

## Commit Message Templates

### Good Multi-Commit Example
```bash
# Commit 1: Core implementation
FEAT(auth): Add JWT authentication middleware

- Implement token validation with configurable expiry
- Add user session management with Redis store
- Include rate limiting (100 req/min per user)
- Add proper error handling for malformed tokens

Breaking change: Requires REDIS_URL environment variable
Performance: <50ms overhead per authenticated request
Security: Follows OWASP JWT best practices

Resolves #234, Linear: AUTH-156
Related to #156, #301
Research: https://auth0.com/blog/jwt-best-practices
RFC: https://tools.ietf.org/html/rfc7519
Architecture: docs/decisions/002-jwt-auth.md

# Commit 2: Dependencies  
CHORE(deps): Add authentication dependencies

- jsonwebtoken: ^9.0.0 for JWT handling
- redis: ^4.5.0 for session storage  
- express-rate-limit: ^6.7.0 for rate limiting

Required for JWT authentication implementation
See: package.json security audit passed
Linear: AUTH-158

# Commit 3: Testing
TEST(auth): Add comprehensive auth middleware tests

- Unit tests for token validation logic
- Integration tests for rate limiting
- Error case coverage for malformed/expired tokens
- Performance tests for Redis session operations

Coverage: 97% for auth module
Test strategy: docs/testing/auth-test-plan.md
Linear: AUTH-159

# Commit 4: Documentation
DOCS(api): Add authentication endpoint documentation

- Document login/logout endpoints and payloads
- Add JWT token format and claims specification  
- Include rate limiting and error response examples
- Update setup instructions for Redis requirement

References: https://docs.company.com/auth-patterns
API spec: docs/api/authentication.yaml
Linear: AUTH-160
Related PR: #445 (frontend auth integration)
```

### Documentation Fix Template
```bash
DOCS(readme): Fix Docker installation instructions

### Documentation Fixes
- Corrected Docker Compose command syntax
- Updated Node.js version requirement from 16 to 18
- Added missing environment variable configuration
- Fixed broken links to deployment guides

### Validation
- Tested installation steps on fresh Ubuntu 22.04
- Verified all links and references work correctly
- Confirmed setup works with latest dependency versions
- Updated last-verified date to current

No functional changes - documentation accuracy only
```

### Security Fix Template
```bash
FIX(auth): Patch authentication bypass vulnerability

### Security Improvements
- Fixed JWT token validation bypass in middleware
- Added additional input sanitization for auth endpoints
- Implemented proper error handling without information leakage
- Added rate limiting to prevent brute force attacks

### Documentation Updates
- SECURITY.md: Updated vulnerability disclosure process
- README.md: Added security best practices section
- API.md: Updated authentication error response examples

### Validation
- Security scan: No vulnerabilities detected
- Penetration testing: Auth bypass confirmed fixed
- Performance: No degradation in auth performance
- Documentation: Security setup instructions verified

Resolves #SEC-2024-001: Authentication bypass
CVE: Pending assignment
```

## Integration with Other Commands

### Seamless Workflow Integration
- **`/test`**: Run tests before commit, include coverage in message
- **`/check`**: Comprehensive validation before commit generation
- **`/sync`**: Coordinate commits across worktrees
- **`/plan`**: Link commits to planned architecture changes

## Quality Gates & Validation

### Pre-Commit Validation
- **Security**: No secrets, no vulnerabilities, proper auth patterns
- **Documentation**: Required updates identified and included
- **Quality**: Tests pass, coverage maintained, performance validated
- **Standards**: Conventional commits, proper formatting, clear messaging

### Post-Commit Coordination
- **Issue Updates**: Automatic progress updates to linked issues
- **Team Notification**: Relevant team members notified of changes
- **Documentation**: Knowledge base updated with commit context
- **Integration**: CI/CD pipeline triggered with proper context

## Success Criteria

### Commit Quality Excellence
- [ ] **Clear Intent**: Commit purpose and impact clearly communicated
- [ ] **Documentation Current**: All affected documentation updated
- [ ] **Security Assured**: No secrets or vulnerabilities introduced
- [ ] **Quality Maintained**: Tests pass, coverage maintained
- [ ] **Team Coordinated**: Relevant stakeholders informed

### MCP Integration Success
- [ ] **Repository Linked**: Issues and PRs properly connected
- [ ] **Documentation Updated**: Knowledge base reflects changes
- [ ] **Project Tracked**: Linear/GitHub issues updated with progress
- [ ] **Team Informed**: Apple Messages/notifications sent as needed

---

**Philosophy**: Commits should tell stories. Documentation should stay current. Security should be automatic. Quality should be built-in. Collaboration should be seamless.