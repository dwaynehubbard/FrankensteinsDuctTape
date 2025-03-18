#!/bin/bash

#### Installing Satori in virtual environment with dependencies ####
if [ -f "./neuron.sh" ]; then
    # make scripts executable
    chmod +x ./neuron.sh
    chmod +x ./satori.py
    # Create virtual environment
    command -v python3 >/dev/null 2>&1 || { echo "Python 3 not found, please install Python 3"; exit 1; }
    python3 -m venv "./satorienv"
    # Check if the virtual environment was created successfully
    if [ -d "./satorienv" ]; then
        echo "Virtual environment created successfully."
        # Activate the virtual environment
        # Using '.' instead of 'source' for better compatibility with different shells
        . "./satorienv/bin/activate"
        # Check if activation was successful
        if [ "$VIRTUAL_ENV" != "" ]; then
            echo "Virtual environment activated."
            pip install -r "./requirements.txt"
            echo "Dependencies installed."
        else
            echo "Failed to activate the virtual environment."
        fi
    else
        #apt install python3-venv # user will get the message and if they're on linux they can follow the instructions
        echo "Failed to create virtual environment."
    fi
else
    echo ".satori folder not found. Please unzip the Satori archive first."
fi
