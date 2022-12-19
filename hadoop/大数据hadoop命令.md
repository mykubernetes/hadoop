hadoop fs命令能够用于其余文件系统，不止是hdfs文件系统内，也就是说该命令的使用范围更广能够用于HDFS、Local FS等不一样的文件系统。而hdfs dfs命令只用于HDFS文件系统；

# 1、hadoop命令

使用语法：`hadoop [--config confdir] COMMAND` #其中config用来覆盖默认的配置sql
```
##command #子命令
fs                   run a generic filesystem user client
version              print the version
jar <jar>            run a jar file
checknative [-a|-h]  check native hadoop and compression libraries availability
distcp <srcurl> <desturl> copy file or directories recursively
archive -archiveName NAME -p <parent path> <src>* <dest> create a hadoop archive
classpath            prints the class path needed to get the
credential           interact with credential providers Hadoop jar and the required libraries
daemonlog            get/set the log level for each daemon
s3guard              manage data on S3
trace                view and modify Hadoop tracing settings
```

## 一、archive shell

建立一个hadoop压缩文件，详细的能够参考 http://hadoop.apache.org/docs/r2.7.0/hadoop-archives/HadoopArchives.htmlexpress

使用格式：`hadoop archive -archiveName NAME -p <parent path> <src>* <dest>`  #-p 能够同时指定多个路径apache

实例：
```
$ hadoop fs -touchz /tmp/test/a.txt

$ hadoop fs -ls /tmp/test/
Found 1 items
-rw-r--r--   3 hive supergroup          0 2019-09-18 13:50 /tmp/test/a.txt

$ hadoop archive -archiveName test.har -p  /tmp/test/a.txt -r 3 /tmp/test
19/09/18 13:52:58 INFO mapreduce.JobSubmitter: number of splits:1
19/09/18 13:52:58 INFO mapreduce.JobSubmitter: Submitting tokens for job: job_1565571819971_6988
19/09/18 13:52:58 INFO impl.YarnClientImpl: Submitted application application_1565571819971_6988
19/09/18 13:52:58 INFO mapreduce.Job: The url to track the job: http://ip_address:8088/proxy/application_1565571819971_6988/
19/09/18 13:52:58 INFO mapreduce.Job: Running job: job_1565571819971_6988
19/09/18 13:53:04 INFO mapreduce.Job: Job job_1565571819971_6988 running in uber mode : false
19/09/18 13:53:04 INFO mapreduce.Job:  map 0% reduce 0%
19/09/18 13:53:08 INFO mapreduce.Job:  map 100% reduce 0%
19/09/18 13:53:13 INFO mapreduce.Job:  map 100% reduce 100%
19/09/18 13:53:13 INFO mapreduce.Job: Job job_1565571819971_6988 completed successfully
19/09/18 13:53:13 INFO mapreduce.Job: Counters: 49
        File System Counters
                FILE: Number of bytes read=80
                FILE: Number of bytes written=313823
                FILE: Number of read operations=0
                FILE: Number of large read operations=0
                FILE: Number of write operations=0
                HDFS: Number of bytes read=264
                HDFS: Number of bytes written=69
                HDFS: Number of read operations=14
                HDFS: Number of large read operations=0
                HDFS: Number of write operations=8
        Job Counters 
                Launched map tasks=1
                Launched reduce tasks=1
                Other local map tasks=1
                Total time spent by all maps in occupied slots (ms)=7977
                Total time spent by all reduces in occupied slots (ms)=12015
                Total time spent by all map tasks (ms)=2659
                Total time spent by all reduce tasks (ms)=2403
                Total vcore-milliseconds taken by all map tasks=2659
                Total vcore-milliseconds taken by all reduce tasks=2403
                Total megabyte-milliseconds taken by all map tasks=8168448
                Total megabyte-milliseconds taken by all reduce tasks=12303360
        Map-Reduce Framework
                Map input records=1
                Map output records=1
                Map output bytes=59
                Map output materialized bytes=76
                Input split bytes=97
                Combine input records=0
                Combine output records=0
                Reduce input groups=1
                Reduce shuffle bytes=76
                Reduce input records=1
                Reduce output records=0
                Spilled Records=2
                Shuffled Maps =1
                Failed Shuffles=0
                Merged Map outputs=1
                GC time elapsed (ms)=91
                CPU time spent (ms)=2320
                Physical memory (bytes) snapshot=1189855232
                Virtual memory (bytes) snapshot=11135381504
                Total committed heap usage (bytes)=3043491840
        Shuffle Errors
                BAD_ID=0
                CONNECTION=0
                IO_ERROR=0
                WRONG_LENGTH=0
                WRONG_MAP=0
                WRONG_REDUCE=0
        File Input Format Counters 
                Bytes Read=167
        File Output Format Counters 
                Bytes Written=0

$ hadoop fs -ls /tmp/test/
Found 2 items
-rw-r--r--   3 hive supergroup          0 2019-09-18 13:50 /tmp/test/a.txt
drwxr-xr-x   - hive supergroup          0 2019-09-18 13:53 /tmp/test/test.har

$ hadoop fs -ls /tmp/test/test.har/
Found 4 items
-rw-r--r--   3 hive supergroup          0 2019-09-18 13:53 /tmp/test/test.har/_SUCCESS
-rw-r--r--   3 hive supergroup         55 2019-09-18 13:53 /tmp/test/test.har/_index
-rw-r--r--   3 hive supergroup         14 2019-09-18 13:53 /tmp/test/test.har/_masterindex
-rw-r--r--   3 hive supergroup          0 2019-09-18 13:53 /tmp/test/test.har/part-0

解压：
hadoop distcp har:///tmp/test/test.har /tmp/test1
hdfs dfs -cp har:///tmp/test/test.har /tmp/test1
```

## 二、checknative安全

检查hadoop的原生代码，通常人用不到网络

使用语法：`hadoop checknative [-a] [-h]`
- -a 检查全部的库
- -h 显示帮助

## 三、classpath

打印hadoop jar或者库的类路径

使用语法：`hadoop classpath [--glob |--jar <path> |-h |--help]`

## 四、credential

管理凭证供应商的凭证、密码和secret(有关秘密信息）

使用语法：`hadoop credential <subcommand> [options]`

## 五、distcp（比较经常使用）

distributed copy的缩写（望文生义),主要用于集群内/集群之间 复制文件。须要使用到mapreduce

使用语法：`hadoop distcp [-option] hdfs://source hdfs://dest`
	
详细见：http://hadoop.apache.org/docs/r2.7.0/hadoop-distcp/DistCp.html

```
经常使用的几个选项：
-m <num_maps>  #指定了拷贝数据时map的数目。请注意并非map数越多吞吐量越大
-i               #忽略失败
-log <logdir>  #记录日志到 <logdir>
-update        #当目标集群上的文件不存在或文件不一致时，才会从源集群拷贝
-overwrite     #覆盖目标集群上的文件
-filter        #过滤不须要复制的文件
-delete        #删除目标文件存在，但不存在source中的文件
```

# 六、fs

与hdfs dfs同用

查看帮助：`hadoop fs -help`

详细查看：http://hadoop.apache.org/docs/r2.7.0/hadoop-project-dist/hadoop-common/FileSystemShell.html

```
# hadoop fs
Usage: hadoop fs [generic options]
        [-appendToFile <localsrc> ... <dst>]
        [-cat [-ignoreCrc] <src> ...]
        [-checksum <src> ...]
        [-chgrp [-R] GROUP PATH...]
        [-chmod [-R] <MODE[,MODE]... | OCTALMODE> PATH...]
        [-chown [-R] [OWNER][:[GROUP]] PATH...]
        [-copyFromLocal [-f] [-p] [-l] [-d] <localsrc> ... <dst>]
        [-copyToLocal [-f] [-p] [-ignoreCrc] [-crc] <src> ... <localdst>]
        [-count [-q] [-h] [-v] [-t [<storage type>]] [-u] [-x] <path> ...]
        [-cp [-f] [-p | -p[topax]] [-d] <src> ... <dst>]
        [-createSnapshot <snapshotDir> [<snapshotName>]]
        [-deleteSnapshot <snapshotDir> <snapshotName>]
        [-df [-h] [<path> ...]]
        [-du [-s] [-h] [-x] <path> ...]
        [-expunge]
        [-find <path> ... <expression> ...]
        [-get [-f] [-p] [-ignoreCrc] [-crc] <src> ... <localdst>]
        [-getfacl [-R] <path>]
        [-getfattr [-R] {-n name | -d} [-e en] <path>]
        [-getmerge [-nl] [-skip-empty-file] <src> <localdst>]
        [-help [cmd ...]]
        [-ls [-C] [-d] [-h] [-q] [-R] [-t] [-S] [-r] [-u] [<path> ...]]
        [-mkdir [-p] <path> ...]
        [-moveFromLocal <localsrc> ... <dst>]
        [-moveToLocal <src> <localdst>]
        [-mv <src> ... <dst>]
        [-put [-f] [-p] [-l] [-d] <localsrc> ... <dst>]
        [-renameSnapshot <snapshotDir> <oldName> <newName>]
        [-rm [-f] [-r|-R] [-skipTrash] [-safely] <src> ...]
        [-rmdir [--ignore-fail-on-non-empty] <dir> ...]
        [-setfacl [-R] [{-b|-k} {-m|-x <acl_spec>} <path>]|[--set <acl_spec> <path>]]
        [-setfattr {-n name [-v value] | -x name} <path>]
        [-setrep [-R] [-w] <rep> <path> ...]
        [-stat [format] <path> ...]
        [-tail [-f] <file>]
        [-test -[defsz] <path>]
        [-text [-ignoreCrc] <src> ...]
        [-touchz <path> ...]
        [-truncate [-w] <length> <path> ...]
        [-usage [cmd ...]]
```

包括以下一些子命令：
```
appendToFile, cat, checksum, chgrp, chmod, chown, copyFromLocal, copyToLocal, count, cp, createSnapshot, deleteSnapshot, df, du, expunge, find, get, getfacl, getfattr, getmerge, help, ls, mkdir, moveFromLocal, moveToLocal, mv, put, renameSnapshot, rm, rmdir, setfacl, setfattr, setrep, stat, tail, test, text, touchz
```

1、查看集群容量使用情况
```
hdfs dfsadmin –report
```

# 常用命令实操

1、`-help`：输出这个命令参数
```
hadoop fs -help rm
```

2、`-ls`: 罗列文件
```
Usage: hadoop fs -ls [-d] [-h] [-R] [-t] [-S] [-r] [-u] <args>
hadoop fs -ls /
```

3、`-mkdir`：在hdfs上建立文件夹
```
Usage: hadoop fs -mkdir [-p] <paths>
Example:
hadoop fs -mkdir /user/hadoop/dir1 /user/hadoop/dir2
hadoop fs -mkdir hdfs://nn1.example.com/user/hadoop/dir hdfs://nn2.example.com/user/hadoop/dir
hadoop fs -mkdir -p /aaa/bbb/cc/dd
```

4、`-moveFromLocal`: 把本地文件移动到hdfs上
```
Usage: hadoop fs -moveFromLocal <localsrc> <dst>
hadoop fs -moveFromLocal /home/hadoop/a.txt /aaa/bbb/cc/dd
```

5、`-moveToLocal`：把hdfs文件移动到本地上
```
Usage: hadoop fs -moveToLocal [-crc] <src> <dst>
hadoop fs -moveToLocal /aaa/bbb/cc/dd /home/hadoop/a.txt
```

6、`-appendToFile`：追加一个文件到已经存在的文件末尾
```
Usage: hadoop fs -appendToFile <localsrc> ... <dst>
example：
hadoop fs -appendToFile localfile1 localfile2 /user/hadoop/hadoopfile
hadoop fs -appendToFile - hdfs://nn.example.com/hadoop/hadoopfile  #表示从标准输入输入数据到hadoopfile中，ctrl+d 结束输入
```

7、`-cat`：显示文件内容
```
Usage: hadoop fs -cat URI [URI ...]
example：
hadoop fs -cat hdfs://nn1.example.com/file1 hdfs://nn2.example.com/file2
hadoop fs -cat file:///file3 /user/hadoop/file4
```

8、`-tail`：显示一个文件的末尾
```
Usage: hadoop fs -tail [-f] URI
hadoop fs -tail /weblog/access_log.1
```

10、`chgrp`: 变动文件目录的所属组
```
Usage: hadoop fs -chgrp [-R] GROUP URI [URI ...]
```

11、`chmod`: 修改文件或者目录的权限
```
Usage: hadoop fs -chmod [-R] <MODE[,MODE]... | OCTALMODE> URI [URI ...]
example：
hadoop  fs  -chmod  666  /hello.txt
```

12、`chown`: 修改目录或者文件的拥有者和所属组
```
Usage: hadoop fs -chown [-R] [OWNER][:[GROUP]] URI [URI ]
example：
hadoop  fs  -chown  someuser:somegrp   /hello.txt
```

11、`-copyFromLocal`：从本地复制文件或者文件夹到hdfs，相似put命令
```
Usage: hadoop fs -copyFromLocal [-f] <localsrc> URI   #其中-f选项会覆盖与原文件同样的目标路径文件
example：
hadoop fs -copyFromLocal start-hadoop.sh  /tmp
```

12、`-copyToLocal`：相似get命令，从hdfs获取文件到本地
```
Usage: hadoop fs -copyToLocal [-ignorecrc] [-crc] URI <localdst>
example：
hadoop fs -copyToLocal /aaa/jdk.tar.gz
```

13、`-cp` ：从hdfs的一个路径拷贝到hdfs的另一个路径
```
Usage: hadoop fs -cp [-f] [-p | -p[topax]] URI [URI ...] <dest>
Example:
hadoop fs -cp /user/hadoop/file1 /user/hadoop/file2
hadoop fs -cp /user/hadoop/file1 /user/hadoop/file2 /user/hadoop/dir
```

14、`-mv`：在hdfs目录中移动文件
```
Usage: hadoop fs -mv URI [URI ...] <dest>
Example:
hadoop fs -mv /user/hadoop/file1 /user/hadoop/file2
hadoop fs -mv hdfs://nn.example.com/file1 hdfs://nn.example.com/file2 hdfs://nn.example.com/file3 hdfs://nn.example.com/dir1
hadoop  fs  -mv  /aaa/jdk.tar.gz  /
```

15、`-get`：获取数据，相似于copyToLocal.但有crc校验，就是从hdfs下载文件到本地
```
Usage: hadoop fs -get [-ignorecrc] [-crc] <src> <localdst>
Example:
hadoop fs -get /tmp/input/hadoop/*.xml /home/hadoop/testdir/
hadoop fs -get /aaa/jdk.tar.gz
```

16、`-getmerge`：合并下载多个文件，比如hdfs的目录 /aaa/下有多个文件:log.1, log.2,log.3,...
```
hadoop fs -getmerge /aaa/log.* ./log.sum
```

17、`-put`：等同于copyFromLocal,把文件复制到hdfs上
```
Usage: hadoop fs -put <localsrc> ... <dst>
Example:
hadoop fs -put localfile hdfs://nn.example.com/hadoop/hadoopfile
hadoop fs -put - hdfs://nn.example.com/hadoop/hadoopfile  #Reads the input from stdin.
hadoop fs -put /aaa/jdk.tar.gz /bbb/jdk.tar.gz.2
```

18、`-rm`：删除文件或文件夹
```
Usage: hadoop fs -rm [-f] [-r |-R] [-skipTrash] URI [URI ...]
Example:
hadoop fs -rm -r /aaa/bbb/
```

19、`-rmdir`：删除空目录
```
Usage: hadoop fs -rmdir [--ignore-fail-on-non-empty] URI [URI ...]
hadoop fs -rmdir /aaa/bbb/ccc
```

20、`-df`：统计文件系统的可用空间信息
```
Usage: hadoop fs -df [-h] URI [URI ...]
example：
hadoop  fs  -df  -h  /
```

21、`-du`: 展现目录包含的文件的大小
```
Usage: hadoop fs -du [-s] [-h] URI [URI ...]
Example:
hadoop fs -du /user/hadoop/dir1 /user/hadoop/file1 hdfs://nn.example.com/user/hadoop/dir1
hadoop fs -du -s -h /aaa/*
```

22、`-count`：计算 目录，文件，字节数
```
Usage: hadoop fs -count [-q] [-h] [-v] <paths> 
example：
hadoop fs -count /aaa/
```

23、`-checksum`： 返回被检查文件的格式
```
Usage: hadoop fs -checksum URI
example：
$  hadoop fs -checksum /tmp/test/test.txt
/tmp/test/test.txt      MD5-of-0MD5-of-512CRC32C        000002000000000000000000fde199c1517b7b26b0565ff6b0f46acc
```

24、`find`: 查找
```
Usage: hadoop fs -find <path> ... <expression> ...
       -name pattern
       -iname pattern #忽略大小写
       -print
       -print0Always
Example:
hadoop fs -find / -name test -print
```

25、`getfacl`: 展现目录或者文件的ACL权限
```
Usage: hadoop fs -getfacl [-R] <path>
$ hadoop fs -getfacl -R  /tmp/test
# file: /tmp/test
# owner: hive
# group: supergroup
getfacl: The ACL operation has been rejected.  Support for ACLs has been disabled by setting dfs.namenode.acls.enabled to false.
```

26、`getfattr`: 显示文件或目录的扩展属性名称和值
```
Usage: hadoop fs -getfattr [-R] -n name | -d [-e en] <path>
       -n name和 -d是互斥的，
       -d表示获取全部属性。
       -R表示循环获取； 
       -e en 表示对获取的内容编码，en的能够取值是 “text”, “hex”, and “base64”.
Examples:
hadoop fs -getfattr -d /file
hadoop fs -getfattr -R -n user.myAttr /dir
```

27、`getmerge`: 合并文件
```
Usage: hadoop fs -getmerge <src> <localdst> [addnl]
hadoop fs -getmerge   /src  /opt/output.txt
hadoop fs -getmerge  /src/file1.txt /src/file2.txt  /output.txt
```

28、`setfacl`: 设置ACL权限
```
Usage: hadoop fs -setfacl [-R] [-b |-k -m |-x <acl_spec> <path>] |[--set <acl_spec> <path>]
-b 删除除基本acl项以外的全部项。保留用户、组和其余用户
-k 删除全部的默认ACL权限
-R 递归操做
-m 修改ACL权限，保留旧的，添加新的
-x 删除指定ACL权限
--set 彻底替换现有的ACL权限
Examples:
hadoop fs -setfacl -m user:hadoop:rw- /file
hadoop fs -setfacl -x user:hadoop /file
hadoop fs -setfacl -b /file
hadoop fs -setfacl -k /dir
hadoop fs -setfacl --set user::rw-,user:hadoop:rw-,group::r--,other::r-- /file
hadoop fs -setfacl -R -m user:hadoop:r-x /dir
hadoop fs -setfacl -m default:user:hadoop:r-x /dir 
```

29、`setfattr`: 设置额外的属性
```
Usage: hadoop fs -setfattr -n name [-v value] | -x name <path>
       -b 删除除基本acl项以外的全部项。保留用户、组和其余用户
       -n 额外属性名
       -v 额外属性值
       -x name 删除额外属性
Examples:
hadoop fs -setfattr -n user.myAttr -v myValue /file
hadoop fs -setfattr -n user.noValue /file
hadoop fs -setfattr -x user.myAttr /file
```

30、`setrep`: 改变文件的复制因子（副本数量）
```
Usage: hadoop fs -setrep [-R] [-w] <numReplicas> <path>
Example:
hadoop fs -setrep -w 3 /user/hadoop/dir1
```

31、`stat`: 获取文件的时间
```
Usage: hadoop fs -stat [format] <path> ...
Example:
hadoop fs -stat "%F %u:%g %b %y %n" /file
```

32、`test`: 测试
```
Usage: hadoop fs -test -[defsz] URI
       -d 判断是不是目录
       -e 判断是否存在
       -f 判断是不是文件
       -s 判断目录是否为空
       -z 判断文件是否为空
Example:
hadoop fs -test -e filename
```

33、`text`：能够用来看压缩文件
```
Usage: hadoop fs -text <src>
hadoop fs -text /weblog/access_log.1
```

34、`touchz`: 建立一个空文件
```
Usage: hadoop fs -touchz URI [URI ...]
```

35、`Snapshot`相关
```
createSnapshot #建立快照
deleteSnapshot #删除快照
详细见：http://hadoop.apache.org/docs/r2.8.0/hadoop-project-dist/hadoop-hdfs/HdfsSnapshots.html
HDFS快照是文件系统的只读时间点副本。能够在文件系统的子树或整个文件系统上拍摄快照。快照的一些常见用例是数据备份，防止用户错误和灾难恢复。
在建立快照前，要设置一个目录为snapshottable（须要管理员权限），表示能够在该目录中建立快照
hdfs dfsadmin -allowSnapshot <path> #在path中启用快照
hdfs dfsadmin -disallowSnapshot <path> #在path中禁止快照
hdfs dfs -ls /foo/.snapshot #列出快照目录下的全部快照
hdfs dfs -createSnapshot <path> [<snapshotName>] #建立快照，快照名默认为时间戳格式
hdfs dfs -deleteSnapshot <path> <snapshotName> #删除快照
hdfs dfs -renameSnapshot <path> <oldName> <newName> #快照重命名
hdfs lsSnapshottableDir #获取快照目录
```

36、`expunge`: 清空回收站（不要瞎用）
```
Usage: hadoop fs -expunge
```


37、`hadoop jar`使用方法
```
jar  #运行一个jar文件
Usage: hadoop jar <jar> [mainClass] args...
Example:
hadoop jar ./test/wordcount/wordcount.jar org.codetree.hadoop.v1.WordCount /test/chqz/input /test/chqz/output的各段的含义：
(1) hadoop：${HADOOP_HOME}/bin下的shell脚本名。
(2) jar：hadoop脚本须要的command参数。
(3) ./test/wordcount/wordcount.jar：要执行的jar包在本地文件系统中的完整路径，参递给RunJar类。
(4) org.codetree.hadoop.v1.WordCount：main方法所在的类，参递给RunJar类。
(5) /test/chqz/input：传递给WordCount类，做为DFS文件系统的路径，指示输入数据来源。
(6) /test/chqz/output：传递给WordCount类，做为DFS文件系统的路径，指示输出数据路径。
```
- hadoop推荐使用yarn jar替代hadoop jar 详情见：http://hadoop.apache.org/docs/r2.8.0/hadoop-yarn/hadoop-yarn-site/YarnCommands.html#jar

38、key:用来管理秘钥，基本不用

39、trace：查看和修改跟踪设置

- 详情见：http://hadoop.apache.org/docs/r2.8.0/hadoop-project-dist/hadoop-common/Tracing.html

参考：
- http://www.javashuo.com/article/p-xuvyvjam-gp.html
