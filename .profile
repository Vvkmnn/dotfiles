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

####################################################
# ~/.profile - Environment variables and PATH setup
####################################################
# Purpose: Comprehensive environment for interactive
#          and login shells, inherited by IDEs/GUIs
#
# Loaded by: ~/.zprofile → here (login shells)
#            ~/.rc sources this second
#
# Sets: XDG dirs, locale, EDITOR, GPG/SSH auth
#       Development PATH for Homebrew, Python,
#       Node, Ruby, Go, Rust, LaTeX, Claude Code
#       Platform-specific (macOS/Linux), Conda
####################################################

# GUARD Prevent double-sourcing and skip in AI sandbox
[ -n "$__PROFILE_SOURCED" ] && return
__PROFILE_SOURCED=1
[ -n "$AI_SANDBOX_ONLY" ] && return

## Environment -------------------------------------

# XDG
export XDG_CONFIG_HOME="$HOME/.config"

# Params
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export BROWSER=open
# export TERM=xterm
export TERM=xterm-256color
export ARCHEY_LOGO_FILE=$HOME/.logo

# Home
# export OPENCODE_CONFIG=/Users/v/.config/opencode/opencode.json

# Editor
export EDITOR='nvim'           # $EDITOR is the default for most shells
export VISUAL=$EDITOR          # $VISUAL in case
export ALTERNATE_EDITOR='nvim' # $EDITOR if all else fails

# AI
# export OPENAI_API_KEY=$(cat ~/.openai)

# Claude Code Optimization
# TODO: Figure out what tehse do with claude code first
# export MAX_THINKING_TOKENS=10000
# export CLAUDE_CODE_MAX_OUTPUT_TOKENS=4000
export UTCP_CONFIG_FILE="$HOME/.utcp_config.json"

# opencode
export PATH=/Users/v/.opencode/bin:$PATH

# Node.js memory for Claude CLI
export NODE_OPTIONS="--max-old-space-size=8192"

# Prompt
# FIX Not global
# export RPROMPT='v@%M %(?,%F{green}[-_-]%f,%F{red}[ಠ_ಠ]%f)'
# export PROMPT=' ॐ  '

# GPG
export GPG_TTY=$(tty)
export SSH_AUTH_SOCK=~/.gnupg/S.gpg-agent.ssh

# OS=$(uname -s)

case "$(uname -s)" in
Linux) ;;

Darwin)
	# Cache brew prefix (saves ~100ms per call)
	HOMEBREW_PREFIX="/opt/homebrew"

	# PostgreSQL (optimized with cached prefix)
	export PATH="$HOMEBREW_PREFIX/opt/postgresql@17/bin:$PATH"

	# windsurf
	export PATH="/Users/v/.codeium/windsurf/bin:$PATH"

	# Prompt
	# export PURE_PROMPT_SYMBOL="ॐ "

	# Homebrew (Apple Silicon optimized)
	export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
	export HOMEBREW_CASK_OPTS="--appdir=/Applications"

	# Legacy Intel brew paths (compatibility)
	export PATH="/usr/local/bin:/usr/local/sbin:$PATH"

	# openSSL
	export LDFLAGS="-L/usr/local/opt/openssl/lib"
	export CPPFLAGS="-I/usr/local/opt/openssl/include"
	export PKG_CONFIG_PATH="/usr/local/opt/openssl/lib/pkgconfig"

	# llvm
	export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
	export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
	export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"

	# emacs/pdf-tools
	# export PKG_CONFIG_PATH=/usr/local/Cellar/zlib/1.2.8/lib/pkgconfig:/usr/local/lib/pkgconfig:/opt/X11/lib/pkgconfig

	## Personal ----------------------------------------

	export PATH="$HOME/Documents/bin:$PATH"

	## brew
	export PATH="/usr/local/sbin:$PATH"

	## openSSL
	export PATH="/usr/local/opt/openssl/bin:$PATH"

	# Python (optimized with cached prefix)
	# export PATH="$HOMEBREW_PREFIX/opt/python@3.13/libexec/bin:$PATH"
	# export PATH=/usr/local/share/python:$PATH
	# export PYENV_ROOT="$HOME/.pyenv"
	# command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
	# eval "$(pyenv init -)"

	# Python (Anaconda)
	# export PATH="$HOME/.miniconda/bin:$PATH"
	# export PATH="/usr/local/anaconda3/bin:$PATH"

	# >>> conda initialize >>>
	# !! Contents within this block are managed by 'conda init' !!
	# __conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2>/dev/null)"
	# if [ $? -eq 0 ]; then
	# 	eval "$__conda_setup"
	# else
	# 	if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
	# 		. "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
	# 	else
	# 		export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
	# 	fi
	# fi
	# unset __conda_setup
	# <<< conda initialize <<<

	# Rust
	#. "$HOME/.cargo/env"

	# Ruby
	export PATH="/usr/local/opt/ruby/bin:$PATH"

	# Node (NVM)
	# export PATH="$HOME/.nvm/versions/node/v12.1.0/bin:$PATH"

	# LaTeX
	export PATH="/Library/TeX/texbin:$PATH"

	# Emacs (Doom)
	export PATH="$HOME/.emacs.d/bin:$PATH"
	export PATH="$HOME/.config/doom/bin:$PATH"
	export PATH="$HOME/v.doom.d/bin:$PATH"

	# Clang
	export CPATH=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include

	# Go
	# export GOROOT="$(brew --prefix golang)/libexec"
	# export GOPATH=$HOME/Documents/dev/go
	# export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

	# LLVM
	export PATH="/usr/local/opt/llvm/bin:$PATH"

	# Go
	export GOROOT=/usr/local/Cellar/go/1.13.4/libexec
	export GOPATH=$HOME/Documents/dev/go
	export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

	# MacOS (Brew) Emacs
	# export PATH="/Applications/Emacs.app/Contents/MacOS/bin:$PATH"

	# Local bin (prioritize for Claude Code, uv, pipx, etc.)
	export PATH="$HOME/.local/bin:$PATH"

	# PNPM
	# export PNPM_HOME="$HOME/Library/pnpm"
	# case ":$PATH:" in
	# *":$PNPM_HOME:"*) ;;
	# *) export PATH="$PNPM_HOME:$PATH" ;;
	# esac

	## Fun ---------------------------------------------
	export PATH="/Applications/Alacritty.app/Contents/MacOS/:$PATH"

	## Work --------------------------------------------
	# PATH="$HOME/Documents/lake/lake-hydra/bin:$PATH"

	# uv (Python package manager)
	. "$HOME/.local/bin/env"

	# . "$HOME/.cargo/env"

	# . "$HOME/.grit/bin/env"

	;;

CYGWIN* | MINGW32* | MSYS* | MINGW*)
	echo '[¬_¬] Loading Windows environment...'
	;;

esac

# Zsh Theme
# [ -f ~/.theme ] && . ~/.theme

# Source Xorg settings
# TODO Causes some dangerous bugs
# [ -f ~/.xprofile ] && . ~/.xprofile

# GO
# export PATH="$HOME/go/bin:$PATH"
# export GOPATH=$HOME/go/bin

# # Python
# export PATH="$HOME/.local/bin:$PATH"
# export PYTHONPATH=$HOME/.local/bin

# # Emacs (Doom)
# export PATH="$HOME/.emacs.d/bin:$PATH"

# Load
# echo '[¬_¬]...'

# . "$HOME/.cargo/env"

# . "$HOME/.grit/bin/env"

# Antigravity
[ -d "$HOME/.antigravity/antigravity/bin" ] && export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
