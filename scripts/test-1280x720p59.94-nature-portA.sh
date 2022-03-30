#!/bin/bash

. ./test-args.sh

while [ 1 ]; do
	date
	ffmpeg2 -y -i $VPBASE/streams/1920x1080p60-ProRes422-275mbit-GradientsMovementNature.mov -r 60000/1001 -s:v 1280x720 \
		$VIDEO_FILTERS \
		-ar 48000 -acodec pcm_s16le -ac 2 -vcodec v210 -f decklink "$DECKLINK_PORT"
done
