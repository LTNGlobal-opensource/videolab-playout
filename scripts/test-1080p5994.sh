#!/bin/bash

. ./test-args.sh

while [ 1 ]; do
	ffmpeg2 -y -i $VPBASE/streams/20180713_122109-clip-highmotion.ts -r 60000/1001 \
		$VIDEO_FILTERS \
		-ar 48000 -acodec pcm_s16le -ac 2 -vcodec v210 -f decklink "$DECKLINK_PORT"
done

