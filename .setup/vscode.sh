#!/usr/bin/env bash
# Setup Visual Studio Code

# Install Visual Studo Code
brew cask install visual-studio-code

# Move settings and symlink
rm ~/Library/Application\ Support/Code/User/settings.json
ln -s ~/.vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json

# Use `core` to install packages
code --list-extensions

# Vim Vscode
code --install-extension vscodevim.vim

# Dracula Theme
code --install-extension dracula-theme.theme-dracula

# Linters
# ESlint
code --install-extension dbaeumer.vscode-eslint