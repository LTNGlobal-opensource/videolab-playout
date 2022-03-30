#!/bin/bash

./deploy.sh --port 1 --cfg-file testcase-317.cfg
./deploy.sh --port 2 --cfg-file testcase-315.cfg
./deploy.sh --port 3 --cfg-file testcase-314.cfg
./deploy.sh --port 4 --cfg-file testcase-313.cfg

./deploy.sh --port 1 --cfg-file testcase-591.cfg --url-output udp://227.1.2.90:4001

