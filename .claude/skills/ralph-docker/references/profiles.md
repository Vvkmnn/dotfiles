# Development Profiles

> Moved verbatim from SKILL.md (lines 309-440) in the 2026-07-06 restructure — per-language claudebox profile setups. Load when configuring a slot.

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

