#!/bin/bash
#Ian and Daniel

#Cleanup

rm /var/log/anomalies.noot 2>/dev/null

function noot_ify_bash() {
    rm /var/log/bkbin.log 2>/dev/null
    rm /var/log/bksbin.log 2>/dev/null
    #intial file creation
    for fname in `ls -F /usr/bin | grep '*'`
    do
	md5sum -b /usr/bin/$fname >> /var/log/bkbin.log 2>/dev/null
    done
    for fname in `ls -F /usr/sbin | grep '*'`
    do	
	md5sum -b /usr/sbin/$fname >> /var/log/bksbin.log 2>/dev/null
    done
}

noot_ify_bash

#next thing
while true
do
    rm /var/tmp/curbin.txt 2>/dev/null
    rm /var/tmp/cursbin.txt 2>/dev/null
    for fname in `ls -F /usr/bin | grep '*'`
    do
	md5sum -b /usr/bin/$fname >> /var/tmp/curbin.txt 2>/dev/null
    done
    for fname in `ls -F /usr/sbin | grep '*'`
    do
	md5sum -b /usr/sbin/$fname >> /var/tmp/cursbin.txt 2>/dev/null
    done
    check1="$(diff /var/log/bkbin.log /var/tmp/curbin.txt)"
    check2="$(diff /var/log/bksbin.log /var/tmp/cursbin.txt)"
    if [[ ! -z $check1 ]] || [[ ! -z $check2 ]]; then
	printf "\x1B[31m$check1$check2\x1B[0m\n"
	echo $check1 >> /var/log/anomalies.noot
	echo $check2 >> /var/log/anomalies.noot
	noot_ify_bash
    fi
    sleep 10
done
