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

## Environment -------------------------------------

# XDG
export XDG_CONFIG_HOME="$HOME/.config"

# Params
export LANG=en_US.iso88591
export LC_ALL=en_US.UTF-8
export BROWSER=open
# export TERM=xterm
export TERM=xterm-256color
export ARCHEY_LOGO_FILE=$HOME/.logo
export DISPLAY=:0

# Editor
export EDITOR='nvim'           # $EDITOR is the default for most shells
export VISUAL=$EDITOR          # $VISUAL in case
export ALTERNATE_EDITOR='nvim' # $EDITOR if all else fails

# Prompt
# FIX Not global
# export RPROMPT='v@%M %(?,%F{green}[-_-]%f,%F{red}[ಠ_ಠ]%f)'
# export PROMPT=' ॐ  '

# OS=$(uname -s)

case "$(uname -s)" in
     Linux) 
	# Emacs (Doom)
	# export PATH="$HOME/.emacs.d/bin:$PATH"
	export PATH="$HOME/.config/emacs/bin:$PATH"

	;;
    Darwin)
        # Prompt
        # export PURE_PROMPT_SYMBOL="ॐ "

	## brew
	export PATH="/usr/local/bin:$PATH"
	export PATH="/usr/local/sbin:$PATH"

	# Brew
	export HOMEBREW_CASK_OPTS="--appdir=/Applications"

	# tmux
	export PATH="/opt/homebrew/bin:$PATH"

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

	# Python
	# export python="/usr/bin/python3"
	# export PATH=/usr/local/share/python:$PATH

        # pipx
        export PATH="$PATH:/home/v/.local/bin"

	# Python (Anaconda)
	export PATH="$HOME/.miniconda/bin:$PATH"
	export PATH="/usr/local/anaconda3/bin:$PATH"

	# >>> conda initialize >>>
	# !! Contents within this block are managed by 'conda init' !!
	__conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2>/dev/null)"
	if [ $? -eq 0 ]; then
		eval "$__conda_setup"
	else
		if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
			. "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
		else
			export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
		fi
	fi
	unset __conda_setup
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
	# export PATH="$HOME/.emacs.d/bin:$PATH"
	export PATH="$HOME/.config/emacs/bin:$PATH"

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

	## Fun ---------------------------------------------
	export PATH="/Applications/Alacritty.app/Contents/MacOS/:$PATH"

	## Work --------------------------------------------
	# PATH="$HOME/Documents/lake/lake-hydra/bin:$PATH"
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
<<<<<<< HEAD


# Created by `pipx` on 2024-02-05 16:01:08
export PATH="$PATH:/home/v/.local/bin"
=======
>>>>>>> origin/v-macos-macbook
