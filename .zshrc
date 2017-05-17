#
# User configuration sourced by interactive shells
#

## Defaults

# Prompt
# Source: http://www.lowlevelmanager.com/2012/03/smile-zsh-prompt-happysad-face.html
RPROMPT='v@%M %(?,%F{green}[-_-]%f,%F{red}[ಠ_ಠ]%f)' #%F{gray} before to color prompt

# GUI Editor - VSCode
export EDITOR='code'

# Terminal Editor - Nvim
if type nvim > /dev/null 2>&1; then
  alias vim='nvim'
fi

# Homebrew Cask
export HOMEBREW_CASK_OPTS="--appdir=/Applications"


## Imports

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

# Dotfiles
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
dotfiles submodule update --init --recursive 