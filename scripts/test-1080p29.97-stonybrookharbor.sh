#!/bin/bash

. ./test-args.sh

while [ 1 ]; do
	date
	ffmpeg2 -y -i $VPBASE/streams/StonyBrookHarbor_1080p2997.mp4 \
		$VIDEO_FILTERS \
		-ar 48000 -acodec pcm_s16le -ac 2 -vcodec v210 -f decklink "$DECKLINK_PORT"
done

