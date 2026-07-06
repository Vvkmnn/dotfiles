# Troubleshooting, Full Reset & SSD Recovery

> Moved verbatim from SKILL.md (lines 183-248 + 663-691) in the 2026-07-06 restructure.

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

---

# PROMPT.md Common Mistakes

### Vague phase instructions

**Wrong:**
```markdown
