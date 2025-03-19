#!/bin/bash -e
###############################################################################
#
# Copyright (C) 2024, Design Pattern Solutions Inc
#
###############################################################################

# Define constants and initialize variables
NEURON_ID="$1"
NEURON_DIR="$HOME/neurons/neuron${NEURON_ID}"
SATORI_DIR_SOURCE_DIR="$HOME/.satori"
SATORI_DIR="$HOME/neurons/neuron${NEURON_ID}/.satori"
INSTALL_DEPENDENCIES=("expect" "openssh-server" "docker.io" "zip" "unzip" "wget" "curl" "vim" "python3.10-venv")
SYSTEMD_SERVICE_SOURCE="satori.service"
SYSTEMD_SERVICE="satori.${NEURON_ID}.service"

# External command paths
APTGET="/usr/bin/apt-get"
CP="/bin/cp"
DOCKER="/usr/bin/docker"
GIT="/usr/bin/git"
PWD="/usr/bin/pwd"
SED="/usr/bin/sed"
SYSTEMCTL="/usr/bin/systemctl"
SUDO="/usr/bin/sudo"

# Functions
splash() {
	echo ""
	echo "DPSI Satori Neuron Creator"
	echo "Copyright (C) 2024, Design Pattern Solutions Inc."
	echo ""
	echo "System Information:"
	echo "$(${SUDO} lsb_release -ds)"
	echo "Release Version: $(${SUDO} lsb_release -rs)"
	echo ""
	echo "Neuron ID: ${NEURON_ID}"
	if [ -z ${NEURON_ID} ]; then
		echo "ERROR: Missing Neuron ID"
		echo ""
		show_syntax
		exit 1
	fi
	NEURON_TEMP_PORT=$(echo "${NEURON_ID}" | awk '{sub(/^0*/,"")}1')
	NEURON_PORT=$(echo "246${NEURON_TEMP_PORT}")
	if [ -z ${NEURON_ID} ]; then
		echo "WARNING: Missing Neuron Port, using 24601"
		NEURON_PORT="24601"
	fi
	echo "Neuron Port: ${NEURON_PORT}"
	WORKING_DIR=$(${PWD})
	NOW=$(date +%s)
	echo "Current Directory: ${WORKING_DIR}"
	echo "NOW: ${NOW}"
	echo ""
}

show_syntax() {
	echo "Usage: $(basename "$0") <ID>"
	echo "    <ID> : Neuron ID"
	echo "    "
}

install_dependencies() {
	echo "** Installing dependencies **"
	${SUDO} ${APTGET} update
	${SUDO} ${APTGET} -y upgrade
	${SUDO} ${APTGET} -y install "${INSTALL_DEPENDENCIES[@]}"
}

install_satori() {
	cd "${SATORI_DIR}" || exit 1
	echo "** Running Satori installer **"
	${SUDO} /bin/bash install.sh
	
	# Setup Docker group for the current user
	if ! getent group docker > /dev/null; then
		${SUDO} /usr/sbin/groupadd docker
		echo "** Docker group created **"
	else
		echo "** Docker group already exists **"
	fi
	
	${SUDO} /usr/sbin/usermod -aG docker "$USER"
	echo "** Docker group updated for user $USER **"

	# Configure and enable Satori service
	echo "** Configuring Satori systemd service ${NEURON_ID} **"
	${SED} -i "s|#User=.*|User=$USER|" "${SATORI_DIR}/${SYSTEMD_SERVICE_SOURCE}"
	${SED} -i "s|WorkingDirectory=.*|WorkingDirectory=${SATORI_DIR}|" "${SATORI_DIR}/${SYSTEMD_SERVICE_SOURCE}"
	${SUDO} ${CP} "${SATORI_DIR}/${SYSTEMD_SERVICE}" /etc/systemd/system/${SYSTEMD_SERVICE}
	${SUDO} ${SYSTEMCTL} daemon-reload
	${SUDO} ${SYSTEMCTL} enable ${SYSTEMD_SERVICE}
	echo "** Satori service enabled **"
	cd ${WORKING_DIR}
}

create_neuron_dir() {
	mkdir -p ${SATORI_DIR}
	cd "${SATORI_DIR}" || exit 1
	echo "** Creating Satori Neuron ${NEURON_ID} using ${SATORI_DIR_SOURCE_DIR} **"
	${CP} -R ${SATORI_DIR_SOURCE_DIR}/* ${SATORI_DIR}/
	cd ${SATORI_DIR}
	${SUDO} /bin/bash install.sh
	${GIT} clone https://github.com/SatoriNetwork/Neuron.git ${NEURON_DIR}/Neuron
	cd ${WORKING_DIR}
}

build_neuron() {
	cd "${NEURON_DIR}/Neuron" || exit 1
	echo "** Building Satori Neuron ${NEURON_ID} using **"
	${SUDO} ${DOCKER} build --no-cache -f Dockerfile -t satorinet/satorineuron:neuron${NEURON_ID} .
	cd ${WORKING_DIR}
}

enable_neuron_service() {
	# Configure and enable Satori service
	cd "${SATORI_DIR}" || exit 1
	echo "** Configuring Satori systemd service **"
	${SED} -i "s|#User=.*|User=$USER|" "${SATORI_DIR}/${SYSTEMD_SERVICE_SOURCE}"
	${SED} -i "s|WorkingDirectory=.*|WorkingDirectory=${SATORI_DIR}|" "${SATORI_DIR}/${SYSTEMD_SERVICE_SOURCE}"
	${SUDO} ${CP} "${SATORI_DIR}/${SYSTEMD_SERVICE_SOURCE}" /etc/systemd/system/${SYSTEMD_SERVICE}
	${SUDO} ${SYSTEMCTL} daemon-reload
	${SUDO} ${SYSTEMCTL} enable ${SYSTEMD_SERVICE}
	echo "** Satori service enabled **"
	cd ${WORKING_DIR}
}

enable_v2_engine() {
	cd "${SATORI_DIR}" || exit 1
	echo "** Enabling v2 Satori Engine **"
	mkdir -p ${SATORI_DIR}/config
	if [ -e ${SATORI_DIR}/config/config.yaml ]; then
		mv ${SATORI_DIR}/config/config.yaml ${SATORI_DIR}/config/config.yaml.${NOW}
	fi
	echo "engine version: v2" > ${SATORI_DIR}/config/config.yaml
	echo "mining mode: true" >> ${SATORI_DIR}/config/config.yaml
	cd ${WORKING_DIR}
}

update_neuron_sh() {
	cd "${SATORI_DIR}" || exit 1
	echo "** Updating neuron.sh **"
	${SED} -i "s|\$HOME|${NEURON_DIR}|g" neuron.sh
	cd ${WORKING_DIR}
}

update_satori_py() {
	cd "${SATORI_DIR}" || exit 1
	echo "** Updating satori.py **"
	${SED} -i "s|\~\/\.satori|${SATORI_DIR}|g" satori.py
	${SED} -i "s|http\:\/\/127\.0\.0\.1\:24601|http\:\/\/127\.0\.0\.1\:${NEURON_PORT}|g" satori.py
	${SED} -i "s|docker run \-t \-\-rm \-\-name satorineuron |docker run \-t \-\-rm \-\-name satorineuron${NEURON_ID} |g" satori.py
	${SED} -i "s|\-p 24601\:24601 |\-p ${NEURON_PORT}\:24601 |g" satori.py
	${SED} -i "s|satorineuron\:{version}|satorineuron\:neuron${NEURON_ID}|g" satori.py
	cd ${WORKING_DIR}
}

update_satori_memory_limit() {
	cd "${SATORI_DIR}" || exit 1
	echo "** Updating satori.py memory limit **"
	${SED} -i "s|\-\-cpus\=4 |\-\-cpus\=4 \-\-memory\=2g |g" satori.py
	cd ${WORKING_DIR}
}

# Script execution starts here
splash
create_neuron_dir
build_neuron
enable_neuron_service
enable_v2_engine
update_neuron_sh
update_satori_py
update_satori_memory_limit

cd ${WORKING_DIR}
