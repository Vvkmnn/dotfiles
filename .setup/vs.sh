#!/usr/bin/env bash

# if [ ! -f ~/Library/Application\ Support/Code/User/settings.json]; 
# 	mv ~/Library/Application\ Support/Code/User/settings.json ~/Library/Application\ Support/Code/User/settings.json.backup
# fi
# 
# # Move settings and symlink
rm ~/Library/Application\ Support/Code/User/settings.json
ln -s ~/.vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json
