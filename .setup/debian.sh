#!/usr/bin/env bash
# Setup Debian

# Update
sudo apt update

# Extras
sudo apt install software-properties-common wget x11-xkb-utils python3-pip

# Keyservers
sudo apt update 2>&1 1>/dev/null | sed -ne 's/.*NO_PUBKEY //p' | while read key; do if ! [[ ${keys[*]} =~ "$key" ]]; then sudo apt-key adv --keyserver hkp://pool.sks-keyservers.net:80 --recv-keys "$key"; keys+=("$key"); fi; done

# Mega
wget https://mega.nz/linux/MEGAsync/Debian_9.0/amd64/megasync-Debian_9.0_amd64.deb
sudo dpkg -i megasync-Debian_9.0_amd64.deb
sudo apt-get -f install
rm megasync-Debian_9.0_amd64.deb

# Update
sudo apt update && sudo apt install

