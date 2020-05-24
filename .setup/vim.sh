#!/usr/bin/env bash
# Install Vim

case "$(uname -s)" in
   Linux)

   # Install Vim
   sudo apt-get install -y vim vim-gtk

   ;;
Darwin)

    # Install Zsh
    brew install vim

   ;;
esac
