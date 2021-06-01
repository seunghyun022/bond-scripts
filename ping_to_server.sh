#!/bin/sh

iplist=`cat ./serverlist`

for i in $iplist
do
	echo "------------------------------------"
    echo "HostName : ${i}"
	available=`ping -c 1 $i | grep packets | awk -F\  '{print $4}'`
	if [ "${available}" == "1" ];then
        echo "${i} is Available"
    else
        echo "${i} is Unavailabe"
    fi
done
