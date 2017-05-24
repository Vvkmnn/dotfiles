#
# User configuration sourced by interactive shells
#

## Personal Defaults
LANG=en_US.UTF-8
TERM=xterm-256color

# GUI Editor - VSCode
export EDITOR='code'

# Terminal Editor - Nvim
if type nvim > /dev/null 2>&1; then
  alias vim='nvim'
fi

# Dotfiles
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"


## Terminal Defaults
# ZLE_RPROMPT_INDENT=0

RPROMPT='v@%M %(?,%F{green}[-_-]%f,%F{red}[ಠ_ಠ]%f)'


# Powerlevel9k

# POWERLEVEL9K_INSTALLATION_PATH=~/.zim/modules/prompt/external-themes/powerlevel9k/powerlevel9k.zsh-theme
# POWERLEVEL9K_MODE='awesome-patched' # Uses Sauce (Source Code Pro Nerd) font

# POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir)
# POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(command_execution_time anaconda nvm vcs time)

# POWERLEVEL9K_CONTEXT_TEMPLATE="%(?,%F{green}[-_-]%f,%F{red}[ಠ_ಠ]%f)"

# POWERLEVEL9K_VCS_SHOW_SUBMODULE_DIRTY=false


# POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
# POWERLEVEL9K_SHORTEN_STRATEGY="truncate_right"

# POWERLEVEL9K_CONTEXT_BACKGROUND='black'
# POWERLEVEL9K_DIR_HOME_BACKGROUND='09'
# POWERLEVEL9K_DIR_DEFAULT_BACKGROUND='09'
# POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND='009'
# POWERLEVEL9K_DIR_HOME_FOREGROUND='236'
# POWERLEVEL9K_DIR_DEFAULT_FOREGROUND='236'
# POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND='236'

# ZLE_LPROMPT_INDENT=0

# Spaceship

SPACESHIP_PROMPT_SYMBOL=": "
SPACESHIP_PROMPT_SEPARATE_LINE=false
SPACESHIP_PROMPT_ADD_NEWLINE=false

SPACESHIP_DIR_TRUNC=2

SPACESHIP_TIME_SHOW=false

## General Defaults

# Homebrew Cask
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

#  Zim
if [[ -s ${ZDOTDIR:-${HOME}}/.zim/init.zsh ]]; then
  source ${ZDOTDIR:-${HOME}}/.zim/init.zsh
fi

# Continuum Anaconda
export PATH=~/anaconda3/bin:$PATH

# Google Go
export GOPATH=~/Code/Go

# Google Cloud SDK
if [ -f ~/Code/Gcloud/google-cloud-sdk ]; then
  cd ~/Code/Gcloud/google-cloud-sdk
  source 'path.zsh.inc'
  source 'completion.zsh.inc'
fi
