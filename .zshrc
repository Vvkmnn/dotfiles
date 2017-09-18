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
# ##############               ##       ############
# ##################                ################
# ##################################################
# ##################################################

## Personal Defaults -------------------------------

# Exports
export LANG=en_US.UTF-8
export BROWSER=open
export TERM=xterm-256color
export EDITOR=vim

# macVim
alias vim='mvim -v'

# Dotfiles
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

# Aliases
# source $HOME/.aliases

## Environment Defaults ----------------------------

# Path
export PATH="/usr/local/bin:$PATH"

# Homebrew Cask
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
 
# RVM
# export PATH="$PATH:$HOME/.rvm/bin"

# Google Cloud
if [ -f "${HOME}/.google/google-cloud-sdk/path.zsh.inc" ]; then source "${HOME}/.google/google-cloud-sdk/path.zsh.inc"; fi
if [ -f "${HOME}/.google/google-cloud-sdk/completion.zsh.inc" ]; then source "${HOME}/.google/google-cloud-sdk/completion.zsh.inc"; fi

# Anaconda
export PATH="${HOME}/.anaconda/bin:$PATH"

# Iterm2
test -e "${HOME}/.iterm2/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2/.iterm2_shell_integration.zsh"

# Go lang
export GOPATH="$HOME/.go"
export PATH="$GOPATH/bin:$PATH"

## Shell Defaults ----------------------------------

# Spaceship Theme 
SPACESHIP_PROMPT_SYMBOL="ॐ "
SPACESHIP_PROMPT_SEPARATE_LINE=true
SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_PROMPT_COLOR=red
SPACESHIP_DIR_TRUNC=3
SPACESHIP_TIME_SHOW=true
SPACESHIP_TIME_COLOR=blue
SPACESHIP_BATTERY_SHOW=false
SPACESHIP_BATTERY_ALWAYS_SHOW=false
SPACESHIP_VI_MODE_COLOR=cyan
SPACESHIP_VI_MODE_INSERT=𝛁 # Nabla, normal mode
SPACESHIP_VI_MODE_NORMAL=𝚫 # Delta, edit mode
SPACESHIP_PYENV_SHOW=false
SPACESHIP_CONDA_SHOW=true

# Vim in Zsh
bindkey -v
KEYTIMEOUT=1

# Little Helper!
RPROMPT='v@%M %(?,%F{green}[-_-]%f,%F{red}[ಠ_ಠ]%f)'
ZLE_LPROMPT_INDENT=0

## Shell Plugins -----------------------------------

# Zplug (Zsh Plugin Manager)
source ~/.zplug/init.zsh

# Autosuggestions
zplug "zsh-users/zsh-autosuggestions"

# Syntax highlighting
zplug "zsh-users/zsh-syntax-highlighting", defer:2

# Sublime Support
# zplug "plugins/sublime", from:oh-my-zsh

# Vi(m) Mode
zplug "plugins/vi-mode", from:oh-my-zsh

# Git Plugin
zplug "plugins/git", from:oh-my-zsh

# Spaceship Theme
zplug "denysdovhan/spaceship-zsh-theme", use:spaceship.zsh, from:github, as:theme

# Athame (Vim in Shell)
# zplug "ardagnir/athame"

# Autoenv for Zsh
zplug "zpm-zsh/autoenv"

# Z - jump around
zplug "rupa/z", use:z.sh

# Dracula theme for zsh
# zplug 'dracula/zsh', as:theme

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
	printf "Install? [y/N]: "
	if read -q; then
		echo; zplug install
	fi
fi

# Then, source plugins and add commands to $PATH
zplug load # --verbose
