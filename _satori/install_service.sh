#!/bin/bash

# Script to update satori.service with correct user, group, and ExecStart

CURRENT_DIR=$(pwd)
SERVICE_FILE="$CURRENT_DIR/satori.service"
CURRENT_USER=$(whoami)

# give user permission to run docker without sudo
if groups $USER | grep -q docker; then
    echo "User has docker permissions."
else
    echo "Giving user docker permissions. Please try again."
    sudo groupadd docker
    sudo usermod -aG docker $CURRENT_USER
    newgrp docker
fi 

# Updating the User and Group in the satori.service file
sed -i "s/#User=.*/User=$CURRENT_USER/" $SERVICE_FILE

# Updating the WorkingDirectory path
sed -i "s|WorkingDirectory=.*|WorkingDirectory=$CURRENT_DIR|" $SERVICE_FILE

# install service
sudo cp satori.service /etc/systemd/system/satori.service
sudo systemctl daemon-reload
sudo systemctl enable satori.service
sudo systemctl start satori.service

# Check if everything went well
if groups $USER | grep -q docker && [ -f "/etc/systemd/system/satori.service" ] && systemctl status satori.service &> /dev/null; then
    echo "satori.service has been updated with User, Group, and WorkingDirectory path."
else
    echo "failed to install service, please do so manually."
fi
