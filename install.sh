#!/bin/bash

# # Make sure the script is run as root
# if [ "$EUID" -ne 0 ]; then
#     echo "Please run as root:"
#     echo "sudo $0"
#     exit 1
# fi

install_packages() {

    # Prompt
    echo "Installing the following packages: $@"

    # Install packages
    sudo apt-get update >/dev/null && sudo apt-get install -y $@

}

error_exit() {

    # Error message
    echo "Fatal: !! retunred exit status $?, exiting..."

    exit 1
}

install_nvim_from_source() {

    INSTALL_DIR=/opt/neovim

    # Necessary packages
    declare -a PACKAGES=(
        gcc
        ninja-build
        gettext
        cmake
        unzip
    )

    # Install packages
    install_packages ${PACKAGES[@]}

    # Grab the most recent stable release of Neovim
    git submodule update --init || error_exit
    cd neovim && git checkout stable

    # Install Neovim!
    make --silent CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$INSTALL_DIR"
    sudo make --silent install

    if [[ $? -eq 0 ]]; then

        # Make a symlink to the executable
        sudo ln -s $INSTALL_DIR/bin/nvim /usr/local/bin/nvim

        # Done!
        return 0
    else

        # Error message
        echo "Fatal: Make returned a non-zero exit status, exiting..."

        exit 1
    fi
}

install_neovim() {

    # Install necessary packages
    install_packages curl

    # Try to install the easy way first
    echo "Installing Neovim via AppImage..."

    # URL to the latest Neovim AppImage
    NEOVIM_INSTALL_URL="https://github.com/neovim/neovim/releases/latest/download/nvim.appimage"

    # Download the appimage and make it executable
    curl -LO $NEOVIM_INSTALL_URL && chmod u+x nvim.appimage

    # Get the full path to the appimage
    NVIM_APPIMAGE=$(readlink -f ./nvim.appimage)

    # Check if the appimage works
    ./nvim.appimage --version
    if [[ $? -eq 0 ]]; then

        # If it works, then move it to /usr/local/bin
        sudo mv $NVIM_APPIMAGE /usr/local/bin/nvim

        # Done!
        return 0

    else

        # If it doesn't work, then delete it
        rm $NVIM_APPIMAGE

        # Prompt
        echo "AppImage is incompatible, installing Neovim from source..."

        # Install Neovim from source
        install_nvim_from_source

        return $? # Return the exit status of the function

    fi

}

#################### Script Start ####################
clear

# Parse input flags
for i in "$@"; do
    case $i in
    -h | --help)
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "-h, --help      Show this help message"
        echo ""
        exit 0
        ;;
    esac
done

WORKING_DIR=$(pwd)
CONFIG_DIR=~/.config/nvim

# If we're not in the config directory, throw an error
if [[ ! "$WORKING_DIR" == "$CONFIG_DIR" ]]; then

    # Prompt
    echo "Fatal: Please run this script from the config directory:"
    echo "cd $CONFIG_DIR"
    exit 1
fi

# Check if Neovim is already installed
VERSION=$(nvim --version)
if [[ $? -ne 0 ]]; then

    # Install Neovim
    install_neovim

    if [[ $? -ne 0 ]]; then
        echo "Fatal: Neovim was not found and could not be installed, exiting..."
        exit $?
    else
        echo "Neovim installed successfully!"
        echo "$VERSION"
    fi

fi

# Necessary packages for Neovim and plugins
declare -a PACKAGES=(
    wget
    cargo
    ruby
    gem
    npm
    luarocks
    python3
    python3-pip
    php
    composer
    perl
    ripgrep
    fd-find
)

# Install packages
install_packages ${PACKAGES[@]} && sudo apt-get autoremove -y

# Create a symlink for python3
PYTHON3_EXE=$(which python3)
sudo ln -s $PYTHON3_EXE /usr/local/bin/python3
# Install pynvim
$PYTHON3_EXE -m pip install -q pynvim

# Install neovim for ruby
gem install -q neovim && gem environment -q

# Install neovim for npm
npm install -q -g n
n -q lts && n -q latest
npm install -q -g neovim

# Install cpanm and neovim for perl
cpan -q App::cpanminus && cpan -q Neovim::Ext
