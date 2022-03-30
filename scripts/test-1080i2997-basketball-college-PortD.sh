#!/bin/bash

. ./test-args.sh

while [ 1 ]; do
	date
	decoder-0.12 \
		-y -i $VPBASE/streams/college-basketball-1080i-timecode.mov -t 00:00:45 \
		$VIDEO_FILTERS \
		-ar 48000 -acodec pcm_s16le -ac 2 -vcodec v210 -f decklink "$DECKLINK_PORT"
done

