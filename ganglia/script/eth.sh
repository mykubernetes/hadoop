#!/bin/sh
HOST_NAME=`hostname`
for NET in `grep "ONBOOT=yes" /etc/sysconfig/network-scripts/ifcfg-* | grep -v -E 'lo|bond|.tar' | awk -F":" '{print $1}' | cut -d"-" -f 3`
do
HOST_IP=`ip addr show $NET | grep -v inet6 |awk '/inet/{gsub(/addr:/,"");print $2}'|awk -F/ '{print $1}'`
ROUTE=`route -n |grep ^0.0.0.0 |awk '{print $2}'`

ping $ROUTE -c 10 -i 0.5 > /tmp/ping_route.txt
PACKET_LOSS=`cat /tmp/ping_route.txt |grep -A3 ping |awk -F'[ %]' '/packet/{print $6}'`
PACKET_LOSS_MAX=`cat /tmp/ping_route.txt |grep -A3 ping |grep rtt |awk -F'[ /]' '{print $9}'`
PACKET_LOSS_AVG=`cat /tmp/ping_route.txt |grep -A3 ping |grep rtt |awk -F'[ /]' '{print $8}'`
PACKET_LOSS_MIN=`cat /tmp/ping_route.txt |grep -A3 ping |grep rtt |awk -F'[ /]' '{print $7}'`

if [ $PACKET_LOSS -eq 0 ];then
printf  "\e[32mHOST_NAME：\e[0m\e[31m%7s\e[0m\n\e[32mHOST_IPADDR：\e[0m\e[31m%5s\e[0m\n\e[32mPACKET_LOSS：\e[0m\e[31m%s\e[0m\n" $HOST_NAME $HOST_IP $PACKET_LOSS%
#  echo  network packet loss is  $PACKET_LOSS%
    else
      echo -------$HOST_NAME $HOST_IP ----------
#     grep -A3 ping /tmp/ping_route.txt
#      echo network packet loss is $PACKET_LOSS%
#      echo network max is $PACKET_LOSS_MAX
#      echo network avg is $PACKET_LOSS_AVG
#      echo network min is $PACKET_LOSS_MIN
printf "\e[32mHOST_NAME：\e[0m\e[31m%7s\e[0m\n\e[32mHOST_IPADDR：\e[0m\e[31m%5s\e[0m\n\e[32mPACKET_LOSS：\e[0m\e[31m%s\e[0m\n\e[32mnetwork_max：\e[0m\e[31m%5s\e[0m\n\e[32mnetwork_avg：\e[0m\e[31m%5s\e[0m\n\e[32mnetwork_min：\e[0m\e[31m%5s\e[0m\n" $HOST_NAME $HOST_IP $PACKET_LOSS% $PACKET_LOSS_MAX $PACKET_LOSS_AVG $PACKET_LOSS_MIN
fi
done

