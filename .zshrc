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
export LANG=en_US.UTF-8
export BROWSER=open
export TERM=xterm-256color
export EDITOR=vim

# Path
export PATH="/usr/local/bin:$PATH"

# Dotfiles
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

# Aliases
# source $HOME/.aliases

## Application Defaults

# Homebrew Cask
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
 
# RVM
# export PATH="$PATH:$HOME/.rvm/bin"


# Google Go
# export GOPATH=~/Code/Go

# Google Cloud
if [ -f "${HOME}/.google-cloud/google-cloud-sdk/path.zsh.inc" ]; then source "${HOME}/.google-cloud/google-cloud-sdk/path.zsh.inc"; fi
if [ -f "${HOME}/.google-cloud/google-cloud-sdk/completion.zsh.inc" ]; then source "${HOME}/.google-cloud/google-cloud-sdk/completion.zsh.inc"; fi

# Anaconda
# export PATH="${HOME}/.anaconda/bin:$PATH"

# Iterm2
test -e "${HOME}/.iterm2/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2/.iterm2_shell_integration.zsh"

# Autoenv - Load .envs automagically
# source /usr/local/opt/autoenv/activate.sh

## Shell Defaults -------------------------------

ZLE_LPROMPT_INDENT=0

# Spaceship
SPACESHIP_PROMPT_SYMBOL="ॐ "
SPACESHIP_PROMPT_SEPARATE_LINE=true
SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_PROMPT_COLOR=blue
SPACESHIP_DIR_TRUNC=3
SPACESHIP_TIME_SHOW=true
SPACESHIP_TIME_COLOR=blue
SPACESHIP_BATTERY_SHOW=false
SPACESHIP_BATTERY_ALWAYS_SHOW=false
SPACESHIP_VI_MODE_COLOR=cyan
SPACESHIP_VI_MODE_INSERT=𝛁
SPACESHIP_VI_MODE_NORMAL=𝚫

# Vim Promprt
export RPS1="%{$reset_color%}"

# Vim in Zsh
bindkey -v
KEYTIMEOUT=1

# Little Helper!
RPROMPT='v@%M %(?,%F{green}[-_-]%f,%F{red}[ಠ_ಠ]%f)'

# Zplug
source ~/.zplug/init.zsh

# Autosuggestions
zplug "zsh-users/zsh-autosuggestions"

# Syntax highlighting
zplug "zsh-users/zsh-syntax-highlighting", defer:2

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
