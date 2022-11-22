```
#!/bin/bash
timestamp=$(date "+%Y%m%d%H%M%S")
ip=192.168.101.27
txt=./a.txt
cpu=$(curl http://$ip:8088/cluster/cluster | awk "NR==196" | awk '{print $1}')
allcpu=$(curl http://$ip:8088/cluster/cluster | awk "NR==199" | awk '{print $1}')
mem=$(curl http://$ip:8088/cluster/cluster | awk "NR==187" | awk '{print $1}')
allmem=$(curl http://$ip:8088/cluster/cluster | awk "NR==190" | awk '{print $1}')
echo $timestamp $cpu $allcpu $mem $allmem >> $txt
```
