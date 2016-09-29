#!/usr/bin/env bash

while 1
do
	default_count=90
	sess_count=`netstat -anpt | grep python | grep 16509`

	if [ $sess_count < $default_count ]
	then
		netstat -anpt | grep python | grep ESTABLISHED | awk '{print $7}' | cut -d \/ -f1 | grep -oE "[[:digit:]]{1,}" | xargs kill
	else
		exit 1
	fi
done
