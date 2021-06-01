#! /bin/bash


serverlist=`cat ./serverlist`
read -p    "                Put UserName for remote Server : " user
read -s -p "                Put Password for UserName : " paswd
echo "\n"
for i in $serverlist
do
    echo "----------------------------------------------------------------------------------------------------------------"
    echo "Host Name : ${i}"
    hello=`sshpass -p ${paswd} ssh ${user}@$i -o LogLevel=error -o StrictHostKeyChecking=no 'echo "/sbin/ifconfig" | sudo /bin/bash'`
    echo "${hello}"
done
