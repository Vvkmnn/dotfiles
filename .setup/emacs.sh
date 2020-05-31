#!/usr/bin/env bash
# Install and switch to Zshell

case "$(uname -s)" in
   Linux)
   # Ubuntu PPA (snapshot)
   # https://launchpad.net/~ubuntu-elisp/+archive/ubuntu/ppa
   # sudo add-apt-repository -y ppa:ubuntu-elisp/ppa 
       
   # Doom Dependencies 
   # Ubuntu 20.04
   sudo apt-get update
   sudo apt install -y git fd-find ripgrep emacs python3-pip python-is-python3 shellcheck markdown python3-venv

   # Doom Emacs 
   # included in dotfiles with submodule init && submodule update
   # git clone --depth 1 https://github.com/hlissner/doom-emacs ~/.emacs.d
   # ~/.emacs.d/bin/doom install

   # Available from dotfiles and path
   # .config/doom .emacs.d

   # Install packages
   doom install

   # Compile
   # doom compile :core

   # Cleanup
   doom sync
   doom doctor

   # Python3 Dependencies
   pip install black pyflakes isort pipenv pytest
   
   # Node Dependencies
    npm i -g bash-language-server

   # Cleanup
   sudo apt autoremove

    
   ;;
Darwin)

    # Install emacs with natural title bars
    # this one works with skhd & yabai on macOS
    brew install emacs-mac --with-spacemacs-icon --with-natural-title-bar

    # Doom Emacs
    git clone https://github.com/hlissner/doom-emacs ~/.emacs.d

    # Doom Config
    git clone git@github.com:Vvkmnn/v.doom.d.git ~/.config/doom
    ln -s ~/.config/doom/ ~/.v.doom.d 

    # Doom Refresh
    doom refresh

    # Emacs as a Daemon / Server
    # ln -sfv /usr/local/opt/emacs/*.plist ~/Library/LaunchAgents
    # launchctl load ~/Library/LaunchAgents/homebrew.mxcl.emacs.plist

    # Emacs as a Client
    # brew cask install emacsclient

    # https://superuser.com/questions/50095/how-can-i-run-mac-osx-graphical-emacs-in-daemon-mode
    # Use the emacs config that forks Doom!
    # brew cask install emacs-mac-spacemacs-icon
    # brew install emacs-plus --with-natural-title-bar
    # brew tap caskroom/fonts && brew cask install font-source-code-pro



    ;;
esac
