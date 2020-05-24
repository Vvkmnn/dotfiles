#!/usr/bin/env bash
# Install and switch to Fish

# Ask for the administrator password upfront.
sudo -v

# Install Zsh
brew install fish

# Install Zsh completions
# zsh-completions

# Install Zplug
# brew install zplug

# Add Zsh to list of approved shells
sudo sh -c "echo $(which fish) >> /etc/shells"

# Switch Default Shell to Zsh
chsh -s $(which fish)


