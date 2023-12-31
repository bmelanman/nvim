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

    # Get a list of all containers
    CONTAINERS=$(docker ps -a --format '{{.Names}}')

    # If the container exists, then remove it
    if [[ $CONTAINERS == *"$CONTAINER_NAME"* ]]; then
        docker rm -f "$CONTAINER_NAME" >/dev/null
    fi

    # Create a new container names "test"
    docker run -td --name="$CONTAINER_NAME" ubuntu:latest

    # Enable colors in the terminal
    docker exec -it "$CONTAINER_NAME" /bin/bash -c "sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /root/.bashrc"

    # Update and install git
    docker exec -it "$CONTAINER_NAME" /bin/bash -c "apt-get update -q && apt-get install -q -y git sudo"

    # Create the config directory
    docker exec -it "$CONTAINER_NAME" /bin/bash -c "mkdir -p $CONFIG_DIR && cd $CONFIG_DIR"

    # Clone the nvim repo
    docker exec -it "$CONTAINER_NAME" /bin/bash -c "git clone https://github.com/bmelanman/nvim.git $CONFIG_DIR"

    # Import come convenience commands
    declare -a COMMANDS=(
        "alias rewq='clear'"
        "alias la='ls -laFh'"
        "alias go='cd $CONFIG_DIR'"
        "cd /root/"
    )

    # Add the commands to the bashrc
    for i in "${COMMANDS[@]}"; do
        docker exec -it "$CONTAINER_NAME" /bin/bash -c "echo \"$i\" | tee -a /root/.bashrc"
    done
else

    # Start the container
    docker start "$CONTAINER_NAME" >/dev/null

fi

# Run the installer!
if [[ $INSTALL_FLAG -eq 1 ]]; then
    docker exec -it "$CONTAINER_NAME" /bin/bash -c "cd $CONFIG_DIR && ./install.sh"
fi

# Enter the container after installation if desired
if [[ $ENTER_FLAG -eq 1 ]]; then
    docker exec -it "$CONTAINER_NAME" /bin/bash
fi
