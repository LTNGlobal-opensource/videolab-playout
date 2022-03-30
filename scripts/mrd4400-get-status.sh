#!/bin/bash

# A quick script to set the MRD4400 Select Service Lock Mode and set the Service number
# to a user selected PAT program.
# Lots of hardcoded junk, including usernames, passwords, ip addresses.

USAGETXT="$0 <--get-service-number N> <--set-service-number N>"
IPADDRESS=192.168.2.111

function mrd_get_service_number()
{
	# Query what service has been selected dor decoding (PAT Program Number)
	wget -O reply --save-cookies cookies.txt --keep-session-cookies --post-data 'user=admin&password=' \
		'http://'${IPADDRESS}'/webservice.fcgi?action=csf.stores&_dc=1543944135326&params={"filter":["SelectedService"],"revision":21462,"firstInst":"0","maxRows":0}'
	cat reply
}

function mrd_set_service_number()
{
	wget -O reply --save-cookies cookies.txt --keep-session-cookies --post-data \
		'user=admin&password=&action=csf.txn&params={"ops":[{"label":"serviceselectionMode","inst":".1.1","val":"1"},{"label":"serviceselectionBackupState","inst":".1.1","val":"2"},{"label":"servicelockLockMode","inst":".1.1","val":"2"},{"label":"servicelockServiceName","inst":".1.1","val":"Service '${1}'"},{"label":"servicelockServiceNum","inst":".1.1","val":'${1}'},{"label":"servicelockBackupLockMode","inst":".1.1","val":"1"},{"label":"servicelockBackupServiceName","inst":".1.1","val":""},{"label":"servicelockBackupServiceNum","inst":".1.1","val":1}]}' \
		'http://'${IPADDRESS}'/webservice.fcgi'
}

if [ $# -eq 0 ]; then
	echo $USAGETXT
	exit 1
fi

while (($#)); do
	case $1 in
	--get-service-number)
		mrd_get_service_number
		;;
	--set-service-number)
		mrd_set_service_number $2
		shift
		;;
	*)
		echo $USAGETXT
		exit 1
	esac
	shift
done
