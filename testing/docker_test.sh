#!/bin/bash

# This script is used to test the installation script in a docker container

# Container name
CONTAINER_NAME="test"
# Neovim config directory
CONFIG_DIR=/root/.config/nvim
# Flags
INSTALL_FLAG=0
ENTER_FLAG=0
RESET_FLAG=0

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
        echo "-r, --remove    Remove the test environment container"
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
    -r | --remove)
        RESET_FLAG=1
        shift
        ;;
    *)
        echo "Fatal: Unknown option: $i"
        exit 1
        ;;
    esac
done

clear

# Remove the container if desired
if [[ $RESET_FLAG -eq 1 ]]; then

    # Remove all containers
    docker rm -f $(docker ps -aq)

    # Create a new container names "test"
    docker run -td --name="$CONTAINER_NAME" ubuntu:latest

    # Update and install git
    docker exec -it "$CONTAINER_NAME" /bin/bash -c "apt-get update -q && apt-get install -y git sudo -q"

    # Create the config directory
    docker exec -it "$CONTAINER_NAME" /bin/bash -c "mkdir -p $CONFIG_DIR && cd $CONFIG_DIR"

    # Clone the nvim repo
    docker exec -it "$CONTAINER_NAME" /bin/bash -c "git clone https://github.com/bmelanman/nvim.git $CONFIG_DIR"

    # Import come convenience commands
    docker exec -it "$CONTAINER_NAME" /bin/bash -c "echo \"alias rewq='clear'\" | tee -a /root/.bashrc"
    docker exec -it "$CONTAINER_NAME" /bin/bash -c "echo \"alias la='ls -laFh'\" | tee -a /root/.bashrc"
    docker exec -it "$CONTAINER_NAME" /bin/bash -c "echo \"alias go='cd $CONFIG_DIR'\" | tee -a /root/.bashrc"

fi

# Run the installer!
if [[ $INSTALL_FLAG -eq 1 ]]; then
    docker exec -it "$CONTAINER_NAME" /bin/bash -c "./install.sh"
fi

# Enter the container after installation if desired
if [[ $ENTER_FLAG -eq 1 ]]; then
    docker exec -it "$CONTAINER_NAME" /bin/bash
fi
