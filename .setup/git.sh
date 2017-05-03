#!/usr/bin/env bash


# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `osxprep.sh` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Source Github credentials if not already available (must be copied in .extra)
source .extra

# Git OSX Keychain Helper from http://burnedpixel.com/blog/setting-up-git-and-github-on-your-mac/
# Download the keychain helper
brew install git

# Modify permissions on the helper so it can operate
git credential-osxkeychain

# Tells Git to use the helper
git config --global credential.helper osxkeychain

# Check again to see if the helper is successfully installed
git credential-osxkeychain

# Add the original upstream repo (dev-martin/dotfiles)
# Should already be included in this git setup, but if not uncomment this
git upstream add https://github.com/donnemartin/dev-setup

# This is now added as remote repository (upstream), verify with get remote list
git remote -v

# Now can pull and merge donnemartin/dev-setup's master branch with local master
git pull upstream master

# Conflicts may arise, review and merge as necessary
