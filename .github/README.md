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

### Windows

[wsl](https://learn.microsoft.com/en-us/windows/wsl/install)
```bat
:: Install Debian on W10 with WSL
winget install Debian.Debian               \
& winget install Microsoft.WindowsTerminal \

```
```shell
sudo apt install gnupg2 apt-transport-https wget
wget -O - https://pkg.wslutiliti.es/public.key | sudo tee -a /etc/apt/trusted.gpg.d/wslu.asc

# Debian 12 (typically)
# https://wslutiliti.es/wslu/install.html
echo "deb https://pkg.wslutiliti.es/debian bookworm main" | sudo tee -a /etc/apt/sources.list

# provides wslview
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
wslview .setup/capslock.ahk      # If wslu installed
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

```sh
brew install yabai skhd         
	&& git-open bottom \
	&& ngrok tidy 
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

