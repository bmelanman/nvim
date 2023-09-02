#!/bin/bash

# This script is used to test the installation script in a docker container

# Container name
CONTAINER_NAME="test"
# Flag for running the install script
INSTALL_FLAG=0
# Flag for entering the container after installation
ENTER_FLAG=0
# Neovim config directory
CONFIG_DIR=~/.config/nvim

# User input
for i in "$@"; do
    case $i in
    -h | --help)
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "-h, --help      Show this help message"
        echo "-i, --install   Run the install script"
        echo "-e, --enter     Enter the container after installation"
        echo ""
        exit 0
        ;;
    -i | --install)
        INSTALL_FLAG=1
        shift
        ;;
    -e | --enter)
        ENTER_FLAG=1
        shift
        ;;
    esac
done

# Remove all containers
docker rm -f $(docker ps -aq)

# Create a new container names "test"
docker run -td --name=$CONTAINER_NAME ubuntu:latest

# Update and install git
docker exec -it $CONTAINER_NAME /bin/bash -c 'apt-get update -q && apt-get install -y git -q'

# Clone the nvim repo
docker exec -it $CONTAINER_NAME /bin/bash -c 'git clone https://github.com/bmelanman/nvim.git $CONFIG_DIR && cd $CONFIG_DIR'

# Run the installer!
docker exec -it $CONTAINER_NAME /bin/bash -c './install.sh'

# Enter the container after installation if desired
if [[ $ENTER_FLAG -eq 1 ]]; then
    docker exec -it $CONTAINER_NAME /bin/bash
fi
