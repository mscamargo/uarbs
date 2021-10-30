#!/bin/sh
# Ubuntu's Auto Rice Boostrapping Script (UARBS)
# by Marcos Camargo <mscamargo.dev@gmail.com>
# inspired by <https://larbs.xyz/>
# License: GNU GPLv3

### FUNCTIONS ###

LOGS_FILE=~/install.logs

error() { printf "%s\n" "$1" >&2; exit 1; }

installpkg(){ sudo apt install -y "$1" >> $LOGS_FILE ;}

update_repos() {
	dialog --title "UARBS Installation" --infobox "Updating repositories.." 5 70
	sudo apt update -y >> $LOGS_FILE
}

sudo apt install -y dialog >> $LOGS_FILE || error "Are you sure your running this as a root user"

update_repos || error "User exited."

for x in curl ca-certificates git zsh ; do
	dialog --title "UARBS Installation" --infobox "Installing \`$x\` which is required to install and configure other programs." 5 70
	installpkg "$x"
done

clear
