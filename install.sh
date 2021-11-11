#!/bin/sh
# Ubuntu's Auto Rice Boostrapping Script (UARBS)
# by Marcos Camargo <mscamargo.dev@gmail.com>
# License: GNU GPLv3

packages_file="https://raw.githubusercontent.com/mscamargo/uarbs/master/packages.txt"

update () { clear; echo "Updating repositories..."; sudo apt update -y; }

add_ppa () { clear; echo "Adding ppa $1..."; sudo add-apt-repository -y "$1"; }

add_ppas () {
    add_ppa ppa:regolith-linux/release
}

install () { clear; echo "Installing $1..."; sudo apt install -y "$1" ;}

install_packages () {
    cp "$packages_file" /tmp/packages.txt || wget "$packages_file" -O /tmp/packages.txt
    while read package; do
        install "$package"
    done < /tmp/packages.txt
}

install_sddm () {
    clear
    install sddm
    sudo systemctl enable sddm
    sudo mkdir -p /usr/share/sddm/themes
    git clone https://github.com/RadRussianRus/sddm-slice.git /tmp/sddm-slice
    sudo cp -r /tmp/sddm-slice /usr/share/sddm/themes/slice
    sudo echo -e "[Theme]\nCurrent=slice" | sudo tee /etc/sddm.conf
}

install_brave () {
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    update
    install brave-browser
}

install_discord () {
    clear
    wget https://dl.discordapp.net/apps/linux/0.0.16/discord-0.0.16.deb -O /tmp/discord.deb
    install /tmp/discord.deb
}

install_dots () {
    clear
    echo "Installing dotfiles..."
    mkdir -p ~/.local/src/dots
    cd ~/.local/src/dots
    git init --bare
    git remote add origin https://github.com/mscamargo/dots
    cd ~
    git --git-dir=$HOME/.local/src/dots --work-tree=$HOME pull origin master
    git update-index --assume-unchanged "~/README.md"
    rm README.md
}

add_ppas
update
install_packages
install_sddm
install_dots
install_brave
install_discord

clear

echo "All done!"
