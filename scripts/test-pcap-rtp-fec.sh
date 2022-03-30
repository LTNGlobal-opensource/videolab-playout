#!/bin/bash -x

# This was output from a CM5000, ultra low latency 9mbps, 1920x1080i29.97, configured as:
#   RTP-FEC D1 columns 4 rows 5 steps 1

. ./test-args.sh

NIC_PCAP_FILE=$VPBASE/streams/rtp-fec-d1.pcap.$NIC_OUTPUT.$NIC_ADDRESS

if [ ! -f $NIC_PCAP_FILE ]; then
	CMD="$VPBASE/bin/tcprewrite --srcipmap=10.90.131.55/32:$NIC_ADDRESS/32 --infile=$VPBASE/streams/rtp-fec-d1.pcap --outfile=$NIC_PCAP_FILE"
	$CMD
fi

while [ 1 ]; do
	$VPBASE/bin/tcpreplay -i $NIC_OUTPUT $NIC_PCAP_FILE
	sleep 0.1
done
