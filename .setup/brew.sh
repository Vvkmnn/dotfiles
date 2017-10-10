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

        # Unix Utilities {{{

	# Install GNU core utilities (those that come with OS X are outdated).
	# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
	brew install coreutils

	# Install some other useful utilities like `sponge`.
	# brew install moreutils

	# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
	# brew install findutils
        
	# Install GNU `sed`, overwriting the built-in `sed`.
	# brew install gnu-sed --with-default-names
        
	# Install Bash 4.
	# brew install bash
	# brew install bash-completion2

	# We installed the new shell, now we have to activate it
	# echo "Adding the newly installed shell to the list of allowed shells"
	# Prompts for password
	# sudo bash -c 'echo /usr/local/bin/bash >> /etc/shells'
	# Change to the new shell, prompts for password
	# chsh -s /usr/local/bin/bash

        # Grep
	brew install homebrew/dupes/grep
        # OpenSSH
	brew install homebrew/dupes/openssh

	# ack - excellent little search tool: https://www.youtube.com/watch?time_continue=85&v=sKmyl5D8Da8
	brew install ack


	# git LFS - Large file storage; just in case
	brew install git-lfs
        git lfs install --system

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

	# Install `wget` with IRI support.
	brew install wget --with-iri
        # }}}
    
        # Python {{{
	brew install python
	brew install python3
        # }}}

	# Ruby {{{
	# brew install ruby-build
	# brew install rbenv
	# LINE='eval "$(rbenv init -)"'
	# grep -q "$LINE" ~/.extra || echo "$LINE" >> ~/.extra

	# Vim {{{
	brew install vim --override-system-vi
        # }}}

        # Tmux {{{
	brew install tmux
        # }}}

	# Fonts {{{
	brew tap caskroom/fonts   
	brew cask install font-inconsolata-for-powerline
	brew cask install font-inconsolata
        # }}}

        # CLI {{{
	# Z
	brew install z

        # htop
        brew install htop
        
        # Archey
	brew install archey

	# Reddit
	brew install rtv 

        # The Fuck 
        brew install thefuck

        # htop
        brew install htop

        # fzf
        # brew install fzf
        # $(brew --prefix)/opt/fzf/install

        # htop
        brew install htop
        # }}}

	# Postinstall and Cleanup
	brew doctor
	brew cleanup
