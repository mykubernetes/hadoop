flume安装  
========

1、Flume日志收集，也可以收集端口，程序将收集来的数据发给Kafka用来实时进行数据收集，Spark、Storm用来实时处理数据，impala用来实时查询。  


Flume角色  
- Source 用于采集数据，Source是产生数据流的地方，同时Source会将产生的数据流传输到Channel，这个有点类似于Java IO部分的Channel  
- Channel 用于桥接Sources和Sinks，类似于一个队列。  
- Sink 从Channel收集数据，将数据写到目标源（可以是下一个Source，也可以是HDFS或者HBase）  

1、安装flume  
```
# tar -zxf flume-ng-1.5.0-cdh5.3.6.tar.gz -C /opt/modules/cdh/
```  

2、进入解压后的路径  
``` 
# cd /opt/modules/cdh/apache-flume-1.5.0-cdh5.3.6-bin/
```  

3、进入配置文件路径并更改模板文件  
```
# cd conf
# mv flume-env.sh.template flume-env.sh
```  

4、修改配置java的环境变量  
```
# vim flume-env.sh
export JAVA_HOME=/opt/modules/jdk1.8.0_121
```  

5、Flume帮助命令
```
$ bin/flume-ng
```
6、案例
===
案例一：Flume监听端口，输出端口数据。
---
创建Flume Agent配置文件flume-telnet.conf
```
# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = netcat
a1.sources.r1.bind = localhost
a1.sources.r1.port = 44444

# Describe the sink
a1.sinks.k1.type = logger

# Use a channel which buffers events in memory
a1.channels.c1.type = memory
a1.channels.c1.capacity = 1000
a1.channels.c1.transactionCapacity = 100

# Bind the source and sink to the channel
a1.sources.r1.channels = c1
a1.sinks.k1.channel = c1
```

安装telnet工具
```
$ sudo rpm -ivh telnet-server-0.17-59.el7.x86_64.rpm 
$ sudo rpm -ivh telnet-0.17-59.el7.x86_64.rpm
```

首先判断44444端口是否被占用
```
$ netstat -an | grep 44444
```

先开启flume先听端口
```
$ bin/flume-ng agent --conf conf/ --name a1 --conf-file conf/flume-telnet.conf -Dflume.root.logger==INFO,console
```

使用telnet工具向本机的44444端口发送内容。
```
$ telnet localhost 44444
```

案例二：监听上传Hive日志文件到HDFS
---
拷贝Hadoop相关jar到Flume的lib目录下
```
share/hadoop/common/lib/hadoop-auth-2.5.0-cdh5.3.6.jar
share/hadoop/common/lib/commons-configuration-1.6.jar
share/hadoop/mapreduce1/lib/hadoop-hdfs-2.5.0-cdh5.3.6.jar
share/hadoop/common/hadoop-common-2.5.0-cdh5.3.6.jar
```

创建flume-hdfs.conf文件
```
# Name the components on this agent
a2.sources = r2
a2.sinks = k2
a2.channels = c2

# Describe/configure the source
a2.sources.r2.type = exec
a2.sources.r2.command = tail -f /opt/modules/cdh/hive-0.13.1-cdh5.3.6/logs/hive.log
a2.sources.r2.shell = /bin/bash -c

# Describe the sink
a2.sinks.k2.type = hdfs
a2.sinks.k2.hdfs.path = hdfs://192.168.122.20:8020/flume/%Y%m%d/%H

a2.sinks.k2.hdfs.filePrefix = events-hive-           #上传文件的前缀
a2.sinks.k2.hdfs.round = true                        #是否按照时间滚动文件夹
a2.sinks.k2.hdfs.roundValue = 1                      #多少时间单位创建一个新的文件夹
a2.sinks.k2.hdfs.roundUnit = hour                    #重新定义时间单位
a2.sinks.k2.hdfs.useLocalTimeStamp = true            #是否使用本地时间戳
a2.sinks.k2.hdfs.batchSize = 1000                    #积攒多少个Event才flush到HDFS一次
a2.sinks.k2.hdfs.fileType = DataStream               #设置文件类型，可支持压缩
a2.sinks.k2.hdfs.rollInterval = 600                  #多久生成一个新的文件
a2.sinks.k2.hdfs.rollSize = 134217700                #设置每个文件的滚动大小
a2.sinks.k2.hdfs.rollCount = 0                       #文件的滚动与Event数量无关
a2.sinks.k2.hdfs.minBlockReplicas = 1                #最小冗余数


# Use a channel which buffers events in memory
a2.channels.c2.type = memory
a2.channels.c2.capacity = 1000
a2.channels.c2.transactionCapacity = 100

# Bind the source and sink to the channel
a2.sources.r2.channels = c2
a2.sinks.k2.channel = c2
```
执行监控配置
```
$ bin/flume-ng agent --conf conf/ --name a2 --conf-file conf/flume-hdfs.conf 
```

案例三：Flume监听整个目录
---
创建配置文件flume-dir.conf
```
$ cp -a flume-hdfs.conf flume-dir.conf
a3.sources = r3
a3.sinks = k3
a3.channels = c3

# Describe/configure the source
a3.sources.r3.type = spooldir
a3.sources.r3.spoolDir = /opt/modules/cdh/apache-flume-1.5.0-cdh5.3.6-bin/upload
a3.sources.r3.fileHeader = true

a3.sources.r3.ignorePattern = ([^ ]*\.tmp)      #忽略所有以.tmp结尾的文件，不上传

# Describe the sink
a3.sinks.k3.type = hdfs
a3.sinks.k3.hdfs.path = hdfs://192.168.122.20:8020/flume/upload/%Y%m%d/%H
a3.sinks.k3.hdfs.filePrefix = upload-           #上传文件的前缀
a3.sinks.k3.hdfs.round = true                   #是否按照时间滚动文件夹
a3.sinks.k3.hdfs.roundValue = 1                 #多少时间单位创建一个新的文件夹
a3.sinks.k3.hdfs.roundUnit = hour               #重新定义时间单位
a3.sinks.k3.hdfs.useLocalTimeStamp = true       #是否使用本地时间戳
a3.sinks.k3.hdfs.batchSize = 1000               #积攒多少个Event才flush到HDFS一次
a3.sinks.k3.hdfs.fileType = DataStream          #设置文件类型，可支持压缩
a3.sinks.k3.hdfs.rollInterval = 600             #多久生成一个新的文件
a3.sinks.k3.hdfs.rollSize = 134217700           #设置每个文件的滚动大小
a3.sinks.k3.hdfs.rollCount = 0                  #文件的滚动与Event数量无关
a3.sinks.k3.hdfs.minBlockReplicas = 1           #最小冗余数


# Use a channel which buffers events in memory
a3.channels.c3.type = memory
a3.channels.c3.capacity = 1000
a3.channels.c3.transactionCapacity = 100

# Bind the source and sink to the channel
a3.sources.r3.channels = c3
a3.sinks.k3.channel = c3
```
执行测试
```
$ bin/flume-ng agent --conf conf/ --name a3 --conf-file conf/flume-dir.conf &
```
