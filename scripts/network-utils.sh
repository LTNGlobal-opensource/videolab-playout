#!/bin/bash

function show_nic_address
{
	ip -4 addr show dev $1 | grep inet | sed 's!^ *!!g' | cut -d' ' -f2 | sed s'!/.*!!g'
}

function nic_exists
{
#	echo "Checking for presence of NIC $1"
	ip address show dev $1 >/dev/null 2>&1
	if [ $? -eq 1 ]; then
		echo "NIC $1 does not exist"
		return 1
	fi
	return 0
}

while (($#))
do
        case $1 in
        --nic-exists)
		shift
		nic_exists $1
		if [ $? -eq 1 ]; then
			exit 1
		fi
		;;
        --show-nic-address)
		shift
		nic_exists $1
		if [ $? -eq 1 ]; then
			exit 1
		fi
		show_nic_address $1
		;;
	*)
		echo "Unsupported test"
		exit 1
		;;
	esac
	shift
done
