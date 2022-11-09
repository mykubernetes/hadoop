# 大数据之Hadoop的HDFS存储优化—异构存储（冷热数据分离）

异构存储主要解决，不同的数据，储存在不同类型的硬盘中，达到最佳性能的问题

## 1）存储类型

- RAM_DISK：内存镜像文件系统
- SSD：SSD固态硬盘
- DISK：普通磁盘，在HDFS中，如果没有主动声明数据目录储存类型默认都是DISK
- ARCHIVE：没有特指哪种存储介质，主要指的是计算能力比较弱而储存密度比较高的介质，用来解决数据容量扩增的问题，一般用于归档



## 2）储存策略

| 策略ID | 策略名称 | 副本分布 | 描述 |
|--------|---------|---------|------|
| 15 | Lazy_Persist | RAM_DISK:1, DISK: n-1 | 一个副本保存在RAM_DISK中，其余副本保存在磁盘中。 |
| 12 | All_SSD | SSD :n | 所有副本都保存在SSD中。 |
| 10 | One_SSD | SSD:1, DISK: n-1 | 一个副本保存在SSD中，其余副本保存在磁盘中。 |
| 7 | Hot(default) | DISK: n | 所有副本保存在磁盘中，这也是默认的存储策略。 |
| 6 | Warm | DISK:1, ARCHIVE: n-1 | 一个副本保存在磁盘上，其余副本保存在归档存储上。 |
| 2 | Cold | ARCHIVE: n | 所有副本都保存在归档存储上。 |

# Shell操作#

（1）查看当前有哪些存储策略可用。
```
hdfs storagepolicies -listPolicies
```

（2）为指定路径（数据存储目录或文件）的存储策略
```
hdfs storagepolicies -setStoragePolicy -path xxx -policy xxx
```

（3）获取指定路径（数据存储目录或文件）的存储策略
```
hdfs storagepolicies -getStoragePolicy -path xxx
```

（4）取消策略：执行该命令后该目录或文件，及其上级的目录为准，如果是根目录，那么就是HOT
```
hdfs storagepolicies -unsetStoragePolicy -path xxx
```

（5）查看文件块的分布
```
hdfs fsck xxx -files -blocks -locations
```

（6）查看集群节点
```
hadoop dfsadmin -report
```

# 测试环境准备

## 1）环境描述

服务器规模：5台

集群配置：副本数为2，创建好带有存储类型的目录（提前创建）

集群规划

| 节点 | 存储类型分配 |
|------|-------------|
| hadoop102 | RAM_DISK，SSD |
| hadoop103 | SSD，DISK |
| hadoop104 | DISK，RAM_DISK |
| hadoop105 | ARCHIVE |
| hadoop106 | ARCHIVE |

## 2）配置文件信息

（1）为hadoop102节点的hdfs-site.xml添加如下信息
```
<property>
    <name>dfs.replication</name>
    <value>2</value>
</property>
<property>
    <name>dfs.storage.policy.enabled</name>
    <value>true</value>
</property>
<property>
    <name>dfs.datanode.data.dir</name>
    <value>[SSD]file:///opt/module/hadoop-3.1.3/hdfsdata/ssd,[RAM_DISK]file:///opt/module/hadoop-3.1.3/hdfsdata/ram_disk</value>
</property>
```

（2）为hadoop103节点的hdfs-site.xml添加如下信息
```
<property>
    <name>dfs.replication</name>
    <value>2</value>
</property>
<property>
    <name>dfs.storage.policy.enabled</name>
    <value>true</value>
</property>
<property>
    <name>dfs.datanode.data.dir</name>
    <value>[SSD]file:///opt/module/hadoop-3.1.3/hdfsdata/ssd,[DISK]file:///opt/module/hadoop-3.1.3/hdfsdata/disk</value>
</property>
```

（3）为hadoop104节点的hdfs-site.xml添加如下信息
```
<property>
    <name>dfs.replication</name>
    <value>2</value>
</property>
<property>
    <name>dfs.storage.policy.enabled</name>
    <value>true</value>
</property>
<property>
    <name>dfs.datanode.data.dir</name>
    <value>[RAM_DISK]file:///opt/module/hadoop-3.1.3/hdfsdata/ram_disk,[DISK]file:///opt/module/hadoop-3.1.3/hdfsdata/disk</value>
</property>
```

（4）为hadoop105节点的hdfs-site.xml添加如下信息
```
<property>
    <name>dfs.replication</name>
    <value>2</value>
</property>
<property>
    <name>dfs.storage.policy.enabled</name>
    <value>true</value>
</property>
<property>
    <name>dfs.datanode.data.dir</name>
    <value>[ARCHIVE]file:///opt/module/hadoop-3.1.3/hdfsdata/archive</value>
</property>
```

（5）为hadoop106节点的hdfs-site.xml添加如下信息
```
<property>
    <name>dfs.replication</name>
    <value>2</value>
</property>
<property>
    <name>dfs.storage.policy.enabled</name>
    <value>true</value>
</property>
<property>
    <name>dfs.datanode.data.dir</name>
    <value>[ARCHIVE]file:///opt/module/hadoop-3.1.3/hdfsdata/archive</value>
</property>
```

## 3）数据准备

（1）启动集群
```
[hadoop@hadoop102 hadoop-3.1.3]$ hdfs namenode -format
[hadoop@hadoop102 hadoop-3.1.3]$ myhadoop.sh start
```

（2）在HDFS上创建文件目录
```
[hadoop@hadoop102 hadoop-3.1.3]$ hadoop fs -mkdir /hdfsdata
```
（3）上传文件
```
[hadoop@hadoop102 hadoop-3.1.3]$ hadoop fs -put NOTICE.txt /hdfsdata
```

可在Browsing HDFS查看文件信息

# HOT存储策略案例#

（1）最开始我们未设置存储策略的情况下，我们获取该目录的存储策略
```
[hadoop@hadoop102 hadoop-3.1.3]$ hdfs storagepolicies -getStoragePolicy -path /hdfsdata
The storage policy of /hdfsdata is unspecified
```

（2）查看上传的文件块分布
```
[hadoop@hadoop102 hadoop-3.1.3]$ hdfs fsck /hdfsdata -files -blocks -locations

[DatanodeInfoWithStorage[192.168.10.104:9866,DS-e3ce2615-178f-4489-b58e-27a577f4b72f,DISK], DatanodeInfoWithStorage[192.168.10.103:9866,DS-e8c8d524-7005-4dc4-99ed-30820ff67ef5,DISK]]
```
未设置存储策略，所有文件都存储在DISK下。所以，`默认存储策略为HOT`。

# WARM存储策略测试

（1）接下来为数据降温
```
[hadoop@hadoop102 ~]$ hdfs storagepolicies -setStoragePolicy -path /hdfsdata -policy WARM
```

（2）再次查看文件块分布，我们可以看到文件块依然放在原处
```
[hdoop@hadoop102 ~]$ hdfs fsck /hdfsdata -files -blocks -locations
```

（3）我们需要让他HDFS按照存储策略自行移动文件夹
```
[hadoop@hadoop102 ~]$ hdfs mover /hdfsdata
```

（4）再次查看文件块分布
```
[hdoop@hadoop102 ~]$ hdfs fsck /hdfsdata -files -blocks -locations

[DatanodeInfoWithStorage[192.168.10.106:9866,DS-a417ad5b-f80a-4f8c-a500-d6d5a6c52d6d,ARCHIVE], DatanodeInfoWithStorage[192.168.10.103:9866,DS-e8c8d524-7005-4dc4-99ed-30820ff67ef5,DISK]]
```
文件一半在DISK，一半在ARCHIVE，符合我们设置的WARM策略

# COLD策略测试

（1）继续降温为clod
```
[hadoop@hadoop102 ~]$ hdfs storagepolicies -setStoragePolicy -path /hdfsdata -policy COLD
```
注意：当我们将目录设置为COLD并且我们未配置ARCHIVE存储目录的情况下，不可以直接向该目录直接上传文件，会报出异常。

（2）手动转移
```
[hadoop@hadoop102 ~]$ hdfs mover /hdfsdata
```

（3）检查文件快分布
```
[hdoop@hadoop102 ~]$ hdfs fsck /hdfsdata -files -blocks -locations

[DatanodeInfoWithStorage[192.168.10.106:9866,DS-a417ad5b-f80a-4f8c-a500-d6d5a6c52d6d,ARCHIVE], DatanodeInfoWithStorage[192.168.10.105:9866,DS-1c17f839-d8f5-4ca2-aa4c-eaebbdd7c638,ARCHIVE]]
```
所有文件块都在ARCHIVE，符合COLD存储策略。

# ONE_SSD策略测试

（1）更改策略为ONE_SSD
```
[hadoop@hadoop102 ~]$ hdfs storagepolicies -setStoragePolicy -path /hdfsdata -policy ONE_SSD
```

（2）手动转移
```
[hadoop@hadoop102 ~]$ hdfs mover /hdfsdata
```

（3）检查文件快分布
```
[hdoop@hadoop102 ~]$ hdfs fsck /hdfsdata -files -blocks -locations

[DatanodeInfoWithStorage[192.168.10.104:9866,DS-e3ce2615-178f-4489-b58e-27a577f4b72f,DISK], DatanodeInfoWithStorage[192.168.10.103:9866,DS-0a858711-8264-4152-887a-9408e2f83c3a,SSD]]
```
文件块分布为一半在SSD，一半在DISK，符合One_SSD存储策略。

# ALL_SSD策略测试

（1）更改策略为ALL_SSD
```
[hadoop@hadoop102 ~]$ hdfs storagepolicies -setStoragePolicy -path /hdfsdata -policy ALL_SSD
```

（2）手动转移
```
[hadoop@hadoop102 ~]$ hdfs mover /hdfsdata
```

（3）检查文件快分布
```
[hdoop@hadoop102 ~]$ hdfs fsck /hdfsdata -files -blocks -locations

[DatanodeInfoWithStorage[192.168.10.102:9866,DS-b4a0eba9-0335-409a-aab5-2ebfe724fe0a,SSD], DatanodeInfoWithStorage[192.168.10.103:9866,DS-0a858711-8264-4152-887a-9408e2f83c3a,SSD]]
```
所有的文件块都存储在SSD，符合All_SSD存储策略。

# LAZY_PERSIST策略测试

（1）更改策略为LAZY_PERSIST
```
[hadoop@hadoop102 ~]$ hdfs storagepolicies -setStoragePolicy -path /hdfsdata -policy LAZY_PERSIST
```

（2）手动转移
```
[hadoop@hadoop102 ~]$ hdfs mover /hdfsdata
```

（3）检查文件快分布
```
[hdoop@hadoop102 ~]$ hdfs fsck /hdfsdata -files -blocks -locations

[DatanodeInfoWithStorage[192.168.10.104:9866,DS-e3ce2615-178f-4489-b58e-27a577f4b72f,DISK], DatanodeInfoWithStorage[192.168.10.103:9866,DS-e8c8d524-7005-4dc4-99ed-30820ff67ef5,DISK]]
```

文件块都存储在了DISK中，与预期的不一样，这是因为，还需要配置`dfs.datanode.max.locked.memory`和`dfs.block.size`参数。

当存储策略为LAZY_PERSIST时，文件块副本都存储在DISK上的原因有如下两点:
- （1）当客户端所在节点没有RAM_DISK时，则会写入客户端所在的DataNode节点的DISK磁盘。其余副本会写入其他节点的DISK磁盘。
- （2）当客户端所在的DataNode有RAM_DISK时，但`dfs.datanode.max.locked.memory`参数未设置或设置过小（小于`dfs.block.size`参数值）时，则会写入客户端所在的DataNode节点的DISK磁盘，其余会写入其他节点的DISK磁盘。

但是由于虚拟机的`max locked memory`为64KB，所以如果参数配置过大，会报错
```
ERRORorg.apache.hadoop.hdfs.server.datanode.DataNode: Exception in secureMain

java.lang.RuntimeException: Cannotstart datanode because the configured max locked memory size(dfs.datanode.max.locked.memory) of 209715200 bytes is more than the datanode'savailable RLIMIT_MEMLOCK ulimit of 65536 bytes.
```

我们可以通过该命令查看此参数的内存
```
[hadoop@hadoop102 ~]$ ulimit -a

max locked memory       (kbytes, -l) 64
max memory size         (kbytes, -m) unlimited
```

参考：
- https://www.pudn.com/news/62aeeaaaa11cf7345fb4fc0f.html
