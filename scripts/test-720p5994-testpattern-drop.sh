#!/bin/bash

. ./test-args.sh

while [ 1 ]; do
	date
	CMD="TestPattern.drop -d$TP_PORT -p1 -m14 -s32 -c16"
	echo $CMD
	$CMD
	sleep 1
done

