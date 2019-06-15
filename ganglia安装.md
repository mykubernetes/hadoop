官网  
http://ganglia.info/

1、CentOS7 YUM源自带epel网络源，直接安装  
```
# yum install epel-release
# yum update glib2
# yum install ganglia-web ganglia-gmetad ganglia-gmond 
```  

2.  配置监控端  
```
# vim /etc/ganglia/gmetad.conf   #修改以下两项
 data_source "Hadoop01" 192.168.101.66                  #拉取gmond数据地址，Hadoop01为集群名称
 case_sensitive_hostnames 1                             #分主机名大小写
 xml_port 8651                                          #数据汇总交换端口
 interactive_port 8652                                  #web端获取数据端口
 rrd_rootdir "/var/lib/ganglia/rrds"                    #rrd数据库存放路径，可以不用配置
```  
 
 3、关联Apache，因为Ganglia自创建的配置ganglia.conf有问题，所以先删除，再创建个软连接到Apache根目录下。  
 ```
 # rm /etc/httpd/conf.d/ganglia.conf  
 # ln -s /usr/share/ganglia /var/www/html/ganglia
 ```  
 
 4、启动Apache和Ganglia，并设置开机启动
 ```
 # systemctl start httpd
 # systemctl start gmetad
 # systemctl enable httpd
 # systemctl enable gmetad
 ```  
 
 5、安装与配置被监控端(每台同样配置）
 ```
 # yum install ganglia-gmond
 # vi /etc/ganglia/gmond.conf
 ……
 cluster{
   name = "Hadoop01"              #集群名，和上面那个一样
   owner = "unspecified"
   latlong = "unspecified"
   url = "unspecified"
 }
  
 /* Thehost section describes attributes of the host, like the location */
 host {
   location = "unspecified"
 }
  
 /*Feel free to specify as many udp_send_channels as you like.  Gmond
    used to only support having a single channel*/
 udp_send_channel{
   #bind_hostname = yes # Highly recommended,soon to be default.
                       # This option tells gmond to use asource  address
                        # that resolves to themachine's hostname.  Without
                        # this, the metrics mayappear to come from any
                        # interface and the DNSnames associated with
                        # those IPs will be usedto create the RRDs.
   #mcast_join = 239.2.11.71   #关闭多播
   host = 192.168.18.215       #添加发送IP/主机名
   port = 8649                 #默认端口
   ttl = 1
 }
 
 /* Youcan specify as many udp_recv_channels as you like as well. */
 udp_recv_channel{
   #mcast_join = 239.2.11.71  
   port = 8649
   bind = 192.168.18.215      #接收地址
   retry_bind = true
   # Size of the UDP buffer. If you are handlinglots of metrics you really
   # should bump it up to e.g. 10MB or evenhigher.
   # buffer = 10485760
 }
 ……
 ```  
 
 6、将修改好的gmond.conf配置scp到其他节点   
 ```
 # scp /etc/ganglia/gmond.conf root@node03:/etc/ganglia/gmond.conf
 ```  
 
 7、启动代理程序，并设置开机启动  
 ```
# systemctl start gmond
# systemctl enable gmond
 ```  
 
 8、web访问  
 http://192.168.101.66/ganglia  
 
gmond调试模式，会运行到前台，输出日志，数值越高日志越详细，最大10  
``` gmond -d 10 ```


添加Hadoop被Ganglia监控，去掉文件中以***释并修改（每台同样配置）
---
```
# vi /opt/hadoop-2.6.0/etc/hadoop/hadoop-metrics2.properties
*.sink.ganglia.class=org.apache.hadoop.metrics2.sink.ganglia.GangliaSink31
*.sink.ganglia.period=10
*.sink.ganglia.supportsparse=true
*.sink.ganglia.slope=jvm.metrics.gcCount=zero,jvm.metrics.memHeapUsedM=both
*.sink.ganglia.dmax=jvm.metrics.threadsBlocked=70,jvm.metrics.memHeapUsedM=40
namenode.sink.ganglia.servers=192.168.18.215:8649    #当有多个ganglia监控系统时，以逗号分隔
datanode.sink.ganglia.servers=192.168.18.215:8649     #都指定ganglia服务器
resourcemanager.sink.ganglia.servers=192.168.18.215:8649
nodemanager.sink.ganglia.servers=192.168.18.215:8649
```  

添加HBase被Ganglia监控，添加如下（每台同样配置）
---
```
# vi /opt/hbase-1.0.1.1/conf/hadoop-metrics2-hbase.properties
*.sink.ganglia.class=org.apache.hadoop.metrics2.sink.ganglia.GangliaSink31  
*.sink.ganglia.period=10  
hbase.sink.ganglia.period=10  
hbase.sink.ganglia.servers=192.168.18.215:8649
```  

重启Hadoop和HBase
---
```
# stop-dfs.sh
# stop-yarn.sh
# stop-hbase.sh
# start-dfs.sh
# start-yarn.sh
# start-hbase.sh   #HRegionServer节点需要手动启动（hbase-daemon.sh start regionserver）
```  
