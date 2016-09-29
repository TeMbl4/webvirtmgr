#!/usr/bin/env bash

default_count=80
sess_count=`netstat -anpt | grep python | grep 16509 | wc -l`

if [ $sess_count -eq 0 ]
then
	exit 1
else
    if [ $sess_count -le $default_count ];
    then
        netstat -anpt | grep python | grep ESTABLISHED | awk '{print $7}' | cut -d \/ -f1 | grep -oE "[[:digit:]]{1,}" | xargs kill
    else
        exit 1
    fi
fi

