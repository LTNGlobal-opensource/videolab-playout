#!/bin/bash

for port in {08..15}
do
	URL="udp://227.1.2.90:40${port}"
	./deploy.sh --port $port --cfg-file testcase-057.cfg --url-output $URL
	sleep 0.25
done
