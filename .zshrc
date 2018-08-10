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
export TERM=xterm-256color
export ARCHEY_LOGO_FILE=$HOME/.logo

# Editor
export VISUAL='open -a /Applications/Emacs.app/Contents/MacOS/Emacs' # $VISUAL opens any edits in in GUI mode
export EDITOR=$VISUAL
export ALTERNATE_EDITOR='vim'                   # $EDITOR if all else fails
# export EDITOR='emacsclient -a'                # $EDITOR opens terminal edits in GUI mode

# Editor
alias v='vim'
alias v!='nvim -u NONE'
alias e=$VISUAL
alias emacs=$VISUAL

# Runtime Path
# export PATH="/usr/local/bin:$PATH"
# export PATH="/usr/local/sbin:$PATH"
# export PATH="$HOME/.vimr:$PATH"
# export PATH="/usr/local/bin:$PATH"


## Environment Defaults ----------------------------

# Dotfiles
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
alias d="dotfiles"
# alias ds="dotfiles status"
# alias d+="dotfiles add"
# alias d-="dotfiles remove"
# alias d?="dotfiles commit"

# Vim-mode
# bindkey -v
KEYTIMEOUT=1

## Language Defaults -------------------------------

# Python 3 > 2
export python='python3'

# Ruby
# export PATH="$PATH:$HOME/.rvm/bin"

# Haskell (Stack Distribution)
export haskell="stack ghci"

# Python 3
# export PATH="${HOME}/.anaconda/bin:$PATH" # Anaconda Distribution

# Node
export NVM_DIR=~/.nvm
export NVM_AUTO_USE=true
export NVM_LAZY_LOAD=true
# source $(brew --prefix nvm)/nvm.sh

# Go
# export GOPATH="$HOME/.go"
# export PATH="$GOPATH/bin:$PATH"

## Shell Tools -------------------------------------

# Sleep
alias sleepoff='sudo pmset -b sleep 0; sudo pmset -b disablesleep 1'
alias sleepon='sudo pmset -b sleep 5; sudo pmset -b disablesleep 0'

# vimR
export VIMCONFIG=~/.config/nvim
export VIMDATA=~/.local/share/nvim
export NVIMCONFIG=~/.config/nvim
export NVIMDATA=~/.local/share/nvim

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

# node@6
export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/opt/node@6/bin:$PATH"

# FZF
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# thefuck
eval "$(thefuck --alias)"

## Shell Theme -------------------------------------

# checkBot
# ZLE_LPROMPT_INDENT=0
# RPROMPT='v@%M %(?,%F{green}[-_-]%f,%F{red}[ಠ_ಠ]%f)'

## Shell Plugins -----------------------------------

# Install Zplug (if missing)
# if [ ! -d ~/.zplug ]; then
#     git clone https://github.com/zplug/zplug ~/.zplug
# fi

# Initialize and Update
source ~/.zplug/init.zsh

# Autosuggestions
zplug "zsh-users/zsh-autosuggestions"

# Autocompletions
zplug "zsh-users/zsh-completions", from:oh-my-zsh

# Syntax highlighting
zplug "zsh-users/zsh-syntax-highlighting", defer:2

# Emacs
# zplug "plugins/emacs", from:oh-my-zsh

# Sublime Support
# zplug "plugins/sublime", from:oh-my-zsh

# Vi(m) Mode {{{
# export RPS1="%{$reset_color%}"
# zplug "plugins/vi-mode", from:oh-my-zsh
# }}}

# Git Plugin
zplug "plugins/git", from:oh-my-zsh

# Virtual Env Wrapper
# zplug "plugins/virtualenvwrapper", from:oh-my-zsh

# denysdovhan/spaceship-prompt {{{
zplug "denysdovhan/spaceship-prompt", use:spaceship.zsh, from:github, as:theme

SPACESHIP_CHAR_SYMBOL='ॐ '
# SPACESHIP_CHAR_SYMBOL='ॐ> '
# SPACESHIP_CHAR_SYMBOL='>> '
# RPROMPT='v@%M %(?,%F{green}[-_-]%f,%F{red}[ಠ_ಠ]%f)'
SPACESHIP_PROMPT_SEPARATE_LINE=true
SPACESHIP_PROMPT_ADD_NEWLINE=true
# SPACESHIP_PROMPT_COLOR=red
SPACESHIP_DIR_TRUNC=2
SPACESHIP_TIME_COLOR=blue
SPACESHIP_TIME_SHOW=always
SPACESHIP_USER_SHOW=always
SPACESHIP_TIME_12HR=true
SPACESHIP_USER_PREFIX=''
SPACESHIP_USER_SUFFIX=''
SPACESHIP_USER_COLOR=red
SPACESHIP_HOST_SHOW=always
# SPACESHIP_HOST_COLOR=red
SPACESHIP_HOST_PREFIX=' on '
SPACESHIP_HOST_SUFFIX=' %(?,%F{green}[-_-]%f,%F{red}[ಠ_ಠ]%f)'
SPACESHIP_VI_MODE_SHOW=true
# SPACESHIP_VI_MODE_COLOR=cyan
# SPACESHIP_VI_MODE_INSERT=∇ # Nabla, normal mode
# SPACESHIP_VI_MODE_NORMAL=Δ # Delta, edit mode
SPACESHIP_BATTERY_PREFIX=' at '
SPACESHIP_BATTERY_SHOW=true

SPACESHIP_PROMPT_ORDER=(
  time          # Time stampts section
  dir           # Current directory section
  git           # Git section (git_branch + git_status)
  hg            # Mercurial section (hg_branch  + hg_status)
  package       # Package version
  node          # Node.js section
  ruby          # Ruby section
  elixir        # Elixir section
  xcode         # Xcode section
  swift         # Swift section
  golang        # Go section
  php           # PHP section
  rust          # Rust section
  haskell       # Haskell Stack section
  julia         # Julia section
  docker        # Docker section
  aws           # Amazon Web Services section
  venv          # virtualenv section
  conda         # conda virtualenv section
  pyenv         # Pyenv section
  dotnet        # .NET section
  ember         # Ember.js section
  kubecontext   # Kubectl context section
  exec_time     # Execution time
  line_sep      # Line break
  vi_mode       # Vi-mode indicator
  jobs          # Background jobs indicator
  exit_code     # Exit code section
  char          # Prompt character
)
SPACESHIP_RPROMPT_ORDER=(
  jobs          # Background jobs indicator
  user          # Username section
  host          # Hostname section
  battery       # Battery level and status
  exit_code     # Exit code section
)

# }}}

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

# nvm-auto - Autoload .nvmrc
# zplug "dijitalmunky/nvm-auto"

# v - jump into vim!
# zplug "meain/v"

# git-open - Jump straight to a git repo with <git open>
zplug 'paulirish/git-open'

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


## Plugin Settings ---------------------------------

# Emacs {{{
# Checks if there's a frame open
# emacsclient -n -e “(if (> (length (frame-list)) 1) ‘t)” 2> /dev/null | grep t &> /dev/null

# if [ “$?” -eq “1” ]; then
#     emacsclient -a ‘’ -nqc “$@” &> /dev/null
# else
#     emacsclient -nq “$@” &> /dev/null
# fi
# }}}

# fzf {{{
# export FZF_DEFAULT_OPTS='--height 40% --reverse --border'

# z - Jump to a match, else use FZF
# unalias z 2> /dev/null
# z() {
#     [ $# -gt 0 ] && _z "$*" && return
#     cd "$(_z -l 2>&1 | fzf --height 40% --reverse --inline-info +s --tac --query "$*" | sed 's/^[0-9,.]* *//')"
# }

# Use RG for faster search
# export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'

# emacs {{{
# emacs () { pgrep -xiq emacs && emacsclient -n $@ || emacsclient -n -c --alternate-editor="" $@; }
#
# if [ -n "$INSIDE_EMACS" ]; then
#     export ZSH_THEME="rawsyntax"
# else
#     export ZSH_THEME="robbyrussell"
# fi
# }}}

#}}}
