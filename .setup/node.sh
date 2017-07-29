#!/usr/bin/env bash

# Check for NPM
if test ! $(which npm); then
	  echo "Installing node..."
	  brew install node
	  npm install -g npm 
    fi

# Install command-line tools using Homebrew.
npm update

# XO Linter
npm install -g xo

# Semantic Release CLI (Semver)
npm install -g semantic-release-cli

npm install -g ngrok
