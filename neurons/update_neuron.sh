#!/bin/bash
###############################################################################
#
# Copyright (C) 2024, Design Pattern Solutions Inc
#
###############################################################################

# Ensure the script is executed with exactly one argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path_to_neurons_directory>"
    exit 1
fi

NEURONS_DIR="$1"

# Check if the specified directory exists
if [ ! -d "$NEURONS_DIR" ]; then
    echo "Error: Directory $NEURONS_DIR does not exist."
    exit 1
fi

# Iterate over each neuronXXX subdirectory
for NEURON_DIR in "$NEURONS_DIR"/neuron???; do
    if [ -d "$NEURON_DIR" ]; then
        # Extract the numeric identifier (XXX) from the directory name
        NEURON_ID=$(basename "$NEURON_DIR" | grep -oP '\d{3}')

        ## Skip specific neurons
        #if [[ "$NEURON_ID" == "053" || "$NEURON_ID" == "054" || "$NEURON_ID" == "055" ]]; then
        #    echo "Skipping neuron$NEURON_ID..."
        #    continue
        #fi

	echo "*********************************************"
	echo "**  NEURON ID: $NEURON_ID"
	echo "*********************************************"

        # Stop the systemd service
        echo "Stopping systemd service for satori.$NEURON_ID.service..."
        sudo systemctl stop "satori.$NEURON_ID.service"

        # Stop the corresponding Docker container
        echo "Stopping Docker container satorineuron$NEURON_ID..."
        sudo docker stop "satorineuron$NEURON_ID"

        # Navigate to the Neuron subdirectory
        if cd "$NEURON_DIR/Neuron"; then
            echo "Entering directory: $NEURON_DIR/Neuron"

            # Generate the patch file
            TIMESTAMP=$(date +%s)
            PATCH_FILE="satorineuron$NEURON_ID.$TIMESTAMP.patch"
            echo "Creating patch file: $PATCH_FILE..."
            git diff > "$PATCH_FILE"

            # Reset and pull the latest changes from Git
            echo "Resetting repository..."
            git reset --hard
            echo "Pulling latest changes from Git..."
            git pull

            # Reapply the patch file
            echo "Reapplying the patch file: $PATCH_FILE..."
            git apply "$PATCH_FILE"
            if [ $? -ne 0 ]; then
                echo "Error: Failed to apply the patch file $PATCH_FILE."
            else
                echo "Patch file applied successfully."
            fi

            # Build the Docker image
            echo "Building Docker image for neuron$NEURON_ID..."
            sudo docker build --no-cache -f Dockerfile -t "satorinet/satorineuron:neuron$NEURON_ID" .

            # Navigate back to the base directory
            cd - > /dev/null
        else
            echo "Error: Could not enter directory $NEURON_DIR/Neuron"
        fi

        # Start the systemd service
        echo "Starting systemd service for satori.$NEURON_ID.service..."
        sudo systemctl start "satori.$NEURON_ID.service"
    else
        echo "Skipping invalid directory: $NEURON_DIR"
    fi
done

echo "Script execution completed."

