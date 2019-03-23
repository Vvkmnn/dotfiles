#!/usr/bin/env bash
# Install and switch to Zshell

# Ask for the administrator password upfront.
sudo -v

# Install Zsh
brew install zsh 

# Install Zsh completions
zsh-completions

# Install Zplug
# brew install zplug

# Add Zsh to list of approved shells
ssudo sh -c "echo $(which zsh) >> /etc/shells"

# Switch Default Shell to Zsh
chsh -s $(which zsh)


