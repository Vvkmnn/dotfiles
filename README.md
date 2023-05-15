# dotfiles

```
##################################################
##################################################
######################        ####################
################                    ##############
#############                #######   ###########
###########                #########     #########
#########                 ########         #######
########                  ######            ######
#######                   ######             #####
######            ####### ######              ####
#####           ######### ######               ###
#####           #######   ######               ###
#####            ######    #####               ###
#####             ######    ####               ###
#####              ######    ###               ###
#####               ######    #                ###
######               ######                   ####
#######               #####                  #####
########               #####                ######
##########              #####             ########
############             #####          ##########
##############               ##       ############
##################                ################
##################################################
##################################################
```

[A](https://medium.com/@webprolific/getting-started-with-dotfiles-43c3602fd789) [dotfile](https://dotfiles.github.io) [repo](https://news.ycombinator.com/item?id=11070797)[.](https://www.atlassian.com/git/tutorials/dotfiles)

## Pre Install

### Debian

```sh
sudo apt update  &&             \
sudo apt upgrade &&             \
sudo apt install openssh-client \
                 git zsh curl   \
                 neovim tmux  
```

```sh
chsh -s /bin/zsh                # switch to zsh from bash
```

[wsl](https://learn.microsoft.com/en-us/windows/wsl/install)
```sh
winget install Debian.Debian    # Install Debian on W10 with WSL
```

[ahk](https://www.autohotkey.com/)
```sh
cat .setup/capslock.ahk         # Capslock -> Esc + Ctrl on WSL 
```
```sh
explorer.exe .setup             # Explorer open 
```

### MacOS

[xcode](https://developer.apple.com/xcode/resources/)
```sh
xcode-select --install
```

[brew.sh](https://brew.sh)
```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 
```

utils
```
brew install yabai skhd         \
```
```sh
brew install git-open bottom    \
             ngrok tidy 
```

emacs
```sh
brew install git ripgrep        \
            coreutils fd        
```
```sh
brew install emacs-mac          \ 
   --with-dbus                  \
   --with-starter               \
   --with-rsvg                  \
   --with-imagemagick           \
   --with-no-title-bars         \
   --with-spacemacs-icon        \ 
   --with-native-comp           \
   --with-mac-metal             \
   --with-xwidgets

```

casks
```sh
brew install --cask protonmail-bridge protonvpn
```
```sh
brew install --cask 1password adguard
```
```sh
brew install --cask karabiner-elements          
```
```sh
brew install --cask miniconda
```

## Install

```sh
# ssh
ssh-keygen -t rsa -b 4096 -C "example@example.com"
cat ~/.ssh/id_rsa.pub

# github
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
git clone --bare git@github.com:Vvkmnn/dotfiles.git --branch <os> $HOME/.dotfiles
dotfiles stash
dotfiles checkout

# optional
git config --global credential.helper 'cache --timeout=7777'
dotfiles config status.showUntrackedFiles no

```

## Backup

```sh
cd
mkdir -p .backup && \
dotfiles checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | \
xargs -I{} mv {} .backup/{}
```

## Post Install

```sh
# submodules
dotfiles submodule init
dotfiles submodule update

# TODO guided
./.setup/setup.sh

# individual
chmod +x ./setup/*.sh
./.setup/<example>.sh

# core
vim.sh   # Editor
zsh.sh   # Shell
emacs.sh # IDE
#brave.sh # Browser TODO Opera

# utility
debian.sh
capslock.sh
```

## Update

```sh
# combined
dotfiles submodule update --init --recursive

# create + update
dotfiles submodule init # Create all folders 
dotfiles submodule update # Update all folders to master branch
```

