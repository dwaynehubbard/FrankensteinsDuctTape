#####################
# Installing Satori #
#####################

Here we outline 4 easy steps to install Satori on Linux, the first two of which you have probably already completed. There are automated scripts that run the remaining two steps, or you can run each command manually.

## Step -1. Istall docker

If you haven't already, install the Docker Engine.
Ubuntu: https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
Debian: https://docs.docker.com/engine/install/debian/#install-using-the-repository
Fedora: https://docs.docker.com/engine/install/fedora/#install-using-the-repository
Or follow the instructions at https://docs.docker.com/desktop/install/linux-install/

## Step 0. Download and unzip Satori for linux

If you haven't already, you'll need to get satori from Satorinet.io.
You can unzip it into your home directory or where ever you want satori installed.
Here's how you can using the terminal.

First you'll need `zip` and `unzip` and `wget` if you don't have them already.

For Debian/Ubunto-based systems use:
```
sudo apt-get update
sudo apt-get install zip unzip wget curl
```

For Red Hat/CentOS-based systems use:
```
sudo yum update
sudo yum install zip unzip wget curl
```

Then you can download and unzip Satori:
```
cd ~
wget -P ~/ https://satorinet.io/static/download/satori.zip
unzip ~/satori.zip
rm ~/satori.zip
cd ~/.satori
```

Now you should have this folder: `~/.satori`

## Step 1. Install dependancies

Satori runs a small python script to manage the docker container and relay messages from the p2p network. It uses two packages: requests and aiohttp. We're going to install a python virtual environment to house these python dependancies. You need Python3.7 or greater to run this script.

**automated:**
```
bash install.sh
```

**manual:**
```
chmod +x ./neuron.sh
chmod +x ./satori.py
python3 -m venv "./satorienv"
source "./satorienv/bin/activate"
pip install -r "./requirements.txt"
deactivate
```

If you get a message about installing venv for python please do so, and try agian.

The message will provide a command to install python's virtual environments and it may vary depending on your linux distribution but should probably look something like this:

```
apt-get install python3-venv
```

## Step 2. Set up a service to keep Satori running

We're going to use systemd to keep satori up and running all the time.

**automated:**
```
bash install_service.sh
```

**manual:**
```
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
sed -i "s/#User=.*/User=$USER/" "$(pwd)/satori.service"
sed -i "s|WorkingDirectory=.*|WorkingDirectory=$(pwd)|" "$(pwd)/satori.service"
sudo cp satori.service /etc/systemd/system/satori.service
sudo systemctl daemon-reload
sudo systemctl enable satori.service
sudo systemctl start satori.service
```

Then logout and login.

## Step 3. verify it's up and running occasionally

Try to keep it runnning as much as you can. Satori data streams that are active every day retain their sanctioned status and are eligible for rewards. Satori Neurons that are up and running every month remain activate and eligible for rewards.

```
sudo systemctl status satori.service
```

You can even watch the logs:
```
journalctl -fu satori.service
```
