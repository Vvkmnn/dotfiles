#!/usr/bin/env bash
# Setup Visual Studio Code

# Install Visual Studo Code
brew cask install visual-studio-code

# Remove settings and symlink
rm ~/Library/Application\ Support/Code/User/settings.json
rm ~/Library/Application\ Support/Code/User/bindings.json

# Symlink Backups
ln -s ~/.vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json
ln -s ~/.vscode/settings.json ~/Library/Application\ Support/Code/User/bindings.json

# Use `core` to install packages
code --list-extensions

# Vim Vscode
code --install-extension vscodevim.vim

# Dracula Theme
code --install-extension dracula-theme.theme-dracula

# Linters
# ESlint
code --install-extension dbaeumer.vscode-eslint
