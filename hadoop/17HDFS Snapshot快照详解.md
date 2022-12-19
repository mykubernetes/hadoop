# 1. Snapshot快照

## 1.1 快照介绍和作用
- HDFS `snapshot`是HDFS`整个文件系统，或者某个目录在某个时刻的镜像`。该镜像并不会随着源目录的改变而进行动态的更新。可以将快照理解为拍照片时的那一瞬间的投影，过了那个时间之后，又会有新的一个投影。
- HDFS 快照的核心功能包括：数据恢复、数据备份、数据测试。

### 1.1.1 数据恢复
  可以通过滚动的方式来对重要的目录进行创建 snapshot 的操作，这样在系统中就存在针对某个目录的多个快照版本。当用户误删除掉某个文件时，可以通过最新的 snapshot 来进行相关的恢复操作。

### 1.1.2 数据备份
  可以使用 snapshot 来进行整个集群，或者某些目录、文件的备份。管理员以某个时刻的 snapshot 作为备份的起始结点，然后通过比较不同备份之间差异性，来进行增量备份。

### 1.1.3 数据测试
  在某些重要数据上进行测试或者实验，可能会直接将原始的数据破坏掉。可以临时的为用户针对要操作的数据来创建一个 snapshot，然后让用户在对应的 snapshot 上进行相关的实验和测试，从而避免对原始数据的破坏。

## 1.2 HDFS快照的实现
- 在了解 HDFS 快照功能如何实现之前，首先有一个根本的原则需要记住：快照不是数据的简单拷贝，快照只做差异的记录。这一原则在其他很多系统的快照概念中都是适用的，比如磁盘快照，也是不保存真实数据的。因为不保存实际的数据，所以快照的生成往往非常迅速。
- 在 HDFS 中，如果在其中一个目录比如/A下创建一个快照，则快照文件中将会存在与/A目录下完全一致的子目录文件结构以及相应的属性信息，通过命令也能看到快照里面具体的文件内容。但是这并不意味着快照已经对此数据进行完全的拷贝 。这里遵循一个原则：对于大多不变的数据，你所看到的数据其实是当前物理路径所指的内容，而发生变更的inode数据才会被快照额外拷贝，也就是所说的差异拷贝。
- inode 译成中文就是索引节点，它用来存放文件及目录的基本信息，包含时间、名称、拥有者、所在组等信息。
- HDFS 快照不会复制 datanode 中的块，只记录了块列表和文件大小。
- HDFS 快照不会对常规 HDFS 操作产生不利影响，修改记录按逆时针顺序进行，因此可以直接访问当前数据。通过从当前数据中减去修改来计算快照数据。

## 1.3 快照的命令

## 1.3.1 快照功能启停命令
```
$ hdfs dfsadmin
Usage: hdfs dfsadmin
Note: Administrative commands can only be run as the HDFS superuser.
	[-report [-live] [-dead] [-decommissioning] [-enteringmaintenance] [-inmaintenance]]
	[-safemode <enter | leave | get | wait | forceExit>]
	[-saveNamespace [-beforeShutdown]]
	[-rollEdits]
	[-restoreFailedStorage true|false|check]
	[-refreshNodes]
	[-setQuota <quota> <dirname>...<dirname>]
	[-clrQuota <dirname>...<dirname>]
	[-setSpaceQuota <quota> [-storageType <storagetype>] <dirname>...<dirname>]
	[-clrSpaceQuota [-storageType <storagetype>] <dirname>...<dirname>]
	[-finalizeUpgrade]
	[-rollingUpgrade [<query|prepare|finalize>]]
	[-upgrade <query | finalize>]
	[-refreshServiceAcl]
	[-refreshUserToGroupsMappings]
	[-refreshSuperUserGroupsConfiguration]
	[-refreshCallQueue]
	[-refresh <host:ipc_port> <key> [arg1..argn]
	[-reconfig <namenode|datanode> <host:ipc_port> <start|status|properties>]
	[-printTopology]
	[-refreshNamenodes datanode_host:ipc_port]
	[-getVolumeReport datanode_host:ipc_port]
	[-deleteBlockPool datanode_host:ipc_port blockpoolId [force]]
	[-setBalancerBandwidth <bandwidth in bytes per second>]
	[-getBalancerBandwidth <datanode_host:ipc_port>]
	[-fetchImage <local directory>]
	[-allowSnapshot <snapshotDir>]
	[-disallowSnapshot <snapshotDir>]
	[-shutdownDatanode <datanode_host:ipc_port> [upgrade]]
	[-evictWriters <datanode_host:ipc_port>]
	[-getDatanodeInfo <datanode_host:ipc_port>]
	[-metasave filename]
	[-triggerBlockReport [-incremental] <datanode_host:ipc_port> [-namenode <namenode_host:ipc_port>]]
	[-listOpenFiles [-blockingDecommission] [-path <path>]]
	[-help [cmd]]
```

HDFS 中可以针对整个文件系统或者文件系统中某个目录创建快照，但是`创建快照的前提是相应的目录开启快照的功能`。

1、如果针对没有启动快照功能的目录创建快照则会报错：
```
$ hdfs dfs -createSnapshot /input
createSnapshot: Directory is not a snapshottable directory: /input
```

2、启用快照功能：
```
$ hdfs dfsadmin -allowSnapshot /input
```

3、禁用快照功能：
```
$ hdfs dfsadmin -disallowSnapshot /input
```

### 1.3.2 快照操作相关命令
```
$ hdfs dfs
Usage: hadoop fs [generic options]
	[-appendToFile <localsrc> ... <dst>]
	[-cat [-ignoreCrc] <src> ...]
	[-checksum [-v] <src> ...]
	[-chgrp [-R] GROUP PATH...]
	[-chmod [-R] <MODE[,MODE]... | OCTALMODE> PATH...]
	[-chown [-R] [OWNER][:[GROUP]] PATH...]
	[-concat <target path> <src path> <src path> ...]
	[-copyFromLocal [-f] [-p] [-l] [-d] [-t <thread count>] <localsrc> ... <dst>]
	[-copyToLocal [-f] [-p] [-ignoreCrc] [-crc] <src> ... <localdst>]
	[-count [-q] [-h] [-v] [-t [<storage type>]] [-u] [-x] [-e] [-s] <path> ...]
	[-cp [-f] [-p | -p[topax]] [-d] <src> ... <dst>]
	[-createSnapshot <snapshotDir> [<snapshotName>]]
	[-deleteSnapshot <snapshotDir> <snapshotName>]
	[-df [-h] [<path> ...]]
	[-du [-s] [-h] [-v] [-x] <path> ...]
	[-expunge [-immediate] [-fs <path>]]
	[-find <path> ... <expression> ...]
	[-get [-f] [-p] [-ignoreCrc] [-crc] <src> ... <localdst>]
	[-getfacl [-R] <path>]
	[-getfattr [-R] {-n name | -d} [-e en] <path>]
	[-getmerge [-nl] [-skip-empty-file] <src> <localdst>]
	[-head <file>]
	[-help [cmd ...]]
	[-ls [-C] [-d] [-h] [-q] [-R] [-t] [-S] [-r] [-u] [-e] [<path> ...]]
	[-mkdir [-p] <path> ...]
	[-moveFromLocal [-f] [-p] [-l] [-d] <localsrc> ... <dst>]
	[-moveToLocal <src> <localdst>]
	[-mv <src> ... <dst>]
	[-put [-f] [-p] [-l] [-d] [-t <thread count>] <localsrc> ... <dst>]
	[-renameSnapshot <snapshotDir> <oldName> <newName>]
	[-rm [-f] [-r|-R] [-skipTrash] [-safely] <src> ...]
	[-rmdir [--ignore-fail-on-non-empty] <dir> ...]
	[-setfacl [-R] [{-b|-k} {-m|-x <acl_spec>} <path>]|[--set <acl_spec> <path>]]
	[-setfattr {-n name [-v value] | -x name} <path>]
	[-setrep [-R] [-w] <rep> <path> ...]
	[-stat [format] <path> ...]
	[-tail [-f] [-s <sleep interval>] <file>]
	[-test -[defswrz] <path>]
	[-text [-ignoreCrc] <src> ...]
	[-touch [-a] [-m] [-t TIMESTAMP (yyyyMMdd:HHmmss) ] [-c] <path> ...]
	[-touchz <path> ...]
	[-truncate [-w] <length> <path> ...]
	[-usage [cmd ...]]

$ hdfs lsSnapshottableDir

$ hdfs snapshotDiff <path> <fromSnapshot> <toSnapshot>
```
快照相关的操作命令有：
- createSnapshot创建快照
- deleteSnapshot删除快照
- renameSnapshot重命名快照
- lsSnapshottableDir列出可以快照目录列表
- snapshotDiff获取快照差异报告

## 1.4 案例：快照的使用

1、开启指定目录的快照
```
$ hdfs dfsadmin -allowSnapshot /input
Allowing snapshot on /input succeeded
```

2、对指定目录创建快照
```
$ hdfs dfs -createSnapshot /input，系统自动生成快照名称
Create snapshot /input/.snapshot/s20220124-162056.329

$ hdfs dfs -createSnapshot /input mysnap1，指定名称创建快照
Create snapshot /input/.snapshot/mysnap1
```

3、重命名快照
```
$ hdfs dfs -renameSnapshot /input mysnap1 mysnap2
Rename snapshot mysnap1 to mysnap2 under hdfs://192.168.68.101.8020/input
```

4、列出当前用户所有可以快照的目录
```
$ hdfs lsSnapshottableDir
drwxr-xr-x 0 hadoop supergroup 0 2022-01-24 16:21 2 65536 /input
```

5、比较两个快照不同之处
```
$ echo 222 > 2.txt
$ hadoop fs -appendToFile 2.txt /input/1.txt

$ hadoop fs -cat /input/1.txt
hello hadoop
stream data
flink spark
222

$ hdfs dfs -createSnapshot /input mysnap3
Created snapshot /input/.snapshot/mysnap3

$ hadoop fs -put 2.txt /input
$ hdfs dfs -createSnapshot /input mysnap4
Created snapshot /input/.snapshot/mysnap4
```

```
$ hdfs snapshotDiff /input mysnap2 mysnap3
Difference between snapshot mysnap2 and snapshot mysnap3 under directory /input:
M          ./1.txt

$ hdfs snapshotDiff /input mysnap2 mysnap4
Difference between snapshot mysnap2 and snapshot mysnap4 under directory /input:
M          .
+          ./2.txt
M          ./1.txt
```
- `+` The file/directory has been created.
- `-` The file/directory has been deleted.
- `M` The file/directory has been modified.
- `R` The file/directory has been renamed.

6、删除快照
```
hdfs dfs -deleteSnapshot /input mysnap4
Deleted snapshot mysnap4 hdfs://192.168.68.101.8020/input
```

7、删除有快照的目录
```
hadoop fs -rm -r /input
rm: Failed to move to trash: hdfs://192.168.68.101.8020/input: The directory /input cannot be deleted since /input is snapshottable and already has snapshots
```
**拥有快照的目录不允许被删除**，某种程度上也保护了文件安全。
