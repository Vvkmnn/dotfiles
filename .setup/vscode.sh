#!/usr/bin/env bash
# Setup Visual Studio Code

# Install Visual Studo Code
brew cask install visual-studio-code-insiders

# Move settings and symlink
rm ~/Library/Application\ Support/Code\ -\ Insiders/User/settings.json
rm ~/Library/Application\ Support/Code\ -\ Insiders/User/bindings.json

# Symlink existing files
ln -s ~/.vscode/settings.json ~/Library/Application\ Support/Code\ -\ Insiders/User/settings.json
ln -s ~/.vscode/bindings.json ~/Library/Application\ Support/Code\ -\ Insiders/User/bindings.json

# Use `core` to install packages
# code --list-extensions

# Vim Vscode
code --install-extension vscodevim.vim

# Dracula Theme
code --install-extension dracula-theme.theme-dracula

# Linters
# ESlint
# code --install-extension dbaeumer.vscode-eslint
