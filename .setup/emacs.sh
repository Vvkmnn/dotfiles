# emacs - Spacemacs!

# Install emacs with natural title bars
# this one works with skhd and chunkwm on macOS
brew tap railwaycat/emacsmacport
brew install emacs-mac --with-natural-title-bar


# Emacs as a Daemon / Server
ln -sfv /usr/local/opt/emacs/*.plist ~/Library/LaunchAgents
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.emacs.plist

# Emacs as a Client
brew cask install emacsclient

# https://superuser.com/questions/50095/how-can-i-run-mac-osx-graphical-emacs-in-daemon-mode
# Use the emacs config that forks Doom!
brew cask install emacs-mac-spacemacs-icon
brew install emacs-plus --with-natural-title-bar
brew tap caskroom/fonts && brew cask install font-source-code-pro
