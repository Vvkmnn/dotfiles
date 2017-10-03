#!/usr/bin/env bash
# Install and switch to Zshell

# Ask for the administrator password upfront.
sudo -v

# Install Zsh
brew install zsh

# Install Zplug
# brew install zplug

# Switch Default Shell to Zsh
chsh -s $(which zsh)

