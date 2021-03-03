官网https://flink.apache.org/zh/

https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/

Flink支持多种安装模式
- Local—本地单机模式，学习测试时使用
- Standalone—独立集群模式，Flink自带集群，开发测试环境使用
- StandaloneHA—独立集群高可用模式，Flink自带集群，开发测试环境使用
- On Yarn—计算资源统一由Hadoop YARN管理，生产环境使用

Local本地模式原理
- 1.Flink程序由JobClient进行提交
- 2.JobClient将作业提交给JobManager
- 3.JobManager负责协调资源分配和作业执行。资源分配完成后，任务将提交给相应的TaskManager
- 4.TaskManager启动一个线程以开始执行。TaskManager会向JobManager报告状态更改,如开始执行，正在进行或已完成。 
- 5.作业执行完成后，结果将发送回客户端(JobClient)

Standalone独立集群模式原理
- 1.client客户端提交任务给JobManager
- 2.JobManager负责申请任务运行所需要的资源并管理任务和资源，
- 3.JobManager分发任务给TaskManager执行
- 4.TaskManager定期向JobManager汇报状态

Standalone-HA高可用集群模式
- 从之前的架构中我们可以很明显的发现 JobManager 有明显的单点问题(SPOF，single point of failure)。JobManager 肩负着任务调度以及资源分配，一旦 JobManager 出现意外，其后果可想而知。
- 在 Zookeeper 的帮助下，一个 Standalone的Flink集群会同时有多个活着的 JobManager，其中只有一个处于工作状态，其他处于 Standby 状态。当工作中的 JobManager 失去连接后(如宕机或 Crash)，Zookeeper 会从 Standby 中选一个新的 JobManager 来接管 Flink 集群。

Flink On Yarn模式
- 1.Yarn的资源可以按需使用，提高集群的资源利用率
- 2.Yarn的任务有优先级，根据优先级运行作业
- 3.基于Yarn调度系统，能够自动化地处理各个角色的 Failover(容错)
  - JobManager 进程和 TaskManager 进程都由 Yarn NodeManager 监控
  - 如果 JobManager 进程异常退出，则 Yarn ResourceManager 会重新调度 JobManager 到其他机器
  - 如果 TaskManager 进程异常退出，JobManager 会收到消息并重新向 Yarn ResourceManager 申请资源，重新启动 TaskManager


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
jobmanager.rpc.address: node01
# The RPC port where the JobManager is reachable.
jobmanager.rpc.port: 6123                   # 端口号

# The heap size for the JobManager JVM
jobmanager.heap.size: 1024m                 # JobManager JVM 大小

# The heap size for the TaskManager JVM     # TaskManager JVM 大小
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
rest.address: node01

taskmanager.numberOfTaskSlots: 2       #插槽数
web.submit.enable: true                #web是否支持提交作业

#历史服务器
jobmanager.archive.fs.dir: hdfs://node01:8020/flink/completed-jobs/
historyserver.web.address: node01
historyserver.web.port: 8082
historyserver.archive.fs.dir: hdfs://node01:8020/flink/completed-jobs/

# HA settings
state.backend: filesystem                                                        # 开启HA，使用文件系统作为快照存储
high-availability: zookeeper                                                     # 使用zookeeper搭建高可用
high-availability.zookeeper.quorum: node01:2181,node02:2181,node03:2181          # 配置ZK集群地址
high-availability.zookeeper.path.root: /flink                                    # flink在zk的根路径
high-availability.cluster-id: /cluster_flink
high-availability.storageDir: hdfs://node01:9000/flink/recovery                  # 存储JobManager的元数据到HDFS
state.backend.fs.checkpointdir: hdfs://node01:8020/flink-checkpoints             # 启用检查点，可以将快照保存到HDFS
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

3、单独启动
# jobmanager.sh ((start|start-foreground) cluster)|stop|stop-all
# taskmanager.sh start|start-foreground|stop|stop-all

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

