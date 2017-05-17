#
# User configuration sourced by interactive shells
#

## Defaults

# Zsh Theme

if [ ! -f ~/.zim/modules/prompt/functions/prompt_v_setup ]; then
    ln -s ~/.assets/zsh/v.zsh-theme ~/.zim/modules/prompt/functions/prompt_v_setup
fi

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
