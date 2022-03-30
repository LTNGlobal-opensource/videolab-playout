#!/bin/bash

MAXPORT=10

usage()
{
	echo "$0 <--status | --start | --stop | --ingest | --egress>"
}

if [ $# -eq 0 ]; then
	usage
	exit 1
fi

while (($#)); do
	case $1 in
	--start)
		for port in $(seq -w 1 $MAXPORT)
		do
			# Leading 0 on 08 and 09 base hates, octal?
			portarg=`echo $port | sed s'!^0!!'`
			URL="udp://224.4.4.${portarg}:40${port}"
			./deploy.sh --port $port --cfg-file testcase-334.cfg --url-output $URL
		done
		;;
	--stop)
		for port in $(seq -w 1 $MAXPORT)
		do
			./deploy.sh --port $port --stop
		done
		;;
	--status)
		./deploy.sh --status
		;;
	--ingest)
		../bin/tstools_nic_monitor -i net2.3 -M -F 'udp dst portrange 4000-4999'
		;;
	--egress)
		../bin/tstools_nic_monitor -i net2.3 -M -F 'udp dst portrange 6000-6999'
		;;
	*)
		usage
		echo "$1 is illegal"
		exit 1
	esac
	shift
done

