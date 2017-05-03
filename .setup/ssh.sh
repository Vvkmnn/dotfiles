#!/usr/bin/env bash

# .extra
source .extra

# From: http://burnedpixel.com/blog/setting-up-git-and-github-on-your-mac/

# Point the terminal to the directory that would contain SSH keys for your user account.
cd ~/.ssh


# Make a subdirectory called "key_backup" in the current directory
mkdir keyBackup

# Copies the id_rsa keypair into key_backup
$ cp id_rsa* keyBackup

# Deletes the id_rsa keypair in your ~/.ssh directory
$ rm id_rsa*

# Create a new ssh key using the provided email. The email you use in this step should match the one you entered when you created your Github account
 ssh-keygen -t rsa -C $MAIL
