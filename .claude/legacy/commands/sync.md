# /sync - Intelligent Branch Synchronization & Container Orchestration

---
argument-hint: "[--main] [--branch=<name>] [--force] [--containers] [--no-push] [--dry-run]"
---

## Overview
Revolutionary branch synchronization system combining graceful Git operations with container orchestration, hybrid Claude 4 intelligence, and comprehensive MCP integration. Prevents merge conflicts while maintaining container environment consistency across worktrees.

## Usage
```bash
/sync [--main] [--branch=<name>] [--force] [--containers] [--no-push] [--dry-run]
```

## Hybrid Intelligence Architecture

### 1. Claude Conflict Prevention Analysis
```bash
# Large-scale conflict detection and resolution strategy
claude: "analyze @. repository for potential merge conflicts between branches"
claude: "review @docker-compose.yml @.devcontainer/ for container consistency"
claude: "scan @package.json @requirements.txt for dependency conflicts"
```

### 2. Claude Strategic Merge Planning
```bash
# Sophisticated merge strategy with conflict resolution
- Three-way merge analysis and optimization
- Container environment conflict resolution
- Database migration coordination
- CI/CD pipeline synchronization
```

### 3. MCP Server Coordination
Container-aware synchronization with all 20 MCP servers:
- **Git Operations**: GitHub MCP for repository management
- **Container Management**: GCP MCP for cloud container orchestration
- **Environment Validation**: Apple MCP for local development consistency
- **Testing Integration**: Playwright, tmux for cross-environment validation
- **Documentation**: Obsidian, Context7 for change documentation

## Process

### Phase 1: Pre-Sync Analysis (Claude-Powered)
1. **Repository State Analysis**
   ```bash
   claude: "analyze current worktree vs main branch differences in @."
   claude: "identify @docker-compose.yml @Dockerfile changes across branches"
   claude: "check @.env.example @config/ for environment variable conflicts"
   ```

2. **Container Environment Validation**
   ```bash
   claude: "compare container configurations between worktrees"
   claude: "analyze @k8s/ @.devcontainer/ for orchestration conflicts"
   claude: "validate @package.json @requirements.txt compatibility"
   ```

### Phase 2: Intelligent Merge Strategy (Claude Intelligence)
1. **Conflict Prevention Planning**
   ```xml
   <merge_strategy>
     <context>Branch differences and potential conflicts</context>
     <objective>Seamless merge with zero conflicts and container consistency</objective>
     <thinking>Analyze file conflicts, dependency changes, container differences</thinking>
     <mcp_integration>GitHub for repository ops, GCP for container validation</mcp_integration>
     <validation>Cross-worktree environment consistency</validation>
   </merge_strategy>
   ```

2. **Container Orchestration Coordination**
   ```bash
   # Ensure container consistency across environments
   - Validate Docker Compose service compatibility
   - Check Kubernetes resource conflicts
   - Coordinate database migration states
   - Synchronize environment variable configurations
   ```

### Phase 3: Graceful Synchronization (MCP Integration)
1. **Git Operations with Conflict Resolution**
   ```bash
   # GitHub MCP: Advanced repository operations
   mcp__github__get_pull_request_files: Analyze changed files
   mcp__github__create_branch: Create temporary merge branches
   mcp__github__merge_pull_request: Execute controlled merges
   
   # Sequential-thinking MCP: Complex merge logic
   mcp__sequential-thinking__sequentialthinking: "Optimize merge strategy"
   ```

2. **Container Environment Synchronization**
   ```bash
   # GCP MCP: Cloud container management
   mcp__gcp-mcp__list-gke-clusters: Coordinate Kubernetes environments
   
   # tmux MCP: Local container orchestration
   mcp__tmux__execute-command: "docker-compose down && docker-compose up -d"
   ```

### Phase 4: Validation & Testing (Hybrid Verification)
1. **Cross-Environment Validation**
   ```bash
   # Playwright MCP: End-to-end environment testing
   mcp__playwright__browser_navigate: Test application across environments
   
   # Apple MCP: Local environment consistency
   mcp__apple-mcp__messages: Team notifications of sync completion
   ```

2. **Documentation Updates**
   ```bash
   # Obsidian MCP: Knowledge graph updates
   mcp__obsidian__obsidian_append_content: Document sync operations
   
   # Context7 MCP: Best practice validation
   mcp__context7__get-library-docs: Verify merge follows best practices
   ```

## Command Options

### `--main` - Sync Current Branch with Main
**Hybrid Workflow:**
1. **Claude**: Analyze differences between current branch and main
2. **Claude**: Plan conflict-free merge strategy
3. **GitHub MCP**: Execute controlled merge operations
4. **Container Validation**: Ensure environment consistency

**Process:**
- Fetch latest main branch changes
- Identify potential conflicts before they occur
- Apply intelligent three-way merge
- Validate container configurations
- Update local worktree environment

### `--branch=<name>` - Sync with Specific Branch
**Hybrid Workflow:**
1. **Claude**: Cross-branch analysis and dependency checking
2. **Claude**: Multi-branch merge strategy optimization
3. **MCP Coordination**: Environment-aware synchronization
4. **Container Orchestration**: Service consistency validation

**Advanced Features:**
- Cross-worktree dependency resolution
- Container service compatibility checking
- Database migration coordination
- Environment variable synchronization

### `--containers` - Container-First Synchronization
**Container Orchestration:**
1. **Development Containers**: Sync .devcontainer configurations
2. **Docker Compose**: Coordinate service definitions
3. **Kubernetes**: Synchronize cluster configurations
4. **Environment Variables**: Merge .env and config files

**Container Validation Pipeline:**
```yaml
# Container sync validation
services:
  sync-validation:
    build: .
    command: |
      # Validate container compatibility
      docker-compose config --quiet
      
      # Check service dependencies
      docker-compose ps --services
      
      # Validate environment variables
      docker-compose exec app env | grep -E "^(DB_|API_|CACHE_)"
    environment:
      - SYNC_MODE=validation
```

### `--force` - Override Conflict Protection
**Intelligent Force Sync:**
1. **Backup Current State**: Automatic stash and branch backup
2. **Force Merge with Recovery**: Execute merge with rollback capability
3. **Container Reset**: Reset containers to target branch state
4. **Validation**: Comprehensive post-sync testing

### `--no-push` - Local Sync Only
**Local Development Focus:**
- Sync changes without pushing to remote
- Update local worktree environments
- Coordinate container configurations
- Maintain development environment consistency

### `--dry-run` - Preview Sync Operations
**Safe Preview Mode:**
1. **Claude**: Analyze proposed changes without execution
2. **Claude**: Report potential conflicts and resolutions
3. **MCP Simulation**: Preview all sync operations
4. **Container Impact**: Show container configuration changes

## Container Integration Patterns

### Development Container Coordination
```json
// .devcontainer/devcontainer.json sync
{
  "name": "${workspaceFolderBasename}-${containerWorkspaceFolder}",
  "build": {
    "dockerfile": "../docker/Dockerfile.dev",
    "context": "..",
    "args": {
      "WORKTREE_NAME": "${containerWorkspaceFolder}",
      "BRANCH_NAME": "${containerWorkspaceFolder}"
    }
  },
  "forwardPorts": [3000, 5432, 6379],
  "containerEnv": {
    "WORKTREE_ISOLATION": "true",
    "BRANCH_SPECIFIC_DB": "${containerWorkspaceFolder}_db"
  }
}
```

### Docker Compose Multi-Environment
```yaml
# docker-compose.sync.yml
services:
  app:
    build: .
    container_name: "${PROJECT_NAME}-${WORKTREE_NAME}"
    environment:
      - NODE_ENV=${NODE_ENV:-development}
      - BRANCH_NAME=${WORKTREE_NAME}
      - DATABASE_URL=postgresql://postgres:password@db:5432/${PROJECT_NAME}_${WORKTREE_NAME}
    volumes:
      - .:/app
      - /app/node_modules
    networks:
      - ${PROJECT_NAME}_${WORKTREE_NAME}

  db:
    image: postgres:15
    container_name: "${PROJECT_NAME}-${WORKTREE_NAME}-db"
    environment:
      - POSTGRES_DB=${PROJECT_NAME}_${WORKTREE_NAME}
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    volumes:
      - db_data_${WORKTREE_NAME}:/var/lib/postgresql/data
    networks:
      - ${PROJECT_NAME}_${WORKTREE_NAME}

networks:
  ${PROJECT_NAME}_${WORKTREE_NAME}:
    driver: bridge

volumes:
  db_data_${WORKTREE_NAME}:
```

### Kubernetes Multi-Environment
```yaml
# k8s/sync-coordination.yml
apiVersion: v1
kind: Namespace
metadata:
  name: ${PROJECT_NAME}-${WORKTREE_NAME}
  labels:
    sync.claude.ai/managed: "true"
    sync.claude.ai/worktree: ${WORKTREE_NAME}
    sync.claude.ai/project: ${PROJECT_NAME}

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
  namespace: ${PROJECT_NAME}-${WORKTREE_NAME}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: main
      worktree: ${WORKTREE_NAME}
  template:
    metadata:
      labels:
        app: main
        worktree: ${WORKTREE_NAME}
    spec:
      containers:
      - name: app
        image: ${PROJECT_NAME}:${WORKTREE_NAME}
        env:
        - name: BRANCH_NAME
          value: ${WORKTREE_NAME}
        - name: DATABASE_URL
          value: postgresql://postgres:password@postgres:5432/${PROJECT_NAME}_${WORKTREE_NAME}
```

## Advanced Sync Patterns

### Intelligent Conflict Resolution
```bash
# Claude-powered conflict analysis
1. Identify conflicting files and their semantic differences
2. Generate merge strategies based on code patterns
3. Preserve critical configurations (database, API keys)
4. Validate merged result against both branch contexts

# Claude strategic resolution
1. Analyze business logic conflicts
2. Preserve architectural integrity
3. Maintain security and performance standards
4. Generate test cases for merged functionality
```

### Cross-Worktree Coordination
```bash
# Synchronize multiple worktrees simultaneously
/sync --all-worktrees
- Coordinate main → feature branches
- Ensure container environment consistency
- Validate cross-branch compatibility
- Update shared configuration files
```

### Database Migration Coordination
```bash
# Smart database sync across environments
1. Detect schema changes between branches
2. Generate migration coordination scripts
3. Execute migrations in correct order
4. Validate data consistency across environments
```

## Quality Gates & Validation

### Pre-Sync Validation
- **Container Health**: All services running and healthy
- **Database State**: Migrations applied, data consistent
- **Environment Variables**: All required variables present
- **Network Connectivity**: Service-to-service communication working

### Post-Sync Validation
- **Application Health**: Full application functionality verified
- **Container Orchestration**: Services properly coordinated
- **Data Integrity**: Database consistency maintained
- **Performance**: No regression in critical metrics

## MCP Server Coordination Matrix

### Git & Repository Management
```bash
GitHub MCP → Repository operations, PR management
Linear MCP → Issue tracking, project synchronization
Sequential-thinking MCP → Complex merge logic analysis
```

### Container & Infrastructure
```bash
GCP MCP → Cloud container orchestration
Apple MCP → Local development environment
tmux MCP → Local container management
Playwright MCP → Cross-environment testing
```

### Documentation & Knowledge
```bash
Obsidian MCP → Sync operation documentation
Context7 MCP → Best practice validation
Magic MCP → UI consistency across environments
Figma MCP → Design-development synchronization
```

## Integration with Other Commands

### Seamless Workflow Integration
- **`/pull`**: Initial repository setup with sync configuration
- **`/test`**: Cross-environment test validation after sync
- **`/check`**: Quality assurance across synchronized environments
- **`/commit`**: Intelligent commits with sync metadata

## Error Handling & Recovery

### Rollback Mechanisms
```bash
# Automatic rollback on sync failure
1. Restore previous Git state from automatic stash
2. Revert container configurations to pre-sync state
3. Reset database to known good state
4. Restore environment variables and configurations
```

### Conflict Resolution Assistance
```bash
# AI-powered conflict resolution
1. Claude: Analyze conflict patterns and suggest resolutions
2. Claude: Generate contextual merge strategies
3. GitHub MCP: Create conflict resolution branches
4. Validation: Test merged result before finalizing
```

## Success Criteria

### Sync Operation Success
- [ ] **Zero Conflicts**: Graceful merge without manual conflict resolution
- [ ] **Container Consistency**: All environments properly synchronized
- [ ] **Data Integrity**: Database and application state consistent
- [ ] **Performance Maintained**: No degradation in application performance
- [ ] **Documentation Updated**: All changes properly documented

### Container Orchestration Success
- [ ] **Environment Isolation**: Proper worktree-specific containerization
- [ ] **Service Discovery**: Container networking properly configured
- [ ] **Resource Management**: Optimal resource allocation across environments
- [ ] **Health Monitoring**: All services healthy post-sync

---

**Philosophy**: Sync should be invisible. Conflicts should be prevented, not resolved. Containers should be environment-agnostic. Documentation should be automatic. Recovery should be immediate.