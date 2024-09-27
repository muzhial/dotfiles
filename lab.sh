#!/bin/bash

detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="Linux"
        CPU_COUNT=$(nproc)
        echo "OS: Linux, CPU: ${CPU_COUNT}"
        echo $(uname -a)
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macOS"
        CPU_COUNT=$(sysctl -n hw.ncpu)
        echo "OS: macOS, CPU: ${CPU_COUNT}"
        echo $(uname -a)
    else
        echo "OS: Unknown"
        OS="Unknown"
    fi
    echo
}

prompt() {
    local prompt_message=$1
    local default_value=$2
    local user_input

    read -p "$prompt_message: " user_input
    if [ -z "$user_input" ]; then
        user_input=$default_value
    fi
    echo $user_input
}

install_software() {
    local software_name=$1
    local default_choice=$2

    choice=$(prompt "> Do you want to install $software_name? (Y/n)" $default_choice)

    if [ "$choice" == "y" ]; then
        echo "Installing $software_name..."
    else
        echo "Skipping installation of $software_name."
    fi
}

main() {
    detect_os
    install_software "cmd" "y"
}

main