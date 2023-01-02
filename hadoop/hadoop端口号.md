

| 组件| 节点 | 默认端口 | 配置 | 用途说明 |
|-----|------|---------|------|----------|
| HDFS | DataNode | 50010 | dfs.datanode.address | datanode服务端口，用于数据传输 |
| HDFS | DataNode | 50075 | dfs.datanode.http.address | http服务的端口 |
| HDFS  |DataNode | 50475 | dfs.datanode.https.address | https服务的端口 |
| HDFS | DataNode | 50020 | dfs.datanode.ipc.address | ipc服务的端口 |
| HDFS | NameNode | 50070 | dfs.namenode.http-address | http服务的端口 |
| HDFS | NameNode | 50470 | dfs.namenode.https-address | https服务的端口 |
| HDFS | NameNode | 9000 | fs.default.name | 内部通讯端口 |
| HDFS | NameNode | 8020 | fs.defaultFS | 接收Client连接的RPC端口，用于获取文件系统metadata信息。 |
| HDFS | journalnode | 8485 | dfs.journalnode.rpc-address | RPC服务 |
| HDFS | journalnode | 8480 | dfs.journalnode.http-address | HTTP服务 |
| HDFS | ZKFC | 8019 | dfs.ha.zkfc.port | ZooKeeper FailoverController，用于NN HA |
| YARN | ResourceManager | 8032 | yarn.resourcemanager.address | RM的applications manager(ASM)端口 |
| YARN | ResourceManager | 8030 | yarn.resourcemanager.scheduler.address | scheduler组件的IPC端口 |
| YARN | ResourceManager | 8031 | yarn.resourcemanager.resource-tracker.address | IPC |
| YARN | ResourceManager | 8033 | yarn.resourcemanager.admin.address | IPC |
| YARN | ResourceManager | 8088 | yarn.resourcemanager.webapp.address | http服务端口 |
| YARN | NodeManager | 8040 | yarn.nodemanager.localizer.address | localizer IPC |
| YARN | NodeManager | 8042 | yarn.nodemanager.webapp.address | http服务端口 |
| YARN | NodeManager | 8041 | yarn.nodemanager.address | NM中container manager的端口 |
| YARN | JobHistory Server | 10020 | mapreduce.jobhistory.address | IPC |
| YARN | JobHistory Server | 19888 | mapreduce.jobhistory.webapp.address | http服务端口 |
| HBase | Master | 60000 | hbase.master.port | IPC |
| HBase | Master | 60010 | hbase.master.info.port | http服务端口 |
| HBase | RegionServer | 60020 | hbase.regionserver.port | IPC |
| HBase | RegionServer | 60030 | hbase.regionserver.info.port | http服务端口 |
| HBase | HQuorumPeer | 2181 | hbase.zookeeper.property.clientPort | HBase-managed ZK mode，使用独立的ZooKeeper集群则不会启用该端口。 |
| HBase | HQuorumPeer | 2888 | hbase.zookeeper.peerport | HBase-managed ZK mode，使用独立的ZooKeeper集群则不会启用该端口。 |
| HBase | HQuorumPeer | 3888 | hbase.zookeeper.leaderport | HBase-managed ZK mode，使用独立的ZooKeeper集群则不会启用该端口。 |
| Hive | Metastore | 9083 | | /etc/default/hive-metastore中export PORT=`<port>`来更新默认端口 |
| Hive | HiveServer | 10000 | | /etc/hive/conf/hive-env.sh中export HIVE_SERVER2_THRIFT_PORT=`<port>`来更新默认端口 |
| ZooKeeper | Server | 2181 | /etc/zookeeper/conf/zoo.cfg中clientPort=`<port>` | 对客户端提供服务的端口 |
| ZooKeeper | Server | 2888 | /etc/zookeeper/conf/zoo.cfg中server.x=[hostname]:nnnnn[:nnnnn]，标蓝部分 | follower用来连接到leader，只在leader上监听该端口。 |
| ZooKeeper | Server | 3888 | /etc/zookeeper/conf/zoo.cfg中server.x=[hostname]:nnnnn[:nnnnn]，标蓝部分 | 用于leader选举的。只在electionAlg是1,2或3(默认)时需要。 |
| Spark | | 8080 | | Web监控端口 |
| Spark | | 4040 | | Job监控端口 |

常见端口汇总：
```
Hadoop:
50070：HDFS WEB UI端口
8020 ： 高可用的HDFS RPC端口
9000 ： 非高可用的HDFS RPC端口
8088 ： Yarn 的WEB UI 接口
8485 ： JournalNode 的RPC端口
8019 ： ZKFC端口
19888：jobhistory WEB UI端口
```

```
Zookeeper:
2181 ： 客户端连接zookeeper的端口
2888 ： zookeeper集群内通讯使用，Leader监听此端口
3888 ： zookeeper端口 用于选举leader
```

```
Hbase:
60010：Hbase的master的WEB UI端口 （旧的） 新的是16010
60030：Hbase的regionServer的WEB UI 管理端口
```

```
Hive:
9083 : metastore服务默认监听端口
10000：Hive 的JDBC端口
```

```
Spark：
7077 ： spark 的master与worker进行通讯的端口 standalone集群提交Application的端口
8080 ： master的WEB UI端口 资源调度
8081 ： worker的WEB UI 端口 资源调度
4040 ： Driver的WEB UI 端口 任务调度
18080：Spark History Server的WEB UI 端口
```

```
Kafka：
9092： Kafka集群节点之间通信的RPC端口
```

```
Redis：
6379： Redis服务端口
```

```
CDH：
7180： Cloudera Manager WebUI端口
7182： Cloudera Manager Server 与 Agent 通讯端口
```

```
HUE：
8888： Hue WebUI 端口
```

```
kibanna
5601：UI 端口
```




参考：
- https://www.jianshu.com/p/fcfd512bc322
