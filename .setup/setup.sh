#!/usr/bin/env bash

###########################
# This script installs dotfiles and runs the default system configuration scripts
# by Vivek Menon, based on work by Adam Eivy
###########################


## Bot
source ./bot.sh

tell "Hello. I'm going to setup specific tools and system settings for this macOS machine..."

## Admin
# Ask for the administrator password upfront
if ! sudo grep -q "%wheel		ALL=(ALL) NOPASSWD: ALL #atomantic/dotfiles" "/etc/sudoers"; then

  # Ask for the administrator password upfront
  tell "I need your sudo password so I can install some things..."
  sudo -v

  # Keep-alive: update existing sudo time stamp until the script has finished
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

## Sudo
# TODO: Seems risky; review later. 
#   tell "Do you want me to setup this machine to allow you to run sudo without a password?\nPlease read here to see what I am doing:\nhttp://wiki.summercode.com/sudo_without_a_password_in_mac_os_x \n"

#   read -r -p "  Make sudo passwordless? [y|N] " response

#   if [[ $response =~ (yes|y|Y) ]];then
#       sudo cp /etc/sudoers /etc/sudoers.back
#       echo '%wheel		ALL=(ALL) NOPASSWD: ALL #atomantic/dotfiles' | sudo tee -a /etc/sudoers > /dev/null
#       sudo dscl . append /Groups/wheel GroupMembership $(whoami)
#       tell "You can now run sudo commands without password!"
#   fi
fi

## Hosts
# /etc/hosts

# tell "Do you want me to change the hosts file on this machine to the ad-blocking hosts file from someonewhocares.org? :\n"
# TODO: Worth it?

# read -r -p "  Overwrite /etc/hosts with ../.assets/hosts file) [y|N] " response
# if [[ $response =~ (yes|y|Y) ]];then
#     action "cp /etc/hosts /etc/hosts.backup"
#     sudo cp /etc/hosts /etc/hosts.backup
#     ok
#     action "cp ./configs/hosts /etc/hosts"
#     sudo cp ./configs/hosts /etc/hosts
#     ok
#     tell "Your /etc/hosts file has been updated. Last version is saved in /etc/hosts.backup"
# fi

tell "Let's check if your Github credentials are setup correctly..."

grep 'user = GITHUBUSER' ./homedir/.gitconfig > /dev/null 2>&1
if [[ $? = 0 ]]; then
    read -r -p "  What is your github.com username? " githubuser

  fullname=`osascript -e "long user name of (system info)"`

  if [[ -n "$fullname" ]];then
    lastname=$(echo $fullname | awk '{print $2}');
    firstname=$(echo $fullname | awk '{print $1}');
  fi

  if [[ -z $lastname ]]; then
    lastname=`dscl . -read /Users/$(whoami) | grep LastName | sed "s/LastName: //"`
  fi
  if [[ -z $firstname ]]; then
    firstname=`dscl . -read /Users/$(whoami) | grep FirstName | sed "s/FirstName: //"`
  fi
  email=`dscl . -read /Users/$(whoami)  | grep EMailAddress | sed "s/EMailAddress: //"`

  if [[ ! "$firstname" ]];then
    response='n'
  else
    echo -e "I see that your full name is $COL_YELLOW$firstname $lastname$COL_RESET"
    read -r -p "  Is this correct? [Y|n] " response
  fi

  if [[ $response =~ ^(no|n|N) ]];then
    read -r -p "  What is your first name? " firstname
    read -r -p "  What is your last name? " lastname
  fi
  fullname="$firstname $lastname"

  tell "Great $fullname, "

  if [[ ! $email ]];then
    response='n'
  else
    echo -e "The best I can make out, your email address is $COL_YELLOW$email$COL_RESET"
    read -r -p "  Is this correct? [Y|n] " response
  fi

  if [[ $response =~ ^(no|n|N) ]];then
    read -r -p "  What is your email? " email
    if [[ ! $email ]];then
      error "you must provide an email to configure .gitconfig"
      exit 1
    fi
  fi


  warn "Replacing items in .gitconfig with your info ($COL_YELLOW$fullname, $email, $githubuser$COL_RESET)"

  # test if gnu-sed or MacOS sed

  sed -i "s/GITHUBFULLNAME/$firstname $lastname/" ./homedir/.gitconfig > /dev/null 2>&1 | true
  if [[ ${PIPESTATUS[0]} != 0 ]]; then
    echo
    running "looks like you are using MacOS sed rather than gnu-sed, accommodating"
    sed -i '' "s/GITHUBFULLNAME/$firstname $lastname/" ./homedir/.gitconfig;
    sed -i '' 's/GITHUBEMAIL/'$email'/' ./homedir/.gitconfig;
    sed -i '' 's/GITHUBUSER/'$githubuser'/' ./homedir/.gitconfig;
    ok
  else
    echo
    tell "looks like you are already using gnu-sed. woot!"
    sed -i 's/GITHUBEMAIL/'$email'/' ./homedir/.gitconfig;
    sed -i 's/GITHUBUSER/'$githubuser'/' ./homedir/.gitconfig;
  fi
else
fin "Your .gitconfig exists; you're all set."
fi

## Wallpaper
tell "Now let's see about that wallpaper...'"

MD5_NEWWP=$(md5 ../.assets/graphics/Hal.jpg | awk '{print $4}')
MD5_OLDWP=$(md5 /System/Library/CoreServices/DefaultDesktop.jpg | awk '{print $4}')

if [[ "$MD5_NEWWP" != "$MD5_OLDWP" ]]; then
  read -r -p "  Do you want to use your default desktop wallpaper? [Y|n] " response
  if [[ $response =~ ^(no|n|N) ]];then
    echo "skipping...";
    fin "Nevermind."
  else
    warn "Setting a custom wallpaper image..."
    # `DefaultDesktop.jpg` is already a symlink, and
    # all wallpapers are in `/Library/Desktop Pictures/`. The default is `Wave.jpg`.
    rm -rf ~/Library/Application Support/Dock/desktoppicture.db
    sudo rm -f /System/Library/CoreServices/DefaultDesktop.jpg > /dev/null 2>&1
    sudo rm -f /Library/Desktop\ Pictures/El\ Capitan.jpg > /dev/null 2>&1
    sudo rm -f /Library/Desktop\ Pictures/Sierra.jpg > /dev/null 2>&1
    sudo rm -f /Library/Desktop\ Pictures/Sierra\ 2.jpg > /dev/null 2>&1
    sudo cp ../.assets/graphics/Hal.jpg /System/Library/CoreServices/DefaultDesktop.jpg;
    sudo cp ../.assets/graphics/Hal.jpg /Library/Desktop\ Pictures/Sierra.jpg;
    sudo cp ../.assets/graphics/Hal.jpg /Library/Desktop\ Pictures/Sierra\ 2.jpg;
    sudo cp ../.assets/graphics/Hal.jpg /Library/Desktop\ Pictures/El\ Capitan.jpg;
    fin "All done!"
  fi
fi

## Homebrew

tell "Checking if you have Homebrew installed..."
brew_bin=$(which brew) 2>&1 > /dev/null
if [[ $? != 0 ]]; then
  warn "Installing Homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    if [[ $? != 0 ]]; then
      error "Unable to install homebrew, script $0 abort!"
      exit 2
  fi
else
  fin "You've already got it!"
  # Make sure we’re using the latest Homebrew
  tell "Let's update Homebrew..."
  brew update
  fin "There we go."
  tell "Now, before installing brew packages, we can upgrade any outdated packages..."
  read -r -p "  Run brew upgrade? [y|N] " response
  if [[ $response =~ ^(y|yes|Y) ]];then
      # Upgrade any already-installed formulae
      warn "Upgrading brew packages..."
      brew upgrade
      fin "Brews updated..."
  else
      warn "Skipped brew package upgrades.";
  fi
fi

## Brew Cask

tell "Checking if you have Brew Cask installed..."
output=$(brew tap | grep cask)
if [[ $? != 0 ]]; then
  warn "Nope. Installing brew-cask"
  require_brew caskroom/cask/brew-cask
fi
brew tap caskroom/versions > /dev/null 2>&1
fin "Yep, all here!"

## Brew Utilities
tell "Now let's get you set up with some Brew utilities..."

# skip those GUI clients, git command-line all the way
require_brew git
# need fontconfig to install/build fonts
require_brew fontconfig
# update zsh to latest
require_brew zsh
# update ruby to latest
require_brew ruby

fin "All done!"

## Zsh
source ./zsh.sh

# tell "creating symlinks for project dotfiles..."
# pushd homedir > /dev/null 2>&1
# now=$(date +"%Y.%m.%d.%H.%M.%S")

# for file in .*; do
#   if [[ $file == "." || $file == ".." ]]; then
#     continue
#   fi
#   running "~/$file"
#   # if the file exists:
#   if [[ -e ~/$file ]]; then
#       mkdir -p ~/.dotfiles_backup/$now
#       mv ~/$file ~/.dotfiles_backup/$now/$file
#       echo "backup saved as ~/.dotfiles_backup/$now/$file"
#   fi
#   # symlink might still exist
#   unlink ~/$file > /dev/null 2>&1
#   # create the link
#   ln -s ~/.dotfiles/homedir/$file ~/$file
#   echo -en '\tlinked';ok
# done

# popd > /dev/null 2>&1


# tell "Installing vim plugins"
# # cmake is required to compile vim bundle YouCompleteMe
# # require_brew cmake
# vim +PluginInstall +qall > /dev/null 2>&1

# tell "installing fonts"
# ./fonts/install.sh
# brew tap caskroom/fonts
# require_cask font-fontawesome
# require_cask font-awesome-terminal-fonts
# require_cask font-hack
# require_cask font-inconsolata-dz-for-powerline
# require_cask font-inconsolata-g-for-powerline
# require_cask font-inconsolata-for-powerline
# require_cask font-rotello-mono
# require_cask font-rotello-mono-for-powerline
# require_cask font-source-code-pro
# ok

# if [[ -d "/Library/Ruby/Gems/2.0.0" ]]; then
#   running "Fixing Ruby Gems Directory Permissions"
#   sudo chown -R $(whoami) /Library/Ruby/Gems/2.0.0
#   ok
# fi

# # node version manager
# require_brew nvm

# # nvm
# require_nvm stable

# # always pin versions (no surprises, consistent dev/build machines)
# npm config set save-exact true

# #####################################
# # Now we can switch to node.js mode
# # for better maintainability and
# # easier configuration via
# # JSON files and inquirer prompts
# #####################################

# tell "installing npm tools needed to run this project..."
# npm install
# ok

# tell "installing packages from config.js..."
# node index.js
# ok

# running "cleanup homebrew"
# brew cleanup > /dev/null 2>&1
# ok

# ###############################################################################
# tell "Configuring General System UI/UX..."
# ###############################################################################
# # Close any open System Preferences panes, to prevent them from overriding
# # settings we’re about to change
# running "closing any system preferences to prevent issues with automated changes"
# osascript -e 'tell application "System Preferences" to quit'
# ok

# # Ask for the administrator password upfront
# sudo -v

# # Keep-alive: update existing `sudo` time stamp until finished
# while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# my_dir="$(dirname "$0")"

# # Setup brew sh
# "$my_dir/zsh.sh"