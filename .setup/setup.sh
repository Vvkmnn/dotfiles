#!/usr/bin/env bash

##########################
# Sets up a new macOS System
# by Vivek Menon, based on work by Adam Eivy
###########################

## Bot
source bot.sh

tell "Starting macOS setup script..."

## Git

ask "Set up Git? [y|N] " response
if [[ $response =~ (yes|y|Y) ]];then
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
        fin "Git Setup complete."
    fi
fi

## Brew
ask "Set up Homebrew? [y|N] " response
if [[ $response =~ (yes|y|Y) ]];then
    source ./brew.sh
    fin "Brew setup complete."
fi

## Brew
ask "Set up Zsh? [y|N] " response
if [[ $response =~ (yes|y|Y) ]];then
    source ./zsh.sh
    fin "Zsh setup complete."
fi
## Zsh
# tell "Setting up Zsh..."
# source ./zsh.sh

fin "Setup complete!"

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
# fi

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

# ## Wallpaper
# tell "Now let's see about that wallpaper...'"
# 
# MD5_NEWWP=$(md5 ../.assets/graphics/Hal.jpg | awk '{print $4}')
# MD5_OLDWP=$(md5 /System/Library/CoreServices/DefaultDesktop.jpg | awk '{print $4}')
# 
# if [[ "$MD5_NEWWP" != "$MD5_OLDWP" ]]; then
#   read -r -p "  Do you want to use your default desktop wallpaper? [Y|n] " response
#   if [[ $response =~ ^(no|n|N) ]];then
#     echo "skipping...";
#     fin "Nevermind."
#   else
#     warn "Setting a custom wallpaper image..."
#     # `DefaultDesktop.jpg` is already a symlink, and
#     # all wallpapers are in `/Library/Desktop Pictures/`. The default is `Wave.jpg`.
#     rm -rf ~/Library/Application Support/Dock/desktoppicture.db
#     sudo rm -f /System/Library/CoreServices/DefaultDesktop.jpg > /dev/null 2>&1
#     sudo rm -f /Library/Desktop\ Pictures/El\ Capitan.jpg > /dev/null 2>&1
#     sudo rm -f /Library/Desktop\ Pictures/Sierra.jpg > /dev/null 2>&1
#     sudo rm -f /Library/Desktop\ Pictures/Sierra\ 2.jpg > /dev/null 2>&1
#     sudo cp ../.assets/graphics/Hal.jpg /System/Library/CoreServices/DefaultDesktop.jpg;
#     sudo cp ../.assets/graphics/Hal.jpg /Library/Desktop\ Pictures/Sierra.jpg;
#     sudo cp ../.assets/graphics/Hal.jpg /Library/Desktop\ Pictures/Sierra\ 2.jpg;
#     sudo cp ../.assets/graphics/Hal.jpg /Library/Desktop\ Pictures/El\ Capitan.jpg;
#     fin "All done!"
#   fi
# fi

## Homebrew

# tell "Checking if you have Homebrew installed..."
# brew_bin=$(which brew) 2>&1 > /dev/null
# if [[ $? != 0 ]]; then
#   warn "Installing Homebrew..."
#     ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
#     if [[ $? != 0 ]]; then
#       error "Unable to install homebrew, script $0 abort!"
#       exit 2
#   fi
# else
#   fin "You've already got it!"
#   # Make sure we’re using the latest Homebrew
#   tell "Let's update Homebrew..."
#   brew update
#   fin "There we go."
#   tell "Now, before installing brew packages, we can upgrade any outdated packages..."
#   read -r -p "  Run brew upgrade? [y|N] " response
#   if [[ $response =~ ^(y|yes|Y) ]];then
#       # Upgrade any already-installed formulae
#       warn "Upgrading brew packages..."
#       brew upgrade
#       fin "Brews updated..."
#   else
#       warn "Skipped brew package upgrades.";
#   fi
# fi

## Brew Cask

# tell "Checking Brew Cask installed..."
# output=$(brew tap | grep cask)
# if [[ $? != 0 ]]; then
#   warn "Nope. Installing brew-cask"
#   require_brew caskroom/cask/brew-cask
# fi
# brew tap caskroom/versions > /dev/null 2>&1
# fin "Yep, all here!"
