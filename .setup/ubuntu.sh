#!/usr/bin/env bash
# Setup Ubuntu

# Extras
sudo apt install ubuntu-restricted-extras


# Install Regolith
sudo add-apt-repository ppa:regolith-linux/release
sudo apt install -y regolith-desktop i3xrocks-net-traffic i3xrocks-cpu-usage i3xrocks-time

# Install Xcape
sudo apt install xcape

# Update
sudo apt-get update && sudo apt-get dist-upgrade

# Logout and choose Regolith
gnome-session-quit
