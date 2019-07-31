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
