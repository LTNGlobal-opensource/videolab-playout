#!/bin/bash

# QA and future playout systems we'll locate
# everything under /storage. However, take care
# of existing boxes.
export VPBASE=/storage/playout/playout
if [ ! -d $VPBASE ]; then
	export VPBASE=~/playout
fi

export PATH=$PATH:$VPBASE/bin
export LD_LIBRARY_PATH=$VPBASE/bin

which screen >/dev/null
if [ $? -ne 0 ]; then
	echo "Screen not installed?"
	exit 1
fi

which lspci >/dev/null
if [ $? -ne 0 ]; then
	echo "pciutils not installed, missing lspci command"
	exit 1
fi

if [ "`ls -l $VPBASE/bin/tcpreplay | cut -c1-17`" != "-rwsr-sr-x 1 root" ]; then
	if [ "`ls -l $VPBASE/bin/tcpreplay | cut -c1-18`" != "-rwsr-sr-x. 1 root" ]; then
		echo "Error, $VPBASE/bin/tcpreplay permissions are wrong, they should be -rwsr-sr-x and the binary owned by root"
		echo "       correct this else pcap playout is considered broken."
		echo "       sudo chown root bin/tcpreplay"
		echo "       sudo chmod ug+s bin/tcpreplay"
		exit 1
	fi
fi

# Prevent accidental usage by wrong user
# Is ignored when unset/empty for backwards compatibility
export WANTED_USER=
