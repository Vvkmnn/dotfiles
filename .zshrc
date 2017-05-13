

#
# User configuration sourced by interactive shells
#

#  Zim
if [[ -s ${ZDOTDIR:-${HOME}}/.zim/init.zsh ]]; then
  source ${ZDOTDIR:-${HOME}}/.zim/init.zsh
fi

# Homebrew Cask
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# Prompt
# Source: http://www.lowlevelmanager.com/2012/03/smile-zsh-prompt-happysad-face.html
RPROMPT='v@%M %(?,%F{green}[-_-]%f,%F{red}[ಠ_ಠ]%f)' #%F{gray} before to color prompt

# Default Editor - VSCode
export EDITOR='code'

# Anaconda
export PATH=~/anaconda3/bin:$PATH

# Go
# export $GOPATH="/Users/v/Develop/Go"alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME"

# Dotfiles
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME"