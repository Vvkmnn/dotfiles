#!/usr/bin/env bash

# Ask for the administrator password upfront
sudo -v

# Alf
curl -sSL https://raw.githubusercontent.com/psyrendust/alf/master/bootstrap/baseline.zsh | zsh

# Keep-alive: update existing `sudo` time stamp until `osxprep.sh` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

tell "Switching the login shell to ZSH..."

CURRENTSHELL=$(dscl . -read /Users/$USER UserShell | awk '{print $2}')
if [[ "$CURRENTSHELL" != "/usr/local/bin/zsh" ]]; then
  warn "setting newer homebrew zsh (/usr/local/bin/zsh) as your shell (password required)"
  sudo bash -c 'echo "/usr/local/bin/zsh" >> /etc/shells'
  chsh -s /usr/local/bin/zsh
  sudo dscl . -change /Users/$USER UserShell $SHELL /usr/local/bin/zsh > /dev/null 2>&1
  fin "Switched!"
fi

tell "Checking if you have the Oh-my-Zsh framework installed..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

if [[ ! -d "../.oh-my-zsh/custom/themes/dracula" ]]; then
  cp ../.assets/dracula/zsh/dracula.zsh-theme ../.oh-my-zsh/themes/
fi

fin "All set."

 # Source .zshrc for new changes
source ~/.zshrc