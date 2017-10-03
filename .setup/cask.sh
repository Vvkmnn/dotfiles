#!/usr/bin/env bash
# Install Apps using Homebrew Cask.

# Set Homebrew Exports
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# Cask - Install Mac apps
brew install caskroom/cask/brew-cask
brew tap caskroom/versions

# spectacle - hotkey window management
brew cask install spectacle

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

# Install developer friendly quick look plugins; see https://github.com/sindresorhus/quick-look-plugins
brew cask install qlcolorcode qlstephen qlmarkdown quicklook-json qlprettypatch quicklook-csv betterzipql qlimagesize webpquicklook 
