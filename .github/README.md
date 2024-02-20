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

[testing](https://wiki.debian.org/LTS)
```sh
sudo apt-get update                      \
&& sudo apt-get upgrade                  \
&& sudo apt-get install git zsh curl vim \
                        openssh-client   \
                        aptitude         \
```
```sh
# /etc/apt/sources.list
deb http://deb.debian.org/debian bookworm main contrib non-free
non-free-firmware
deb-src http://deb.debian.org/debian bookworm main contrib non-free
non-free-firmware

deb http://deb.debian.org/debian-security bookworm-security main contrib
non-free non-free-firmware
deb-src http://deb.debian.org/debian-security bookworm-security main contrib
non-free non-free-firmware

deb http://deb.debian.org/debian bookworm-updates main contrib non-free
non-free-firmware
deb-src http://deb.debian.org/debian bookworm-updates main contrib non-free
non-free-firmware

# w !sudo tee %                           # Vim Sudo (Emergencies)
# sudo cp \ 
#     /usr/share/doc/apt/examples/sources.list \
#     /etc/apt/sources.list               # Default backup on Debian
```
```sh
sudo apt-get update \
&& sudo apt-get dist-upgrade \
&& sudo apt-get install --reinstall build-essential
```
```sh
chsh -s $(which zsh)            # switch to zsh from bash
```

[neovim](https://neovim.io/)
```sh
# optional, vim9 +huge default in Debian Testing

dotfiles submodule update --init         \
                          --recursive    \
&& cd .neovim                            \
&& sudo aptitude update                  \
&& sudo aptitude install ninja-build     \
                         gettext cmake   \
                         unzip curl      \
&& make CMAKE_BUILD_TYPE=RelWithDebInfo  \
&& make install                          \
```

[wsl](https://learn.microsoft.com/en-us/windows/wsl/install)
```sh
winget install Debian.Debian    # Install Debian on W10 with WSL
```

[ahk](https://www.autohotkey.com/)
```sh
cat .setup/capslock.ahk         # Capslock -> Esc + Ctrl on WSL 
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

apps
```zsh
# window = keyboard manager
brew install koekeishiya/formulae/skhd koekeishiya/formulae/yabai
skhd --start-service && yabai --start-service

# apps
brew install neovim karabiner-elements    \
  alacritty 1password mullvadvpn alfred   \
  adguard  bottom ngrok obsidian           
```


defaults
```zsh
# iCloud Files
defaults write NSGlobalDomain "NSDocumentSaveNewDocumentsToCloud" -bool "false" 

# Dock
defaults write com.apple.dock orientation right #my preference for main machine
defaults write com.apple.dock tilesize -int 27

# Finder
defaults write com.apple.Finder AppleShowAllFiles true
defaults write com.apple.finder CreateDesktop false
```

## [emacs](https://github.com/doomemacs/doomemacs)
```
brew install git ripgrep coreutils fd

brew install emacs-mac                   \
   --with-dbus                           \
   --with-dbus                           \
   --with-starter                        \
   --with-librsvg                        \
   --with-imagemagick                    \
   --with-xwidgets                       \ 
   --with-ctags                          \
   --with-native-comp                    \
   --with-mac-metal                      \
   --with-natural-title-bar              \
   --with-spacemacs-icon                 \
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

[ssh](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
```sh
ssh-keygen -t rsa -b 4096 -C "example@example.com"
cat ~/.ssh/id_rsa.pub
```

[github](https://github.com/Vvkmnn/dotfiles)
```
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
git clone --bare git@github.com:Vvkmnn/dotfiles.git --branch <os> $HOME/.dotfiles
dotfiles stash
dotfiles checkout

# optional
git config --global credential.helper 'cache --timeout=7777777'
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

[subtrees](https://www.atlassian.com/git/tutorials/git-subtree)
```zsh
git fetch v.nvim
git subtree pull --prefix .config/nvim v.nvim master --squash

```

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

