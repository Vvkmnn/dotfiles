# /pull - Intelligent Repository Cloning & Worktree Orchestration

---
argument-hint: "<git-url> [project-name] [--bare] [--containers] [--analyze] [--setup-all]"
---

## Overview
Revolutionary repository setup system combining optimal Git worktree architecture with container environment detection, hybrid Claude 4 intelligence, and comprehensive MCP integration. Implements 2024 best practices for modern development workflows.

## Usage
```bash
/pull <git-url> [project-name] [--bare] [--containers] [--analyze] [--setup-all]
```

## Hybrid Intelligence Architecture

### 1. Claude Repository Analysis
```bash
# Large-scale repository understanding with massive token window
claude: "analyze @README.md @package.json @docker-compose.yml for project architecture"
claude: "scan @.github/ @docs/ for development workflow patterns"
claude: "review @src/ @lib/ for technology stack and dependencies"
```

### 2. Claude Strategic Setup
```bash
# Sophisticated project setup optimization
- Optimal worktree structure design
- Container environment configuration
- Development workflow optimization
- Security and performance setup
```

### 3. MCP Server Integration
Complete project setup with all 20 MCP servers:
- **Repository**: GitHub MCP for repository operations
- **Containers**: GCP MCP for cloud container orchestration
- **Documentation**: Obsidian, Context7 for knowledge management
- **Development**: Apple MCP, tmux for local environment setup
- **Security**: Brave Search, Perplexity for vulnerability research

## Process

### Phase 1: Repository Intelligence Gathering (Claude-Powered)
1. **Repository Structure Analysis**
   ```bash
   # Clone repository for initial analysis
   git clone --depth=1 <git-url> /tmp/repo-analysis
   
   # Claude analysis of entire repository
   claude: "analyze @. repository structure and identify key characteristics"
   claude: "review @package.json @requirements.txt @Cargo.toml for dependencies"
   claude: "scan @docker-compose.yml @Dockerfile @.devcontainer/ for containers"
   claude: "examine @.github/ for CI/CD and development workflows"
   ```

2. **Technology Stack Detection**
   ```bash
   claude: "identify programming languages, frameworks, and tools used in @."
   claude: "analyze @docs/ @README.md for setup requirements and conventions"
   claude: "detect testing frameworks, build tools, and deployment patterns"
   ```

### Phase 2: Optimal Worktree Architecture (Claude Intelligence)
1. **Bare Repository Setup (2024 Best Practice)**
   ```xml
   <worktree_strategy>
     <context>Repository analysis and development requirements</context>
     <objective>Optimal bare repository structure with isolated worktrees</objective>
     <thinking>Design for parallel development, container isolation, performance</thinking>
     <mcp_integration>GitHub for repo ops, Apple for local setup</mcp_integration>
     <validation>Verify structure supports all detected workflows</validation>
   </worktree_strategy>
   ```

2. **Intelligent Directory Structure**
   ```bash
   # Extract clean project name from Git URL
   project_name=$(basename "$git_url" .git | sed 's/[^a-zA-Z0-9_-]//g')
   
   # Create optimal structure
   mkdir "$project_name" && cd "$project_name"
   git clone --bare "$git_url" .bare
   echo "gitdir: ./.bare" > .git
   git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
   git fetch origin
   ```

### Phase 3: Container Environment Detection (MCP Integration)
1. **Development Container Analysis**
   ```bash
   # GitHub MCP: Repository container configuration analysis
   mcp__github__get_file_contents: ".devcontainer/devcontainer.json"
   mcp__github__get_file_contents: "docker-compose.yml"
   mcp__github__get_file_contents: "Dockerfile"
   
   # GCP MCP: Cloud container compatibility check
   mcp__gcp-mcp__list-projects: Detect existing cloud configurations
   ```

2. **Environment Setup Automation**
   ```bash
   # Apple MCP: Local development tool verification
   mcp__apple-mcp__messages: "Repository cloned: $project_name"
   
   # tmux MCP: Development session setup
   mcp__tmux__create-session: "$project_name-dev"
   mcp__tmux__create-window: "main-worktree"
   ```

### Phase 4: Intelligent Worktree Creation (Hybrid Orchestration)
1. **Main Worktree with Container Integration**
   ```bash
   # Create main worktree with environment detection
   git worktree add main
   cd main
   
   # Container environment setup if detected
   if [ -f "docker-compose.yml" ]; then
     # Setup container environment with worktree isolation
     export WORKTREE_NAME="main"
     export PROJECT_NAME="$project_name"
     docker-compose -f docker-compose.yml -p "${project_name}-main" up -d
   fi
   ```

2. **Automated Branch Worktree Creation**
   ```bash
   # GitHub MCP: Fetch remote branches for worktree creation
   mcp__github__list_commits: Get active development branches
   
   # Create worktrees for major development branches
   git branch -r | grep -E "(develop|staging|feature/)" | while read branch; do
     branch_name=$(echo $branch | sed 's/origin\///' | tr '/' '-')
     git worktree add "$branch_name" "$branch"
   done
   ```

## Command Options

### `--bare` - Bare Repository Structure (Default)
**Optimal 2024 Structure:**
```bash
project-name/
├── .bare/                    # Contains all Git metadata
├── .git                      # Points to .bare directory  
├── main/                     # Main branch worktree
├── develop/                  # Development branch worktree
├── feature-auth/             # Feature branch worktree
├── .devcontainer/           # Shared dev container config
├── docker-compose.yml       # Container orchestration
└── CLAUDE.md               # Project-specific Claude instructions
```

### `--containers` - Container-First Setup
**Development Container Integration:**
1. **Auto-detect Container Configurations**
   - .devcontainer/ for VS Code dev containers
   - docker-compose.yml for service orchestration
   - Dockerfile for custom container builds
   - kubernetes/ for K8s deployment configs

2. **Worktree-Specific Container Environments**
   ```yaml
   # Auto-generated docker-compose.override.yml per worktree
   services:
     app:
       container_name: "${PROJECT_NAME}-${WORKTREE_NAME}"
       environment:
         - BRANCH_NAME=${WORKTREE_NAME}
         - DATABASE_URL=postgresql://postgres:password@db:5432/${PROJECT_NAME}_${WORKTREE_NAME}
       volumes:
         - .:/app
       networks:
         - ${PROJECT_NAME}_${WORKTREE_NAME}
   ```

### `--analyze` - Comprehensive Repository Analysis
**Hybrid Intelligence Deep Dive:**
1. **Claude Large-Scale Analysis"
   - Complete codebase architecture mapping
   - Dependency tree analysis and optimization
   - Documentation completeness assessment
   - Security and performance pattern detection

2. **Claude Strategic Insights**
   - Development workflow optimization recommendations
   - Container orchestration best practices
   - Testing strategy and quality gate setup
   - Team collaboration and productivity enhancements

### `--setup-all` - Complete Development Environment
**Full Automation Pipeline:**
1. **Repository Setup**: Optimal worktree structure
2. **Container Orchestration**: Multi-environment setup
3. **Development Tools**: IDE integration, testing setup
4. **Documentation**: CLAUDE.md project configuration
5. **Security**: Initial security scan and configuration
6. **Performance**: Optimization baseline establishment

## Container Integration Patterns

### Development Container Coordination
```json
// .devcontainer/devcontainer.json (auto-generated per worktree)
{
  "name": "${PROJECT_NAME}-${WORKTREE_NAME}",
  "build": {
    "dockerfile": "../docker/Dockerfile.dev",
    "context": "..",
    "args": {
      "WORKTREE_NAME": "${WORKTREE_NAME}",
      "NODE_ENV": "development"
    }
  },
  "forwardPorts": [3000, 5432, 6379],
  "postCreateCommand": "npm install && npm run setup:${WORKTREE_NAME}",
  "containerEnv": {
    "WORKTREE_ISOLATION": "true",
    "DATABASE_URL": "postgresql://postgres:password@db:5432/${PROJECT_NAME}_${WORKTREE_NAME}"
  }
}
```

### Docker Compose Orchestration
```yaml
# docker-compose.yml (enhanced for multi-worktree)
services:
  app:
    build: .
    container_name: "${PROJECT_NAME:-app}-${WORKTREE_NAME:-main}"
    environment:
      - NODE_ENV=${NODE_ENV:-development}
      - BRANCH_NAME=${WORKTREE_NAME:-main}
      - DATABASE_URL=postgresql://postgres:password@db:5432/${PROJECT_NAME:-app}_${WORKTREE_NAME:-main}
    volumes:
      - .:/app
      - /app/node_modules
    ports:
      - "${APP_PORT:-3000}:3000"
    depends_on:
      - db
      - redis
    networks:
      - ${PROJECT_NAME:-app}_${WORKTREE_NAME:-main}

  db:
    image: postgres:15
    container_name: "${PROJECT_NAME:-app}-${WORKTREE_NAME:-main}-db"
    environment:
      - POSTGRES_DB=${PROJECT_NAME:-app}_${WORKTREE_NAME:-main}
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    volumes:
      - db_data_${WORKTREE_NAME:-main}:/var/lib/postgresql/data
    ports:
      - "${DB_PORT:-5432}:5432"
    networks:
      - ${PROJECT_NAME:-app}_${WORKTREE_NAME:-main}

  redis:
    image: redis:7-alpine
    container_name: "${PROJECT_NAME:-app}-${WORKTREE_NAME:-main}-redis"
    volumes:
      - redis_data_${WORKTREE_NAME:-main}:/data
    ports:
      - "${REDIS_PORT:-6379}:6379"
    networks:
      - ${PROJECT_NAME:-app}_${WORKTREE_NAME:-main}

networks:
  ${PROJECT_NAME:-app}_${WORKTREE_NAME:-main}:
    driver: bridge

volumes:
  db_data_${WORKTREE_NAME:-main}:
  redis_data_${WORKTREE_NAME:-main}:
```

### Kubernetes Multi-Environment
```yaml
# k8s/worktree-namespace.yml (auto-generated)
apiVersion: v1
kind: Namespace
metadata:
  name: ${PROJECT_NAME}-${WORKTREE_NAME}
  labels:
    claude.ai/managed: "true"
    claude.ai/worktree: ${WORKTREE_NAME}
    claude.ai/project: ${PROJECT_NAME}
    claude.ai/created-by: "claude-pull-command"

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: worktree-config
  namespace: ${PROJECT_NAME}-${WORKTREE_NAME}
data:
  BRANCH_NAME: ${WORKTREE_NAME}
  PROJECT_NAME: ${PROJECT_NAME}
  ENVIRONMENT: development
  DATABASE_URL: postgresql://postgres:password@postgres:5432/${PROJECT_NAME}_${WORKTREE_NAME}
```

## MCP Server Coordination

### Repository Operations
```bash
# GitHub MCP: Advanced repository management
mcp__github__get_file_contents: "package.json"
mcp__github__list_commits: Remote branch analysis
mcp__github__search_repositories: Similar project patterns

# Linear MCP: Project management integration
mcp__linear__list_projects: Link to existing project management
```

### Development Environment Setup
```bash
# Apple MCP: Local tool integration
mcp__apple-mcp__notes: "Project setup: $project_name"
mcp__apple-mcp__reminders: "Review worktree setup in 1 week"

# tmux MCP: Development session orchestration
mcp__tmux__create-session: "$project_name"
mcp__tmux__create-window: "main"
mcp__tmux__create-window: "containers"
```

### Documentation & Knowledge Management
```bash
# Obsidian MCP: Project knowledge base
mcp__obsidian__obsidian_append_content: "Projects/$project_name.md"

# Context7 MCP: Best practice validation
mcp__context7__get-library-docs: Technology-specific setup guides
```

## Advanced Features

### Intelligent Branch Detection
```bash
# Analyze repository for active development patterns
- Detect feature branch naming conventions
- Identify long-running development branches  
- Create worktrees for active pull requests
- Setup container environments per branch type
```

### Security & Performance Optimization
```bash
# Initial security scan
- Secret detection in repository history
- Dependency vulnerability assessment
- Container security best practices
- Access control and permissions setup

# Performance baseline establishment
- Bundle size analysis and optimization
- Container resource allocation
- Database optimization recommendations
- CI/CD pipeline efficiency assessment
```

### Team Collaboration Setup
```bash
# Automated team workflow configuration
- Git hooks for code quality
- Pre-commit validation setup
- Container environment documentation
- Development workflow documentation
```

## Success Criteria

### Repository Setup Success
- [ ] **Optimal Structure**: Bare repository with isolated worktrees
- [ ] **Container Ready**: All environments properly containerized
- [ ] **Development Ready**: IDE integration and tools configured
- [ ] **Documentation Complete**: CLAUDE.md and setup guides created
- [ ] **Security Validated**: Initial security scan completed
- [ ] **Performance Optimized**: Baseline metrics established

### MCP Integration Success
- [ ] **All Servers Active**: 20 MCP servers properly integrated
- [ ] **Hybrid Intelligence**: Claude analysis + Claude optimization
- [ ] **Automation Complete**: Minimal manual setup required
- [ ] **Environment Isolated**: Worktree-specific configurations

## Integration with Other Commands

### Seamless Workflow Preparation
- **`/test`**: Test environment ready in each worktree
- **`/check`**: Quality gates configured for all environments
- **`/sync`**: Cross-worktree synchronization enabled
- **`/plan`**: Project architecture documented and optimized

---

**Philosophy**: Setup once, develop everywhere. Containers should be invisible. Worktrees should be effortless. Intelligence should be automatic. Quality should be built-in.