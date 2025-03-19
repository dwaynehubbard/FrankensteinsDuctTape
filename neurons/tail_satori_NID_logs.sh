#!/bin/bash -e
###############################################################################
#
# Copyright (C) 2024, Design Pattern Solutions Inc
#
###############################################################################

splash() {
	echo ""
	echo "DPSI Satori Neuron Creator"
	echo "Copyright (C) 2024, Design Pattern Solutions Inc."
	echo ""
}

do_tail() {
	NID=$(pwd | awk -F "\/" '{print $5}' | awk -F "neuron" '{print $2}') ; echo "$NID" ; journalctl -fu satori.$NID.service
}

splash
do_tail
