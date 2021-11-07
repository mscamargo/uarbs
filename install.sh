#!/bin/sh
# Ubuntu's Auto Rice Boostrapping Script (UARBS)
# by Marcos Camargo <mscamargo.dev@gmail.com>
# License: GNU GPLv3

packages_file="https://raw.githubusercontent.com/mscamargo/uarbs/master/packages.txt"

error() { printf "%s\n" "$1" >&2; exit 1; }

install() { clear; echo "Installing $1..."; sudo apt install -y "$1" ;}

update() { clear; echo "Updating repositories.."; sudo apt update -y; }

update || error "Update process failed"

# Installing packages
cp "$packages_file" /tmp/packages.txt) || wget "$packages_file" -O /tmp/packages.txt 
while read package; do
	install "$package"
done < /tmp/packages.txt

# Installing SDDM
install sddm
sudo systemctl enable sddm
sudo mkdir -p /usr/share/sddm/themes
git clone https://github.com/RadRussianRus/sddm-slice.git /tmp/sddm-slice
rm -rf /tmp/sddm-slice/.git
sudo cp -r /tmp/sddm-slice /usr/share/sddm/themes/slice
sudo echo "[Theme]\nCurrent=slice" >> /etc/sddm.conf

clear
