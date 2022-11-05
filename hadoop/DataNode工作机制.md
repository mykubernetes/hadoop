# 一、DataNode工作机制  
1）一个数据块在datanode上以文件形式存储在磁盘上，包括两个文件，一个是数据本身，一个是元数据包括数据块的长度，块数据的校验和，以及时间戳。  
2）DataNode启动后向namenode注册，通过后，周期性（1小时）的向namenode上报所有的块信息。  
3）心跳是每3秒一次，心跳返回结果带有namenode给该datanode的命令如复制块数据到另一台机器，或删除某个数据块。如果超过10分钟没有收到某个datanode的心跳，则认为该节点不可用。  
4）集群运行中可以安全加入和退出一些机器

# 二、 数据完整性  
1）当DataNode读取block的时候，它会计算checksum  
2）如果计算后的checksum，与block创建时值不一样，说明block已经损坏  
3）client读取其他DataNode上的block.  
4）datanode在其文件创建后周期验证checksum  

# 三、 掉线时限参数设置  
datanode进程死亡或者网络故障造成datanode无法与namenode通信，namenode不会立即把该节点判定为死亡，要经过一段时间，这段时间暂称作超时时长。HDFS默认的超时时长为10分钟+30秒。如果定义超时时间为timeout，则超时时长的计算公式为：  
	timeout  = 2 * dfs.namenode.heartbeat.recheck-interval + 10 * dfs.heartbeat.interval。  
	而默认的dfs.namenode.heartbeat.recheck-interval 大小为5分钟，dfs.heartbeat.interval默认为3秒。  
	需要注意的是hdfs-site.xml 配置文件中的heartbeat.recheck.interval的单位为毫秒，dfs.heartbeat.interval的单位为秒。  
```
<property>
    <name>dfs.namenode.heartbeat.recheck-interval</name>
    <value>300000</value>
</property>
<property>
    <name> dfs.heartbeat.interval </name>
    <value>3</value>
</property>
```

# 四、 DataNode的目录结构  
和namenode不同的是，datanode的存储目录是初始阶段自动创建的，不需要额外格式化。  
1、在/opt/module/hadoop-2.7.2/data/tmp/dfs/data/current这个目录下查看版本号  
```
$ cat VERSION   
storageID=DS-1b998a1d-71a3-43d5-82dc-c0ff3294921b  
clusterID=CID-1f2bf8d1-5ad2-4202-af1c-6713ab381175  
cTime=0  
datanodeUuid=970b2daf-63b8-4e17-a514-d81741392165  
storageType=DATA_NODE  
layoutVersion=-56  
```
2、具体解释  
	（1）storageID：存储id号  
	（2）clusterID集群id，全局唯一  
	（3）cTime属性标记了datanode存储系统的创建时间，对于刚刚格式化的存储系统，这个属性为0；但是在文件系统升级之后，该值会更新到新的时间戳。  
	（4）datanodeUuid：datanode的唯一识别码  
	（5）storageType：存储类型  
	（6）layoutVersion是一个负整数。通常只有HDFS增加新特性时才会更新这个版本号。  
3、在/opt/module/hadoop-2.7.2/data/tmp/dfs/data/current/BP-97847618-192.168.10.102-1493726072779/current这个目录下查看该数据块的版本号  
```
$ cat VERSION
#Mon May 08 16:30:19 CST 2017
namespaceID=1933630176
cTime=0
blockpoolID=BP-97847618-192.168.10.102-1493726072779
layoutVersion=-56
```
4、具体解释  
（1）namespaceID：是datanode首次访问namenode的时候从namenode处获取的storageID对每个datanode来说是唯一的（但对于单个datanode中所有存储目录来说则是相同的），namenode可用这个属性来区分不同datanode。  
（2）cTime属性标记了datanode存储系统的创建时间，对于刚刚格式化的存储系统，这个属性为0；但是在文件系统升级之后，该值会更新到新的时间戳。  
（3）blockpoolID：一个block pool id标识一个block pool，并且是跨集群的全局唯一。当一个新的Namespace被创建的时候(format过程的一部分)会创建并持久化一个唯一ID。在创建过程构建全局唯一的BlockPoolID比人为的配置更可靠一些。NN将BlockPoolID持久化到磁盘中，在后续的启动过程中，会再次load并使用。  
（4）layoutVersion是一个负整数。通常只有HDFS增加新特性时才会更新这个版本号。  

# 五、 服役新数据节点  
1、需求：  
随着公司业务的增长，数据量越来越大，原有的数据节点的容量已经不能满足存储数据的需求，需要在原有集群基础上动态添加新的数据节点。  
2、环境准备  
	（1）准备新加入的节点  
	（2）修改ip地址和主机名称  
	（3）将其他配置好的机器的hadoop配置文件scp到新加入节点    
	（4）删除原来HDFS文件系统留存的文件  
		/opt/module/hadoop-2.7.2/data  
3、服役新节点具体步骤  
（1）在namenode的/opt/module/hadoop-2.7.2/etc/hadoop目录下创建dfs.hosts文件  
```
$ pwd
/opt/module/hadoop-2.7.2/etc/hadoop
$ touch dfs.hosts
$ vi dfs.hosts
```
添加如下主机名称（包含新服役的节点）  
```
node001
node002
node003
node004
```
(2）在namenode的hdfs-site.xml配置文件中增加dfs.hosts属性  
```
<property>
      <name>dfs.hosts</name>
      <value>/opt/module/hadoop-2.7.2/etc/hadoop/dfs.hosts</value>
</property>
```
(3)刷新namenode   
```$ hdfs dfsadmin -refreshNodes  ```  
Refresh nodes successful  
(4）更新resourcemanager节点  
```$ yarn rmadmin -refreshNodes  ```  
17/06/24 14:17:11 INFO client.RMProxy: Connecting to ResourceManager at node002/192.168.1.103:8033  
(5)在namenode的slaves文件中增加新主机名称  
	增加node004  不需要分发  
```
node001
node002
node003
node004
```
(6)单独命令启动新的数据节点和节点管理器 
```
$ sbin/hadoop-daemon.sh start datanode
starting datanode, logging to /opt/module/hadoop-2.7.2/logs/hadoop-atguigu-datanode-hadoop105.out
$ sbin/yarn-daemon.sh start nodemanager
starting nodemanager, logging to /opt/module/hadoop-2.7.2/logs/yarn-atguigu-nodemanager-hadoop105.out
```
(7)在web浏览器上检查是否ok  
4、如果数据不均衡，可以用命令实现集群的再平衡  
```
$ ./start-balancer.sh
starting balancer, logging to /opt/module/hadoop-2.7.2/logs/hadoop-atguigu-balancer-hadoop102.out
Time Stamp               Iteration#  Bytes Already Moved  Bytes Left To Move  Bytes Being Moved
```

# 六、退役旧数据节点  
1、在namenode的/opt/module/hadoop-2.7.2/etc/hadoop目录下创建dfs.hosts.exclude文件  
```
$ pwd  
/opt/module/hadoop-2.7.2/etc/hadoop  
$ touch dfs.hosts.exclude  
$ vi dfs.hosts.exclude
```
添加如下主机名称（要退役的节点）  
```
node004
```
2、在namenode的hdfs-site.xml配置文件中增加dfs.hosts.exclude属性  
```
<property>
      <name>dfs.hosts.exclude</name>
      <value>/opt/module/hadoop-2.7.2/etc/hadoop/dfs.hosts.exclude</value>
</property>
```
3、刷新namenode、刷新resourcemanager  
```
$ hdfs dfsadmin -refreshNodes
Refresh nodes successful
$ yarn rmadmin -refreshNodes
17/06/24 14:55:56 INFO client.RMProxy: Connecting to ResourceManager at node002/192.168.1.103:8033
```
4、检查web浏览器，退役节点的状态为decommission in progress（退役中），说明数据节点正在复制块到其他节点。  
 
5、等待退役节点状态为decommissioned（所有块已经复制完成），停止该节点及节点资源管理器。注意：如果副本数是3，服役的节点小于等于3，是不能退役成功的，需要修改副本数后才能退役。·  
```
$ sbin/hadoop-daemon.sh stop datanode
stopping datanode
$ sbin/yarn-daemon.sh stop nodemanager
stopping nodemanager
```
6、从include文件中删除退役节点，再运行刷新节点的命令  
(1）从namenode的dfs.hosts文件中删除退役节点node004  
```
node001
node002
node003
```
(2）刷新namenode，刷新resourcemanager  
```	
$hdfs dfsadmin -refreshNodes
 Refresh nodes successful
$yarn rmadmin -refreshNodes
17/06/24 14:55:56 INFO client.RMProxy: Connecting to ResourceManager at hadoop103/192.168.1.103:8033
```
7、从namenode的slave文件中删除退役节点node004  
```
node001
node002
node003
```
8、如果数据不均衡，可以用命令实现集群的再平衡  
```
bin/start-balancer.sh   
starting balancer, logging to /opt/module/hadoop-2.7.2/logs/hadoop-atguigu-balancer-hadoop102.out
Time Stamp               Iteration#  Bytes Already Moved  Bytes Left To Move  Bytes Being Moved
```

# 七、 Datanode多目录配置  
1）datanode也可以配置成多个目录，每个目录存储的数据不一样。即：数据不是副本。  
2）具体配置如下：  
```
hdfs-site.xml
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file:///${hadoop.tmp.dir}/dfs/data1,file:///${hadoop.tmp.dir}/dfs/data2</value>
    </property>
 ```

# 八、HDFS 的 block 块和副本机制

HDFS 将所有的文件全部抽象成为 block 块来进行存储，不管文件大小，全部一视同仁都是以 block 块的统一大小和形式进行存储，方便我们的分布式文件系统对文件的管理。

所有的文件都是以 block 块的方式存放在 hdfs 文件系统当中，block块的大小可以通过 hdfs-site.xml 当中的配置文件进行指定。
- 在 Hadoop 1 版本当中，文件的 block 块默认大小是 64M
- 在 Hadoop 2 版本当中，文件的 block 块大小默认是128M

```
<property>
    <name>dfs.block.size</name>
    <value>块大小以字节为单位</value>     //只写数值就可以
</property>
```

1、抽象为block块的好处
- 1) 一个文件有可能大于集群中任意一个磁盘
  - 10T*3/128 = xxx块 2T，2T，2T 文件方式存—–>多个block块，这些block块属于一个文件
- 2) 使用块抽象而不是文件可以简化存储子系统
- 3) 块非常适合用于数据备份进而提供数据容错能力和可用性

2、块缓存

**通常 DataNode 从磁盘中读取块，但对于访问频繁的文件，其对应的块可能被显示的缓存在 DataNode 的内存中，以堆外块缓存的形式存在。** 默认情况下，一个块仅缓存在一个DataNode的内存中，当然可以针对每个文件配置DataNode的数量。**作业调度器通过在缓存块的DataNode上运行任务，可以利用块缓存的优势提高读操作的性能。**

例如：

连接（join）操作中使用的一个小的查询表就是块缓存的一个很好的候选。 用户或应用通过在缓存池中增加一个cache directive来告诉namenode需要缓存哪些文件及存多久。缓存池（cache pool）是一个拥有管理缓存权限和资源使用的管理性分组。

例如:

一个文件 130M，会被切分成2个block块，保存在两个block块里面，实际占用磁盘130M空间，而不是占用256M的磁盘空间

3、hdfs的文件权限验证

hdfs的文件权限机制与linux系统的文件权限机制类似
```
r:read w:write x:execute
```
权限x对于文件表示忽略，对于文件夹表示是否有权限访问其内容

如果linux系统用户zhangsan使用hadoop命令创建一个文件，那么这个文件在HDFS当中的owner就是zhangsan

HDFS文件权限的目的，防止好人做错事，而不是阻止坏人做坏事。HDFS相信你告诉我你是谁，你就是谁

4、hdfs的副本因子

为了保证block块的安全性，也就是数据的安全性，在hadoop2当中，文件默认保存三个副本，我们可以更改副本数以提高数据的安全性

在hdfs-site.xml当中修改以下配置属性，即可更改文件的副本数
```
<property>
     <name>dfs.replication</name>
     <value>3</value>
</property>
```
