#!/bin/sh
# Ubuntu's Auto Rice Boostrapping Script (UARBS)
# by Marcos Camargo <mscamargo.dev@gmail.com>
# License: GNU GPLv3

packages_file="./packages.txt"

error() { printf "%s\n" "$1" >&2; exit 1; }

install() { clear; echo "Installing $1..."; sudo apt install -y "$1" ;}

update() { clear; echo "Updating repositories.."; sudo apt update -y; }

update || error "Update process failed"

# Installation loop
while read package; do
	install "$package"
done < $packages_file

# Install suckless softwares

clear
# Install dwm
mkdir ~/src

cd ~/src
git clone https://git.suckless.org/dwm
cd dwm
make
sudo make clean install
