#!/bin/bash

# Make sure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root:"
    echo "sudo $0"
    exit 1
fi

install_nvim_from_source() {

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

    # Neovim config directory
    CONFIG_DIR=~/.config/

    # If we're not in the config directory, move there
    if [[ ! $(pwd) == "$CONFIG_DIR/nvim" ]]; then

        # Make sure the config directory exists
        mkdir -p $CONFIG_DIR

        # Move everything to the config direcory
        mv ../nvim $CONFIG_DIR
    fi

    # Neovim installation directory
    INSTALL_DIR=/opt/neovim

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
        echo $VERSION
    fi
}

# Begin
clear

