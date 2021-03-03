官网https://flink.apache.org/zh/

https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/


1、安装
```
1、解压
# tar -zxvf /home/flink-1.9.1-bin-scala_2.11.tgz -C /usr/local/

2、配置环境变量
# vi /etc/profile
#追加如下内容
export FLINK_HOME=/usr/local/flink-1.9.1/
export
PATH=$PATH:$JAVA_HOME/bin:$ZK_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$KAFKA_HOME/bin:$FLINK_HOME/bin

3、刷新环境变量：
# source /etc/profile
```

2、修改配置文件
```
# vim conf/flink-conf.yaml

#==============================================================================
# Common
#==============================================================================
#jobmanager.rpc.address: hadoop01 HA模式不用
# The RPC port where the JobManager is reachable.
jobmanager.rpc.port: 6123
# The heap size for the JobManager JVM
jobmanager.heap.size: 1024m
# The heap size for the TaskManager JVM
taskmanager.heap.size: 1024m
#==============================================================================
# Rest & web frontend
#==============================================================================
# The port to which the REST client connects to. If rest.bind-port has
# not been specified, then the server will bind to this port as well.
#
rest.port: 8081
# The address to which the REST client will connect to
#
rest.address: hadoop01
# HA settings
high-availability: zookeeper
high-availability.zookeeper.quorum: hadoop01:2181,hadoop02:2181,hadoop03:2181
high-availability.zookeeper.path.root: /flink
high-availability.cluster-id: /cluster_flink
high-availability.storageDir: hdfs://hadoop01:9000/flink/recovery
```

3、配置从节点
```
vim conf/slaves 新版本为conf/workers
hadoop01
hadoop02
hadoop03
```

4、配置主节点
```
vim conf/masters
hadoop01:8081
hadoop02:8081
```

5、分发并修改hadoop02和hadoop03节点的ip或者主机名
```
分发：
# scp -r /etc/profile hadoop02:/etc
# scp -r /etc/profile hadoop03:/etc

# scp -r ../flink-1.9.1/ hadoop02:/usr/local/
# scp -r ../flink-1.9.1/ hadoop03:/usr/local/

#source /etc/profile
# source /etc/profile

修改配置：
# vi ./conf/flink-conf.yaml
rest.address: hadoop02

# vi ./conf/flink-conf.yaml
rest.address: hadoop03
```

6、启动
启动顺序：先启动zk和hdfs、再启动flink。
```
1、拷贝hdfs的依赖包,否正无法启动
# cp /home/flink-shaded-hadoop-2-uber-2.7.5-10.0.jar
/usr/local/flink-1.9.1/lib/
# scp /home/flink-shaded-hadoop-2-uber-2.7.5-10.0.jar
hadoop02:/usr/local/flink-1.9.1/lib/
# scp /home/flink-shaded-hadoop-2-uber-2.7.5-10.0.jar
hadoop03:/usr/local/flink-1.9.1/lib/

2、启动集群
# start-cluster.sh
```

7、浏览器访问  
web访问地址：http://hadoop01:8081  
web访问地址：http://hadoop02:8081

8、关闭standalone模式
```
# stop-cluster.sh
```

9、测试提交批次作业
```
# flink list            #列出计划和正在运行的job
# flink list -s         #列出预定job
# flink list -r         #列出正在运行的job
# flink list -a         #查看运行的作业和退出的作业
# flink list -m yarn-cluster -yid <yarnApplicationID> -r   #列出在YARN 中运行的job
# flink cancel <jobID>  #通过jobID取消job
# flink stop <jobID>    #通过jobID停止job

# flink run /usr/local/flink-1.9.1/examples/batch/WordCount.jar --input /home/words --output /home/out/fl00
```


10、job historyserver配置
```
# The HistoryServer is started and stopped via bin/historyserver.sh (start|stop)
# Directory to upload completed jobs to. Add this directory to the list of
# monitored directories of the HistoryServer as well (see below). #该目录不能创建，则可以手动创建

jobmanager.archive.fs.dir: hdfs://hadoop01:9000/flink_completed_jobs/

# The address under which the web-based HistoryServer listens.

historyserver.web.address: 192.168.216.111

# The port under which the web-based HistoryServer listens.

historyserver.web.port: 8082

# Comma separated list of directories to monitor for completed jobs.

historyserver.archive.fs.dir: hdfs://hadoop01:9000/flink_completed_jobs/

# Interval in milliseconds for refreshing the monitored directories.

historyserver.archive.fs.refresh-interval: 10000
```

11、启动历史服务(重新启动flink集群)
```
# historyserver.sh start
```

12、访问web：http://hadoop01:8082/

