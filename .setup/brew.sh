#!/usr/bin/env bash

# Install command-line tools using Homebrew.

# Ask for the administrator password upfront.
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

	# Check for Homebrew,
	# Install if we don't have it
	if test ! $(which brew); then
		echo "Installing homebrew..."
		ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	fi

	# Make sure we’re using the latest Homebrew.
	brew update

	# Upgrade any already-installed formulae.
	brew upgrade --all

	# Install GNU core utilities (those that come with OS X are outdated).
	# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
	brew install coreutils
	sudo ln -s /usr/local/bin/gsha256sum /usr/local/bin/sha256sum

	# Install some other useful utilities like `sponge`.
	# brew install moreutils
	# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
	# brew install findutils
	# Install GNU `sed`, overwriting the built-in `sed`.
	# brew install gnu-sed --with-default-names
	# Install Bash 4.
	# brew install bash
	# brew tap homebrew/versions
	# brew install bash-completion2

	# Fun stuff
	brew install archey
	brew install rtv 

	# We installed the new shell, now we have to activate it
	# echo "Adding the newly installed shell to the list of allowed shells"
	# Prompts for password
	# sudo bash -c 'echo /usr/local/bin/bash >> /etc/shells'
	# Change to the new shell, prompts for password
	# chsh -s /usr/local/bin/bash

	# Install `wget` with IRI support.
	# brew install wget --with-iri

	# Install Python
	# brew install python
	# brew install python3

	# Install ruby-build and rbenv
	# brew install ruby-build
	# brew install rbenv
	# LINE='eval "$(rbenv init -)"'
	# grep -q "$LINE" ~/.extra || echo "$LINE" >> ~/.extra

	# # Install more recent versions of some OS X tools.
	brew install vim --override-system-vi
	brew install homebrew/dupes/grep
	brew install homebrew/dupes/openssh
	brew install homebrew/dupes/screen
	# brew install homebrew/php/php55 --with-gmp

	# TODO: This is for the Mac App Store; give it it's own script
	# brew install and setup Mac App Store
	# install the Mac App Store
	# https://github.com/argon/mas
	brew install mas

	# Install App Store Xcode
	mas install 497799835

	# Install LastPass
	# mas install 926036361

	#410628904 Wunderlist
	# mas install 410628904

	# Install Simplenote
	mas install 692867256

	# Install Pocket
	mas install 568494494

	# Install Fonts
	brew tap caskroom/fonts   
	brew cask install font-inconsolata-for-powerline
	brew cask install font-inconsolata


	# Install some CTF tools; see https://github.com/ctfs/write-ups.
	#brew install aircrack-ng
	#brew install bfg
	#brew install binutils
	#brew install binwalk
	#brew install cifer
	#brew install dex2jar
	#brew install dns2tcp
	#brew install fcrackzip
	#brew install foremost
	#brew install hashpump
	#brew install hydra
	#brew install john
	#brew install knock
	#brew install netpbm
	#brew install nmap
	#brew install pngcheck
	#brew install socat
	#brew install sqlmap
	#brew install tcpflow
	#brew install tcpreplay
	#brew install tcptrace
	#brew install ucspi-tcp # `tcpserver` etc.
	#brew install homebrew/x11/xpdf
	#brew install xz

	# Install other useful binaries.
	brew cask install keepingyouawake
	# ack - excellent little search tool: https://www.youtube.com/watch?time_continue=85&v=sKmyl5D8Da8
	brew install ack
	# spectacle - hotkey window management
	brew cask install spectacle
	# git LFS - Large file storage; just in case
	brew install git-lfs
	# git Flow - extensions for Vincent Driessen's branching model: https://jeffkreeftmeijer.com/2010/why-arent-you-using-git-flow/
	brew install git-flow
	# brew install git-extras
	# brew install imagemagick --with-webp
	# brew install lua
	# brew install lynx
	# brew install p7zip
	# brew install pigz
	# brew install pv
	# brew install rename
	# brew install rhino
	# brew install speedtest_cli
	# brew install ssh-copy-id
	# brew install tree
	# brew install webkit2png
	# brew install zopfli
	# brew install pkg-config libffi
	# brew install pandoc
	# brew instal irssi

	# Lxml and Libxslt
	# brew install libxml2
	# brew install libxslt
	# brew link libxml2 --force
	# brew link libxslt --force

	# Cheatsheat
	brew cask install cheatsheet 

	# Install Heroku
	# brew install heroku-toolbelt
	# heroku update

	# Install Cask
	brew install caskroom/cask/brew-cask
	brew tap caskroom/versions

	# Set Homebrew Exports
	export HOMEBREW_CASK_OPTS="--appdir=/Applications"

	# Visual Studio Code
	brew cask install caskroom/cask/visual-studio-code

	# Dash 
	brew cask install dash

	# Transmission
	brew cask install transmission

	# Google Chrome	
	brew cask install google-chrome
	brew cask install chromium

	# Core casks
	brew cask install --appdir="/Applications" alfred
	brew cask install --appdir="~/Applications" iterm2
	brew cask install --appdir="~/Applications" java
	brew cask install --appdir="~/Applications" xquartz
	brew cask install spectacle

	# Github
	# brew cask install github-desktop
	# brew cask install githubpulse

	# Development tool casks
	# brew cask install --appdir="/Applications" atom
	# brew cask install --appdir="/Applications" virtualbox
	# brew cask install --appdir="/Applications" vagrant
	# #brew cask install --appdir="/Applications" macdown
	# brew cask install --appdir="/Applications" google-chrome
	# #brew cask install --appdir="/Applications" firefox


	# Communication apps
	# brew cask install --appdir="/Applications" skype
	brew cask install --appdir="/Applications" slack

	# Misc casks
	# brew cask install --appdir="/Applications" dropbox
	# brew cask install --appdir="/Applications" evernote
	# brew cask install --appdir="/Applications" lastpass
	#brew cask install --appdir="/Applications" 1password
	#brew cask install --appdir="/Applications" gimp
	#brew cask install --appdir="/Applications" inkscape

	#Remove comment to install LaTeX distribution MacTeX
	#brew cask install --appdir="/Applications" mactex

	# Link cask apps to Alfred
	brew cask alfred link

	# Install Docker, which requires virtualbox
	brew cask install docker
	# brew install boot2docker

	# Install developer friendly quick look plugins; see https://github.com/sindresorhus/quick-look-plugins
	brew cask install qlcolorcode qlstephen qlmarkdown quicklook-json qlprettypatch quicklook-csv betterzipql qlimagesize webpquicklook 

	# NodeJS
	brew install node

	# Postinstall
	brew doctor

	# Remove outdated versions from the cellar.
	brew cleanup

	# Archey
	brew install archey 
	brew install getantibody/tap/antibody
	brew install z
	brew install vim --with-client-server
brew install rvm
brew cask install transmission
brew install htop
