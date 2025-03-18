# Frankenstein's Duct Tape

This is a collection of bash scripts that can be used to run multiple Satori neurons on a single platform
ranging from a Raspberry Pi 4B w/ 4GB of RAM to a large server

https://satorinet.io/

This project is not associated with the Satori project or the Satori Association.

# Getting Started

This collection of scripts expects the contents of the "\_satori" to be in your $HOME/.satori directory

```
cp -r _satori "$HOME/.satori"
```

Recursively copy the contents the "neurons" directory to your target host.

You want to give your neurons unique IDs. This script uses two-digit numbers. To create 10 neurons
with IDs ranging from 10 to 19, use the following command:

```
cd neurons ;
for n in `seq 10 19`; do NID=$(echo "0$n"); ./create_neuron.sh $NID ; done
```

This will build 10 neurons, named _neuron010_ through _neuron019_. To start/stop your new neurons
you can use the command below, replacing NID with the actual three-digit neuron ID.

```
sudo systemctl stop satori.NID.service ;
sudo docker stop satorineuronNID ;
sudo systemctl start satori.NID.service ;
```

for example, to restart _neuron015_ perform the following:

```
sudo systemctl stop satori.015.service ;
sudo docker stop satorineuron015 ;
sudo systemctl start satori.015.service ;
```

# Updating Your Neuron

To update the Neuron source code with the latest and greatest source code from the Satori Github, use the following
operation:

```
cd ~/neurons ;
./update_neuron.sh ~/neurons 
```



