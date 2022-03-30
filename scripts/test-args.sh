#!/bin/bash

DECKLINK_PORT='DeckLink Duo (4)'
TP_PORT='3'
NETWORK_ADDR=""
URL_OUTPUT=""
NIC_OUTPUT="net1"
OUTPUT_PORT=""

USAGETXT=$(cat <<-END
  Usage: $0\n
     --decklinkoutput 'DeckLink Duo (1..4) | DeckLink 8K Pro (1..4)' [def: $DECKLINK_PORT]\n
     --burnwriter     -- enable burnwriter in video output [def: disabled]
     --url-output url -- Eg udp://127.1.1.1:4001?ifname=en4 [def: disabled]
     --nic-output iface -- Eg net0 [def: net1]
     --output-port # -- Eg 0..32
END
)

if [ $# -eq 0 ]; then
  echo -e $USAGETXT
  exit 1
fi

while (($#))
do
        case $1 in
        --burnwriter)
                if [ "$VIDEO_FILTERS" == "" ]; then
                        VIDEO_FILTERS="-vf"
                fi
                VIDEO_FILTERS="$VIDEO_FILTERS burnwriter"
                ;;
        --output-port)
                shift
                OUTPUT_PORT=$1
		;;
        --decklinkoutput)
                shift
                DECKLINK_PORT=$1
		if [ "$DECKLINK_PORT" == "DeckLink Duo (4)" ]; then
			TP_PORT=3
		fi
		if [ "$DECKLINK_PORT" == "DeckLink Duo (3)" ]; then
			TP_PORT=2
		fi
		if [ "$DECKLINK_PORT" == "DeckLink Duo (2)" ]; then
			TP_PORT=1
		fi
		if [ "$DECKLINK_PORT" == 'DeckLink Duo (1)' ]; then
			TP_PORT=0
		fi
		if [ "$DECKLINK_PORT" == "DeckLink 8K Pro (4)" ]; then
			TP_PORT=3
		fi
		if [ "$DECKLINK_PORT" == "DeckLink 8K Pro (3)" ]; then
			TP_PORT=2
		fi
		if [ "$DECKLINK_PORT" == "DeckLink 8K Pro (2)" ]; then
			TP_PORT=1
		fi
		if [ "$DECKLINK_PORT" == "DeckLink 8K Pro (1)" ]; then
			TP_PORT=0
		fi
                ;;
        --url-output)
                shift
                URL_OUTPUT=$1
		;;
        --nic-output)
                shift
                NIC_OUTPUT=$1
		./network-utils.sh --nic-exists $NIC_OUTPUT
		if [ $? -eq 1 ]; then
			echo "No such NIC $NIC_OUTPUT"
			exit 1
		fi
		NIC_ADDRESS=`./network-utils.sh --show-nic-address $NIC_OUTPUT`
		if [ $? -eq 1 ]; then
			echo "No such NIC address $NIC_OUTPUT"
			exit 1
		fi
		echo "Using NIC $NIC_ADDRESS for playout"
		;;
        *)
                echo $USAGETXT
                exit 1
		;;
        esac
        shift
done

#		-ar 48000 -acodec pcm_s16le -ac 2 -vcodec v210 -f decklink "$DECKLINK_PORT"

