
```
#/bin/bash
#filename:sys&&date disk_util.sh
#authors huangruichong 2017-3-28
GMETRIC="/opt/ganglia/ganglia-3.6.0/bin/gmetric"
HOST_NAME=`hostname`
File=`iostat -x 1 2 > /tmp/bq-bj.txt`
First=`grep -n Device /tmp/bq-bj.txt | awk -F':' '{print $1 }' |sed -n '2p'`
M=$(expr $First - 2)
EndLine=`cat /tmp/bq-bj.txt |wc -l`
N=$(expr $EndLine - 1)
DISK=`df -h |grep -w "/boot" |awk '{print $1}'|cut -d/ -f3|awk -F"[0-9]*" '{print $1}'| uniq`
UTIL=`iostat -d -x 1 10| grep "$DISK" |awk  '{print $NF}'|awk 'BEGIN{sum=0;num=0}{sum+=$1;num+=1}END{printf "%.2f\n",sum/num}'`
AVG=`sed -n -e "${M},${N}p" /tmp/bq-bj.txt|sed  '/Device/d' | grep -v "$DISK" |awk  '{print $NF}'|grep -v '^$' |awk 'BEGIN{sum=0;num=0}{sum+=$1;num+=1
}END{printf "%.2f\n",sum/(num-1)}'`
$GMETRIC -n sys_disk_util -v $UTIL -t uint32 -d 360  -g "disk"
$GMETRIC -n data_disk_util -v $AVG -t uint32 -d 360 -g "disk"
#echo $AVG
#echo $UTIL
```  

```
#!/bin/bash
GMETRIC="/opt/ganglia/ganglia-3.6.0/bin/gmetric"
HOST_NAME=`hostname`
DISK=$[100-`df -h|grep -v "mnt" |awk '{print$5}'|grep -v "Use%" |awk -F'%' '{print $1}' |sort -rn|head -1`]
#UTIL=`iostat -x 60 1 | sed  '1,/Device/d' | awk  '{print $NF}' | sort -n | tail -1`
$GMETRIC -n sys_disk_free  -v $DISK -t uint32   -g "disk"
DISK=$[100-`df -h|grep  "mnt" |awk '{print$5}'|grep -v "Use%" |awk -F'%' '{print $1}' |sort -rn|head -1`]
$GMETRIC -n data_disk_free  -v $DISK -t uint32   -g "disk"
```  

```
#!/bin/sh
HOST_NAME=`hostname`
GMETRIC="/opt/ganglia/ganglia-3.6.0/bin/gmetric"
for BOND in `/usr/sbin/ifconfig |awk -F ':' '/bond/ {print$1}'`
do
 for NET in `cat /proc/net/bonding/$BOND |  awk '/Interface/ {print $3}'`
   do
   I=`/usr/sbin/ethtool $NET |awk '/detected/{print $3}'`
   if [ "$I"x = "no"x ];then
      status=0;
   else
      WC=`/usr/sbin/ethtool $NET |head -n6 |awk -F"base" '{print$1}' |grep -v "S"|wc -l`
      if  [ $WC -eq 2 ];then
         NET1=1000
      else
         NET1=10000
      fi
      NET2=`/usr/sbin/ethtool $NET |grep Speed|awk '{print$2}' |awk -F "M" '{print$1}'`
      if [ $NET2  -eq  $NET1 ];then
         status=$NET1
      else
        /usr/sbin/ifconfig $NET down
        status=0;
      fi
   fi
   $GMETRIC -n $NET  -v $status -t uint32   -g "${HOST_NAME}-mgmt_network"
  done
done
```  

```

#!/bin/sh

SERVICE=crond
HOST_NAME=`hostname`
GMETRIC="/opt/ganglia/ganglia-3.6.0/bin/gmetric"
while true
do
  echo "checking service $SERVICE..."
  running=`/usr/sbin/service $SERVICE status 2>/dev/null | grep "running" | wc -l`
  if [ ! -x $GMETRIC ]; then
      echo "error: gmetric is not found"
      exit 1
  fi
  $GMETRIC -n crond  -v $running -t uint32 -u "status" -g "${HOST_NAME}_service"
  if [ $running -eq "0" ]; then
      echo "$SERVICE is configured on this host(${HOST_NAME}) but down"
  else
      echo "$SERVICE is running nomally on this host(${HOST_NAME})"
  fi
  sleep 120
done
```  
