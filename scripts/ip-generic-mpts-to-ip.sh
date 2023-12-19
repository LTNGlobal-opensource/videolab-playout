#!/bin/bash -x

OUTPUT_URL=""
SCREEN_PORT=""
PCR_PID=""
TS_FILENAME=""
AUX_FILENAME=""

USAGETXT=$(cat <<-END
  Usage: $0\n
     --input        file.ts -- Absolute filename\n
     --pcr-pid      0xnnnn  -- hex\n
     --output-url   url     -- Eg udp://127.1.1.1:4001?ifname=en4 [def: disabled]\n
     --screen-port  #       -- Eg 0..32\n
     --cfg-file    file.cfg -- Not use by the script, but used by the wrpaper to track what test we're running\n
END
)

if [ $# -eq 0 ]; then
  echo -e $USAGETXT
  exit 1
fi

while (($#))
do
        case $1 in
        --input)
                shift
                TS_FILENAME=$1
		;;
        --pcr-pid)
                shift
                PCR_PID=$1
		;;
        --output-url)
                shift
                OUTPUT_URL=$1
		;;
        --screen-port)
                shift
                SCREEN_PORT=$1
		;;
        --cfg-file)
                shift
		;;
        *)
                echo $USAGETXT
		echo "$1 is illegal"
                exit 1
		;;
        esac
        shift
done

if [ "$TS_FILENAME" == "" ]; then
	echo "--input is mandatory"
	exit 1
fi
if [ "$PCR_PID" == "" ]; then
	echo "--pcr-pid is mandatory"
	exit 1
fi
if [ "$OUTPUT_URL" == "" ]; then
	echo "--output-url is mandatory"
	exit 1
fi
if [ "$SCREEN_PORT" == "" ]; then
	echo "--screen-port is mandatory"
	exit 1
fi

AUX_FILENAME=`echo $TS_FILENAME | sed 's!\.ts$!.aux!gi'`

echo filename $TS_FILENAME
echo auxname $AUX_FILENAME

AUX_CREATE=0

if [ ! -f $AUX_FILENAME ]; then
	AUX_CREATE=1
fi
if [[ -f $AUX_FILENAME && ! -s $AUX_FILENAME ]]; then
	AUX_CREATE=1
fi

if [ $AUX_CREATE -eq 1 ]; then
	echo "Creating aux file"
	../bin/ingests -p $PCR_PID $TS_FILENAME
	if [ $? -ne 0 ]; then
		echo "error creating aux file, aborting."
		exit 1
	fi
fi

NET_ADDR=`echo $OUTPUT_URL | sed 's!.*//!!g'`
CMD="../bin/multicat -u -U $TS_FILENAME $NET_ADDR"

while [ 1 ]; do
	echo $CMD
	$CMD
	sleep 0.1
done
