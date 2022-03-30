#!/bin/bash

. ./test-args.sh

while [ 1 ]; do
	TestPattern.solid -d$TP_PORT -p1 -m14 -s32 -c16
done

