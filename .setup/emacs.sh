# emacs - Spacemacs!

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
