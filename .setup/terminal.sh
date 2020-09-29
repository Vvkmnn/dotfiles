#!/usr/bin/env bash
# Install Vim

case "$(uname -s)" in
   Linux)

   # Install Sakura
   sudo apt install sakura

   # Set Default Xterm
   sudo update-alternatives --config x-terminal-emulator

   ;
Darwin)`

    # Install Zsh
    # brew install vim
#
   ;;
esac
