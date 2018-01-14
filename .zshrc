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

## Environment Defaults ----------------------------

# Settings
export LANG=en_US.UTF-8
export BROWSER=open
export VISUAL=vimr
export EDITOR=nvim
export TERM=xterm-256color
export ARCHEY_LOGO_FILE=$HOME/.logo

# Path
# export PATH="/usr/local/bin:$PATH"
# export PATH="/usr/local/sbin:$PATH"
# export PATH="$HOME/.vimr:$PATH"

## Environment Defaults ----------------------------

# Dotfiles
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

# Vim-mode
bindkey -v
KEYTIMEOUT=1

## Language Defaults -------------------------------

# Ruby
# export PATH="$PATH:$HOME/.rvm/bin"

# Haskell (Stack Distribution)
export haskell="stack ghci"

# Python 3
export PATH="${HOME}/.anaconda/bin:$PATH" # Anaconda Distribution

# Node
# export NVM_DIR=~/.nvm
# source $(brew --prefix nvm)/nvm.sh

# Go
export GOPATH="$HOME/.go"
export PATH="$GOPATH/bin:$PATH"

## Shell Tools -------------------------------------

# nvim
alias v=nvim
alias vim=nvim

# vimR
alias V=vimr

# brew
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# nnn
alias n=nnn
export NNN_USE_EDITOR=1
export NNN_DE_FILE_MANAGER=open

# gcloud
if [ -f "${HOME}/.google/path.zsh.inc" ]; then source "${HOME}/.google/path.zsh.inc"; fi
if [ -f "${HOME}/.google/completion.zsh.inc" ]; then source "${HOME}/.google/completion.zsh.inc"; fi

# iterm2
test -e "${HOME}/.iterm2/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2/.iterm2_shell_integration.zsh"

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# thefuck
eval "$(thefuck --alias)"

## Shell Theme -------------------------------------

# Little Helper!
RPROMPT='v@%M %(?,%F{green}[-_-]%f,%F{red}[ಠ_ಠ]%f)'
ZLE_LPROMPT_INDENT=0

# Spaceship Theme
SPACESHIP_PROMPT_SYMBOL="ॐ "
SPACESHIP_PROMPT_SEPARATE_LINE=true
SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_PROMPT_COLOR=red
SPACESHIP_DIR_TRUNC=2
SPACESHIP_TIME_SHOW=true
SPACESHIP_TIME_COLOR=blue
SPACESHIP_BATTERY_SHOW=false
SPACESHIP_BATTERY_ALWAYS_SHOW=false
SPACESHIP_VI_MODE_COLOR=cyan
# SPACESHIP_VI_MODE_INSERT=𝛁 # Nabla, normal mode
# SPACESHIP_VI_MODE_NORMAL=𝚫 # Delta, edit mode
SPACESHIP_PYENV_SHOW=false
SPACESHIP_CONDA_SHOW=true
SPACESHIP_KUBECONTEXT_SHOW=false


## Shell Plugins -----------------------------------

# Install Zplug (if missing)
if [[ ! -d ~/.zplug ]]; then
    git clone https://github.com/zplug/zplug ~/.zplug
fi

# Initialize and Update
source ~/.zplug/init.zsh

# Autosuggestions
zplug "zsh-users/zsh-autosuggestions"

# Autocompletions
zplug "zsh-users/zsh-completions", from:oh-my-zsh

# Syntax highlighting
zplug "zsh-users/zsh-syntax-highlighting", defer:2

# Sublime Support
# zplug "plugins/sublime", from:oh-my-zsh

# Vi(m) Mode
# zplug "plugins/vi-mode", from:oh-my-zsh

# Git Plugin
zplug "plugins/git", from:oh-my-zsh

# Virtual Env Wrapper
# zplug "plugins/virtualenvwrapper", from:oh-my-zsh

# Spaceship Theme
zplug "denysdovhan/spaceship-zsh-theme", use:spaceship.zsh, from:github, as:theme

# Athame (Vim in Shell)
# zplug "ardagnir/athame"

# Autoenv for Zsh
zplug "zpm-zsh/autoenv"

# z - jump around
zplug "rupa/z", use:z.sh

# Fzf-z -- Z and fzf play nice
zplug "andrewferrier/fzf-z"

# nvm - Autoloading and upgrading
zplug "lukechilds/zsh-nvm"

# v - jump into vim!
# zplug "meain/v"

# git-open - Jump straight to a git repo with <git open>
zplug 'paulirish/git-open'

# Dracula theme for zsh
zplug 'dracula/zsh', as:theme

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Then, source plugins and add commands to $PATH
zplug load # --verbose


## Plugin Settings ---------------------------------

# fzf {{{
export FZF_DEFAULT_OPTS='--height 40% --reverse --border'

# z - Jump to a match, else use FZF
unalias z 2> /dev/null
z() {
    [ $# -gt 0 ] && _z "$*" && return
    cd "$(_z -l 2>&1 | fzf --height 40% --reverse --inline-info +s --tac --query "$*" | sed 's/^[0-9,.]* *//')"
}

# Use RG for faster search
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'

#}}}



