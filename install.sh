#!/bin/bash

# # Make sure the script is run as root
# if [ "$EUID" -ne 0 ]; then
#     echo "Please run as root:"
#     echo "sudo $0"
#     exit 1
# fi

install_nvim_from_source() {

    # Working directory
    WORKING_DIR=$(pwd)
    # Neovim config directory
    CONFIG_DIR=~/.config/nvim
    # Neovim installation directory
    INSTALL_DIR=/opt/neovim

    # Necessary packages
    declare -a PACKAGES=(
        gcc
        ninja-build
        gettext
        cmake
        unzip
        curl
    )

    # Prompt
    echo "Installing the following packages: ${PACKAGES[@]}"

    # Install packages
    apt-get update >/dev/null && apt-get install -y ${PACKAGES[@]}

    # If we're not in the config directory, move there
    if [[ ! "$WORKING_DIR" == "$CONFIG_DIR" ]]; then

        # Make sure the config directory exists
        mkdir -p $CONFIG_DIR

        # Move everything to the config direcory
        mv $WORKING_DIR $CONFIG_DIR/../
    fi

    # Grab the most recent stable release of Neovim
    git submodule update --init && git checkout stable

    # Install Neovim!
    make CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$INSTALL_DIR"
    make install

    # Add Neovim to PATH
    export PATH="$PATH:$INSTALL_DIR/neovim/bin"

    # Make sure it's working
    VERSION=$(nvim --version)

    if [[ $? -ne 0 ]]; then
        echo "Fatal: Neovim returned a non-zero exit status, exiting..."
        exit 1
    else
        echo "Neovim installed successfully!"
        echo $VERSION
    fi
}

install_neovim() {

    # Try to install the easy way first
    echo "Installing Neovim..."

    # URL to the latest Neovim AppImage
    NEOVIM_INSTALL_URL="https://github.com/neovim/neovim/releases/latest/download/nvim.appimage"

    # Download the appimage and make it executable
    curl -LO $NEOVIM_INSTALL_URL && chmod u+x nvim.appimage

    # Get the full path to the appimage
    NVIM_APPIMAGE=$(readlink -f ./nvim.appimage)

    # Check if the appimage works
    if [[ -x "$(command -v $NVIM_APPIMAGE)" ]]; then

        # If it works, then move it to /usr/local/bin
        mv $NVIM_APPIMAGE /usr/local/bin/nvim

        # Done!
        echo "Neovim installed successfully!"
        return 0

    else

        # If it doesn't work, then delete it
        rm $NVIM_APPIMAGE

        # Install Neovim from source
        install_nvim_from_source

    fi

}

#################### Main ####################
clear

# Check if Neovim is already installed
if [[ ! -x "$(command -v nvim)" ]]; then

    # Install Neovim
    install_neovim

fi
