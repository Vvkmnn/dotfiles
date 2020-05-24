#!/usr/bin/env bash
# Setup Ubuntu

# Install Regolith
sudo add-apt-repository ppa:regolith-linux/release
sudo apt install -y regolith-desktop i3xrocks-net-traffic i3xrocks-cpu-usage i3xrocks-time

# Logout and choose Regolith
gnome-session-quit
