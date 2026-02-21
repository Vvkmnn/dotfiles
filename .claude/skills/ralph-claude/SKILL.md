---
name: ralph-claude
description: Use when needing autonomous multi-hour development with complete OS isolation - build-outs, implementations, or extended coding sessions without supervision across any language or framework
---

# Ralph Wiggum + Docker Sandbox for Autonomous Development

## Overview

**Ralph Wiggum** is an official Claude Code plugin that runs autonomous development loops for hours. **Docker Sandbox** is Docker Desktop's official isolation feature that contains Claude Code in a disposable container.

**Core principle:** Combine Ralph's autonomy with Docker's isolation for safe, unsupervised development on any project.

## When to Use

**Symptoms this solves:**
- Need to build something over 2+ hours while away
- Want AI to iterate without supervision
- Require complete OS isolation (no risk to host system)
- Building exploratory prototypes or MVPs
- Executing detailed implementation plans autonomously

**When NOT to use:**
- Quick 10-minute tasks (overhead not worth it)
- Production systems requiring human oversight
- Tasks needing frequent user input

## Quick Reference

| Phase | Action | Command |
|-------|--------|---------|
| **1. Prerequisites** | Docker Desktop 4.50+ | `docker --version` |
| **2. Create PROMPT.md** | Write phased plan with completion criteria | See structure below |
| **3. Start sandbox** | Launch isolated Claude | `docker sandbox run claude` |
| **4. Install Ralph** | Inside sandbox | `/plugin install ralph-wiggum@claude-plugins-official` |
| **5. Run loop** | Execute autonomous build | `/ralph-loop "$(cat PROMPT.md)" --max-iterations 40 --timeout 120` |
| **6. Verify** | Check results | Exit sandbox, run tests |

## PROMPT.md Structure

Ralph needs a structured prompt with:

### Required Sections

```markdown
# Build [Project Name]

**Target:** [Duration] autonomous build
**Completion:** `<promise>COMPLETE</promise>` when [criteria]

## Git Commit Style (Optional)

<TYPE>: <Subject (max 50 chars, imperative)>

<Body (max 72 chars/line)>

[Define your commit types: FEAT, FIX, TEST, etc.]

## Tech Stack

| Component | Choice | Why |
|-----------|--------|-----|
| [Framework] | [Name + version] | [Rationale] |
| [Database] | [Name + version] | [Rationale] |
| [Testing] | [Name + version] | [Rationale] |

## Phase 1: [Name] ([time estimate])

### Create [components/files]
[Specific file paths, function signatures, module structure]

### Verification
```bash
[Command that proves this phase works]
# Examples:
# npm test
# cargo build --release
# python -m pytest
# go test ./...
# mvn verify
```

## Phase 2-N: [Continue pattern]

[Break work into 15-30 min phases]
[Each with concrete deliverables + verification]

## Completion Criteria

Output `<promise>COMPLETE</promise>` ONLY when ALL pass:
- [ ] Build/compile succeeds
- [ ] Tests pass
- [ ] [Project-specific functionality works]
- [ ] [Integration points verified]
- [ ] No critical TODOs blocking basic usage

If 7/10 criteria pass, output `<promise>COMPLETE</promise>`.

## Escape Hatch

If stuck after [N] iterations:
1. Document blockers in BLOCKERS.md
2. Ensure build at least compiles
3. Output `<promise>COMPLETE</promise>`

Partial working build > infinite loop.
```

### Key Elements

**Completion promise:** Ralph stops when it outputs `<promise>COMPLETE</promise>` exactly
**Phases:** Break work into measurable chunks with verification
**Escape hatch:** Prevents infinite loops on blockers
**Tech stack table:** Eliminates debate, Ralph uses decided tech
**Verification per phase:** Catch issues early, not at end

## Implementation

### Step 1: Prerequisites

```bash
# Verify Docker Desktop installed and running
docker --version  # Need 4.50+

# Ensure Docker Sandbox feature available
docker sandbox --help
```

### Step 2: Create PROMPT.md

```bash
cd /path/to/your/project

# Create detailed autonomous build instructions
vim PROMPT.md
```

**What to include:**
- **Specific paths:** Not "create models" → "create src/models/user.py with User class"
- **Concrete examples:** Not "handle errors" → "return 404 if resource not found, 500 if db unavailable"
- **Real test data:** Link to actual datasets or specify structure
- **Exact tech versions:** Not "latest React" → "React 18.2"
- **Clear success criteria:** Measurable, testable outcomes

**Phase time estimates:**
- Simple file creation: 10-15 min
- Integration work: 20-30 min
- Complex features: 30-45 min
- Testing + verification: 10-20 min

### Step 3: Start Docker Sandbox

```bash
# Launches isolated Claude Code session
docker sandbox run claude
```

**What this does:**
- Creates disposable container
- Mounts only your project directory
- Filesystem isolated from host
- Network proxied through Docker
- `--dangerously-skip-permissions` enabled by default (safe in container)
- All system changes disappear on exit (only project files persist)

### Step 4: Inside Sandbox - Install Ralph

```bash
# Install Ralph Wiggum plugin
/plugin install ralph-wiggum@claude-plugins-official

# Verify installation
/plugin list | grep ralph
```

### Step 5: Run Ralph Loop

```bash
# Execute autonomous build
/ralph-loop "$(cat PROMPT.md)" \
  --max-iterations 40 \
  --timeout 120 \
  --completion-promise "COMPLETE"
```

**Parameters:**
- `--max-iterations`: Max loops (e.g., 40 iterations at ~3 min each = 2 hours)
- `--timeout`: Hard stop in minutes (120 = 2 hours)
- `--completion-promise`: Exact string to match (without `<promise>` tags)

**Calculating iterations:**
- Estimate minutes per phase from PROMPT.md
- Add 20% buffer for debugging
- Divide total time by 3 (avg iteration time)

**Ralph will:**
1. Read PROMPT.md and project files
2. Execute phases sequentially
3. Run verification commands after each phase
4. Log all decisions and blockers
5. Output `<promise>COMPLETE</promise>` when done or stuck

### Step 6: Verify Results

**When Ralph completes (or timeout hits):**

Exit sandbox (changes persist in your project directory):
```bash
exit  # Leave Docker container
```

**On your host machine:**

```bash
cd /path/to/your/project

# Check what was built
git status
git log --oneline -20  # Review Ralph's commits

# Run verification commands from PROMPT.md
# Examples for different stacks:
cargo build --release           # Rust
npm test                        # JavaScript/TypeScript
python -m pytest                # Python
go test ./...                   # Go
mvn verify                      # Java
mix test                        # Elixir
dotnet test                     # C#

# Check for blockers
cat BLOCKERS.md  # If exists - Ralph documented what stopped it

# Verify isolation worked
# (No changes outside project directory)
```

## Common Mistakes

### ❌ Using manual `docker run`

**Wrong:**
```bash
docker run -it -v $(pwd):/workspace python:3.11 bash
# Then manually install Claude...
```

**Right:**
```bash
docker sandbox run claude  # Official feature, pre-configured
```

**Why:** Docker Sandbox handles Claude installation, permissions, networking automatically.

### ❌ Creating custom config filenames

**Wrong:** `.ralph-config.md`, `.ralph-context.md`, `build-plan.md`

**Right:** `PROMPT.md` - Ralph expects this standard name

**Why:** PROMPT.md is the established convention for autonomous AI instructions.

### ❌ Missing completion promise

**Wrong:**
```markdown
Build succeeds and tests pass.
```

**Right:**
```markdown
Output `<promise>COMPLETE</promise>` ONLY when:
- Build succeeds
- Tests pass
```

**Why:** Ralph doesn't know when to stop without exact promise string.

### ❌ Forgetting timeout parameter

**Wrong:**
```bash
/ralph-loop "$(cat PROMPT.md)" --max-iterations 40
```

**Right:**
```bash
/ralph-loop "$(cat PROMPT.md)" --max-iterations 40 --timeout 120
```

**Why:** Without timeout, Ralph could run past your usage window. Timeout is hard stop.

### ❌ Vague phase instructions

**Wrong:**
```markdown
## Phase 1: Set up project
Create files and tests.
```

**Right:**
```markdown
## Phase 1: Project Scaffolding (15 min)

Create files:
- package.json with dependencies: react@18.2, vite@4.0, vitest@0.34
- src/App.tsx with basic component
- src/main.tsx with React.createRoot

Verification:
```bash
npm install && npm run build
```
```

**Why:** Vague instructions → Ralph makes wrong assumptions → wasted iterations.

### ❌ No escape hatch

**Wrong:** Just phases, no "if stuck" guidance

**Right:** Include escape hatch with iteration limit and acceptable partial state

**Why:** Better to get partial working code than loop infinitely on a blocker.

### ❌ Language/framework-specific PROMPT.md in wrong location

**Wrong:** Generic PROMPT.md for Python project in Rust workspace

**Right:** Create PROMPT.md in project root with appropriate tech stack

**Why:** Ralph reads context from surrounding files - wrong location = wrong assumptions.

## Language-Specific Tips

### Python Projects

```markdown
## Verification
```bash
uv pip install -e ".[dev]"  # or pip install -e ".[dev]"
pytest -v --cov=src
python -m your_module --help
```
```

### JavaScript/TypeScript

```markdown
## Verification
```bash
npm install
npm test
npm run build
npm run lint
```
```

### Rust

```markdown
## Verification
```bash
cargo check
cargo test
cargo build --release
```
```

### Go

```markdown
## Verification
```bash
go mod download
go test ./...
go build -o bin/app
```
```

### Java/Kotlin

```markdown
## Verification
```bash
./gradlew test  # or mvn verify
./gradlew build
java -jar build/libs/app.jar --help
```
```

## Verification Checklist

After Ralph completes:

- [ ] `git log` shows Ralph's commits (in your style if specified)
- [ ] Build command from PROMPT.md succeeds
- [ ] Tests pass (or failures documented in BLOCKERS.md)
- [ ] No changes outside project directory (Docker isolation worked)
- [ ] Ralph output `<promise>COMPLETE</promise>` OR hit timeout
- [ ] If BLOCKERS.md exists, it explains what stopped progress
- [ ] Core functionality from Phase 1-N works as specified

## Integration with Other Skills

**Before Ralph:**
- `superpowers:brainstorming` - Design before building
- `superpowers:writing-plans` - Create implementation plan that becomes PROMPT.md
- `superpowers:using-git-worktrees` - Isolate work in branch (then run Ralph in that worktree)

**After Ralph:**
- `superpowers:verification-before-completion` - Verify Ralph's output
- `superpowers:requesting-code-review` - Review what Ralph built
- `superpowers:finishing-a-development-branch` - Decide merge/PR/cleanup

## Resources

**Official docs:**
- Docker Sandbox: https://docs.docker.com/ai/sandboxes/claude-code/
- Ralph Wiggum: Official Claude Code plugin (install via `/plugin install`)
- Claude Code: https://claude.ai/download

**PROMPT.md templates:**
- Adapt the structure above to your language/framework
- Include tech stack table to eliminate debate
- Break into 15-30 min phases with concrete verification
