---
name: ralph-claudebox
description: Use when setting up isolated Claude Code development with ClaudeBox and Colima on macOS, when needing container sandbox for --dangerously-skip-permissions, when Docker Desktop alternative needed, when troubleshooting ClaudeBox/Colima issues, when creating PROMPT.md for autonomous development
---

# ClaudeBox Sandbox Setup

Run Claude Code with `--dangerously-skip-permissions` in an isolated Docker container using Colima (lightweight Docker Desktop alternative).

## Prerequisites

```bash
brew install colima docker docker-buildx bash
```

**Bash 5+ required** (macOS ships with 3.2):
```bash
/opt/homebrew/bin/bash --version  # Should be 5.x+
```

**Link docker-buildx:**
```bash
mkdir -p ~/.docker/cli-plugins
ln -sfn /opt/homebrew/opt/docker-buildx/bin/docker-buildx ~/.docker/cli-plugins/docker-buildx
```

**Install ClaudeBox:**
```bash
wget https://github.com/RchGrav/claudebox/releases/latest/download/claudebox.run
chmod +x claudebox.run && ./claudebox.run
```

## Storage Options

### Option A: External SSD (Recommended)

Add to `~/.zshrc`:
```bash
export COLIMA_HOME="/Volumes/YourSSD/Sandbox/Colima"
export DOCKER_HOST="unix://$COLIMA_HOME/docker.sock"
```

Start with:
```bash
COLIMA_HOME="/Volumes/YourSSD/Sandbox/Colima" colima start \
  --cpu 4 --memory 8 --disk 60 --vm-type vz --runtime docker
```

### Option B: Local (Default)

No env vars needed. Start with:
```bash
colima start --cpu 4 --memory 8 --disk 60 --vm-type vz --runtime docker
```

## Quick Start

```bash
# 1. Start Colima (use your storage option command above)
# 2. Navigate to project
cd /path/to/your/project

# 3. Save flags (one-time, persists across sessions)
claudebox save --enable-sudo --disable-firewall  # Essential for sudo + plugin installation

# 4. Create slot
claudebox create

# 5. Enter via shell, pin Claude Code version, then launch
claudebox shell
npm install -g @anthropic-ai/claude-code@2.1.25   # pin to known-good version
DISABLE_AUTOUPDATER=1 claude --dangerously-skip-permissions

# Note: claudebox slot <n> [claude arguments...] passes flags through to claude
# --dangerously-skip-permissions is safe here because the container IS the sandbox
```

## Claude Code Version Pinning (Container-Only)

**CRITICAL:** Claude Code v2.1.27 freezes inside containers on first interaction.
([#22103](https://github.com/anthropics/claude-code/issues/22103), [#22200](https://github.com/anthropics/claude-code/issues/22200))

**Fix:** Downgrade inside the container and prevent auto-update:
```bash
claudebox shell
npm install -g @anthropic-ai/claude-code@2.1.25
DISABLE_AUTOUPDATER=1 claude --dangerously-skip-permissions
```

**Check before each session:** `claude --version` should show 2.1.25 (or a known-good version).
**`DISABLE_AUTOUPDATER=1` is mandatory** — without it, Claude auto-updates back to broken version.
**Host is unaffected** — this only impacts containerized environments.

## Slot Management

| Command | Purpose |
|---------|---------|
| `claudebox create` | Create new slot |
| `claudebox slot <n>` | Enter slot n (accepts claude args after) |
| `claudebox slot <n> --dangerously-skip-permissions` | Autonomous mode (no prompts) |
| `claudebox slots` | List all slots |
| `claudebox info` | Show project paths |
| `claudebox save <flags>` | Persist flags for all future slot entries |
| `claudebox rebuild` | Force image rebuild after profile changes |

**Recommended saved flags:**
```bash
claudebox save --enable-sudo --disable-firewall  # Essential for sudo + plugin installation
```
Always include `--disable-firewall` — without it, GitHub access is blocked and plugin installation hangs.

**Slots are isolated** - each has own plugins, history, settings, `.claude/` directory.
**Slots share** - project code at `/workspace`.

**Use cases:**
- Parallel agents on different tasks
- Fresh context when current gets polluted
- Experimentation without risk

## Plugin Installation

Official marketplace `anthropics/claude-plugins-official` is available by default. No auth needed.

```bash
# Inside Claude
/plugin install superpowers
/plugin install code-review
/plugin install commit-commands
/plugin install feature-dev
/plugin install code-simplifier
/plugin install security-guidance
/plugin install ralph-loop
```

**Note:** Install one at a time - multi-install doesn't work.

**Plugins persist per slot** at `~/.claudebox/projects/<hash>/<slot>/.claude/plugins/`

### MCP-Launching Plugins (Do NOT Enable in Container)

These plugins try to start MCP servers that don't work inside the container:
- `rust-analyzer-lsp`, `clangd-lsp` — need binaries not in container PATH
- `context7`, `github` — need MCP server connectivity

If enabled, they cause "1 MCP server failed" in the status bar. Remove from slot's `.claude/settings.json` `enabledPlugins`.

**Safe plugins:** `superpowers`, `code-review`, `feature-dev`, `code-simplifier`, `ralph-loop`, `commit-commands`, `claude-md-management`, `explanatory-output-style`

### Ghost Marketplaces (Known Issue)

Host `~/.claude/` is mounted read-only into the container ([issue #96](https://github.com/RchGrav/claudebox/issues/96)). All host marketplace registrations appear as ghost entries. **This is cosmetic** — plugins from `claude-plugins-official` install and work fine. Ignore the extra marketplaces.

**`--disable-firewall` required:** Without it, GitHub access is blocked and plugin installation hangs at "loading." Always include in saved flags: `claudebox save --enable-sudo --disable-firewall`

**REMINDER:** After creating a new slot, install plugins from `claude-plugins-official` marketplace. Choose plugins relevant to your project (e.g., `ralph-loop` for autonomous iteration, `superpowers` for TDD/debugging). Avoid MCP-launching plugins listed above.

### NO MCP Servers Inside ClaudeBox

ClaudeBox does **NOT** have access to host MCP servers. Tools like `code-mode`, `repomix-mcp`, `notion`, `github`, `claude-historian`, `claude-in-chrome`, etc. require network connectivity to local processes that don't exist inside the container.

**Available inside ClaudeBox:** Only installed plugins (from marketplace above) + standard tools (Bash, Read, Write, Edit, Glob, Grep, WebSearch, WebFetch).

**NOT available:** `mcp__code-mode__*`, `mcp__plugin_repomix-mcp_repomix__*`, `mcp__claude-in-chrome__*`, or any other MCP integrations.

If your PROMPT.md references MCP tools, replace those references with:
- `context7` plugin for library docs (install it first)
- `WebSearch` for web research
- Standard file tools for codebase exploration

## Troubleshooting

| Issue | Fix |
|-------|-----|
| "Docker Desktop is not running" | Start Colima (not Docker Desktop) |
| "Cannot connect to Docker daemon" | Start Colima |
| "disk in use" / socket errors | `colima delete --force` then restart |
| "unbound variable" | Need bash 5+: `brew install bash` |
| Colima unresponsive after sleep | Delete and restart (see below) |
| SSD disconnected / unmounted | Delete and restart (see below) |
| "ha.sock: connection refused" | Stale VM state - delete and restart |
| `exiting, status={Running:false Degraded:false Exiting:true}` | Stale VM after sleep/crash - `colima delete --force` then restart |
| Can't set env vars in ClaudeBox | No CLI flag for agent teams. Use `settings.local.json` with `"env": {"CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"}` - works in both local and ClaudeBox since project files mount at `/workspace` |
| `cargo`/`rustc` not found after profile | **Known bug**: Rust profile installs as root, PATH points to claude's home. Fix: `export PATH="/root/.cargo/bin:$HOME/.cargo/bin:$PATH"` |
| "no C linker" / `cc` not found | Need gcc. **Don't use profiles for this** (template bug #91). Enable sudo first: `claudebox save --enable-sudo`. Inside container: `sudo apt-get update && sudo apt-get install -y gcc g++ make pkg-config libssl-dev` |
| Profile `{{PROFILE_INSTALLATIONS}}` in build error | **Known bug** (GitHub #91) - awk template substitution broken for profiles with apt packages. Fix: `claudebox remove <profile>`, install packages via `sudo apt-get install` inside container (requires `--enable-sudo`) |
| `sudo: a terminal is required to read the password` | Sudo is disabled by default. From HOST: `claudebox save --enable-sudo` (persists across sessions). Then re-enter slot |
| `claudebox install` doesn't install packages | **Known issue** - command accepts input and prints success but no apt step is added to docker build. Use `sudo apt-get install` inside container instead (requires `--enable-sudo`) |
| `GLIBC_2.39 not found` | Almost certainly rust-analyzer (not rustc). Fix: `rustup component remove rust-analyzer` or update to latest. **DO NOT** attempt patchelf/zig-cc/ARM-toolchain workarounds |
| Compiled language missing | Use `claudebox add <profile>` from HOST for language toolchains (rust, go, java work). For C/C++ tools: enable sudo (`claudebox save --enable-sudo`) then `sudo apt-get install -y gcc g++ make` inside container. Apt-based profiles (c, core, build-tools) are broken (see template bug #91) |
| Python packages not available | Base image has `uv` but no venv. Either use `uv venv && uv pip install ...` or add `python` profile for pre-configured dev tools |
| `node`/`npm` not found | Node LTS is pre-installed via NVM. Try: `source ~/.nvm/nvm.sh && node --version`. If still missing, add `javascript` profile |
| Profile changes not taking effect | Run `claudebox rebuild` to force image rebuild |
| Runtime profile slow on first entry | Python/ML/datascience profiles install packages at container start (not docker build). First entry is slow, subsequent entries use cached venv |
| Claude Code freezes on first interaction | **v2.1.27 regression**. Fix: `claudebox shell` → `npm install -g @anthropic-ai/claude-code@2.1.25` → `DISABLE_AUTOUPDATER=1 claude` |
| "1 MCP server failed" in status bar | MCP plugins can't work in container. Remove `rust-analyzer-lsp`, `clangd-lsp`, `context7`, `github` from slot's `enabledPlugins` |
| "No available slots found" | Stale container running. Fix: `docker kill $(docker ps -q --filter "name=claudebox")` |
| Ghost marketplaces in container | Cosmetic — host `~/.claude/` mounted read-only ([#96](https://github.com/RchGrav/claudebox/issues/96)). Install from `claude-plugins-official` only |
| Plugins loading forever | Need `--disable-firewall`: `claudebox save --enable-sudo --disable-firewall` |
| `rebuild` killed my session | `rebuild` destroys running container. Never use during active session |
| `claudebox save` "No project found" | Must `claudebox create` first, then `save` |
| Port 53 forwarding warning on colima start | Negligible — Colima started fine, ignore it |
| First slot entry appears hung | Docker image building on first use — wait for it |

## Full Reset

**When everything is broken** — stale containers, corrupt VM, plugin issues:

```bash
# 1. Kill stale containers
docker kill $(docker ps -q --filter "name=claudebox") 2>/dev/null

# 2. Delete Colima VM
COLIMA_HOME="/Volumes/YourSSD/Sandbox/Colima" colima delete --force
COLIMA_HOME="/Volumes/YourSSD/Sandbox/Colima" colima start \
  --cpu 4 --memory 8 --disk 60 --vm-type vz --runtime docker

# 3. Clean project completely (removes slots, image, everything)
cd /path/to/project
claudebox clean project

# 4. Recreate from scratch
claudebox create
claudebox save --enable-sudo --disable-firewall
claudebox add rust  # or other profiles

# 5. Enter via shell, pin Claude Code version, then launch
claudebox shell
npm install -g @anthropic-ai/claude-code@2.1.25   # pin to known-good version
DISABLE_AUTOUPDATER=1 claude --dangerously-skip-permissions
```

**Note:** `claudebox clean project` removes all slots, image, and project data. Slot plugins must be reinstalled after. Always run from project root, not from a worktree subdirectory.

**Slot data survives `colima delete`** — only the VM is removed. Slot directories at `~/.claudebox/` persist and remount when you recreate the container. But `claudebox clean project` removes everything.

## Architecture

```
Host (macOS)                     Container (ClaudeBox)
────────────────────             ─────────────────────
~/.claudebox/                    /home/claude/
  projects/<hash>/                 .claude/    (slot-specific, bind mount)
    <slot-id>/                   /workspace/   (your project)
      .claude/
```

**Key insight:** `colima delete` only removes VM. Slot data at `~/.claudebox/` persists and remounts on restart.

## What's Pre-installed in the Base Image

ClaudeBox base image is **Debian Bookworm** (glibc 2.36). The base image already includes:
- **Node.js LTS** via NVM v0.39.0 (Claude Code itself runs on Node)
- **uv** (Python package manager from Astral) - installed globally
- **git**, **gh** (GitHub CLI), **tmux**, **vim**, **nano**, **jq**, **curl**, **wget**
- **zsh** with oh-my-zsh (default shell)
- **sudo** package installed, but **disabled by default** (see "Sudo Access" below)

**NOT pre-installed:** gcc, make, rustc, cargo, go, pip, python3 (venv), typescript, eslint

## Sudo Access

**Sudo is disabled by default.** The ClaudeBox `docker-entrypoint` deletes the sudoers file on every container start unless the `--enable-sudo` flag is set:

```bash
# In docker-entrypoint:
if [ "$ENABLE_SUDO" != "true" ]; then
    rm -f /etc/sudoers.d/DOCKERUSER
fi
```

**To enable sudo (persists across all future slot entries):**
```bash
# From HOST:
claudebox save --enable-sudo
```

After this, `sudo apt-get install ...` works inside the container with NOPASSWD. This is the **primary way to install additional packages** (see "Installing Additional Packages" below).

**Without `--enable-sudo`**, you'll see: `sudo: a terminal is required to read the password`

## Installing Additional Packages

**`claudebox install` does NOT work** - it accepts package names and prints "Installing packages" but no apt-get step is added to the docker build (all layers show CACHED). Do not rely on it.

**The correct approach:** Enable sudo, then install inside the container:
```bash
# One-time from HOST (if not already done):
claudebox save --enable-sudo

# Inside container:
sudo apt-get update && sudo apt-get install -y <packages>
```

**Trade-off:** Packages installed this way are lost when the image is rebuilt (`claudebox rebuild`, profile changes). For persistent packages, use profiles that work (rust, go, javascript, java) or re-run `sudo apt-get install` after rebuilds.

## Development Profiles

Profiles add language toolchains on top of the base image. Install from the **HOST** terminal.

### Profile Commands (run from HOST, not inside container)

| Command | Purpose |
|---------|---------|
| `claudebox profiles` | List all available profiles |
| `claudebox add <names...>` | Install profiles (rebuilds image) |
| `claudebox remove <names...>` | Remove profiles |
| `claudebox add status` | Check current project's profiles |
| `claudebox rebuild` | Force rebuild if changes don't take effect |

### Available Profiles

| Profile | What It Installs | How | Dependencies |
|---------|-----------------|-----|-------------|
| `core` | gcc, g++, make, git, pkg-config, libssl-dev, libffi-dev, zlib1g-dev, tmux | apt | (none) |
| `build-tools` | cmake, ninja-build, autoconf, automake, libtool | apt | (none) |
| `rust` | rustup, rustc, cargo (via sh.rustup.rs) | Docker RUN | auto-adds `core` |
| `go` | Go 1.21.0 (upstream archive) | Docker RUN | auto-adds `core` |
| `c` | gcc, gdb, valgrind, clang, clang-tidy, cppcheck, boost, ncurses, cmocka | apt | auto-adds `core`, `build-tools` |
| `python` | Python venv + dev tools (ipython, black, mypy, pylint, pytest, ruff, poetry, pipenv) via uv | **Runtime** (entrypoint) | auto-adds `core` |
| `javascript` | NVM v0.39.3, Node LTS, typescript, eslint, prettier, yarn, pnpm | Docker RUN | auto-adds `core` |
| `java` | SDKMan, OpenJDK, Maven, Gradle, Ant | Docker RUN | auto-adds `core` |
| `ruby` | ruby-full, ruby-dev, sqlite3 | apt | auto-adds `core` |
| `php` | php-cli, php-fpm, composer, mysql/pgsql/sqlite3 extensions | apt | auto-adds `core` |
| `database` | postgresql-client, mysql-client, sqlite3, redis-tools | apt | auto-adds `core` |
| `ml` | torch, transformers, scikit-learn, numpy, pandas, matplotlib | **Runtime** (entrypoint) | auto-adds `core`, `build-tools` |
| `datascience` | jupyter, jupyterlab, numpy, pandas, scipy, matplotlib, seaborn, plotly, R | **Runtime** (entrypoint) | auto-adds `core` |
| `security` | nmap, tcpdump, wireshark-common, john, hashcat, hydra | apt | auto-adds `core` |
| `embedded` | gcc-arm-none-eabi, gdb-multiarch, openocd, platformio | apt + uv tool | auto-adds `core` |

### Profile Type: Docker RUN vs Runtime

- **Docker RUN profiles** (rust, go, javascript, java): Installed during `docker build`. Baked into image. Fast on subsequent slot entry.
- **Runtime profiles** (python, ml, datascience): Installed by the docker-entrypoint when the container starts. Creates a venv at `~/.claudebox/.venv` using `uv`. Slower first entry but packages managed dynamically.
- **apt profiles** (c, core, ruby, php, etc.): Installed via `apt-get` during docker build.

### Python Projects

**Profile NOT required for basic Python.** The base image has `uv` pre-installed. You can:
```bash
# Inside container WITHOUT python profile:
uv venv .venv
source .venv/bin/activate
uv pip install <packages>
```

**Add `python` profile for dev tools:** If you want ipython, black, mypy, pylint, pytest, ruff, poetry, pipenv pre-installed in a managed venv at `~/.claudebox/.venv`:
```bash
# From HOST:
claudebox add python
claudebox slot 1 --dangerously-skip-permissions
```

**For ML/Data Science:** Use dedicated profiles that add heavy packages:
```bash
claudebox add ml          # torch, transformers, scikit-learn, numpy, pandas
claudebox add datascience # jupyter, scipy, matplotlib, seaborn, plotly, R
```

### TypeScript / JavaScript Projects

**Profile NOT required for basic Node.js.** The base image has Node.js LTS via NVM (Claude Code depends on it). You can:
```bash
# Inside container WITHOUT javascript profile:
node --version   # Works - Node LTS pre-installed
npm install      # Works - npm comes with Node
npx tsc          # Works - typescript via npx
```

**Add `javascript` profile for global tooling:** If you want typescript, eslint, prettier, yarn, pnpm available globally:
```bash
# From HOST:
claudebox add javascript
claudebox slot 1 --dangerously-skip-permissions
```

**Note:** The `javascript` profile installs NVM v0.39.3 (slightly newer than base image's v0.39.0) and adds global npm packages. For most projects, `npm install` in your project directory is sufficient without the profile.

### Rust Projects (TWO KNOWN BUGS)

**Bug 1 - PATH mismatch:** The `rust` profile runs `rustup` as `USER root`, installing to `/root/.cargo/`. But it sets `PATH="/home/claude/.cargo/bin:$PATH"` - wrong user's home.

**Bug 2 - Profile template broken (GitHub #91):** The `awk` template substitution for `{{PROFILE_INSTALLATIONS}}` is broken for profiles that install apt packages (core, c, build-tools, etc.). The literal `{{PROFILE_INSTALLATIONS}}` string ends up in RUN commands, causing docker build to fail. **Do NOT use `claudebox add c` or `claudebox add core`** until this is fixed upstream.

**Correct setup for Rust projects:**
```bash
# From HOST (one-time setup):
claudebox save --enable-sudo   # Required for sudo inside container
claudebox add rust             # Only the rust profile (no apt-based profiles)
claudebox slot 1 --dangerously-skip-permissions
```

**Inside container - install C toolchain, fix PATH, verify:**
```bash
# Install gcc (needed for linking) - requires --enable-sudo
sudo apt-get update && sudo apt-get install -y gcc g++ make pkg-config libssl-dev

# Fix PATH for Rust (profile installs to /root/.cargo/)
export PATH="/root/.cargo/bin:$HOME/.cargo/bin:$PATH"

# Verify
cargo --version && rustc --version && gcc --version
cargo build
```

**Note:** The `sudo apt-get install` packages are lost on image rebuild (`claudebox rebuild`, profile changes). Re-run after rebuilds.

**For ralph-loop sessions:** PROMPT0.md can handle the Rust bootstrap automatically (PATH fix + gcc install via sudo). The manual steps above are only needed for interactive sessions without PROMPT0.md.

### CRITICAL: Never manually install toolchains inside the container

**DO NOT** try to install rustup/cargo/go manually inside a running container. This leads to:
- Toolchain binaries in non-persistent locations (lost on container recreation)
- glibc version confusion (see below)
- Hours wasted on workarounds (patchelf, zig-cc, ARM toolchain wrappers)

**ALWAYS** use `claudebox add <profile>` from the host instead. If the profile has bugs (like the Rust USER mismatch), apply the workarounds above.

### The glibc Trap (Rust-specific)

ClaudeBox uses Debian Bookworm with glibc 2.36. Key facts:
- **rustc, cargo, rustup** need glibc 2.17 minimum - **work fine** on Bookworm
- **rust-analyzer** had a [known regression](https://github.com/rust-lang/rust-analyzer/issues/19215) (v0.3.2317) requiring glibc 2.39 on aarch64 - **fixed in v0.3.2328+** (March 2025, targets glibc 2.28)

If you see `GLIBC_2.39 not found`, it's almost certainly **rust-analyzer**, not the Rust compiler. Fix: `rustup component remove rust-analyzer` or update to latest.

**DO NOT** attempt patchelf, zig-as-cc, ARM toolchain loaders, or musl cross-compilation as workarounds.

## Git Worktrees

ClaudeBox keys projects by **directory path**, not branch:

| Scenario | Result |
|----------|--------|
| Same dir, switch branches | Same slots |
| New git worktree (new dir) | New ClaudeBox project |

---

# Creating an Optimal PROMPT.md

For autonomous development with `/ralph-loop`, create a `PROMPT.md` that drives continuous iteration.

## Structure

```markdown
# Project Name - Goal

Brief description of what you're building.

## Visual Target (if UI)
ASCII mockup showing the end state - gives Claude a concrete goal.

## Key Concepts
Table mapping concepts → where they appear → implementation notes.

## Tool Usage Requirements
Explicit instructions to use available tools:
- WebSearch before implementing
- MCP servers (context7, brave-search, github)
- Subagents for parallel work
- Skills (/tdd, /commit, /code-review)

## Project Structure
Directory tree showing expected layout.

## Data Models
Key structs/types with realistic field values.

## Phased Approach
Break into phases: Setup → Structure → Implementation → Polish

## Verification Checklist
What must pass before claiming "done":
- [ ] Build passes
- [ ] Tests pass
- [ ] Linter clean
- [ ] Manual verification

## Guardrails
### NEVER Do
- Skip commits
- Hallucinate APIs
- Leave FIXME.md empty

### ALWAYS Do
- Search before implementing
- Verify with cargo build / npm test / etc.
- Update CHANGELOG.md

## Tracking Files
- CHANGELOG.md - what changed per iteration
- FIXME.md - blockers for human review

## Success Criteria (Progressive)
Level 1: Compiles
Level 2: Renders/Runs
Level 3: With data
Level 4: Animated/Interactive
Level 5: Polished
```

## Best Practices

### 1. Be Concrete, Not Abstract
```markdown
# BAD
Build a nice dashboard

# GOOD
Build a TUI with 7 panels:
- Header: portfolio total, generation, time
- Chart: equity curve with Braille markers
- Leaderboard: sortable table with sparklines
[ASCII mockup here]
```

### 2. Specify Tool Usage
```markdown
## Required Tool Usage

Before writing ANY code:
1. WebSearch for current best practices
2. mcp__context7__query-docs for library APIs
3. mcp__github__search_code for examples

After writing code:
1. cargo build / npm run build
2. Launch code-reviewer agent
```

### 3. Include Anti-Hallucination Measures
```markdown
## Anti-Hallucination Checklist
- [ ] Verified API with docs/search
- [ ] Found working example
- [ ] Tested compilation
- [ ] Checked for deprecation warnings
```

### 4. Define Realistic Mock Data
```markdown
## Mock Data Ranges
- Prices: NVDA $800-900, AAPL $180-200
- Returns: Elite +10-25%, Bottom -15 to -25%
- Sharpe: Elite 1.5-2.5, Bottom -0.5 to 0.5
```

### 5. Continuous Loop Instructions
```markdown
## Completion
This prompt runs INDEFINITELY. No completion promise.
Keep improving until manually stopped.
If stuck, document in FIXME.md and try different approach.
```

### 6. Git Commit Format
```markdown
## Git Commits
[ralph] <type>: <description>

Types: feat, fix, refactor, style, docs, perf
Always commit working states.
```

## Starting Ralph Loop

After PROMPT.md is ready:
```bash
# From host (use claudebox shell for version control)
cd /path/to/project
claudebox shell

# Inside container shell:
npm install -g @anthropic-ai/claude-code@2.1.25  # first time only
DISABLE_AUTOUPDATER=1 claude --dangerously-skip-permissions

# Inside Claude - use full skill path syntax:
/ralph-loop:ralph-loop '<your prompt here>' --max-iterations 0
```

**Note:** The skill path is `ralph-loop:ralph-loop` (plugin:skill), not just `/ralph-loop`. Pass `--max-iterations 0` for unlimited iterations. Do NOT set `--completion-promise` unless you want it to stop.

### Prompt Template for Ralph Loop

The prompt must tell Claude: (1) what files to read, (2) how to verify the build, (3) what to work on, and critically (4) **never stop**. Example:

```
Read <project>/PROMPT.md — it contains architecture, data contract, and guardrails.
Also read <project>/CHANGELOG.md and <project>/FIXME.md for current state.
Then verify the build: cd <project> && cargo build && cargo clippy && cargo test.
If toolchain fails, see FIXME.md for fixes before doing anything else.
Assess actual code state yourself — don't assume CHANGELOG is complete.
Decide what needs work next. Write code ONLY in <project>/.
Update <project>/CHANGELOG.md after meaningful progress.
CRITICAL: You are in a ralph loop. NEVER declare yourself done.
NEVER output a summary and stop. At the end of each iteration,
immediately start the next task. Always end with action, never
with a status report. If all phases complete, optimize — improve
tests, fix bugs, tune parameters. There is always more to do.
```

The "NEVER summarize and stop" instruction is the most important part. Without it, Claude outputs a summary, ends its turn, the stop hook re-feeds the prompt, and Claude does the same summary again — effectively stalling.

### Why Ralph Loop Stops (and Fixes)

| Cause | What happens | Fix |
|-------|-------------|-----|
| Claude "completes" | Model outputs a summary and ends its turn thinking work is done | Add "NEVER declare yourself done" to prompt |
| Stop hook parse failure | `stop-hook.sh` can't extract last assistant message from transcript (malformed JSON, empty text, missing file) | Nothing you can do — this is a plugin bug. Loop silently dies |
| Context window exhaustion | Session context fills up after many iterations | Expected behavior. Claude auto-compacts. For very long sessions, keep iterations focused |
| State file corruption | `.claude/ralph-loop.local.md` YAML frontmatter gets corrupted (e.g., Claude edits it) | Add to PROMPT.md: "NEVER modify .claude/ralph-loop.local.md" |
| Completion promise detected | Claude outputs `<promise>TEXT</promise>` matching your `--completion-promise` | Don't set `--completion-promise` for indefinite loops |

**The state file** lives at `<project>/.claude/ralph-loop.local.md`. It's shared between host and container via the project mount. If you need to kill the loop from the HOST side, delete this file: `rm <project>/.claude/ralph-loop.local.md`

---

# Running Long Sessions

## Prevent Sleep (coffee function)

**Critical for ralph-loop:** Use the `coffee` function to disable lid sleep.

```bash
# In a separate terminal on HOST (not inside ClaudeBox)
coffee
```

This runs `sudo pmset -a disablesleep 1` which:
- Allows closing laptop lid without sleep
- Keeps Docker/Colima running
- Press `Ctrl+C` to restore normal sleep behavior

**Defined in:** `~/.functions` - uses `pmset disablesleep` for true lid-closed operation.

**Alternative (no lid close):**
```bash
caffeinate -dims  # Prevents sleep but lid must stay open
```

## Lid Close Behavior

**Without `coffee`:** Closing lid will:
- Kill network connections
- Corrupt Colima VM state
- Require `colima delete --force` to recover

**With `coffee`:** Safe to close lid - session continues.

## SSD Disconnection Recovery

If external SSD disconnects (cable bump, power issue):

1. Remount SSD
2. Delete corrupted VM:
   ```bash
   COLIMA_HOME="/Volumes/YourSSD/Sandbox/Colima" colima delete --force
   ```
3. Restart Colima:
   ```bash
   COLIMA_HOME="/Volumes/YourSSD/Sandbox/Colima" colima start \
     --cpu 4 --memory 8 --disk 60 --vm-type vz --runtime docker
   ```
4. Re-enter slot:
   ```bash
   claudebox slot 1  # Plugins and history still intact
   ```

**Slot data survives** - only the VM needs recreation.
