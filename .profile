#!/usr/bin/env sh
# Vivek Menon - vvkmnn.xyz

##################################################
##################################################
######################        ####################
################                    ##############
#############                #######   ###########
###########                #########     #########
#########                 ########         #######
########                  ######            ######
#######                   ######             #####
######            ####### ######              ####
#####           ######### ######               ###
#####           #######   ######               ###
#####            ######    #####               ###
#####             ######    ####               ###
#####              ######    ###               ###
#####               ######    #                ###
######               ######                   ####
#######               #####                  #####
########               #####                ######
##########              #####             ########
############             #####          ##########
##############            #####       ############
##################                ################
##################################################
##################################################

# ┌──────────────────────────────── ~/.profile ─ Environment variables ────────┐
#  Vivek Menon <mail@vvkmnn.xyz>
# └────────────────────────────────────────────────────────────────────────────┘
#  Purpose: Set environment variables and PATH for all shells
#  Contains: XDG, locale, editor, AI tools, security, platform-specific
#  Architecture: Uses path_prepend() helper to dedupe PATH

# ┌───────────────────────────────────────────────────────────────── guard ────┐
  [ -n "$__PROFILE_SOURCED" ] && return
  __PROFILE_SOURCED=1
  # scale: per-machine truth layer (heap, jobs, role…) — the ONLY hw-detection file
  [ -f "$HOME/.ai/scale" ] && . "$HOME/.ai/scale"
  [ -n "$AI_SANDBOX_ONLY" ] && return
# └────────────────────────────────────────────────────────────────────────────┘

# ┌────────────────────────────────────────────────────────────────── helper ──┐
  # add to PATH only if not already present
  path_prepend() { [[ ":$PATH:" != *":$1:"* ]] && PATH="$1:$PATH"; }
# └────────────────────────────────────────────────────────────────────────────┘

# ┌───────────────────────────────────────────────────────────────────── xdg ──┐
  export XDG_CONFIG_HOME="$HOME/.config"
# └────────────────────────────────────────────────────────────────────────────┘

# ┌────────────────────────────────────────────────────────────────── locale ──┐
  export LANG=en_US.UTF-8
  export LC_ALL=en_US.UTF-8
# └────────────────────────────────────────────────────────────────────────────┘

# ┌────────────────────────────────────────────────────────────────── editor ──┐
  export EDITOR='nvim'
  export VISUAL=$EDITOR
  export ALTERNATE_EDITOR='nvim'
# └────────────────────────────────────────────────────────────────────────────┘

# ┌─────────────────────────────────────────────────────────────── terminal ───┐
  export BROWSER=open
  export TERM=xterm-256color
  export ARCHEY_LOGO_FILE=$HOME/.logo
# └────────────────────────────────────────────────────────────────────────────┘

# ┌───────────────────────────────────────────────────────────────────── ai ───┐
  export NODE_OPTIONS="--max-old-space-size=${SCALE_NODE_HEAP_MB:-4096}"  # scaled by ~/.ai/scale (was hardcoded 8192)
  export UTCP_CONFIG_FILE="$HOME/.utcp_config.json"
  path_prepend "/Users/v/.opencode/bin"

  # Claude Code privacy (2026-02-02)
  export CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1
  # 2026-05-19: DISABLE_TELEMETRY commented out — silently disables GrowthBook feature
  # flag evaluation, which hides Remote Control (/rc, claude remote-control) and other
  # gated commands. Bug: anthropics/claude-code#29580. Re-enable once decoupled.
  # export DISABLE_TELEMETRY=1
  export DISABLE_ERROR_REPORTING=1
# └────────────────────────────────────────────────────────────────────────────┘

# ┌────────────────────────────────────────────────────────────────── docker ──┐
  # Standard: local Colima (~/.colima) — docker uses its default context, no env needed.
  # OPTIONAL escape hatch (low local storage): if Colima was set up on the vSSD, point
  # docker at it. Auto-activates ONLY when that dir exists — never the fleet default.
  if [ -d "/Volumes/vSSD/Sandbox/Colima" ]; then
    export COLIMA_HOME="/Volumes/vSSD/Sandbox/Colima"
    export DOCKER_HOST="unix://$COLIMA_HOME/docker.sock"
  else
    # Clear any stale/inherited value (e.g. an old `launchctl setenv`) so docker
    # falls back to the default local Colima context.
    unset COLIMA_HOME DOCKER_HOST 2>/dev/null
  fi
# └────────────────────────────────────────────────────────────────────────────┘

# ┌─────────────────────────────────────────────────────────────── security ───┐
  export GPG_TTY=$(tty)
  # SSH_AUTH_SOCK set once in .zshenv/.minimal → 1Password; the old gpg-agent SSH socket was dead.
# └────────────────────────────────────────────────────────────────────────────┘

# ┌─────────────────────────────────────────────────────────────── platform ───┐
  case "$(uname -s)" in
  Darwin)
      HOMEBREW_PREFIX="/opt/homebrew"
      export HOMEBREW_CASK_OPTS="--appdir=/Applications"

      # ────────────────────────────────────────────────────────────────── bin ──
      path_prepend "$HOME/Documents/bin"
      path_prepend "$HOMEBREW_PREFIX/opt/postgresql@17/bin"
      path_prepend "/Users/v/.codeium/windsurf/bin"
      path_prepend "/Library/TeX/texbin"
      path_prepend "/Applications/Alacritty.app/Contents/MacOS/"

      # ────────────────────────────────────────────────────────────── emacs ──
      path_prepend "$HOME/.emacs.d/bin"
      path_prepend "$HOME/.config/doom/bin"
      path_prepend "$HOME/v.doom.d/bin"

      # ─────────────────────────────────────────────────────────────── ruby ──
      path_prepend "/usr/local/opt/ruby/bin"

      # ────────────────────────────────────────────────────────────── build ──
      # openssl
      path_prepend "/usr/local/opt/openssl/bin"
      export LDFLAGS="-L/usr/local/opt/openssl/lib"
      export CPPFLAGS="-I/usr/local/opt/openssl/include"
      export PKG_CONFIG_PATH="/usr/local/opt/openssl/lib/pkgconfig"
      # llvm (append to openssl flags)
      path_prepend "$HOMEBREW_PREFIX/opt/llvm/bin"
      export LDFLAGS="$LDFLAGS -L$HOMEBREW_PREFIX/opt/llvm/lib"
      export CPPFLAGS="$CPPFLAGS -I$HOMEBREW_PREFIX/opt/llvm/include"
      # llvm intel (legacy)
      path_prepend "/usr/local/opt/llvm/bin"
      # xcode sdk
      export CPATH=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include

      # ───────────────────────────────────────────────────────────────── go ──
      # Clean-home pattern: ~/Local is for WORK/projects (visible); toolchain caches stay
      # hidden in $HOME (like .cargo/.npm). Go's GOPATH (module cache + compiled bins) → ~/.go.
      export GOROOT="$(brew --prefix go 2>/dev/null)/libexec"
      export GOPATH="$HOME/.go"
      export GOBIN="$HOME/.go/bin"
      export PATH="$GOBIN:$PATH"

      # ────────────────────────────────────────────────────────────── python ──
      # uv's standalone installer drops ~/.local/bin/env; brew-managed uv does not.
      # Guard the source so a missing file doesn't error on every shell start.
      [ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
      ;;
  Linux) ;;
  CYGWIN* | MINGW32* | MSYS* | MINGW*)
      echo '[¬_¬] Loading Windows environment...'
      ;;
  esac
# └────────────────────────────────────────────────────────────────────────────┘

# ┌──────────────────────────────────────────────────────────────── archive ───┐
  # antigravity (conditional)
  [ -d "$HOME/.antigravity/antigravity/bin" ] && export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

  # openai api
  # export OPENAI_API_KEY=$(cat ~/.openai)

  # claude code optimization (unknown purpose)
  # export MAX_THINKING_TOKENS=10000
  # export CLAUDE_CODE_MAX_OUTPUT_TOKENS=4000

  # opencode config
  # export OPENCODE_CONFIG=/Users/v/.config/opencode/opencode.json

  # prompt symbols
  # export PURE_PROMPT_SYMBOL="ॐ "
  # export RPROMPT='v@%M %(?,%F{green}[-_-]%f,%F{red}[ಠ_ಠ]%f)'
  # export PROMPT=' ॐ  '

  # term alternatives
  # export TERM=xterm

  # homebrew paths (already in PATH via ~/.minimal)
  # export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
  # export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
  # export PATH="/usr/local/sbin:$PATH"

  # emacs pdf-tools
  # export PKG_CONFIG_PATH=/usr/local/Cellar/zlib/1.2.8/lib/pkgconfig:/usr/local/lib/pkgconfig:/opt/X11/lib/pkgconfig

  # python pyenv
  # export PATH="$HOMEBREW_PREFIX/opt/python@3.13/libexec/bin:$PATH"
  # export PATH=/usr/local/share/python:$PATH
  # export PYENV_ROOT="$HOME/.pyenv"
  # command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
  # eval "$(pyenv init -)"

  # python anaconda/conda
  # export PATH="$HOME/.miniconda/bin:$PATH"
  # export PATH="/usr/local/anaconda3/bin:$PATH"
  # __conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2>/dev/null)"

  # rust cargo (on demand)
  # . "$HOME/.cargo/env"

  # node nvm
  # export PATH="$HOME/.nvm/versions/node/v12.1.0/bin:$PATH"

  # go alternative
  # export GOROOT="$(brew --prefix golang)/libexec"
  # export GOPATH=$HOME/Documents/dev/go
  # export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
  # export PATH="$HOME/go/bin:$PATH"
  # export GOPATH=$HOME/go/bin

  # emacs macos app
  # export PATH="/Applications/Emacs.app/Contents/MacOS/bin:$PATH"

  # local bin (already in PATH via ~/.minimal)
  # export PATH="$HOME/.local/bin:$PATH"
  # export PYTHONPATH=$HOME/.local/bin

  # pnpm
  # export PNPM_HOME="$HOME/Library/pnpm"
  # case ":$PATH:" in
  # *":$PNPM_HOME:"*) ;;
  # *) export PATH="$PNPM_HOME:$PATH" ;;
  # esac

  # work lake-hydra
  # PATH="$HOME/Documents/lake/lake-hydra/bin:$PATH"

  # grit
  # . "$HOME/.grit/bin/env"

  # zsh theme
  # [ -f ~/.theme ] && . ~/.theme

  # xorg settings (causes bugs)
  # [ -f ~/.xprofile ] && . ~/.xprofile
# └────────────────────────────────────────────────────────────────────────────┘
