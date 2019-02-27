#!/bin/bash
#Ian and Daniel

#Cleanup

rm /var/log/anomalies.noot 2>/dev/null
if [[ ! -d /var/tmp/tbin ]]; then mkdir /var/tmp/tbin; fi
if [[ ! -d /var/tmp/tsbin ]]; then mkdir /var/tmp/tsbin; fi

function hackup_bashes() {
    rm /var/log/bkbin.log 2>/dev/null
    rm /var/log/bksbin.log 2>/dev/null
    rm /var/tmp/tbin/* 2>/dev/null
    rm /var/tmp/tsbin/* 2>/dev/null

    for fname in $(ls -F /usr/bin | grep '*' | sed 's/.$//')
    do
	cp /usr/bin/$fname /var/tmp/tbin
	md5sum -b /usr/bin/$fname >> /var/log/bkbin.log 2>/dev/null
    done
    for fname in $(ls -F /usr/sbin | grep '*' | sed 's/.$//')
    do	
	cp /usr/sbin/$fname /var/tmp/tsbin
	md5sum -b /usr/sbin/$fname >> /var/log/bksbin.log 2>/dev/null
    done
}

hackup_bashes

while true
do
    rm /var/tmp/curbin.txt 2>/dev/null
    rm /var/tmp/cursbin.txt 2>/dev/null
    for fname in $(ls -F /usr/bin | grep '*' | sed 's/.$//')
    do
	md5sum -b /usr/bin/$fname >> /var/tmp/curbin.txt 2>/dev/null
    done
    for fname in $(ls -F /usr/sbin | grep '*' | sed 's/.$//')
    do
	md5sum -b /usr/sbin/$fname >> /var/tmp/cursbin.txt 2>/dev/null
    done
    check1="$(diff /var/log/bkbin.log /var/tmp/curbin.txt)"
    check2="$(diff /var/log/bksbin.log /var/tmp/cursbin.txt)"
    anoms=0
    if [[ -n $check1 ]]; then
	anomaly="$(echo $check1 | grep -Eo '(\/usr[^ ]*) ')"
	printf "\x1B[31mAnomaly Found in %s\n" $anomaly
	anofname="$(echo $anomaly | rev | grep -Eo '(^[^/]*)/'| rev)"
	anofname=${anofname:1:$((${#anofname}-1))}
	printf "Reverting $anomaly from /var/tmp/tbin/$anofname\x1B[0m\n"
	cp /var/tmp/tbin/$anofname $anomaly
	echo $check1 >> /var/log/anomalies.noot
	((anoms++))
    fi
    if [[ -n $check2 ]]; then
	anomaly="$(echo $check2 | grep -Eo '(\/usr[^ ]*) ')"
	printf "\x1B[31mAnomaly Found in %s\n" $anomaly
	anofname="$(echo $anomaly | rev | grep -Eo '(^[^/]*)/'| rev)"
	anofname=${anofname:1:$((${#anofname}-1))}
	printf "Reverting $anomaly from /var/tmp/tsbin/$anofname\x1B[0m\n"
	cp /var/tmp/tsbin/$anofname $anomaly
	echo $check2 >> /var/log/anomalies.noot
	((anoms++))
    fi
    if [[ anoms -gt 0 ]]; then hackup_bashes; fi
done
