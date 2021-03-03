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

