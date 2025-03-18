#!/bin/bash

# Stop satori service
sudo systemctl stop satori.service
echo "satori.service stopped"

# Stop Docker services
sudo systemctl stop docker
echo "docker stopped"

sudo systemctl stop docker.socket
echo "docker.socket stopped"

# Start Docker services
sudo systemctl start docker
echo "docker started"

# Start satori service
sudo systemctl start satori.service
echo "satori.service started"

# End of script

