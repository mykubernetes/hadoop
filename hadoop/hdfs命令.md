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

- 其实hdfs 和dfs 结合使用的话实际上调用的是hadoop fs这个命令。
```
# hdfs dfs
```

1>.查看hdfs子命令的帮助信息
```
# hdfs dfs -help ls
```

2>.查看hdfs文件系统中已经存在的文件
```
# hdfs dfs -ls /
```

3>.在hdfs文件系统中创建文件
```
# hdfs dfs -touchz /user/yinzhengjie/data/1.txt
```

4>.上传文件至根目录(在上传的过程中会产生一个以"*.Copying"字样的临时文件)
```
# hdfs dfs -put hadoop-2.7.3.tar.gz /
```

5>.在hdfs文件系统中下载文件
```
# hdfs dfs -get /1.txt
```

6>.在hdfs文件系统中删除文件
```
# hdfs dfs -rm /1.txt
```

7>.在hdfs文件系统中查看文件内容
```
# hdfs dfs -cat /xrsync.sh
```

8>.在hdfs文件系统中创建目录
```
# hdfs dfs -mkdir /shell
```

9>.在hdfs文件系统中修改文件名称（当然你可以可以用来移动文件到目录哟）
```
# hdfs dfs -mv /xcall.sh /call.sh

```
```
# hdfs dfs -mv /call.sh /shell
```

10>.在hdfs问系统中拷贝文件到目录
```
# hdfs dfs -cp /xrsync.sh /shell
```

11>.递归删除目录
```
# hdfs dfs -rmr /shell
```

12>.列出本地文件的内容（默认是hdfs文件系统哟）
```
# hdfs dfs -ls file:///home/yinzhengjie/

```
```
# hdfs dfs -ls hdfs:/
```

13>.追加文件内容到hdfs文件系统中的文件
```
# hdfs dfs -appendToFile xrsync.sh /xcall.sh
```

14>.格式化名称节点
```
# hdfs namenode
```

15>.创建快照（关于快照更详细的用法请参考：https://www.cnblogs.com/yinzhengjie/p/9099529.html）
```
# hdfs dfs -createSnapshot /data firstSnapshot
```

16>.重命名快照
```
# hdfs dfs -renameSnapshot /data firstSnapshot newSnapshot
```

17>.删除快照
```
# hdfs dfs -deleteSnapshot /data newSnapshot
```

18>.查看hadoop的Sequencefile文件内容
```
# hdfs dfs -text file:///home/yinzhengjie/data/seq
```

19>.使用df命令查看可用空间
```
# hdfs dfs -df
# hdfs dfs -df -h
```

20>.降低复制因子
```
# hdfs dfs -setrep -w 2 /user/yinzhengjie/data/1.txt
```

21>.使用du命令查看已用空间
```
# hdfs dfs -du /user/yinzhengjie/data/day001

# hdfs dfs -du -h /user/yinzhengjie/data/day001

# hdfs dfs -du -s -h /user/yinzhengjie/data/day001
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

4>.查看当前的模式
```
# hdfs dfsadmin -safemode get
```

5>.进入安全模式
```
# hdfs dfsadmin -safemode enter
```

6>.离开安全模式
```
# hdfs dfsadmin -safemode leave
```

7>.安全模式的wait状态
```
# hdfs dfsadmin -safemode wait
```

8>.检查HDFS集群的状态
```
# hdfs dfsadmin -help report
```

```
# hdfs dfsadmin -report
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
