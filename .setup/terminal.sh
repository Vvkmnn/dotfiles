#!/usr/bin/env bash

case "$(uname -s)" in
   Linux)

   # Install Sakura
   sudo apt install sakura

   # Set Default Xterm
   sudo update-alternatives --config x-terminal-emulator

   ;;
    Darwin)

    # Install Zsh
    # brew install vim

    # Alacritty
    brew install --cask alacritty
   ;;
esac
