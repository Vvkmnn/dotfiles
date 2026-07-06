---
name: ralph-docker
author: Vvkmnn
description: Use when setting up isolated Claude Code development with Docker containers, when needing container sandbox for --dangerously-skip-permissions, when running ralph-loop autonomously, when troubleshooting ClaudeBox/Colima/Docker Desktop sandbox issues, when creating PROMPT.md for autonomous development. Trigger on "claudebox", "ralph docker", "sandbox", "ralph-loop setup".
version: 1.0.0
---

# Docker Sandbox for Claude Code

Run Claude Code with `--dangerously-skip-permissions` in isolated Docker containers. Two approaches documented — use what fits your situation and keep this skill updated as tooling evolves.

| Approach | Tool | Best for | Status |
|----------|------|----------|--------|
| **Primary** | ClaudeBox + Colima | Slots, profiles, external SSD, persistent sandbox | Active — what we use |
| **Fallback** | Docker Desktop `sandbox run` | Quick disposable runs, no setup needed | Legacy — kept for reference |

---

# ClaudeBox + Colima (Primary)

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

## Storage Options & Colima Startup

Colima startup (both storage options, sizing, SSD env vars) is owned by the `start-colima` skill — invoke it rather than duplicating commands here. Summary: external-SSD sets COLIMA_HOME + DOCKER_HOST; local needs nothing; both use `--cpu 4 --memory 8 --disk 60 --vm-type vz --runtime docker`.

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

## Troubleshooting & Full Reset

Moved to `references/troubleshooting.md` (incl. SSD disconnection recovery). Read on failure, not preemptively.

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

Per-language setups: `references/profiles.md`.

## Git Worktrees

ClaudeBox keys projects by **directory path**, not branch:

| Scenario | Result |
|----------|--------|
| Same dir, switch branches | Same slots |
| New git worktree (new dir) | New ClaudeBox project |

---

# Creating an Optimal PROMPT.md

For autonomous development with `/ralph-loop`, create a `PROMPT.md` that drives continuous iteration.

## PROMPT.md Scaffold

Full template (structure, guardrails, tracking files, success criteria, anti-hallucination checklist): `references/prompt-template.md` — copy it into the project, fill the brackets.

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
npm install && npm run build
```

### Missing completion promise

**Wrong:** "Build succeeds and tests pass."
**Right:** `Output <promise>COMPLETE</promise> ONLY when: build succeeds + tests pass`

### No escape hatch

Include an escape hatch with iteration limit and acceptable partial state. Partial working code > infinite loop on a blocker.

### Phase time estimates

- Simple file creation: 10-15 min
- Integration work: 20-30 min
- Complex features: 30-45 min
- Testing + verification: 10-20 min

## Language-Specific Verification

**Python:** `uv pip install -e ".[dev]" && pytest -v --cov=src`
**JavaScript/TypeScript:** `npm install && npm test && npm run build`
**Rust:** `cargo check && cargo test && cargo build --release`
**Go:** `go mod download && go test ./... && go build -o bin/app`
**Java/Kotlin:** `./gradlew test && ./gradlew build`

## Post-Ralph Verification Checklist

- [ ] `git log` shows Ralph's commits
- [ ] Build command from PROMPT.md succeeds
- [ ] Tests pass (or failures documented in BLOCKERS.md)
- [ ] No changes outside project directory
- [ ] If BLOCKERS.md exists, it explains what stopped progress

## Integration with Other Skills

**Before Ralph:** `superpowers:brainstorming`, `superpowers:writing-plans`, `superpowers:using-git-worktrees`
**After Ralph:** `superpowers:verification-before-completion`, `superpowers:requesting-code-review`, `superpowers:finishing-a-development-branch`

---

# Docker Desktop Sandbox (Fallback)

If ClaudeBox/Colima is unavailable or you need a quick disposable run, Docker Desktop 4.50+ has a built-in sandbox:

```bash
docker sandbox run claude
```

This creates a disposable container with your project mounted, `--dangerously-skip-permissions` enabled by default, filesystem isolated from host. All system changes disappear on exit — only project files persist.

Inside the sandbox, install Ralph and run as usual:
```bash
/plugin install ralph-wiggum@claude-plugins-official
/ralph-loop "$(cat PROMPT.md)" --max-iterations 40 --timeout 120 --completion-promise "COMPLETE"
```

**Limitations vs ClaudeBox:** No slots, no profiles, no external SSD support, no persistence between sessions. Use for quick disposable runs when ClaudeBox isn't set up.

**Docs:** https://docs.docker.com/ai/sandboxes/claude-code/

---

# Keeping This Skill Current

Docker-based Claude sandboxing is evolving fast. Update this skill when:
- ClaudeBox releases fix known bugs (profile template #91, `claudebox install`)
- Docker Desktop sandbox gains new features (slots, persistence, profiles)
- Claude Code container regressions are fixed (v2.1.27 freeze) or new ones appear
- New sandboxing approaches emerge (e.g., native Claude Code sandbox mode)
- Our workflow preferences change (different profile combos, SSD vs local, etc.)

**Last reviewed:** 2026-02-23
