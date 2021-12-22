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

add_gpg_keys () {
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
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
    sudo echo -e "[Theme]\nCurrent=slice\n\n[X11]\nSessionCommand=/urs/share/sddm/scripts/Xsession" | sudo tee /etc/sddm.conf
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

install_alacritty () {
    git clone https://github.com/alacritty/alacritty.git /tmp/alacritty
    cd /tmp/alacritty
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source $HOME/.cargo/env
    rustup override set stable
    rustup update stable
    cargo build --release
    sudo tic -xe alacritty,alacritty-direct extra/alacritty.info
    sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
    sudo desktop-file-install extra/linux/Alacritty.desktop
    sudo update-desktop-database
    sudo mkdir -p /usr/local/share/man/man1
    gzip -c extra/alacritty.man | sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
    gzip -c extra/alacritty-msg.man | sudo tee /usr/local/share/man/man1/alacritty-msg.1.gz > /dev/null
    cp extra/completions/_alacritty ${ZDOTDIR:-~}/.zsh_functions/_alacritty
}

install_polybar () {
    git clone --recursive https://github.com/polybar/polybar /tmp/polybar
    cd /tmp/polybar
    mkdir build
    cd build
    cmake ..
    make -j$(nproc)
    # Optional. This will install the polybar executable in /usr/local/bin
    sudo make install
}

install_docker () {
    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
}

install_lazygit () {
    download https://github.com/jesseduffield/lazygit/releases/download/v0.31.3/lazygit_0.31.3_Linux_x86_64.tar.gz
    tar -xzf /tmp/lazygit_0.31.3_Linux_x86_64.tar.gz
    mv /tmp/lazygit ~/.local/bin/lazygit
}

install_required_dependencies
download_installation_files

add_gpg_keys
add_sources
add_ppas
update
install_packages
install_debs
configure_sddm
install_dots
install_alacritty
install_polybar
install_docker
install_lazygit

echo "Setting ZSH as default shell"
chsh -s $(which zsh)

echo "All done!"
