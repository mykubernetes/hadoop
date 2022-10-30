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

# 二.hdfs与dfs结合使用的案例

- 其实`hdfs`和`dfs`结合使用的话实际上调用的是`hadoop fs`这个命令。
```
# hdfs dfs
```

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
- 用法：`hdfs dfs -copyFromLocal <localsrc> URI
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

29.`test`判断文件信息
- 用法：`hadoop fs -test -[defsz] URI`　　　　
- -d 参数选项：如果路径是一个目录，返回0
- -e 参数选项：如果路径已经存在，返回0
- -f 参数选项：如果路径是一个文件，返回0
- -s 参数选项：如果路径不是空，返回0
- -z 参数选项：如果文件长度为0，返回0

URI 参数选项：资源地址，可以是文件也可以是目录。
```
# hdfs dfs <em id="__mceDel">-test -e filename</em>
```

# 三.hdfs与getconf结合使用的案例

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

# 四.hdfs与dfsadmin结合使用的案例

| 命令选项 | 描述 |
|---------|-------|
| -report | 报告文件系统的基本信息和统计信息。 |
| -safemode `enter` `leave` `get` `wait` | 安全模式维护命令。安全模式是Namenode的一个状态，这种状态下，Namenode 1. 不接受对名字空间的更改(只读) 2. 不复制或删除块 Namenode会在启动时自动进入安全模式，当配置的块最小百分比数满足最小的副本数条件时，会自动离开安全模式。安全模式可以手动进入，但是这样的话也必须手动关闭安全模式。 |
| -refreshNodes | 重新读取hosts和exclude文件，更新允许连到Namenode的或那些需要退出或入编的Datanode的集合。| 
| -finalizeUpgrade | 终结HDFS的升级操作。Datanode删除前一个版本的工作目录，之后Namenode也这样做。这个操作完结整个升级过程。| 
| -upgradeProgress `status` `details` `force` | 请求当前系统的升级状态，状态的细节，或者强制升级操作进行。| 
| -metasave filename | 保存Namenode的主要数据结构到hadoop.log.dir属性指定的目录下的`<filename>`文件。对于下面的每一项，`<filename>`中都会一行内容与之对应 1. Namenode收到的Datanode的心跳信号 2. 等待被复制的块 3. 正在被复制的块 4. 等待被删除的块 |
| -setQuota `<quota>` `<dirname>`...`<dirname>` | 为每个目录 `<dirname>`设定配额`<quota>`。目录配额是一个长整型整数，强制限定了目录树下的名字个数。命令会在这个目录上工作良好，以下情况会报错：1. N不是一个正整数，或者2. 用户不是管理员，或者3. 这个目录不存在或是文件，或者4. 目录会马上超出新设定的配额。 |
| -clrQuota `<dirname>`...`<dirname>` | 为每一个目录<dirname>清除配额设定。 命令会在这个目录上工作良好，以下情况会报错：1. 这个目录不存在或是文件，或者2. 用户不是管理员。如果目录原来没有配额不会报错。 |
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

14>.获取某个namenode的节点状态
```
# hdfs haadmin -getServiceState namenode23　　　#注意，这个namenode23是在hdfs-site.xml配置文件中指定的
```

15>.使用dfsadmin -metasave命令提供的信息比dfsadmin -report命令提供的更多。使用此命令可以获取各种的块相关的信息（比如：块总数，正在等待复制的块，当前正在复制的块） 
```
hdfs dfsadmin -metasave /hbase
```
- 我们获取某个目录的详细信息，允许成功后会有以下输出，并在“/var/log/hadoop-hdfs/”目录中创建一个文件，该文件名称和咱们这里输入的path名称一致，即“hbase”

# 五.hdfs与fsck结合使用的案例

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

# 六.hdfs与oiv结合我使用案例

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

# 七.hdfs与oev结合我使用案例

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
