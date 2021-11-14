#!/bin/sh
# Ubuntu's Auto Rice Boostrapping Script (UARBS)
# by Marcos Camargo <mscamargo.dev@gmail.com>
# License: GNU GPLv3

download () { clear; echo "Downloading $1..."; wget "$1" -O /tmp/$(basename "$1"); }

download_installation_files () {
    base_url="https://raw.githubusercontent.com/mscamargo/uarbs/master"
    download "$base_url/packages.list"
    download "$base_url/debs.list"
    download "$base_url/ppas.list"
    download "$base_url/sources.list"
}

add_source () { clear; echo "Adding source..."; echo "$1" | sudo tee /etc/apt/sources.list.d/$2; }

add_sources () {
    while IFS=, read -r source file; do
        add_source "$source" "$file"
    done < /tmp/sources.list
}

add_ppa () { clear; echo "Adding ppa $1..."; sudo add-apt-repository -y "ppa:$1"; }

add_ppas () {
    while read ppa; do
        add_ppa "$ppa"
    done < /tmp/ppas.list
}

update () { clear; echo "Updating repositories..."; sudo apt update -y; }

install () { clear; echo "Installing $1..."; sudo apt install -y "$1"; }

install_packages () {
    while read package; do
        install "$package"
    done < /tmp/packages.list
}

install_required_dependencies () {
    for package in curl git zsh ca-certificates apt-transport-https; do
        install "$package"
    done
}

install_deb () { clear; echo "Installing $(basename $1)"; download "$1"; install /tmp/$(basename $1); }

install_debs () {
    while read deb; do
        install_deb "$deb"
    done < /tmp/debs.list
}

configure_sddm () {
    clear
    echo "Enabling SDDM..."
    sudo systemctl enable sddm
    clear
    echo "Setting Slice Theme..."
    sudo mkdir -pv /usr/share/sddm/themes
    git clone https://github.com/RadRussianRus/sddm-slice.git /tmp/sddm-slice
    sudo cp -rv /tmp/sddm-slice /usr/share/sddm/themes/slice
    sudo echo -e "[Theme]\nCurrent=slice" | sudo tee /etc/sddm.conf
}

install_dots () {
    clear
    echo "Installing dotfiles..."
    mkdir -p ~/src/dots
    cd ~/src/dots
    git init --bare
    git remote add origin https://github.com/mscamargo/dots.git
    git config --local status.showUntrackedFiles no
    cd ~
    git --git-dir=$HOME/src/dots --work-tree=$HOME pull origin master
    git --git-dir=$HOME/src/dots --work-tree=$HOME update-index --assume-unchanged "$HOME/README.md"
    rm README.md
}

install_required_dependencies
download_installation_files

# Add brave keys
clear
echo "Adding Brave Browser keys..."
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

add_sources
add_ppas
update
install_packages
install_debs
configure_sddm
install_dots

echo "Setting ZSH as default shell"
chsh -s $(which zsh)

echo "All done!"
