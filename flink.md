官网https://flink.apache.org/zh/

https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/

安装包下载，选择对应Hadoop的Flink版本下载  
http://flink.apache.org/downloads.html 

Flink支持多种安装模式
- Local—本地单机模式，学习测试时使用
- Standalone—独立集群模式，Flink自带集群，开发测试环境使用
- StandaloneHA—独立集群高可用模式，Flink自带集群，开发测试环境使用
- On Yarn—计算资源统一由Hadoop YARN管理，生产环境使用

1、安装
```
1、解压
# tar -zxvf /home/flink-1.9.1-bin-scala_2.11.tgz -C /usr/local/

2、配置环境变量
# vi /etc/profile
#追加如下内容
export FLINK_HOME=/usr/local/flink-1.9.1/
export PATH=$PATH:$JAVA_HOME/bin:$ZK_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$KAFKA_HOME/bin:$FLINK_HOME/bin

3、刷新环境变量：
# source /etc/profile
```

2、修改配置文件
```
# vim conf/flink-conf.yaml

#==============================================================================
# Common
#==============================================================================
# jobmanager.rpc.address: node01            # 高可用集群不需要配置
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

taskmanager.numberOfTaskSlots: 2       #插槽数，即运行的线程数
web.submit.enable: true                #web是否支持提交作业

#历史服务器与yarn有关系
jobmanager.archive.fs.dir: hdfs://node01:8020/flink/completed-jobs/
historyserver.web.address: node01
historyserver.web.port: 8082
historyserver.archive.fs.dir: hdfs://node01:8020/flink/completed-jobs/
historyserver.archive.fs.refresh-interval: 10000

# HA settings 高可用需要配置
state.backend: filesystem                                                        # 开启HA，使用文件系统作为快照存储
high-availability: zookeeper                                                     # 指定高可用模式（必须）
high-availability.zookeeper.quorum: node01:2181,node02:2181,node03:2181          # 配置ZK集群地址
high-availability.zookeeper.path.root: /flink                                    # 根ZooKeeper节点，在该节点下放置所有集群节点（推荐）
high-availability.cluster-id: /cluster_flink                                     ＃ 自定义集群（推荐）
high-availability.storageDir: hdfs://node01:9000/flink/recovery                  # 存储JobManager的元数据到HDFS
state.backend.fs.checkpointdir: hdfs://node01:8020/flink-checkpoints             # 启用检查点，可以将快照保存到HDFS
state.checkpoints.dir: hdfs:///flink/checkpoints
state.savepoints.dir: hdfs:///flink/checkpoints
```

3、配置主节点
```
vim conf/masters
node01:8081
node02:8081
```

4、配置从节点
```
vim conf/slaves 新版本为conf/workers
node01
node02
node03
```



5、分发并修改hadoop02和hadoop03节点的ip或者主机名
```
1、拷贝安装包到各节点
# scp -r ../flink-1.9.1/ node02:/usr/local/
# scp -r ../flink-1.9.1/ node03:/usr/local/

2、其他节点配置环境变量
# vi /etc/profile
#追加如下内容
export FLINK_HOME=/usr/local/flink-1.9.1/
export PATH=$PATH:$JAVA_HOME/bin:$ZK_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$KAFKA_HOME/bin:$FLINK_HOME/bin

3、刷新环境变量
# source /etc/profile


修改配置：
# vi ./conf/flink-conf.yaml
jobmanager.rpc.address: node2
rest.address: node02

# vi ./conf/flink-conf.yaml
rest.address: node03
jobmanager.rpc.address: node3
```

6、启动
启动顺序：先启动zk和hdfs、再启动flink。
```
1、拷贝hdfs的依赖包,否正无法启动
# cp /home/flink-shaded-hadoop-2-uber-2.7.5-10.0.jar /usr/local/flink-1.9.1/lib/
# scp /home/flink-shaded-hadoop-2-uber-2.7.5-10.0.jar node02:/usr/local/flink-1.9.1/lib/
# scp /home/flink-shaded-hadoop-2-uber-2.7.5-10.0.jar node03:/usr/local/flink-1.9.1/lib/

2、启动集群
# start-cluster.sh

3、单独启动

添加JobManager
# jobmanager.sh ((start|start-foreground) [host] [webui-port])|stop|stop-all
jobmanager.sh start node02

添加TaskManager
# taskmanager.sh start|start-foreground|stop|stop-all
# historyserver.sh start
```

7、浏览器访问  
web访问地址：http://node01:8081  
web访问地址：http://node02:8081

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

# flink run -m node01:8081 /usr/local/flink-1.9.1/examples/batch/WordCount.jar --input /home/words --output /home/out/fl00
```


10、Session模式

1)在yarn上启动一个Flink会话，node1上执行以下命令
```
flink/bin/yarn-session.sh -n 2 -tm 800 -s 1 -d
```
- -n 表示申请2个容器，这里指的就是多少个taskmanager
- -tm 表示每个TaskManager的内存大小
- -s 表示每个TaskManager的slots数量
- -d 表示以后台程序方式运行

2）查看UI界面http://node01:8088/cluster


3)使用flink run提交任务：
```
flink/bin/flink run  /export/server/flink/examples/batch/WordCount.jar
```

4）通过上方的ApplicationMaster可以进入Flink的管理界面

5）关闭yarn-session
```
yarn application -kill application_1599402747874_0001
```

11、Per-Job分离模式

直接提交job
```
# flink/bin/flink run -m yarn-cluster -yjm 1024 -ytm 1024 flink/examples/batch/WordCount.jar
```
- -m  jobmanager的地址
- -yjm 1024 指定jobmanager的内存信息
- -ytm 1024 指定taskmanager的内存信息
