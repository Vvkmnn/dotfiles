#!/usr/bin/env bash
# Install Apps using Homebrew Cask.

# Set Homebrew Exports
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# Cask - Install Mac apps
brew install caskroom/cask/brew-cask
brew tap caskroom/versions

# spectacle - hotkey window management
brew cask install spectacle

# karabiner-elements - custom macOS key modifications (Capslock -> Esc/Ctrl)
brew cask install karabiner-elements

# Heroku - PaaS tools
# brew install heroku-toolbelt
# heroku update

# Visual Studio Code - IDE
brew cask install caskroom/cask/visual-studio-code

# Dash - Docmentation Assistant
brew cask install dash

# Transmission - Torrents
brew cask install transmission

# Google Chrome	- Browser
brew cask install google-chrome

# Alfred - Better Spotlight
brew cask install --appdir="/Applications" alfred
brew cask alfred link # Link cask apps to Alfred

# Iterm2 - Terminal replacement / multiplexer
brew cask install --appdir="~/Applications" iterm2

# Java 
brew cask install --appdir="~/Applications" java

# XQuartz
brew cask install --appdir="~/Applications" xquartz

# Github
# brew cask install github-desktop
brew cask install githubpulse

# Slack - Team communication
brew cask install --appdir="/Applications" slack

# Lastpass - Password Manager
brew cask install --appdir="/Applications" lastpass

# Docker - The Container Engine
brew cask install docker

# Setapp - Paid App subscription
brew cask install setapp 
# FIX: Not a true install; just installs and installer.

# Install developer friendly quick look plugins; see https://github.com/sindresorhus/quick-look-plugins
brew cask install qlcolorcode qlstephen qlmarkdown quicklook-json qlprettypatch quicklook-csv betterzipql qlimagesize webpquicklook 
#Tnnelear
brew cask install tunnelbear

# Amethyst - Tiling Window Manager
# brew cask install amethyst # too unstable 

# Contexts - Window Switcher
brew cask  install contexts

# remembear - Password manager
brew cask install remembear

# tunnelbear - VPN
brew cask install tunnelbear

# tunnelbear - VPN
brew cask install brave-browser

# Afred - Better Spotlight
brew cask install alfred
brew install emacs-mac --with-dbus --with-modules --with-xml2 --with-ctags --with-spacemacs-icon
