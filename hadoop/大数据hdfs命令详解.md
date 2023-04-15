# 一、查看hadf的帮助信息
```
# hdfs
Usage: hdfs [--config confdir] COMMAND
       where COMMAND is one of:
  dfs                  run a filesystem command on the file systems supported in Hadoop.
  namenode -format     format the DFS filesystem
  secondarynamenode    run the DFS secondary namenode
  namenode             run the DFS namenode
  journalnode          run the DFS journalnode
  zkfc                 run the ZK Failover Controller daemon
  datanode             run a DFS datanode
  dfsadmin             run a DFS admin client
  diskbalancer         Distributes data evenly among disks on a given node
  haadmin              run a DFS HA admin client
  fsck                 run a DFS filesystem checking utility
  balancer             run a cluster balancing utility
  jmxget               get JMX exported values from NameNode or DataNode.
  mover                run a utility to move block replicas across
                       storage types
  oiv                  apply the offline fsimage viewer to an fsimage
  oiv_legacy           apply the offline fsimage viewer to an legacy fsimage
  oev                  apply the offline edits viewer to an edits file
  fetchdt              fetch a delegation token from the NameNode
  getconf              get config values from configuration
  groups               get the groups which users belong to
  snapshotDiff         diff two snapshots of a directory or diff the
                       current directory contents with a snapshot
  lsSnapshottableDir   list all snapshottable dirs owned by the current user
                                                Use -help to see options
  portmap              run a portmap service
  nfs3                 run an NFS version 3 gateway
  cacheadmin           configure the HDFS cache
  crypto               configure HDFS encryption zones
  storagepolicies      list/get/set block storage policies
  version              print the version
 
Most commands print help when invoked w/o parameters.
```

# 二.dfs

- 其实`hdfs`和`dfs`结合使用的话实际上调用的是`hadoop fs`这个命令。
```
# hdfs dfs
```

| 命令名 | 格式 | 含义 |
|--------|-----|------|
| -ls | -ls<路径> | 查看指定路径的当前目录结构 |
| -lsr | -lsr<路径> | 递归查看指定路径的目录结构 |
| -du | -du<路径> | 统计目录下个文件大小 |
| -dus | -dus<路径> | 汇总统计目录下文件(夹)大小 |
| -count | -count[-q]<路径> | 统计文件(夹)数量 |
| -mv | -mv<源路径><目的路径> | 移动 |
| -cp | -cp<源路径><目的路径> | 复制 |
| -rm | -rm[-skipTrash]<路径> | 删除文件/空白文件夹 |
| -rmr | -rmr[-skipTrash]<路径> | 递归删除 |
| -put | -put<多个 linux 上的文件> | 上传文件 |
| -copyFromLocal | -copyFromLocal<多个 linux 上的文件> | 从本地复制 |
| -moveFromLocal | -moveFromLocal<多个 linux 上的文件> | 从本地移动 |
| -getmerge	 | getmerge<源路径> | 合并到本地 |
| -cat | -cat | 查看文件内容 |
| -text | -text | 查看文件内容 |
| -copyToLocal | -copyToLocal[-ignoreCrc][-crc][hdfs 源路 径][linux 目的路径] | 复制到本地 |
| -moveToLocal | -moveToLocal[-crc] | 移动到本地 |
| -mkdir | -mkdir | 创建空白文件夹 |
| -setrep | -setrep[-R][-w]<副本数><路径> | 修改副本数量 |
| -touchz | -touchz<文件路径> | 创建空白文件 |
| -stat | -stat[format]<路径> | 显示文件统计信息 |
| -tail | -tail[-f]<文件> | 查看文件尾部信息 |
| -chmod | -chmod[-R]<权限模式>[路径] | 修改权限 |
| -chown | -chown[-R][属主][:[属组]] 路径 | 修改属主 |
| -chgrp | -chgrp[-R] 属组名称 路径 | 修改属组 |
| -help | -help[命令选项] | 帮助 |

1.查看`hdfs`子命令的帮助信息
```
# hdfs dfs -help ls
```

2.`ls`查看hdfs文件系统中已经存在的文件
```
# hdfs dfs -ls /
```
- 显示目录下的所有文件可以加 -R 选项

3.`touchz`在hdfs文件系统中创建空文件
```
# hdfs dfs -touchz /user/yinzhengjie/data/1.txt
```

4.`put`将本地的文件上传（复制）到HDFS是dst目录下(在上传的过程中会产生一个以`*.Copying`字样的临时文件)
- 用法： `hdfs dfs -put <localsrc> ... <dst>`
```
# hdfs dfs -put hadoop-2.7.3.tar.gz /
# hdfs dfs -put hadoop-2.7.3.tar.gz /user/hadoop/testEason
# hdfs dfs -put hadoop-2.7.3.tar.gz hadoop-3.0.1.tar.gz /user/hadoop/testEason
# hdfs dfs -put hadoop-2.7.3.tar.gz hdfs://nn.example.com:8020/hadoop/testEason
```

5.`moveFromLocal`类似于put命令，和put命令不同的是，该操作是移动（意思就是localfile将被删除）
- 用法：`hdfs dfs -moveFromLocal <localsrc> <dst>`　
```
# hdfs dfs -moveFromLocal localfile /user/hadoop/testEason
```

6.`copyFromLocal`类似于put命令，和put命令不同的是，拷贝的源地址必须是本地文件地址
- 用法：`hdfs dfs -copyFromLocal <localsrc> URI`
- -f  参数选项：当拷贝的目标文件存在时，进行覆盖

```
[user@hadoop01 ~]$ hdfs dfs -copyFromLocal localfile.txt /user/hadoop/testEason/test.txt
copyFromLocal: `/test.txt': File exists
[user@hadoop01 ~]$ hdfs dfs -copyFromLocal -f localfile.txt /user/hadoop/testEason/test.txt
```

7.`get`在hdfs文件系统中下载文件
- 用法：`hdfs dfs -get [-ignorecrc] [-crc] <src> <localdst>`
- -ignorecrc 参数选项：复制CRC校验失败的文件
- -crc 参数选项：复制文件以及CRC信息
```
# hdfs dfs -get /1.txt
```

8.`copyToLocal` 类似于get指令。和get命令不同的是，拷贝的目的地址必须是本地文件地址
- 用法：`hdfs dfs -copyToLocal [-ignorecrc] [-crc] URI <localdst>`
```
# hdfs dfs -copyToLocal /word /usr/eason/temp/word.txt
```

9.`rm`在hdfs文件系统中删除文件
```
# hdfs dfs -rm /1.txt
```

- 删除文件夹加上`-r`
```
# hdfs dfs -rm -r /testEason/test/path
```

10.`cat | tail`在hdfs文件系统中查看文件内容
```
# hdfs dfs -cat /xrsync.sh
```

```
# hdfs dfs -tail /xrsync.sh
```

11.`mkdir`在hdfs文件系统中创建目录
```
# hdfs dfs -mkdir /shell
```

- `mkdir`创建多级目录加上 –p
```
# hdfs dfs -mkdir /shell/bash/test.txt
```

12.`mv`在hdfs文件系统中修改文件名称（当然你可以可以用来移动文件到目录哟）
```
# hdfs dfs -mv /xcall.sh /call.sh

```

13.`cp` HDFS文件系统中进行的拷贝操作，将文件从源路径复制到目标路径；这个命令允许有多个源路径，此时目标路径必须是一个目录　　

用法：`hdfs dfs -cp [-f] [-p | -p[topax]] URI [URI ...] <dest>`
- -f 参数选项：当文件存在时，进行覆盖
- -p 参数选项：将权限、所属组、时间戳、ACL以及XAttr等也进行拷贝
```
# hdfs dfs -cp /xrsync.sh /shell
```

14.`rmr`递归删除目录
```
# hdfs dfs -rmr /shell
```

15.列出本地文件的内容（默认是hdfs文件系统哟）
```
# hdfs dfs -ls file:///home/yinzhengjie/

```
```
# hdfs dfs -ls hdfs://namenode:8020/
```

16.追加文件内容到hdfs文件系统中的文件

用法：`hdfs dfs -appendToFile <localsrc> ... <dst>`
```
# hdfs dfs -appendToFile xrsync.sh /xcall.sh
```

17.格式化名称节点
```
# hdfs namenode
```

18.`createSnapshot`创建快照（关于快照更详细的用法请参考：https://www.cnblogs.com/yinzhengjie/p/9099529.html）
```
# hdfs dfs -createSnapshot /data firstSnapshot
```

19.`renameSnapshot`重命名快照
```
# hdfs dfs -renameSnapshot /data firstSnapshot newSnapshot
```

20.`deleteSnapshot`删除快照
```
# hdfs dfs -deleteSnapshot /data newSnapshot
```

21.`text`查看hadoop的Sequencefile文件内容
```
# hdfs dfs -text file:///home/yinzhengjie/data/seq
```

22.`df`使用df命令查看可用空间
- 用法：`hdfs dfs -df [-h] URI [URI ...]`
```
# hdfs dfs -df /
# hdfs dfs -df -h /
```

23.降低复制因子
```
# hdfs dfs -setrep -w 2 /user/yinzhengjie/data/1.txt
```

21.`du`使用du命令查看已用空间
- 用法：`hdfs dfs -du URI [URI …]`
- -s 参数选项：显示当前目录或者文件夹的大小
```
# hdfs dfs -du /user/yinzhengjie/data/day001
# hdfs dfs -du -h /user/yinzhengjie/data/day001
# hdfs dfs -du -s -h /user/yinzhengjie/data/day001
```

22.`chmod`改变文件访问权限，参考Linux命令
- 用法：`hdfs dfs -chmod [-R] <MODE[,MODE]... | OCTALMODE> URI [URI ...]`
- -R 参数选项：将使改变在目录结构下递归进行；命令的使用者必须是文件的所有者或者超级用户；


23.`checksum`查看校验码信息
- 用法： hdfs dfs -checksum URI
```
# hdfs dfs -checksum hdfs://nn1.example.com/file1
# hdfs dfs -checksum file:///etc/hosts
```

24.`chgrp`改变文件所属的组(Change group association of files.)
- 用法： hdfs dfs -chgrp [-R] GROUP URI [URI ...]
- -R 参数选项：将使改变在目录结构下递归进行；命令的使用者必须是文件的所有者或者超级用户
```
# hdfs dfs -chgrp -R test /a
```

25.`chown`改变文件的所有者　　
- 用法：hdfs dfs -chown [-R] [OWNER][:[GROUP]] URI [URI]
- -R 参数选项：将使改变在目录结构下递归进行；命令的使用者必须是超级用户
```
# hdfs dfs -chown -R test /a
```

26.`expunge`从垃圾桶目录永久删除超过保留阈值的检查点中的文件，并创建新检查点　
- 用法：hdfs dfs -expunge


27.`find`查找满足表达式的文件和文件夹，没有配置path的话，默认的就是全部目录/；如果表达式没有配置，则默认为 -print

用法: `hdfs dfs -find <path> ... <expression> ...`
- -name pattern 参数选项：所要查找文件的文件名
- -iname pattern 参数选项：所要查找的文件名，不区分大小写
- -print  参数选项：打印
- -print0 参数选项：打印在一行，如下图所示

```
# hdfs dfs -find /usr/hadoop/testEason -name test -print
```

28.`getmerge`是将HDFS上一个目录中所有的文件合并到一起输出到一个本地文件上
- 用法：`hdfs dfs -getmerge [-nl] <src> <localdst>`
```
# hdfs dfs -getmerge -nl /src /opt/output.txt
# hdfs dfs -getmerge -nl /src/file1.txt /src/file2.txt /output.txt
```

# 三.getconf （重要）

```
hdfs getconf -namenodes          #获取namenode节点
hdfs getconf -secondaryNameNodes #获取secondaryNameNodes节点
hdfs getconf -backupNodes        #获取群集中备份节点的列表
hdfs getconf -includeFile        #获取定义能够加入群集的数据节点的包含文件路径
hdfs getconf -excludeFile        #获取定义须要停用的数据节点的排除文件路径
hdfs getconf -nnRpcAddresses     #获取namenode rpc地址
hdfs getconf -confKey [key]      #从配置中获取特定密钥 ，能够用来返回hadoop的配置信息的具体值
```

1>.获取NameNode的节点名称(可能包含多个)
```
# hdfs getconf -namenodes
```

2>.获取hdfs最小块信息（默认大小为1M,即1048576字节，如果想要修改的话必须为512的倍数，因为HDFS底层传输数据是每512字节进行校验）
```
# hdfs getconf -confKey dfs.namenode.fs-limits.min-block-size
```

3>.查找hdfs的NameNode的RPC地址
```
# hdfs getconf -nnRpcAddresses
```

# 四.dfsadmin （重要）

```
hdfs dfsadmin [GENERIC_OPTIONS]
          [-report [-live] [-dead] [-decommissioning]]   #报告基本的文件系统信息和统计信息，包括测量全部dns上的复制、校验和、快照等使用的原始空间。
          [-safemode enter | leave | get | wait | forceExit] #安全模式维护命令
           #安全模式在namenode启动时自动进入，当配置的最小块百分比知足最小复制条件时自动离开安全模式。若是namenode检测到任何异常，
           #则它将在安全模式下逗留，直到该问题获得解决。若是异常是故意操做的结果，那么管理员可使用-safemode forceExit退出安全模式
          [-saveNamespace] #将当前命名空间保存到存储目录并重置编辑日志。须要安全模式
          [-rollEdits] #在活动的namenode上滚动编辑日志
          [-restoreFailedStorage true |false |check] #此选项将打开或者关闭自动尝试还原失败的存储副本。若是失败的存储再次可用，
          #系统将在检查点期间尝试还原编辑和fsimage。“check”选项将返回当前设置
          [-refreshNodes] #从新读取主机并排除文件，以更新容许链接到namenode的数据节点集，以及应解除或从新启用的数据节点集
          [-setQuota <quota> <dirname>...<dirname>]
          [-clrQuota <dirname>...<dirname>]
          [-setSpaceQuota <quota> [-storageType <storagetype>] <dirname>...<dirname>]
          [-clrSpaceQuota [-storageType <storagetype>] <dirname>...<dirname>]
          [-finalizeUpgrade] #完成hdfs的升级。datanodes删除它们之前版本的工做目录，而后namenode执行相同的操做。这就完成了升级过程
          [-rollingUpgrade [<query> |<prepare> |<finalize>]]
          [-metasave filename] #将namenode的主数据结构保存到hadoop.log.dir属性指定的目录中的filename。若是文件名存在，它将被覆盖。
          #该文件包含带namenode的datanodes心跳，等待复制的块，当前正在复制的块，等待删除的块
          [-refreshServiceAcl] #从新加载服务级别受权策略文件
          [-refreshUserToGroupsMappings] #刷新用户到组的映射
          [-refreshSuperUserGroupsConfiguration] #刷新超级用户代理组映射
          [-refreshCallQueue] #从配置从新加载调用队列
          [-refresh <host:ipc_port> <key> [arg1..argn]] #触发由<host:ipc port>上的<key>指定的资源的运行时刷新。以后的全部其余参数都将发送到主机
          [-reconfig <datanode |...> <host:ipc_port> <start |status>] #开始从新配置或获取正在进行的从新配置的状态。第二个参数指定节点类型。目前，只支持从新加载datanode的配置
          [-printTopology] #打印由namenode报告的机架及其节点的树
          [-refreshNamenodes datanodehost:port] #对于给定的数据节点，从新加载配置文件，中止为已删除的块池提供服务，并开始为新的块池提供服务
          [-deleteBlockPool datanode-host:port blockpoolId [force]] #若是传递了force，则将删除给定数据节点上给定block pool id的块池目录及其内容，不然仅当该目录为空时才删除该目录。
          #若是datanode仍在为块池提供服务，则该命令将失败
          [-setBalancerBandwidth <bandwidth in bytes per second>] #更改HDFS块平衡期间每一个数据节点使用的网络带宽。<bandwidth>是每一个数据节点每秒将使用的最大字节数。
          #此值重写dfs.balance.bandwidthpersec参数。注意：新值在datanode上不是持久的
          [-getBalancerBandwidth <datanode_host:ipc_port>] #获取给定数据节点的网络带宽（字节/秒）。这是数据节点在hdfs块平衡期间使用的最大网络带宽
          [-allowSnapshot <snapshotDir>] #设置快照目录
          [-disallowSnapshot <snapshotDir>] #禁止快照
          [-fetchImage <local directory>] #从namenode下载最新的fsimage并将其保存在指定的本地目录中
          [-shutdownDatanode <datanode_host:ipc_port> [upgrade]] #提交给定数据节点的关闭请求
          [-getDatanodeInfo <datanode_host:ipc_port>] #获取有关给定数据节点的信息
          [-evictWriters <datanode_host:ipc_port>]  #使datanode收回正在写入块的全部客户端。若是因为编写速度慢而挂起退役，这将很是有用
          [-triggerBlockReport [-incremental] <datanode_host:ipc_port>] #触发给定数据节点的块报告。若是指定了“增量”，则为“增量”，不然为完整的块报告
          [-help [cmd]]
```

| 命令选项 | 描述 |
|---------|-------|
| -report | 报告文件系统的基本信息和统计信息。 |
| -safemode `enter` `leave` `get` `wait` | 安全模式维护命令。安全模式是Namenode的一个状态，这种状态下，Namenode 1. 不接受对名字空间的更改(只读) 2. 不复制或删除块 Namenode会在启动时自动进入安全模式，当配置的块最小百分比数满足最小的副本数条件时，会自动离开安全模式。安全模式可以手动进入，但是这样的话也必须手动关闭安全模式。 |
| -refreshNodes | 重新读取hosts和exclude文件，更新允许连到Namenode的或那些需要退出或入编的Datanode的集合。| 
| -finalizeUpgrade | 终结HDFS的升级操作。Datanode删除前一个版本的工作目录，之后Namenode也这样做。这个操作完结整个升级过程。| 
| -upgradeProgress `status` `details` `force` | 请求当前系统的升级状态，状态的细节，或者强制升级操作进行。| 
| -metasave filename | 保存Namenode的主要数据结构到hadoop.log.dir属性指定的目录下的`<filename>`文件。对于下面的每一项，`<filename>`中都会一行内容与之对应 1. Namenode收到的Datanode的心跳信号 2. 等待被复制的块 3. 正在被复制的块 4. 等待被删除的块 |
| -setQuota `<quota>` `<dirname>`...`<dirname>` | 为每个目录 `<dirname>`设定配额`<quota>`。目录配额是一个长整型整数，强制限定了目录树下的名字个数。命令会在这个目录上工作良好，以下情况会报错：1. N不是一个正整数，或者2. 用户不是管理员，或者3. 这个目录不存在或是文件，或者4. 目录会马上超出新设定的配额。 |
| -clrQuota `<dirname>`...`<dirname>` | 为每一个目录`<dirname>`清除配额设定。 命令会在这个目录上工作良好，以下情况会报错：1. 这个目录不存在或是文件，或者2. 用户不是管理员。如果目录原来没有配额不会报错。 |
| -help [cmd] | 显示给定命令的帮助信息，如果没有给定命令，则显示所有命令的帮助信息。 |

1>.查看hdfs dfsadmin的帮助信息
```
# hdfs dfsadmin
```

2>.查看指定命令的帮助信息
```
# hdfs dfsadmin -help rollEdits
```

3>.手动滚动日志（关于日志滚动更详细的用法请参考：https://www.cnblogs.com/yinzhengjie/p/9098092.html）
```
# hdfs dfsadmin -rollEdits
```

4.`safemode`安全模式命令
-安全模式是NameNode的一种状态，在这种状态下，NameNode不接受对名字空间的更改（只读），不复制或删除块；NameNode在启动时自动进入安全模式，当配置块的最小百分数满足最小副本数的条件时，会自动离开安全模式
- enter 参数选项：enter是进入
- leave 参数选项：leave是离开

```
# hdfs dfsadmin -safemode get     #返回安全模式是否开启的信息，返回 Safe mode is OFF/OPEN
# hdfs dfsadmin -safemode enter   #进入安全模工
# hdfs dfsadmin -safemode leave   # 强制 NameNode 离开安全模式
# hdfs dfsadmin -safemode wait    #等待，一直到安全模式结束
```

8>.查看文件系统的基本信息和统计信息
```
# hdfs dfsadmin -help report
# hdfs dfsadmin -report
Configured Capacity: 16493959577600 (15.00 TB)　　　　　　　　　 　#此集群中HDFS的已配置容量
Present Capacity: 16493959577600 (15.00 TB)　　　　　　　　　　　　#此集群中现有的容量
DFS Remaining: 16493167906816 (15.00 TB)　　　　　　　　　　　　　  #此集群中剩余容量
DFS Used: 791670784 (755.00 MB)　　　　　　　　　　　　　  　　　　#HDFS使用的存储统计信息
DFS Used%: 0.00%　　　　　　　　　　　　　　　　　　　　　　　　　 　#同上，只不过以百分比显示而已
Under replicated blocks: 16　　　　　　　　　　　　　　　　　　　　 #显示是否由任何未充分复制，损坏或丢失的块
Blocks with corrupt replicas: 0　　　　　　　　　　　　　　　　　　 #具有损坏副本的块
Missing blocks: 0　　　　　　　　　　　　　　　　　　　　　　　　　　 #丢失的块
Missing blocks (with replication factor 1): 0　　　　　　　　　　  #丢失的块(复制因子为1)
Pending deletion blocks: 0　　　　　　　　　　　　　　　　　　　　　 #挂起的删除块。

-------------------------------------------------
Live datanodes (2):　　　　　　　　　　　　　　　　　            　#显示集群中由多少个DataNode是活动的并可用

Name: 172.200.6.102:50010 (hadoop102.yinzhengjie.com)　　　　　　 #DN节点的IP地址及端口号
Hostname: hadoop102.yinzhengjie.com　　　　　　　　　　　　　　　　#DN节点的主机名
Rack: /rack001　　　　　　　　　　　　　　　　　　　　　　　　　　　#该DN节点的机架编号
Decommission Status : Normal　　　　　　　　　　　　　　　　　　　　#DataNode的退役状态
Configured Capacity: 8246979788800 (7.50 TB)　　　　　　　　　　　#DN节点的配置容量
DFS Used: 395841536 (377.50 MB)　　　　　　　　　　　　　　　　　　#DN节点的使用容量
Non DFS Used: 0 (0 B)　　　　　　　　　　　　　　　　　　　　　　　　#未使用的容量
DFS Remaining: 8246583947264 (7.50 TB)　　　　　　　　　　　　　　　#剩余的容量
DFS Used%: 0.00%　　　　　　　　　　　　　　　　　　　　　　　　　　　#DN节点的使用百分比
DFS Remaining%: 100.00%　　　　　　　　　　　　　　　　　　　　　　　#DN节点的剩余百分比　　
Configured Cache Capacity: 32000000 (30.52 MB)　　　　　　　　　　#缓存使用情况
Cache Used: 319488 (312 KB)
Cache Remaining: 31680512 (30.21 MB)
Cache Used%: 1.00%
Cache Remaining%: 99.00%
Xceivers: 2
Last contact: Mon Aug 17 05:08:10 CST 2020
Last Block Report: Mon Aug 17 04:18:40 CST 2020


Name: 172.200.6.103:50010 (hadoop103.yinzhengjie.com)
Hostname: hadoop103.yinzhengjie.com
Rack: /rack002
Decommission Status : Normal
Configured Capacity: 8246979788800 (7.50 TB)
DFS Used: 395829248 (377.49 MB)
Non DFS Used: 0 (0 B)
DFS Remaining: 8246583959552 (7.50 TB)
DFS Used%: 0.00%
DFS Remaining%: 100.00%
Configured Cache Capacity: 32000000 (30.52 MB)
Cache Used: 0 (0 B)
Cache Remaining: 32000000 (30.52 MB)
Cache Used%: 0.00%
Cache Remaining%: 100.00%
Xceivers: 2
Last contact: Mon Aug 17 05:08:10 CST 2020
Last Block Report: Mon Aug 17 01:43:05 CST 2020


Dead datanodes (1):

Name: 172.200.6.104:50010 (hadoop104.yinzhengjie.com)
Hostname: hadoop104.yinzhengjie.com
Rack: /rack002
Decommission Status : Normal
Configured Capacity: 8246979788800 (7.50 TB)
DFS Used: 395776000 (377.44 MB)
Non DFS Used: 0 (0 B)
DFS Remaining: 8246584012800 (7.50 TB)
DFS Used%: 0.00%
DFS Remaining%: 100.00%
Configured Cache Capacity: 0 (0 B)
Cache Used: 0 (0 B)
Cache Remaining: 0 (0 B)
Cache Used%: 100.00%
Cache Remaining%: 0.00%
Xceivers: 0
Last contact: Mon Aug 17 04:02:57 CST 2020
Last Block Report: Mon Aug 17 01:43:05 CST 2020
```

9>.目录配额（计算目录下的所有文件的总个数，如果为1，表示目录下不能放文件，即空目录！）
```
# hdfs dfsadmin -setQuota 5 /data
```

10>.空间配额（计算目录下所有文件的总大小，包括副本数，因此空间配最小的值可以得到一个等式："空间配最小的值  >= 需要上传文件的实际大小 * 副本数"）
```
# hdfs dfsadmin -setSpaceQuota 134217745 /data
```

11>.清空配额管理
```
# hdfs dfsadmin -clrSpaceQuota /data
```

12>.对某个目录启用快照功能（快照功能默认为禁用状态）
```
# hdfs dfsadmin -allowSnapShot /data
```

13>.对某个目录禁用快照功能
```
# hdfs dfsadmin -disallowSnapShot /data
```

14>.使用dfsadmin -metasave命令提供的信息比dfsadmin -report命令提供的更多。使用此命令可以获取各种的块相关的信息（比如：块总数，正在等待复制的块，当前正在复制的块） 
```
hdfs dfsadmin -metasave /hbase
```
- 我们获取某个目录的详细信息，允许成功后会有以下输出，并在“/var/log/hadoop-hdfs/”目录中创建一个文件，该文件名称和咱们这里输入的path名称一致，即“hbase”

15>.-refreshNodes
- 重新读取hosts和exclude文件，使新的节点或需要退出集群的节点能够被NameNode重新识别。这个命令在新增节点或注销节点时用到。
```
hdfs dfsadmin -refreshNodes
```

16.finalizeUpgrade
- 终结HDFS的升级操作。DataNode删除前一个版本的工作目录，之后NameNode也这样做。

17.upgradeProgress
- status| details | force：请求当前系统的升级状态 | 升级状态的细节| 强制升级操作



# 五.fsck （重要）

```
hdfs fsck <path>
          [-list-corruptfileblocks |
          [-move | -delete | -openforwrite]
          [-files [-blocks [-locations | -racks | -replicaDetails]]]
          [-includeSnapshots]
          [-storagepolicies] [-blockId <blk_Id>]

-delete    删除损坏的文件
-files    打印正在检查的文件.
-files -blocks    打印块报告
-files -blocks -locations    Print out locations for every block.
-files -blocks -racks    打印每一个块的位置
-files -blocks -replicaDetails    打印出每一个副本的详细信息.
-includeSnapshots    若是给定路径指示SnapshotTable目录或其下有SnapshotTable目录，则包括快照数据
-list-corruptfileblocks    打印出所属丢失块和文件的列表.
-move    将损坏的文件移动到/lost+found.
-openforwrite    打印为写入而打开的文件.
-storagepolicies    打印块的存储策略摘要.
-blockId    打印出有关块的信息.
```

1>.查看hdfs文件系统信息
```
# hdfs fsck / 
Connecting to namenode via http://node101.yinzhengjie.org.cn:50070/fsck?ugi=hdfs&path=%2F
FSCK started by hdfs (auth:SIMPLE) from /10.1.2.101 for path / at Thu May 23 14:32:41 CST 2019
.......................................
/user/yinzhengjie/data/day001/test_output/_partition.lst:  Under replicated BP-1230584423-10.1.2.101-1558513980919:blk_1073742006_1182. Target Replicas is 10 but found 4 live replica(s), 0 decommissioned replica(s), 0 decommissioning replica(s).
..................Status: HEALTHY　　　　　　#代表这次HDFS上block检查结果
 Total size:    2001318792 B (Total open files size: 498 B)　　　　　　　#代表根目录下文件总大小
 Total dirs:    189　　　　　　　　　　　　　　　　　　　　　　　　　　 　#代表检测的目录下总共有多少目录
 Total files:   57　　　　　　　　　　　　　　　　　　　　　　　　　　 　 #代表检测的目录下总共有多少文件
 Total symlinks:                0 (Files currently being written: 7)　　 #代表检测的目录下有多少个符号链接
 Total blocks (validated):      58 (avg. block size 34505496 B) (Total open file blocks (not validated): 6)　　　　#代表检测的目录下有多少的block是有效的。
 Minimally replicated blocks:   58 (100.0 %)　　　　　　　　             #代表拷贝的最小block块数。
 Over-replicated blocks:        0 (0.0 %)　　　　　　　　　　            #代表当前副本数大于指定副本数的block数量。
 Under-replicated blocks:       1 (1.7241379 %)　　　　　　              #代表当前副本书小于指定副本数的block数量。
 Mis-replicated blocks:         0 (0.0 %)　　　　　　　　　            　#代表丢失的block块数量。
 Default replication factor:    3　　　　　　　　　　　　　　             #代表默认的副本数（自身一份，默认拷贝两份）。
 Average block replication:     2.3965516　　　　　　　　　            　#代表块的平均复制数，即平均备份的数目，Default replication factor 的值为3，因此需要备份在备份2个，这里的平均备份数等于2是理想值，如果大于2说明可能有多余的副本数存在。
 Corrupt blocks:                0　　　　　　　　　　　　　　           　#代表坏的块数，这个指不为0，说明当前集群有不可恢复的块，即数据丢失啦！
 Missing replicas:              6 (4.137931 %)　　　　　　             　#代表丢失的副本数　
 Number of data-nodes:          4　　　　　　　　　　　　　　            #代表有多好个DN节点
 Number of racks:               1　　　　　　　　　　　　　　            #代表有多少个机架
FSCK ended at Thu May 23 14:32:41 CST 2019 in 7 milliseconds
 
 
The filesystem under path '/' is HEALTHY
```

2>.fsck指令显示HDFS块信息
```
hdfs fsck / -files -blocks
```

# 六.oiv

1>.查看hdfs oiv的帮助信息
```
# hdfs oiv
Usage: bin/hdfs oiv [OPTIONS] -i INPUTFILE -o OUTPUTFILEOffline Image Viewer
View a Hadoop fsimage INPUTFILE using the specified PROCESSOR,saving the results in OUTPUTFILE.
 
The oiv utility will attempt to parse correctly formed image filesand will abort fail with mal-formed image files.
 
The tool works offline and does not require a running cluster inorder to process an image file.
 
The following image processors are available:
  * XML: This processor creates an XML document with all elements of the fsimage enumerated, suitable for further analysis by XML tools.
  * FileDistribution: This processor analyzes the file size distribution in the image.
    -maxSize specifies the range [0, maxSize] of file sizes to be analyzed (128GB by default).
    -step defines the granularity of the distribution. (2MB by default)
  * Web: Run a viewer to expose read-only WebHDFS API.
    -addr specifies the address to listen. (localhost:5978 by default)
  * Delimited (experimental): Generate a text file with all of the elements common to both inodes and inodes-under-construction, separated by a delimiter. The default delimiter is \t, though this may be changed via the -delimiter argument.
 
Required command line arguments:
-i,--inputFile <arg>   FSImage file to process.
 
Optional command line arguments:
-o,--outputFile <arg>  Name of output file. If the specified file exists, it will be overwritten. (output to stdout by default)
-p,--processor <arg>   Select which type of processor to apply against image file. (XML|FileDistribution|Web|Delimited) (Web by default)
-delimiter <arg>       Delimiting string to use with Delimited processor.  
-t,--temp <arg>        Use temporary dir to cache intermediate result to generate Delimited outputs. If not set, Delimited processor constructs the namespace in memory before outputting text.
-h,--help              Display usage information and exit
```

2>.使用oiv命令查询hadoop镜像文件
```
# hdfs oiv -i ./hadoop/dfs/name/current/fsimage_0000000000000000767 -o yinzhengjie.xml -p XML
```

# 七.oev

1>.查看hdfs oev的帮助信息
```
# hdfs oev
Usage: bin/hdfs oev [OPTIONS] -i INPUT_FILE -o OUTPUT_FILE Offline edits viewer
Parse a Hadoop edits log file INPUT_FILE and save results in OUTPUT_FILE.
Required command line arguments:
-i,--inputFile <arg>   edits file to process, xml (case insensitive) extension means XML format,any other filename means binary format
-o,--outputFile <arg>  Name of output file. If the specified file exists, it will be overwritten,format of the file is determined by -p option
 
Optional command line arguments:
-p,--processor <arg>   Select which type of processor to apply against image file, currently supported processors are: binary (native binary format that Hadoop uses), xml (default, XML format), stats (prints statistics about edits file)
-h,--help              Display usage information and exit
-f,--fix-txids         Renumber the transaction IDs in the input,so that there are no gaps or invalid transaction IDs.
-r,--recover           When reading binary edit logs, use recovery mode.  This will give you the chance to skip corrupt parts of the edit log.
-v,--verbose           More verbose output, prints the input and output filenames, for processors that write to a file, also output to screen. On large image files this will dramatically increase processing time (default is false).
 
 
Generic options supported are
-conf <configuration file>     specify an application configuration file
-D <property=value>            use value for given property
-fs <local|namenode:port>      specify a namenode
-jt <local|resourcemanager:port>    specify a ResourceManager
-files <comma separated list of files>    specify comma separated files to be copied to the map reduce cluster
-libjars <comma separated list of jars>    specify comma separated jar files to include in the classpath.
-archives <comma separated list of archives>    specify comma separated archives to be unarchived on the compute machines.
 
The general command line syntax is
bin/hadoop command [genericOptions] [commandOptions]
```

2>.使用oev命令查询hadoop的编辑日志文件
```
hdfs oev -i ./hadoop/dfs/name/current/edits_0000000000000001007-0000000000000001008 -o edits.xml -p XML
```

# groups
```
groups #返回用户的所属组
Usage: hdfs groups [username ...]
```

# lsSnapshottableDir
```
lsSnapshottableDir #查看快照目录
Usage: hdfs lsSnapshottableDir [-help]
```

# jmxget 
```
jmxget  #从特定服务获取jmx信息
Usage: hdfs jmxget [-localVM ConnectorURL | -port port | -server mbeanserver | -service service]
```

# snapshotDiff
```
snapshotDiff  #对比快照信息的不一样
Usage: hdfs snapshotDiff <path> <fromSnapshot> <toSnapshot>
详情见：http://hadoop.apache.org/docs/r2.8.0/hadoop-project-dist/hadoop-hdfs/HdfsSnapshots.html#Get_Snapshots_Difference_Report
```

# balancer（重要）
```
balancer
 hdfs balancer
          [-threshold <threshold>]
          [-policy <policy>]
          [-exclude [-f <hosts-file> | <comma-separated list of hosts>]]
          [-include [-f <hosts-file> | <comma-separated list of hosts>]]
          [-source [-f <hosts-file> | <comma-separated list of hosts>]]
          [-blockpools <comma-separated list of blockpool ids>]
          [-idleiterations <idleiterations>]
-policy <policy>    datanode (default): 若是每一个数据节点都是平衡的，则群集是平衡的.
blockpool: 若是每一个数据节点中的每一个块池都是平衡的，则群集是平衡的.
-threshold <threshold>    磁盘容量的百分比。这将覆盖默认阈值
-exclude -f <hosts-file> | <comma-separated list of hosts>    排除平衡器正在平衡的指定数据节点
-include -f <hosts-file> | <comma-separated list of hosts>    仅包含要由平衡器平衡的指定数据节点
-source -f <hosts-file> | <comma-separated list of hosts>    仅选取指定的数据节点做为源节点。
-blockpools <comma-separated list of blockpool ids>    平衡器将仅在此列表中包含的块池上运行.
-idleiterations <iterations>    退出前的最大空闲迭代次数。这将覆盖默认的空闲操做（5次）
```

# cacheadmin
```
cacheadmin
Usage: hdfs cacheadmin -addDirective -path <path> -pool <pool-name> [-force] [-replication <replication>] [-ttl <time-to-live>]
hdfs crypto -createZone -keyName <keyName> -path <path>
  hdfs crypto -listZones
  hdfs crypto -provisionTrash -path <path>
  hdfs crypto -help <command-name>
```
- 详情见：http://hadoop.apache.org/docs/r2.8.0/hadoop-project-dist/hadoop-hdfs/CentralizedCacheManagement.html

# datanode
```
datanode #运行datanode
Usage: hdfs datanode [-regular | -rollback | -rollingupgrade rollback]
-regular    正常启动(default).
-rollback   将datanode回滚到之前的版本。这应该在中止datanode并分发旧的hadoop版本以后使用
-rollingupgrade rollback    回滚滚动升级操做
```

# haadmin（重要）
```
hdfs haadmin -checkHealth <serviceId>  #检查给定namenode的运行情况
hdfs haadmin -failover [--forcefence] [--forceactive] <serviceId> <serviceId> #在两个namenodes之间启动故障转移
hdfs haadmin -getServiceState <serviceId> #肯定给定的namenode是活动的仍是备用的
hdfs haadmin -help <command>
hdfs haadmin -transitionToActive <serviceId> [--forceactive] #将给定namenode的状态转换为active
hdfs haadmin -transitionToStandby <serviceId> #将给定namenode的状态转换为standby
```
- 详情见：http://hadoop.apache.org/docs/r2.8.0/hadoop-project-dist/hadoop-hdfs/HDFSHighAvailabilityWithNFS.html

# journalnode
```
journalnode #为经过QJM实现的高可用hdfs启动journalnode
Usage: hdfs journalnode
```

# mover　　
```
Usage: hdfs mover [-p <files/dirs> | -f <local file name>]
-f 指定包含要迁移的hdfs文件/目录列表的本地文件
-p 指定要迁移的hdfs文件/目录的空间分隔列表
```
- 详情见：http://hadoop.apache.org/docs/r2.8.0/hadoop-project-dist/hadoop-hdfs/ArchivalStorage.html

# namenode
```
namenode
hdfs namenode [-backup] |  #开始备份节点
         [-checkpoint] | #检查点开始节点
         [-format [-clusterid cid ] [-force] [-nonInteractive] ] |  #格式化指定的NameNode。 它启动NameNode，
         #对其进行格式化而后将其关闭。 若是名称目录存在，则为-force选项格式。 若是名称目录存在，则-nonInteractive选项将停止，除非指定了-force选项
         [-upgrade [-clusterid cid] [-renameReserved<k-v pairs>] ] | #在分发新的Hadoop版本后，应该使用升级选项启动Namenode
         [-upgradeOnly [-clusterid cid] [-renameReserved<k-v pairs>] ] | #升级指定的NameNode而后关闭它
         [-rollback] | #将NameNode回滚到之前的版本。 应在中止群集并分发旧Hadoop版本后使用此方法
         [-rollingUpgrade <rollback |started> ] |#滚动升级 详情见：http://hadoop.apache.org/docs/r2.8.0/hadoop-project-dist/hadoop-hdfs/HdfsRollingUpgrade.html
         [-finalize] |  #再也不支持。使用dfsadmin -finalizeUpgrade替换
         [-importCheckpoint] | #从检查点目录加载image并将其保存到当前目录中。 从属性dfs.namenode.checkpoint.dir读取检查点目录
         [-initializeSharedEdits] | #格式化新的共享编辑目录并复制足够的编辑日志段，以便备用NameNode能够启动
         [-bootstrapStandby [-force] [-nonInteractive] [-skipSharedEditsCheck] ] | #容许经过从活动NameNode复制最新的命名空间快照来引导备用NameNode的存储目录
         [-recover [-force] ] | #在损坏的文件系统上恢复丢失的元数据
         [-metadataVersion ] #验证配置的目录是否存在，而后打印软件和映像的元数据版本
```

# secondarynamenode
```
Usage: hdfs secondarynamenode [-checkpoint [force]] | [-format] | [-geteditsize]
-checkpoint [force]    若是EditLog size> = fs.checkpoint.size，则检查SecondaryNameNode。 若是使用force，则检查点与EditLog大小无关
-format    启动期间格式化本地存储
-geteditsize    打印NameNode上未取消选中的事务的数量
```

# storagepolicies
```
storagepolicies #列出全部存储策略
Usage: hdfs storagepolicies
详情见：http://hadoop.apache.org/docs/r2.8.0/hadoop-project-dist/hadoop-hdfs/ArchivalStorage.html
```

# zkfc
```
Usage: hdfs zkfc [-formatZK [-force] [-nonInteractive]]
-formatZK    格式化Zookeeper实例
-force: 若是znode存在，则格式化znode。 
-nonInteractive：若是znode存在，则格式化znode停止，除非指定了-force选项
-h    Display help
```

# verifyMeta 
```
verifyMeta  #验证HDFS元数据和块文件。 若是指定了块文件，咱们将验证元数据文件中的校验和是否与块文件匹配
Usage: hdfs debug verifyMeta -meta <metadata-file> [-block <block-file>]
-block block-file    用于指定数据节点的本地文件系统上的块文件的绝对路径
-meta metadata-file    数据节点的本地文件系统上的元数据文件的绝对路径
```

# computeMeta
```
computeMeta #从块文件计算HDFS元数据。 若是指定了块文件，咱们将从块文件计算校验和，并将其保存到指定的输出元数据文件中
Usage: hdfs debug computeMeta -block <block-file> -out <output-metadata-file>
-block block-file    数据节点的本地文件系统上的块文件的绝对路径
-out output-metadata-file    输出元数据文件的绝对路径，用于存储块文件的校验和计算结果。
```

# recoverLease
```
recoverLease #恢复指定路径上的租约。 该路径必须驻留在HDFS文件系统上。 默认重试次数为1
Usage: hdfs debug recoverLease -path <path> [-retries <num-retries>]
[-path path]    要恢复租约的HDFS路径
[-retries num-retries]    客户端重试调用recoverLease的次数。 默认重试次数为1
```

# 八.hadoop命令介绍

- 在上面我们以及提到过，"hadoop fs"其实就等价于“hdfs dfs”,但是hadoop有些命令是hdfs 命令所不支持的，我们举几个例子：

1>.检查压缩库本地安装情况
```
# hadoop checknative
```

2>.格式化名称节点
```
# hadoop namenode -format
```

3>.执行自定义jar包
```
# hadoop jar YinzhengjieMapReduce-1.0-SNAPSHOT.jar cn.org.yinzhengjie.mapreduce.wordcount.WordCountApp /world.txt /out
```

参考：
- 关于“Hadoop fs”更多相关命令请参考我的笔记：https://www.cnblogs.com/yinzhengjie/p/9906360.html
- http://www.javashuo.com/article/p-konunspd-dy.html
