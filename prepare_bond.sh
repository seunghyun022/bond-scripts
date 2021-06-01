#! /bin/bash


serverlist=`cat ./serverlist`
read -p    "                Put UserName for remote Server : " user
read -s -p "                Put Password for UserName : " paswd
echo "\n"
for i in $serverlist
do
    echo "----------------------------------------------------------------------------------------------------------------"
    echo "Host Name  : ${i}"
    output=`sshpass -p ${paswd} ssh ${user}@$i -o LogLevel=error -o StrictHostKeyChecking=no   "echo \"cat /etc/redhat-release\" | sudo /bin/bash;
                                                                                    /sbin/ifconfig;
                                                                                    echo \"route -n\" | sudo /bin/bash;
                                                                                    echo \"cat /etc/resolv.conf\" | sudo /bin/bash;
                                                                                    echo \"rm -rf /home/TMON/${user}/bonding\" | sudo /bin/bash;
                                                                                    echo \"rm -rf /root/bonding\" | sudo /bin/bash;"`
    os=`echo "${output}" | grep CentOS | awk '{print$3}' | awk -F. '{print$1}'`
    if [ "${os}" == "release" ];
    then
        os=`echo "${output}" | grep CentOS | awk '{print$4}' | awk -F. '{print$1}'`
    fi

    
    if [ "${os}" == "7" ]; then
        ipaddr=`echo "${output}" | grep inet | head -1 | awk -F\  '{print$2}'`
    elif [ "${os}" == "6" ]; then
        ipaddr=`echo "${output}" | grep Bcast | awk -F\: '{print$2}' | awk -F\  '{print$1}'`
    else
        exit
    fi
    
    gw=`echo "${output}"| grep UG | awk '{print$2}'`
    dns=`echo "${output}" | grep nameserver | head -1 | awk '{print$2}'`
    echo "OS Version : ${os}"
    echo "IP Address : ${ipaddr}"
    echo "GW Address : ${gw}"
    echo "DNS Server : ${dns}"
    `rm -rf ./bonding`
    `cp -r ./bonding_skel/$os ./bonding`
    sed -i "s/%IP/${ipaddr}/g" ./bonding/ifcfg-bond0
    sed -i "s/%GW/${gw}/g" ./bonding/ifcfg-bond0
    
    if [ "${os}" == "7" ]; then
        sed -i "s/%DNS/${dns}/g" ./bonding/ifcfg-bond0
    fi

    `sshpass -p ${paswd} scp -r ./bonding ${user}@$i:/home/TMON/${user}/bonding`
    echo "Network Configuration Files Successfully moved to Remote ${i}"
    `sshpass -p ${paswd} ssh ${user}@$i -o LogLevel=error -o StrictHostKeyChecking=no "echo \"chown -R root:root /home/TMON/${user}/bonding\" | sudo /bin/bash;
                                                                                       echo \"cp -r /home/TMON/${user}/bonding /root/bonding\" | sudo /bin/bash"`
    echo "Network Configuration Files ready at /root/bonding/"
    echo "Done"
done
echo "To Apply Network Configuration\nPlease ENTER ./apply_bond.sh"
