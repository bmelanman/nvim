#!/bin/bash

# # Make sure the script is run as root
# if [ "$EUID" -ne 0 ]; then
#     echo "Please run as root:"
#     echo "sudo $0"
#     exit 1
# fi

install_nvim_from_source() {

    WORKING_DIR=$(pwd)
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
    sudo apt-get update >/dev/null && sudo apt-get install -y ${PACKAGES[@]}

    # Grab the most recent stable release of Neovim
    git submodule update --init
    cd neovim && git checkout stable

    # Install Neovim!
    make CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$INSTALL_DIR"
    sudo make install

    if [[ $? -ne 0 ]]; then
        echo "Fatal: Make returned a non-zero exit status, exiting..."
        exit 1
    else

        # Add Neovim to PATH
        export PATH="$PATH:$INSTALL_DIR/neovim/bin"

        # Done!
        return 0
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
    ./nvim.appimage --version
    if [[ $? -ne 0 ]]; then

        # If it works, then move it to /usr/local/bin
        sudo mv $NVIM_APPIMAGE /usr/local/bin/nvim

        # Done!
        return 0

    else

        # If it doesn't work, then delete it
        rm $NVIM_APPIMAGE

        # Install Neovim from source
        install_nvim_from_source

        return $? # Return the exit status of the function

    fi

}

#################### Main ####################
clear

CONFIG_DIR=~/.config/nvim

# If we're not in the config directory, throw an error
if [[ ! "$WORKING_DIR" == "$CONFIG_DIR" ]]; then

    # Prompt
    echo "Fatal: Please run this script from the config directory:"
    echo "cd $CONFIG_DIR"
    exit 1
fi

# Check if Neovim is already installed
if [[ ! -x "$(command -v nvim)" ]]; then

    # Install Neovim
    install_neovim

    if [[ $? -ne 0 ]]; then
        echo "Fatal: Neovim was not found and could not be installed, exiting..."
        exit $?
    else
        echo "Neovim installed successfully!"
        echo "$(nvim --version)"
    fi

fi
