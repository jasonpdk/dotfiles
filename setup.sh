#!/bin/bash

# update first
sudo dnf update -y

sudo dnf install -y zsh vim tmux git

# Vundle
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
cp ./vim/.vimrc ./.tmux.conf ~

INSTALL_TYPE=$1

if [ "$INSTALL_TYPE" == "full" ] || [ "$INSTALL_TYPE" == "media" ]
then
    # RPM Fusion repo
    sudo dnf install -y  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

    # Install gome extensions
    wget -O gnome-shell-extension-installer "https://github.com/brunelli/gnome-shell-extension-installer/raw/master/gnome-shell-extension-installer"
    chmod +x gnome-shell-extension-installer
    
    ./gnome-shell-extension-installer 307 # Dash to dock
    ./gnome-shell-extension-installer 19 # User themes
    ./gnome-shell-extension-installer 750 # Open weather

    dconf write /org/gnome/desktop/wm/preferences/button-layout "'appmenu:minimize,maximize,close'"
    dconf write /org/gnome/desktop/interface/enable-hot-corners true
    dconf write /org/gnome/desktop/interface/show-battery-percentage true
    dconf write /org/gnome/desktop/interface/clock-show-weekday true
    dconf write /org/gnome/desktop/interface/clock-show-date true
    dconf write /org/gnome/desktop/interface/clock-show-seconds true

    sudo dnf install -y filezilla vlc firefox gparted pass conky

    # Pass
    # TODO pass init needs gpg key
    sudo rm -r  ~/.password-store
    git clone git@github.com:jasonpdk/pass.git ~/.password-store

    # Chrome
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
    sudo dnf install -y ./google-chrome-stable_current_x86_64.rpm
    
    # Conky
    cp ./conky/.conkyrc ~/.config/.conkyrc
    cp ./conky/conky.desktop ~/.config/autostart/conky.desktop

    if [ "$INSTALL_TYPE" == "full" ]
    then
        # install vscode
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
        sudo dnf check-update
        sudo dnf install -y code

        sudo dnf install -y thunderbird gnome-tweak-tool gimp

        # insync
        sudo rpm --import https://d2t3ff60b2tol4.cloudfront.net/repomd.xml.key

        sudo echo "
            [insync]
            name=insync repo
            baseurl=http://yum.insync.io/[DISTRIBUTION]/$releasever/
            gpgcheck=1
            gpgkey=https://d2t3ff60b2tol4.cloudfront.net/repomd.xml.key
            enabled=1
            metadata_expire=120m
        " >> /etc/yum.repos.d/insync.repo

        sudo dnf install -y insync

        # Discord
        wget https://discordapp.com/api/download\?platform\=linux\&format\=tar.gz -O discord.tar.gz
        tar -xvf discord.tar.gz
        # TODO 

        # Postman
        wget https://dl.pstmn.io/download/latest/linux64 -O postman-linux-x64.tar.gz
        sudo tar xvzf postman-linux-x64.tar.gz -C /opt
        sudo ln -s /opt/Postman/Postman /usr/bin/postman

        touch ~/.local/share/applications/postman.desktop
        echo "
            [Desktop Entry]
            Name=Postman
            GenericName=API Client
            X-GNOME-FullName=Postman API Client
            Comment=Make and view REST API calls and responses
            Keywords=api;
            Exec=/opt/Postman/Postman
            Terminal=false
            Type=Application
            Icon=/opt/Postman/app/resources/app/assets/icon.png
            Categories=Development;Utilities;
        " >> ~/.local/share/applications/postman.desktop

    elif [ "$INSTALL_TYPE" == "media" ]
    then
        sudo dnf install -y kodi
    fi
fi

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
cp ./zsh/.zshrc ~
