#!/usr/bin/env bash

# Brew install mackup for OSX
# https://github.com/lra/mackup

echo "------------------------------"
echo "Installing and setting up Mackup."


brew install mackup

# Link current mackup cfg to Dropbox
# Delet the default value, and copy the configuration file in this repo
rm  ~/.mackup.cfg
#ln -s ~/Dropbox/dotfiles/.mackup.cfg ~/.mackup.cfg
#cp .mackup.cfg ~/.mackup.cfg


echo "------------------------------"
echo "Restoring and backing up all dotfiles."

# Mackup Restore
mackup restore

# Mackup Backup
mackup backup
