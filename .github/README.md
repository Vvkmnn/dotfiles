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
                        file nala        \
                        openssh-client   \
                        aptitude         

# optional
sudo apt-get update \
&& sudo apt-get dist-upgrade \
&& sudo apt-get install --reinstall build-essential
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

[zsh](https://www.zsh.org/)
```sh
# switch to zsh from bash
chsh -s $(which zsh)            
```

[brew](https://docs.brew.sh/Homebrew-on-Linux)
```sh
sudo apt install build-essential procps curl file git
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# [ -d /home/linuxbrew/.linuxbrew ] && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv) # already in .shell
```

[emacs](https://www.gnu.org/software/emacs/)
```sh
brew install emacs

# Xming server on WSL1 Debian
# https://sourceforge.net/projects/xming/

# emacs-gtk
```

[neovim](https://neovim.io/)

```sh
# optional, vim9 +huge default in Debian Testing
# brew install neovim

# vvkmnn/v.nvim
cd $HOME/.config/neovim                  \
&& git pull origin 

sudo aptitude update                     \
&& sudo aptitude install ninja-build     \
                         gettext cmake   \
                         unzip curl      \
&& make CMAKE_BUILD_TYPE=RelWithDebInfo  \
&& make install                          \


# clear stash
rm -rf ~/.local/share/nvim
```

trees
```
# TODO nvim
dotfiles subtree pull --prefix .tmux/plugins/tpm tpm master --squash
```

submodules
```
dotfiles submodule update --init         \
                          --recursive    \
```

### Windows

[wsl](https://learn.microsoft.com/en-us/windows/wsl/install)
```bat
:: Install Debian on W10 with WSL
winget install Debian.Debian               \
& winget install Microsoft.WindowsTerminal \

```

[wslu](https://wslutiliti.es/wslu/)
```shell
sudo apt install gnupg2 apt-transport-https wget
wget -O - https://pkg.wslutiliti.es/public.key | sudo tee -a /etc/apt/trusted.gpg.d/wslu.asc

# Debian 12 (typically)
# https://wslutiliti.es/wslu/install.html
echo "deb https://pkg.wslutiliti.es/debian bookworm main" | sudo tee -a /etc/apt/sources.list

# provides wslview and other utils
sudo apt update && sudo apt install wslu 
```
[wezterm]()
```bat
winget install wez.wezterm 

:: windows shortcut
:: "C:\Program Files\WezTerm\wezterm-gui.exe" --config-file="\\wsl.localhost\Debian\home\v\.config\wezterm\wezterm.lua" start -- wsl -d Debian
```

[ahk](https://www.autohotkey.com/)

```sh
cat .setup/capslock.ahk         # Capslock -> Esc + Ctrl on WSL 
explorer.exe .setup             # Explorer open 
wslview ~/.setup/capslock.ahk   # If wslu installed
```

### macOS

[xcode](https://developer.apple.com/xcode/resources/)

```sh
xcode-select --install
```

[brew.sh](https://brew.sh)

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

fonts

```zsh
brew tap homebrew/cask-fonts && brew install --cask font-jetbrains-mono-nerd-font
```

apps

```zsh
# window = keyboard manager
brew install koekeishiya/formulae/skhd koekeishiya/formulae/yabai
skhd --start-service && yabai --start-service

# qol
brew install neovim karabiner-elements    \
  wezterm 1password mullvadvpn alfred nvm \
  adguard ngrok obsidian gh jq fzf btop   \
  coreutils 1password-cli

# extra
brew install discord ffmpeg lua sqlite3   \
             mas mactex font-fontawesome

# maybe
brew install emacs-mac-spacemacs-icon tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

tmux
```
<Prefix> + I # install tpm, included as subtree by default
```

post

```sh
nvm install node                           # installs system node via brew nvm
```

flavor

```
# borders
brew install FelixKratz/formulae/borders

# yabai scripting
# https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release)#configure-scripting-addition
echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai) \
| cut -d " " -f 1) $(which yabai) --load-sa" \
| sudo tee /private/etc/sudoers.d/yabai
# https://github.com/koekeishiya/yabai/issues/1333#issuecomment-1193128981
# sudo nvram boot-args=-arm64e_preview_abi

# svim
brew install FelixKratz/formulae/svim && brew services start svim

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

# Highlight Color (svim)
defaults write NSGlobalDomain AppleHighlightColor -string "0.800000 0.200000 0.200000"
```

## [emacs](https://github.com/doomemacs/doomemacs)

```
# emacs29
brew install git ripgrep coreutils fd      \
&& brew install railwaycat/emacsmacport/emacs-mac \
 --with-spacemacs-icon                     \
 --with-ctags                              \
 --with-native-compilation                 \
  --with-mac-metal                         \
  --with-starter


# deprecated
# brew install emacs-mac                   \
#    --with-dbus                           \
#    --with-dbus                           \
#    --with-starter                        \
#    --with-librsvg                        \
#    --with-imagemagick                    \
#    --with-xwidgets                       \
#    --with-ctags                          \
#    --with-native-comp                    \
#    --with-mac-metal                      \
#    --with-natural-title-bar              \
#    --with-spacemacs-icon                 \
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
<<<<<<< HEAD
git config --global credential.helper 'cache --timeout=7777'          
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*" # use in .dotfiles to make git fetch --all work again
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
dotfiles fetch v.nvim
dotfiles subtree pull --prefix .config/nvim v.nvim master --squash

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
