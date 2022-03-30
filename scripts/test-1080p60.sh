#!/bin/bash

. ./test-args.sh

while [ 1 ]; do
	date
	decoder-0.26 \
		-y -i $VPBASE/streams/20180713_122109-clip-highmotion.ts \
-vf drawtext="fontsize=15:fontfile=MONACO.TTF:\
timecode='00\:00\:00\:00':rate=60:text='TCR\:':fontsize=72:fontcolor='white':\
boxcolor=0x000000AA:box=1:x=860-text_w/2:y=960" \
		-ar 48000 -acodec pcm_s16le -ac 2 -vcodec v210 -use_3glevel_a off -f decklink "$DECKLINK_PORT"
done

