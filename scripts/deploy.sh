#!/bin/bash

# Ports 1-4  are reserved for SDI outputs
# Ports 5-32 used for non-SDI outputs

ENABLE_BURNWRITER=""
OUTPUT_PORT="1"
DEF_OUTPUT_PORT=$OUTPUT_PORT
DECKLINK_OUTPUT="DeckLink Duo (4)"
URL_DST=""
NIC_DST=""

usage()
{
  echo
  echo "Usage: $0"
  echo "   --port <1..32>                 [def: $DEF_OUTPUT_PORT]"
  echo "                                  1..4 Reserved for SDI"
  echo "   --cfg-file <filename.cfg>      [def: none]"
  echo "   --burnwriter                   Enable burnwriter [def: disabled] (SDI Modes only)"
  echo "   --time                         Enable seconds.ms video timestamp [def: disabled] (SDI Modes only)"
  echo "   --stop-all                     Stop all playout streams"
  echo "   --stop                         Stop a specific port"
  echo "   --status                       Show all playout streams"
  echo "   --stream-usage                 Check which streams are used (or not)"
  echo "   --url-output udp://ip:port?ifname=<nic>"
  echo "                                  For a MPEG-TS playout stream, send UDP output to this address."
  echo "   --nic-output net1              PCAP playout, modify the pcap to match this NICs src ip and playout."
  echo ""
  echo "Eg: ./deploy.sh --port 1 --cfg-file testcase-011.cfg --url-output udp://227.1.1.2:5001"
  echo "    ./deploy.sh --port 1 --cfg-file testcase-320.cfg"
  echo "    ./deploy.sh --port 1 --cfg-file testcase-034.cfg"
  echo "    ./deploy.sh --port 1 --cfg-file testcase-900.cfg --nic-output eno2"
  echo "    ./deploy.sh --port 9 --cfg-file testcase-601.cfg --url-output srt://vtflex.duckdns.org:9650"
  echo "    ./deploy.sh --port 9 --cfg-file testcase-650.cfg --url-output rtmp://myserver.com:1935/url/streamid"
  echo "    ./deploy.sh --port 1 --stop"
  echo
}

if [ "$VPBASE" == "" ]; then
	. ../env.sh
fi

if [ $# -eq 0 ]; then
  for FILE in `ls testcase-[0123456789]*.cfg`
  do
    #echo "`basename $FILE` -- `grep CASENAME $FILE`"
    grep CASENAME $FILE | sed s'!CASENAME="!!g' | sed 's!"$!!g'
  done
  usage
  exit 1
fi

list_stream_usage()
{
	unused=0
	total=0
	echo "Count Filename"
	echo "---------------------------------------------------------------------"

	for FILE in `ls $VPBASE/streams | grep -v readme.txt | grep -v .gitignore | grep -v aux$`
	do
		REFS=`grep $FILE $VPBASE/scripts/*.cfg $VPBASE/scripts/*.sh | wc -l`
		if [ $REFS -eq 0 ]; then
			unused=`expr $unused + 1`
		fi
		printf "%5d $FILE\n" $REFS
		total=`expr $total + 1`
	done

	echo "Streams: $total"
	echo " Unused: $unused"
	echo "Stream Library: `du -B1000000000 $VPBASE/../streams | cut -f1` GB"
}

playout_start()
{
	# This was folded into decklink-generic.... it can eventually go away
	lspci | grep "DeckLink 8K Pro" >/dev/null
	if [ $? -eq 0 ]; then
		if [ "$OUTPUT_PORT" -eq 1 ]; then DECKLINK_OUTPUT="DeckLink 8K Pro (1)"; fi
		if [ "$OUTPUT_PORT" -eq 2 ]; then DECKLINK_OUTPUT="DeckLink 8K Pro (3)"; fi
		if [ "$OUTPUT_PORT" -eq 3 ]; then DECKLINK_OUTPUT="DeckLink 8K Pro (2)"; fi
		if [ "$OUTPUT_PORT" -eq 4 ]; then DECKLINK_OUTPUT="DeckLink 8K Pro (4)"; fi
	else
		if [ "$OUTPUT_PORT" -eq 1 ]; then DECKLINK_OUTPUT="DeckLink Duo (1)"; fi
		if [ "$OUTPUT_PORT" -eq 2 ]; then DECKLINK_OUTPUT="DeckLink Duo (3)"; fi
		if [ "$OUTPUT_PORT" -eq 3 ]; then DECKLINK_OUTPUT="DeckLink Duo (2)"; fi
		if [ "$OUTPUT_PORT" -eq 4 ]; then DECKLINK_OUTPUT="DeckLink Duo (4)"; fi
	fi

	URL_OUTPUT=""
	if [ "$URL_DST" != "" ]; then
		URL_OUTPUT="--url-output $URL_DST"
	fi

	NIC_OUTPUT=""
	if [ "$NIC_DST" != "" ]; then
		NIC_OUTPUT="--nic-output $NIC_DST"
	fi

	echo "Starting playout of test video on port $OUTPUT_PORT"
	echo screen -S playport${OUTPUT_PORT} -d -m ./$PLAYOUTAPP --decklinkoutput "$DECKLINK_OUTPUT" $ENABLE_BURNWRITER $URL_OUTPUT $NIC_OUTPUT --output-port $OUTPUT_PORT
	screen -S playport${OUTPUT_PORT} -d -m ./$PLAYOUTAPP --decklinkoutput "$DECKLINK_OUTPUT" $ENABLE_BURNWRITER $URL_OUTPUT $NIC_OUTPUT --output-port $OUTPUT_PORT
}

playout_stop()
{
	echo "Stopping playout of test video on port $OUTPUT_PORT"
#	ps -elf playout${OUTPUT_PORT} | grep testpattern
#	if [ $? -eq 0 ]; then
#	fi
	if screen -S playport${OUTPUT_PORT} -X quit >/dev/null; then
		:
		echo "Stopped playout on port $OUTPUT_PORT"
	else
		:
		echo "No existing playout to stop"
	fi
}

echo "`date`: $USER : $0 $@" >>$VPBASE/scripts/history.log

while (($#)); do
        case $1 in
	--status)
		PLAYOUTS=`ps -ef | grep -i screen | grep -i playport[0-9] | sed 's!^.*playport!   -> playport!' | wc -l`
		echo Current running playouts: $PLAYOUTS
		ps -ef | grep -i screen | grep -i playport[0-9] | sed 's!^.*playport!   -> playport!'
		exit 1
		;;
        --burnwriter)
                ENABLE_BURNWRITER="--burnwriter"
                ;;
        --time)
                ENABLE_TIME="--time"
                ;;
        --port)
                shift
                OUTPUT_PORT=$(printf "%02d" $(( 10#$1 )))
		if [ $OUTPUT_PORT -lt 1 ] || [ $OUTPUT_PORT -gt 32 ]; then
			usage
			echo "Illegal port number, should be 1..32"
			exit 1
		fi
                ;;
        --stop)
		if [ $OUTPUT_PORT -lt 1 ] || [ $OUTPUT_PORT -gt 32 ]; then
			usage
			echo "Illegal port number, should be 1..32"
			exit 1
		fi
		playout_stop
		exit 0
		;;
        --stop-all)
		for port in {01..32}
		do
			OUTPUT_PORT=$port
			playout_stop
		done
		kill `pidof TestPattern.solid` 2>/dev/null
		exit 0
		;;
        --cfg-file)
                shift
                CFG_FILE=$1
                if [ ! -f $CFG_FILE ]; then
                  echo "$CFG_FILE is invalid or doesn't exist."
                  exit 1
                fi
                ;;
        --url-output)
                shift
                URL_DST=$1
                ;;
        --nic-output)
                shift
                NIC_DST=$1
                ;;
        --stream-usage)
		list_stream_usage
                shift
		exit 0
                ;;
        *)
		usage
		echo "$1 is illegal"
                exit 1
        esac
        shift
done

if [ ! -f $CFG_FILE ]; then
	echo "$1 test case not found."
	exit 1
fi

# Import any application defaults
if [ ! -f $CFG_FILE ]; then
	echo "'defaults.cfg' file is missing."
	exit 1
else
	. ./defaults.cfg
fi

HOSTDEFAULTS="defaults-`hostname`.cfg"
if [ -f $HOSTDEFAULTS ]; then
	#echo "Importing additional defaults from file $HOSTDEFAULTS"
	. ./$HOSTDEFAULTS
fi

. ./$CFG_FILE

if [ "$ENCODER" == "" ]; then
	:
	#echo "Test case is missing an ENCODER definition, will not attempt to configure or control an encoder"
fi

if [ "$CASENAME" == "" ]; then
	echo "test case missing CASENAME definition"
	exit 1
fi

if [ "$PLAYOUTAPP" == "" ]; then
	if [ "$GENERIC_PLAYOUT_TYPE" == "" ]; then
		echo "test case missing PLAYOUTAPP definition, or GENERIC_PLAYOUT_TYPE definition"
		exit 1
	fi
fi

if [ "$GENERIC_PLAYOUT_TYPE" != "" ]; then
	if [ "$GENERIC_PLAYOUT_TYPE" != "NONE" ]; then
		if [ "$GENERIC_PLAYOUT_TYPE" != "IP_TS" ]; then
			if [ "$GENERIC_PLAYOUT_TYPE" != "SDI" ]; then
				if [ "$GENERIC_PLAYOUT_TYPE" != "SRT_TS" ]; then
					if [ "$GENERIC_PLAYOUT_TYPE" != "RTMP_TS" ]; then
						echo "test case invalid GENERIC_PLAYOUT_TYPE definition"
						exit 1
					fi
				fi
			fi
		fi
	fi
fi
#echo "Preparing for $CASENAME"
#echo "Using playout via $PLAYOUTAPP"

playout_stop

if [ "$GENERIC_PLAYOUT_TYPE" == "" ]; then
	playout_start
else
	if [ "$GENERIC_PLAYOUT_TYPE" == "IP_TS" ]; then
		echo "Starting playout of IP_TS on port $OUTPUT_PORT"
		CMD="screen -S playport${OUTPUT_PORT} -d -m ./$GENERIC_PLAYOUT_APP $URL_OUTPUT \
			--screen-port $OUTPUT_PORT \
			--output-url $URL_DST \
			$GENERIC_ARGS --cfg-file $CFG_FILE"
		echo $CMD
		$CMD
	fi
	if [ "$GENERIC_PLAYOUT_TYPE" == "SRT_TS" ]; then
		echo "Starting playout of SRT_TS on port $OUTPUT_PORT"
		CMD="screen -S playport${OUTPUT_PORT} -d -m ./$GENERIC_PLAYOUT_APP $URL_OUTPUT \
			--screen-port $OUTPUT_PORT \
			--output-url $URL_DST \
			$GENERIC_ARGS --cfg-file $CFG_FILE"
		echo $CMD
		$CMD
	fi
	if [ "$GENERIC_PLAYOUT_TYPE" == "RTMP_TS" ]; then
		echo "Starting playout of RTMP_TS on port $OUTPUT_PORT"
		CMD="screen -S playport${OUTPUT_PORT} -d -m ./$GENERIC_PLAYOUT_APP $URL_OUTPUT \
			--screen-port $OUTPUT_PORT \
			--output-url $URL_DST \
			$GENERIC_ARGS --cfg-file $CFG_FILE"
		echo $CMD
		$CMD
	fi
	if [ "$GENERIC_PLAYOUT_TYPE" == "SDI" ]; then
		if [ "$OUTPUT_PORT" -gt 4 ]; then
			echo "SDI Output port must be 1..4, aborting"
			exit 1
		fi
		echo "Starting playout of decompressed video on port $OUTPUT_PORT"
		CMD="screen -S playport${OUTPUT_PORT} -d -m ./$GENERIC_PLAYOUT_APP \
			--output-port $OUTPUT_PORT \
			$ENABLE_TIME \
			$ENABLE_BURNWRITER \
			$GENERIC_ARGS --cfg-file $CFG_FILE"
		echo $CMD
		eval $CMD
	fi
fi

