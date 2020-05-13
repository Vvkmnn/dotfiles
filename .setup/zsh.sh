#!/usr/bin/env bash
# Install and switch to Zshell

case "$(uname -s)" in
   Linux)

   # Install ZSh
   sudo apt-get -y install zsh curl

   # Zimfw
   # NOTE Appends templates from github.com/zimfw/zimfw; already included in
   # dotfiles
   # curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
   
   # Switch Default Shell to Zsh
   chsh -s $(which zsh)

   # Update Zim
   zimfw update

   ;;
Darwin)
    # Ask for the administrator password upfront.
    sudo -v

    # Install Zsh
    brew install zsh 

    # Install Zsh completions
    zsh-completions

    # Install Zplug
    # brew install zplug

    # Add Zsh to list of approved shells
    sudo sh -c "echo $(which zsh) >> /etc/shells"

    # Switch Default Shell to Zsh
    chsh -s $(which zsh)

    ;;
esac
