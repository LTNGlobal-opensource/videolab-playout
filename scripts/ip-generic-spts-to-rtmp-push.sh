#!/bin/bash -x

# As a general principle, we push transport into RTMP with the following adjustments:
# 1. We transcode any audio to stereo AAC 44.1KHz 128Kbps
# 2. We copy video as is, regardless of whether the downstream system can support it.
#    We do this because we want to push content from different H.264 encoders to the destination
#    and we don't want to make the mistake of 'cleaning' or standardizing the video
#    indirectly through ffmpeg.

OUTPUT_URL=""
SCREEN_PORT=""
TS_FILENAME=""

USAGETXT=$(cat <<-END
  Usage: $0\n
     --input        file.ts -- Absolute filename\n
     --output-url   url     -- Eg rtmp://mydomain.somewhere.com:4001/url/key\n
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

#CMD="../bin/decoder-0.36-dev -re -i $TS_FILENAME -c:a aac -b:v 128k -ar 44100 -ac 2 -c:v libx264 -g 30 -preset veryfast -tune zerolatency -b:v 3000k -f flv $OUTPUT_URL"

CMD="../bin/decoder-0.36-dev -re -i $TS_FILENAME -c:a aac -b:v 128k -ar 44100 -ac 2 -vcodec copy -f flv $OUTPUT_URL"

while [ 1 ]; do
	echo $CMD
	$CMD
	sleep 0.1
done
