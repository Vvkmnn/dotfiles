#! /usr/bin/env bash
# Vivek Menon - vvkmnn.xyz

# ##################################################
# ##################################################
# ######################        ####################
# ################                    ##############
# #############                #######   ###########
# ###########                #########     #########
# #########                 ########         #######
# ########                  ######            ######
# #######                   ######             #####
# ######            ####### ######              ####
# #####           ######### ######               ###
# #####           #######   ######               ###
# #####            ######    #####               ###
# #####             ######    ####               ###
# #####              ######    ###               ###
# #####               ######    #                ###
# ######               ######                   ####
# #######               #####                  #####
# ########               #####                ######
# ##########              #####             ########
# ############             #####          ##########
# ##############            #####       ############
# ##################                ################
# ##################################################
# ##################################################

## Environment -------------------------------------

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export BROWSER=open
export TERM=xterm-256color
export ARCHEY_LOGO_FILE=$HOME/.logo
# Editor
export EDITOR='vim'           # $VISUAL is the default for most shells
export EDITOR=$VISUAL         # $EDITOR in case
export ALTERNATE_EDITOR='vim' # $EDITOR if all else fails

# Prompt
export RPROMPT='v@%M %(?,%F{green}[-_-]%f,%F{red}[ಠ_ಠ]%f)'
export PROMPT=' ॐ  '

 #OS=$(uname -s)
# case "$(uname -s)" in
#     Linux)
# ;;
# 
#     Darwin)
# 	echo '[¬_¬] Loading macOS environment...'
# 	# Prompt
# 	export PURE_PROMPT_SYMBOL="ॐ "
# 
# 	# Brew
# 	export HOMEBREW_CASK_OPTS="--appdir=/Applications"
# 
# 	# openSSL
# 	export LDFLAGS="-L/usr/local/opt/openssl/lib"
# 	export CPPFLAGS="-I/usr/local/opt/openssl/include"
# 	export PKG_CONFIG_PATH="/usr/local/opt/openssl/lib/pkgconfig"
# 
# 	# llvm
# 	export LDFLAGS="-L/usr/local/opt/llvm/lib"
# 	export CPPFLAGS="-I/usr/local/opt/llvm/include"
# 
# 	# emacs/pdf-tools
# 	# export PKG_CONFIG_PATH=/usr/local/Cellar/zlib/1.2.8/lib/pkgconfig:/usr/local/lib/pkgconfig:/opt/X11/lib/pkgconfig
# 
# 	## Personal ----------------------------------------
# 
# 	export PATH="$HOME/Documents/bin:$PATH"
# 	# export PATH="$HOME/Documents/dev/github-jack:$PATH"
# 
# 	## brew
# 	export PATH="/usr/local/sbin:$PATH"
# 
# 	## openSSL
# 	export PATH="/usr/local/opt/openssl/bin:$PATH"
# 
# 	# Python (Anaconda)
# 	# PATH="$HOME/.miniconda/bin:$PATH"
# 	export PATH="/usr/local/anaconda3/bin:$PATH"
# 
# 	# Ruby
# 	export PATH="/usr/local/opt/ruby/bin:$PATH"
# 
# 	# Node (NVM)
# 	# export PATH="$HOME/.nvm/versions/node/v12.1.0/bin:$PATH"
# 
# 	# LaTeX
# 	export PATH="/Library/TeX/texbin:$PATH"
# 
# 	# Emacs (Doom)
# 	export PATH="$HOME/.emacs.d/bin:$PATH"
# 
# 	# Clang
# 	export CPATH=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include
# 
# 	# Go
# 	export GOROOT=/usr/local/Cellar/go/1.13.4/libexec
# 	export GOPATH=$HOME/Documents/dev/go
# 	export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
# 
# 	# LLVM
# 	export PATH="/usr/local/opt/llvm/bin:$PATH"
# 
# 	# Go
# 	export GOROOT=/usr/local/Cellar/go/1.13.4/libexec
# 	export GOPATH=$HOME/Documents/dev/go
# 	export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
# 
# 	# MacOS (Brew) Emacs
# 	# export PATH="/Applications/Emacs.app/Contents/MacOS/bin:$PATH"
# 
# 	## Fun ---------------------------------------------
# 	export PATH="/Applications/Alacritty.app/Contents/MacOS/:$PATH"
# 
# 	## Work --------------------------------------------
# 	# PATH="$HOME/Documents/lake/lake-hydra/bin:$PATH"
# 	;;
# 
#     CYGWIN* | MINGW32* | MSYS* | MINGW*)
# 	echo '[¬_¬] Loading Windows environment...'
# 	;;
# 
# esac


# Zsh Theme
# [ -f ~/.theme ] && . ~/.theme

# Source Xorg settings
# TODO Causes some dangerous bugs
# [ -f ~/.xprofile ] && . ~/.xprofile

# GO
export PATH="$HOME/go/bin:$PATH"
export GOPATH=$HOME/go/bin

# Python
export PATH="$HOME/.local/bin:$PATH"
export PYTHONPATH=$HOME/.local/bin

# NVM
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# Emacs (Doom)
export PATH="$HOME/.emacs.d/bin:$PATH"

# Load
# echo '[¬_¬]...'





