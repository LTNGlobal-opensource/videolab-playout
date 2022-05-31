#!/bin/bash -x

OUTPUT_URL=""
SCREEN_PORT=""
TS_FILENAME=""
STREAM_ID=""

USAGETXT=$(cat <<-END
  Usage: $0\n
     --input        file.ts -- Absolute filename\n
     --output-url   url     -- Eg srt://mydomain.somewhere.com:4001\n
     --stream-id    name    -- Eg video.tx/dev/demo2\n
     --screen-port  #       -- Eg 0..32\n
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
        --output-url)
                shift
                OUTPUT_URL=$1
		;;
        --screen-port)
                shift
                SCREEN_PORT=$1
		;;
        --stream-id)
                shift
                STREAM_ID="-s $1"
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
if [ "$OUTPUT_URL" == "" ]; then
	echo "--output-url is mandatory"
	exit 1
fi
if [ "$SCREEN_PORT" == "" ]; then
	echo "--screen-port is mandatory"
	exit 1
fi

echo filename $TS_FILENAME

CMD="../bin/tstools_srt_transmit -i $TS_FILENAME -o $OUTPUT_URL $STREAM_ID"

while [ 1 ]; do
	echo $CMD
	$CMD
	sleep 0.1
done
