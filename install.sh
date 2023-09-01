#!/bin/bash

# Make sure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root:"
    echo "sudo $0"
    exit 1
fi

clear

# Necessary packages
declare -a PACKAGES=(
    gcc
    cmake
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
CONFIG_DIR=~/.config/nvim

# Get the current folder location
PWD=$(pwd)

# If we're not in the config directory, move there
if [[ ! PWD == CONFIG_DIR ]]; then

    # Make sure the config directory exists
    mkdir -p ~/.config

    # Move everything to the config direcory
    mv ../nvim $CONFIG_DIR
    cd $CONFIG_DIR/install

fi

# Init submodules if necessary
git submodule update --init



