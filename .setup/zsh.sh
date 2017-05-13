#!/usr/bin/env bash

# Ask for the administrator password upfront
sudo -v

# Zim!
git clone --recursive https://github.com/Eriner/zim.git ${ZDOTDIR:-${HOME}}/.zim

# Prepend Zim Templates (Already Available)
# setopt EXTENDED_GLOB
# for template_file ( ${ZDOTDIR:-${HOME}}/.zim/templates/* ); do
#   user_file="${ZDOTDIR:-${HOME}}/.${template_file:t}"
#   touch ${user_file}
#   ( print -rn "$(<${template_file})$(<${user_file})" >! ${user_file} ) 2>/dev/null
# done

# Set Zsh as shell
chsh -s =zsh

# Source .zlogin
source ${ZDOTDIR:-${HOME}}/.zlogin

if [[ ! -d "../.oh-my-zsh/custom/themes/dracula" ]]; then
  cp ../.assets/dracula/zsh/dracula.zsh-theme ../.oh-my-zsh/themes/
fi

fin "All set."

# Update Zim
zmanage update

 # Source .zlogin to compile new .zshrc
source ~/.login