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
export EDITOR=vim
export TERM=xterm-256color

# Editors
# neoVim & Vscode
alias v='nvim'
alias vs='code'

# Dotfiles
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

# Aliases
# source $HOME/.aliases

## Environment Defaults ----------------------------

# Path
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/.vimr:$PATH"

# Homebrew Cask
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
 
# RVM
# export PATH="$PATH:$HOME/.rvm/bin"

# Google Cloud
if [ -f "${HOME}/.google/path.zsh.inc" ]; then source "${HOME}/.google/path.zsh.inc"; fi
if [ -f "${HOME}/.google/completion.zsh.inc" ]; then source "${HOME}/.google/completion.zsh.inc"; fi

# Anaconda
export PATH="${HOME}/.anaconda/bin:$PATH"

# Iterm2
test -e "${HOME}/.iterm2/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2/.iterm2_shell_integration.zsh"

# Go 
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
# SPACESHIP_VI_MODE_INSERT=𝛁 # Nabla, normal mode
# SPACESHIP_VI_MODE_NORMAL=𝚫 # Delta, edit mode
SPACESHIP_PYENV_SHOW=false
SPACESHIP_CONDA_SHOW=true

# Vim in Zsh
bindkey -v
KEYTIMEOUT=1

# Little Helper!
RPROMPT='v@%M %(?,%F{green}[-_-]%f,%F{red}[ಠ_ಠ]%f)'
ZLE_LPROMPT_INDENT=0

## Shell Plugins -----------------------------------

# Install Zplug (if missing)
if [[ ! -d ~/.zplug ]]; then
  git clone https://github.com/zplug/zplug ~/.zplug
fi

# Initialize and Update
source ~/.zplug/init.zsh && zplug update 

# Autosuggestions
zplug "zsh-users/zsh-autosuggestions"

# Autocompletions
zplug "zsh-users/zsh-completions", from:oh-my-zsh

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

# z - jump around
zplug "rupa/z", use:z.sh

# v - jump into vim!
# zplug "meain/v"

# Fzf-z -- Z and fzf play nice
zplug "andrewferrier/fzf-z"

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


## Plugin Defaults ---------------------------------

# Fuzzy File Finder
export FZF_DEFAULT_OPTS='--height 40% --reverse --border'

# z - Jump to a match, else use FZF
unalias z 2> /dev/null
z() {
  [ $# -gt 0 ] && _z "$*" && return
  cd "$(_z -l 2>&1 | fzf --height 40% --reverse --inline-info +s --tac --query "$*" | sed 's/^[0-9,.]* *//')"
}

