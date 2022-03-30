#!/bin/bash -x

. ./test-args.sh

export LTN_ENABLE_AUDIO_ALL=1

while [ 1 ]; do
	date
	export LD_LIBRARY_PATH=../bin
	decoder-ndi-enabled -y -i $VPBASE/streams/24hr-bars-tone-tv-burnin-1280x720p5994.ts \
		$VIDEO_FILTERS \
		-f libndi_newtek -clock_video true -clock_audio true -y -pix_fmt uyvy422 playout${OUTPUT_PORT}
	sleep 1
done
