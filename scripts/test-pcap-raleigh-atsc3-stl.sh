#!/bin/bash -x

. ./test-args.sh

NIC_PCAP_FILE=$VPBASE/streams/atsc3-stl-raleigh-no-CC.pcap.$NIC_OUTPUT.$NIC_ADDRESS

if [ ! -f $NIC_PCAP_FILE ]; then
	CMD="$VPBASE/bin/tcprewrite --srcipmap=10.110.83.51/32:$NIC_ADDRESS/32 --infile=$VPBASE/streams/atsc3-stl-raleigh-no-CC.pcap --outfile=$NIC_PCAP_FILE"
	$CMD
fi

while [ 1 ]; do
	$VPBASE/bin/tcpreplay -i $NIC_OUTPUT $NIC_PCAP_FILE
	sleep 0.1
done
