
[原文链接hadoop官方文档](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-common/CommandsManual.html)

# User Commands

- [classpath](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#classpath)
- [dfs](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#dfs)
- [envvars](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#envvars)
- [fetchdt](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#fetchdt)
- [fsck](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#fsck)
- [getconf](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#getconf)
- [groups](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#groups)
- [httpfs](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#httpfs)
- [lsSnapshottableDir](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#lsSnapshottableDir)
- [jmxget](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#jmxget)
- [oev](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#oev)
- [oiv](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#oiv)
- [oiv_legacy](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#oiv_legacy)
- [snapshotDiff](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#snapshotDiff)
- [version](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#version)

# Administration Commands
- [balancer](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#balancer)
- [cacheadmin](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#cacheadmin)
- [crypto](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#crypto)
- [datanode](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#datanode)
- [dfsadmin](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#dfsadmin)
- [dfsrouter](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#dfsrouter)
- [dfsrouteradmin](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#dfsrouteradmin)
- [diskbalancer](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#diskbalancer)
- [ec](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#ec)
- [haadmin](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#haadmin)
- [journalnode](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#journalnode)
- [mover](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#mover)
- [namenode](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#namenode)
- [nfs3](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#nfs3)
- [portmap](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#portmap)
- [secondarynamenode](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#secondarynamenode)
- [storagepolicies](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#storagepolicies)
- [zkfc](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#zkfc)

# Debug Commands
- [verifyMeta](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#verifyMeta)
- [computeMeta](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#computeMeta)
- [recoverLease](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html#recoverLease)

# 概述

所有的hadoop命令均由bin/hadoop脚本引发。不指定参数运行hadoop脚本会打印所有命令的描述。 用法：
```
hadoop [--config confdir] [COMMAND] [GENERIC_OPTIONS] [COMMAND_OPTIONS]
```
- Hadoop有一个选项解析框架用于解析一般的选项和运行类。
- --config confdir 覆盖缺省配置目录，缺省是${HADOOP_HOME}/conf
- COMMAND 在下面进行详细解释
- GENERIC_OPTIONS 多个命令都支持的通用选项
- COMMAND_OPTIONS 各种各样的命令和它们的选项会在下面提到。这些命令被分为 用户命令 管理命令两组。
- GENERIC_OPTION 描述
  - -conf `<configuration file>` 指定应用程序的配置文件
  - -D `<property=value>` 为指定的property 指定值value，在通过参数进行调优中经常使用
  - -fs local|namenode:port 指定namenode
  - -jt local|jobtracker:port 指定job tracker。只适用于job
  - -files `<逗号分隔的文件列表>` 指定要拷贝到map reduce集群的文件的逗号分隔的列表，只适用于job
  - -libjars `<逗号分隔的jar列表>` 指定要包含到classpath中的jar文件的逗号分隔的列表，只适用于job
  - -archives `<逗号分隔的archive列表>` 指定要被解压到计算节点上的档案文件的逗号分割的列表，只适用于job

| COMMAND_OPTIONS | 描述 |
| ---------------| ----- |
| SHELL_OPTIONS | 常见的shell选项集。这些内容记录在“[命令手册](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-common/CommandsManual.html#Shell_Options)”页面上。 |
| GENERIC_OPTIONS | 多个命令支持的通用选项集。有关更多信息，请参阅“[Hadoop 命令手册](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-common/CommandsManual.html#Generic_Options)”。 |
| COMMAND COMMAND_OPTIONS | 以下各节介绍了各种命令及其选项。这些命令已分组为“[用户命令](https://blog.csdn.net/zhanglong_4444/article/details/87696852#User_Commands)”和“[管理命令](https://blog.csdn.net/zhanglong_4444/article/details/87696852#Administration_Commands)”。 |


## 一、用户命令

- 对hadoop集群的用户有用的命令。

### classpath （类路径）

```
Usage: hdfs classpath [--glob |--jar <path> |-h |--help]
```

| 命令选项 | 描述 |
| :--------- | :----- |
| --glob | expand wildcards |
| --jar path | 在jar命名路径中编写类路径作为清单 |
| -h, --help | 打印 |

打印获取 Hadoop jar 和所需库所需的类路径。如果在不带参数的情况下调用，则输出命令脚本设置的类路径，它可能在类路径条目中包含通配符。其他选项在通配符展开后打印类路径，或者将类路径写入 jar 文件的清单中。后者在不能使用通配符并且展开的类路径超过了所支持的最大命令行长度的环境中非常有用。



### dfs（使用率最高）
- 在Hadoop支持的文件系统上运行filesystem命令，可以在[File System Shell Guide](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-common/FileSystemShell.html)中找到各种COMMAND_OPTIONS ，这个命令是日常中使用最多的命令之一。

用法：`hdfs dfs [COMMAND [COMMAND_OPTIONS]]`

### envvars
用法：`hdfs envvars`

显示计算的Hadoop环境变量

## fetchdt
用法: `hdfs fetchdt <opts> <token_file_path>`

| 命令选项  | 描述 |
| :------- | :------- |
| --webservice NN_Url | 连接NN的Url(从http或https开始) |
| --renewer name | 权令牌续订者的名称 |
| --cancel | 消授权令牌 |
| --renew | 更新授权令牌。必须使用-renewer name选项获取委托令牌。 |
| --print | 打印委托令牌 |
| token_file_path | 用于存储令牌的文件路径。 |

从 NameNode 获取委托令牌。更多信息见[fetchdt](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HdfsUserGuide.html#fetchdt)。

### fsck（使用率较高）
用法：
```
hdfs fsck <path>
          [-list-corruptfileblocks |
          [-move | -delete | -openforwrite]
          [-files [-blocks [-locations | -racks | -replicaDetails | -upgradedomains]]]
          [-includeSnapshots] [-showprogress]
          [-storagepolicies] [-maintenance]
          [-blockId <blk_Id>]
```
  
| 命令选项                       | 描述                                                   |
| :----------------------------- | :----------------------------------------------------- |
| path                           | 要检测的路径                                            |
| -delete                        | 删除损坏的文件                                          |
| -files                         | 打印出要检查的文件                                      |
| -files -blocks                 | 打印出文件及对应的块报告                                |
| -files -blocks -locations      | 打印出文件的各个block及block在在的节点位置               |
| -files -blocks -racks          | 打印出文件和文件的各个block及数据节点位置的网络拓扑        |
| -files -blocks -replicaDetails | 打印出每个副本的详细信息                                |
| -files -blocks -upgradedomains | 打印每个块的升级域。                                    |
| -includeSnapshots              | 如果给定路径指示快照目录或其下有快照目录，则包括快照数据   |
| -list-corruptfileblocks        | 打印出所属的缺失块和文件列表                             |
| -move                          | 将损坏的文件移至/ lost + found                          |
| -openforwrite                  | 打印出用于写入的文件                                    |
| -showprogress                  | 打印出输出点的点。默认为OFF（无进度）。                    |
| -storagepolicies               | 打印出块的存储策略摘要。                                  |
| -maintenance                   | 打印出维护状态节点详细信息。                              |
| -blockId                       | 打印出有关块的信息                                      |

运行HDFS文件系统检查实用程序。有关详细信息，请参阅[fsck](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HdfsUserGuide.html#fsck)。

```
.........................................Status: HEALTHY
 Total size:	24912786198 B                           #代表根目录下文件总大小
 Total dirs:	2016                                    #根目录下总共有多少目录
 Total files:	3741                                    #代表检测的目录下总共有多少文件
 Total symlinks:		0                       #代表检测下目录下有多少个符号链接
 Total blocks (validated):	3678 (avg. block size 6773460 B)  #代表检测的目录下有多少的block是有效的
 Minimally replicated blocks:	3678 (100.0 %)          #代表拷贝的最小block块数
 Over-replicated blocks:	0 (0.0 %)               #代表当前副本数大于指定副本数的block数量
 Under-replicated blocks:	0 (0.0 %)               #代表当前副本数小于指定副本数的block数量
 Mis-replicated blocks:		0 (0.0 %)               #代表丢失的block数量
 Default replication factor:	2                       #代表默认的副本数（自身一份，默认拷贝一份）
 Average block replication:	2.0                     #代表块平均的副本数
 Corrupt blocks:		0                       #代表坏的block数，这个值不为0，说明当前集群有不可恢复的块，即数据丢失
 Missing replicas:		0 (0.0 %)               #代表丢失的副本数
 Number of data-nodes:		3                       #代表有多少个Datanode节点
 Number of racks:		1                       #代表有多少个机架
FSCK ended at Fri Jan 20 17:26:42 CST 2023 in 262 milliseconds
```

```
$ hdfs fsck /test/fish -files -blocks
Connecting to namenode via http://hadoopcluster78:50070
FSCK started by hadoop (auth:SIMPLE) from /10.0.1.78 for path /test/fish at Fri Aug 14 12:01:50 CST 2015
/test/fish <dir>
/test/fish/box_log_20150721.txt 2018468864 bytes, 16 block(s):  OK
0. BP-701099497-10.0.1.78-1430101367576:blk_1073749326_8927 len=134217728 repl=3
1. BP-701099497-10.0.1.78-1430101367576:blk_1073749327_8928 len=134217728 repl=3
2. BP-701099497-10.0.1.78-1430101367576:blk_1073749328_8929 len=134217728 repl=3
3. BP-701099497-10.0.1.78-1430101367576:blk_1073749329_8930 len=134217728 repl=3
4. BP-701099497-10.0.1.78-1430101367576:blk_1073749330_8931 len=134217728 repl=3
5. BP-701099497-10.0.1.78-1430101367576:blk_1073749331_8932 len=134217728 repl=3
6. BP-701099497-10.0.1.78-1430101367576:blk_1073749332_8933 len=134217728 repl=3
7. BP-701099497-10.0.1.78-1430101367576:blk_1073749333_8934 len=134217728 repl=3
8. BP-701099497-10.0.1.78-1430101367576:blk_1073749334_8935 len=134217728 repl=3
9. BP-701099497-10.0.1.78-1430101367576:blk_1073749335_8936 len=134217728 repl=3
10. BP-701099497-10.0.1.78-1430101367576:blk_1073749336_8937 len=134217728 repl=3
11. BP-701099497-10.0.1.78-1430101367576:blk_1073749337_8938 len=134217728 repl=3
12. BP-701099497-10.0.1.78-1430101367576:blk_1073749338_8939 len=134217728 repl=3
13. BP-701099497-10.0.1.78-1430101367576:blk_1073749339_8940 len=134217728 repl=3
14. BP-701099497-10.0.1.78-1430101367576:blk_1073749340_8941 len=134217728 repl=3
15. BP-701099497-10.0.1.78-1430101367576:blk_1073749341_8942 len=5202944 repl=3

Status: HEALTHY
 Total size:    2018468864 B
 Total dirs:    1
 Total files:    1
 Total symlinks:        0
 Total blocks (validated):    16 (avg. block size 126154304 B)
 Minimally replicated blocks:    16 (100.0 %)
 Over-replicated blocks:    0 (0.0 %)
 Under-replicated blocks:    0 (0.0 %)
 Mis-replicated blocks:        0 (0.0 %)
 Default replication factor:    3
 Average block replication:    3.0
 Corrupt blocks:        0
 Missing replicas:        0 (0.0 %)
 Number of data-nodes:        4
 Number of racks:        1
FSCK ended at Fri Aug 14 12:01:50 CST 2015 in 1 milliseconds


The filesystem under path '/test/fish' is HEALTHY
```


### getconf
用法：
```
hdfs getconf -namenodes
hdfs getconf -secondaryNameNodes
hdfs getconf -nnRpcAddresses
hdfs getconf -journalNodes
hdfs getconf -backupNodes
hdfs getconf -includeFile
hdfs getconf -excludeFile
hdfs getconf -confKey [key]       -->使用较多
```

| 命令选项       | 描述                                               |
| :------------- | :------------------------------------------------- |
| -namenodes     | 获取集群中的名称节点列表                           |
| -secondaryNameNodes	| 获取群集中的辅助名称节点列表                  |
| -backupNodes | 获取群集中的备份节点列表。                           |
| -journalNodes  | 获取群集中的日记节点列表                           |
| -includeFile   | 获取dfs.hosts配置的值，该值定义了哪些DataNode加入到集群。   |
| -excludeFile   | 获取dfs.hosts.exclude配置的值，该值定义了哪些DataNode排除在集群之外。       |
| -nnRpcAddresses | 获取namenode rpc地址                            |
| -confKey [key] | 从配置中获取配置的参数值                           |

从配置目录中获取配置信息，进行后处理。

```
$ hdfs getconf -namenodes
node01 node03

$ hdfs getconf -nnRpcAddresses
node01:8022
node03:8022

$ hdfs getconf -confKey dfs.webhdfs.enabled
true

$ hdfs getconf -includeFile
Configuration dfs.hosts is missing.

$ hdfs getconf -excludeFile
Configuration dfs.hosts.exclude is missing.
```


### groups

用法：`hdfs groups [username ...]`

返回给定一个或多个用户名的组信息。

```
$ hdfs groups hadoop
hadoop : clustergroup  //hadoop属于clustergroup组
```

### httpfs

用法：`hdfs httpfs`

运行HttpFS服务器，HDFS HTTP网关。

### lsSnapshottableDir

用法：`hdfs lsSnapshottableDir [-help]`

| 命令选项                | 描述                                                         |
| :---------------------- | :---------------------------------------------------------- |
| -help                   | 打印帮助                                                     |

获取快照目录列表。当它以超级用户身份运行时，它将返回所有快照目录。否则，它返回当前用户拥有的那些目录。


### jmxget

用法: `hdfs jmxget [-localVM ConnectorURL | -port port | -server mbeanserver | -service service]`

| 命令选项                | 描述                                                         |
| :---------------------- | :---------------------------------------------------------- |
| -help                  | 打印帮助                                                       |
| -localVM ConnectorURL   | 连接到同一台计算机上的VM                                       |
| -port mbean server port  | 指定mbean服务器端口，如果缺少它将尝试连接到同一VM中的MBean Server |
| -server                 | 指定mbean服务器（默认为localhost）                             |
| `-service NameNode \| DataNode` | 指定jmx服务。默认情况下为NameNode。                     |

服务的快照信息

```
$ hdfs jmxget -service NameNode
init: server=localhost;port=;service=NameNode;localVMUrl=null

Domains:
	Domain = JMImplementation
	Domain = com.sun.management
	Domain = java.lang
	Domain = java.nio
	Domain = java.util.logging

MBeanServer default domain = DefaultDomain

MBean count = 22

Query MBeanServer MBeans:
List of all the available keys:
15/08/18 16:26:37 INFO util.ExitUtil: Exiting with status 0
```

### oev（修改参数慎用，查看参数可以使用）
```
Usage: hdfs oev [OPTIONS] -i INPUT_FILE -o OUTPUT_FILE
```
| 命令选项                | 描述                                                         |
| :---------------------- | :----------------------------------------------------------- |
| -i， - inputFile **arg**  | 编辑要处理的文件，xml（不区分大小写）扩展名表示XML格式，任何其他文件名表示二进制格式 |
| -o， - outputFile **arg** | 输出文件的名称。如果指定的文件存在，则将覆盖该文件，文件的格式由-p选项确定 |

可选的命令行参数：

| 命令选项               | 描述                                                         |
| :--------------------- | :----------------------------------------------------------- |
| -f， --fix-txids       | 重新编号输入中的事务ID，以便没有间隙或无效的事务ID。         |
| -h，--help             | 显示使用信息并退出                                           |
| -r，--recover          | 读取二进制编辑日志时，请使用恢复模式。这将使您有机会跳过编辑日志的损坏部分。 |
| -p， --processor **arg** | 选择要对图像文件应用的处理器类型，当前支持的处理器是：二进制（Hadoop使用的本机二进制格式），xml（默认，XML格式），统计信息（打印有关编辑文件的统计信息） |
| -v， --verbose         | 更详细的输出，打印输入和输出文件名，用于写入文件的处理器，也输出到屏幕。在大图像文件上，这将大大增加处理时间（默认为false）。 |

Hadoop离线编辑查看器。有关详细信息，请参阅[脱机编辑查看器指南](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HdfsEditsViewer.html)。

### oiv（修改参数慎用，查看参数可以使用）

用法：`hdfs oiv [OPTIONS] -i INPUT_FILE`

必需的命令行参数：

| 命令选项                       | 描述                                                         |
| :----------------------------- | :----------------------------------------------------------- |
| `-i \| --inputFile input file` | 指定要处理的输入fsimage文件（或XML文件，如果使用ReverseXML处理器）。 |

可选的命令行参数：

| 命令选项                        | 描述                                                         |
| :------------------------------ | :----------------------------------------------------------- |
| -o， --outputFile **output file** | 如果指定的输出处理器生成一个，请指定输出文件名。如果指定的文件已存在，则会以静默方式覆盖该文件。（默认情况下输出到stdout）如果输入文件是XML文件，它还会创建`<outputFile>.md5`。 |
| -p，--processor **processor**     | 指定要对图像文件应用的图像处理器。目前有效的选项是Web（默认），XML，Delimited，FileDistribution和ReverseXML。 |
| -addr address                     | 指定要侦听的地址（主机：端口）。（localhost：默认为5978）。此选项与Web处理器一起使用。 |
| -maxSize size                     | 指定要以字节为单位分析的文件大小的范围[0，maxSize]（默认为128GB）。此选项与FileDistribution处理器一起使用。 |
| -step size                        | 以字节为单位指定分发的粒度（默认为2MB）。此选项与FileDistribution处理器一起使用。 |
| -format                          | 以人类可读的方式而不是多个字节格式化输出结果。（默认为false）。此选项与FileDistribution处理器一起使用。 |
| -delimiter arg                   | 定界字符串以与分隔处理器一起使用。 |
| -t， - temp temporary dir	      | 使用临时目录缓存中间结果以生成分隔输出。如果未设置，则分隔处理器在输出文本之前在内存中构造命名空间。 |
| -h， - help                     | 显示工具使用情况和帮助信息并退出。 |

Hadoop离线图像查看器，用于Hadoop 2.4或更高版本中的图像文件。有关详细信息，请参阅[脱机图像查看器](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HdfsImageViewer.html)


### oiv_legacy

用法：`hdfs oiv_legacy [OPTIONS] -i INPUT_FILE -o OUTPUT_FILE`

| 命令选项                        | 描述                                                         |
| :------------------------------ | :----------------------------------------------------------- |
| -i， - inputFile input file | 指定要处理的输入fsimage文件。 |
| -o， - outputFile output file | 如果指定的输出处理器生成一个，请指定输出文件名。如果指定的文件已存在，则会以静默方式覆盖该文件。 |

可选的命令行参数：

| 命令选项                        | 描述                                                         |
| :------------------------------ | :----------------------------------------------------------- |
| -p \| --processorprocessor | 指定要对图像文件应用的图像处理器。有效选项包括Ls（默认），XML，分隔符，缩进，FileDistribution和NameDistribution。 |
| -maxSize size | 指定要以字节为单位分析的文件大小的范围[0，maxSize]（默认为128GB）。此选项与FileDistribution处理器一起使用。 |
| -step size | 以字节为单位指定分发的粒度（默认为2MB）。此选项与FileDistribution处理器一起使用。 |
| -format | 以人类可读的方式而不是多个字节格式化输出结果。（默认为false）。此选项与FileDistribution处理器一起使用。 |
| -skipBlocks | 不要枚举文件中的单个块。这可以节省具有非常大的文件的命名空间上的处理时间和outfile文件空间。Ls处理器读取块以正确确定文件大小并忽略此选项。 |
| -printToScreen | 将处理器的输出管道输出到控制台以及指定的文件。在极大的命名空间上，这可能会使处理时间增加一个数量级。 |
| -delimiter arg | 与分隔处理器一起使用时，将默认选项卡分隔符替换为arg指定的字符串。 |
| -h \| --help | 显示工具使用情况和帮助信息并退出。 |

适用于旧版Hadoop的Hadoop离线图像查看器。有关详细信息，请参阅[oiv_legacy命令](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HdfsImageViewer.html#oiv_legacy_Command)。

### snapshotDiff

用法：`hdfs snapshotDiff <path> <fromSnapshot> <toSnapshot>`

确定HDFS快照之间的差异。有关更多信息，请参阅[HDFS快照文档](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HdfsSnapshots.html#Get_Snapshots_Difference_Report)。

## version

用法: `hdfs version`

打印版本。


## 二、管理命令(较为常用)

- 对hadoop集群的管理员有用的命令,

### balancer
用法：
```
hdfs balancer
          [-policy <policy>]
          [-threshold <threshold>]
          [-exclude [-f <hosts-file> | <comma-separated list of hosts>]]
          [-include [-f <hosts-file> | <comma-separated list of hosts>]]
          [-source [-f <hosts-file> | <comma-separated list of hosts>]]
          [-blockpools <comma-separated list of blockpool ids>]
          [-idleiterations <idleiterations>]
          [-runDuringUpgrade]
```

| 命令选项                                                    | 描述                                                         |
| :---------------------------------------------------------- | :----------------------------------------------------------- |
| `-policy <policy>`                                            | datanode（默认值）：如果每个datanode均衡，则群集是平衡的。 blockpool：如果每个datanode中的每个块池都是平衡的，则群集是平衡的。 |
| `-threshold <threshold>`                                      | 指定磁盘容量的均衡百分比，这会覆盖默认阈值                   |
| `-exclude -f <hosts-file> \| <comma-separated list of hosts>` | 指定文件中数据节点不会被平衡                                 |
| `-include -f <hosts-file> \| <comma-separated list of hosts>` | 仅仅平衡指定文件中的数据节点                                 |
| `-source -f <hosts-file> \| <comma-separated list of hosts>`  | 仅仅从指定的文件中平衡数据（平衡的源）到其它节点             |
| `-blockpools <comma-separated list of blockpool ids>`         | 平衡器仅在此列表中包含的块池上运行                           |
| `-idleiterations <iterations>`                                | 退出前的最大空闲迭代次数。这会覆盖默认的空闲状态（5）。      |
| `-runDuringUpgrade`                                           | 是否在正在进行的HDFS升级期间运行平衡器，不建议这样做，因为它不会影响过度使用的机器上的已用空间。 |
| -h \| - help                                                  | 显示工具使用情况和帮助信息并退出。                          |

运行集群平衡实用程序。管理员只需按Ctrl-C即可停止重新平衡过程。有关详细信息，请参阅[Balancer](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HdfsUserGuide.html#Balancer)。

请注意，blockpool策略比datanode策略更严格。

除了上述命令选项外，还引入了一个固定功能，从2.7.0开始，以防止某些副本被平衡器/移动器移动。默认情况下，此固定功能处于禁用状态，可通过配置属性“dfs.datanode.block-pinning.enabled”启用。启用时，此功能仅影响写入create（）调用中指定的favored节点的块。对于HBase regionserver等应用程序，我们希望维护数据局部性时，此功能非常有用。

### cacheadmin

用法：
```
hdfs cacheadmin [-addDirective -path <path> -pool <pool-name> [-force] [-replication <replication>] [-ttl <time-to-live>]]
hdfs cacheadmin [-modifyDirective -id <id> [-path <path>] [-force] [-replication <replication>] [-pool <pool-name>] [-ttl <time-to-live>]]
hdfs cacheadmin [-listDirectives [-stats] [-path <path>] [-pool <pool>] [-id <id>]]
hdfs cacheadmin [-removeDirective <id>]
hdfs cacheadmin [-removeDirectives -path <path>]
hdfs cacheadmin [-addPool <name> [-owner <owner>] [-group <group>] [-mode <mode>] [-limit <limit>] [-maxTtl <maxTtl>]]
hdfs cacheadmin [-modifyPool <name> [-owner <owner>] [-group <group>] [-mode <mode>] [-limit <limit>] [-maxTtl <maxTtl>]]
hdfs cacheadmin [-removePool <name>]
hdfs cacheadmin [-listPools [-stats] [<name>]]
hdfs cacheadmin [-help <command-name>]
```

有关更多信息，请参阅[HDFS缓存管理文档](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/CentralizedCacheManagement.html#cacheadmin_command-line_interface)。

### crypto

用法：
```
hdfs crypto -createZone -keyName <keyName> -path <path>
hdfs crypto -listZones
hdfs crypto -provisionTrash -path <path>
hdfs crypto -help <command-name>
```
有关更多信息，请参阅[HDFS透明加密文档](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/TransparentEncryption.html#crypto_command-line_interface)。

### 数据节点升级命令

用法：`hdfs datanode [-regular | -rollback | -rollingupgrade rollback]`

| 命令选项                 | 描述                                                         |
| :----------------------- | :----------------------------------------------------------- |
| -regular                 | 正常的datanode启动（默认）。                                 |
| -rollback                | 将datanode回滚到以前的版本。这应该在停止datanode并分发旧的hadoop版本后使用。 |
| -rollingupgrade rollback | 回滚滚动升级操作。                                           |

运行HDFS datanode。

### dfsadmin（重要）
用法：
```
hdfs dfsadmin [-report [-live] [-dead] [-decommissioning] [-enteringmaintenance] [-inmaintenance]]
hdfs dfsadmin [-safemode enter | leave | get | wait | forceExit]
hdfs dfsadmin [-saveNamespace [-beforeShutdown]]
hdfs dfsadmin [-rollEdits]
hdfs dfsadmin [-restoreFailedStorage true |false |check]
hdfs dfsadmin [-refreshNodes]
hdfs dfsadmin [-setQuota <quota> <dirname>...<dirname>]
hdfs dfsadmin [-clrQuota <dirname>...<dirname>]
hdfs dfsadmin [-setSpaceQuota <quota> [-storageType <storagetype>] <dirname>...<dirname>]
hdfs dfsadmin [-clrSpaceQuota [-storageType <storagetype>] <dirname>...<dirname>]
hdfs dfsadmin [-finalizeUpgrade]
hdfs dfsadmin [-rollingUpgrade [<query> |<prepare> |<finalize>]]
hdfs dfsadmin [-upgrade [query | finalize]
hdfs dfsadmin [-refreshServiceAcl]
hdfs dfsadmin [-refreshUserToGroupsMappings]
hdfs dfsadmin [-refreshSuperUserGroupsConfiguration]
hdfs dfsadmin [-refreshCallQueue]
hdfs dfsadmin [-refresh <host:ipc_port> <key> [arg1..argn]]
hdfs dfsadmin [-reconfig <namenode|datanode> <host:ipc_port> <start |status |properties>]
hdfs dfsadmin [-printTopology]
hdfs dfsadmin [-refreshNamenodes datanodehost:port]
hdfs dfsadmin [-getVolumeReport datanodehost:port]
hdfs dfsadmin [-deleteBlockPool datanode-host:port blockpoolId [force]]
hdfs dfsadmin [-setBalancerBandwidth <bandwidth in bytes per second>]
hdfs dfsadmin [-getBalancerBandwidth <datanode_host:ipc_port>]
hdfs dfsadmin [-fetchImage <local directory>]
hdfs dfsadmin [-allowSnapshot <snapshotDir>]
hdfs dfsadmin [-disallowSnapshot <snapshotDir>]
hdfs dfsadmin [-shutdownDatanode <datanode_host:ipc_port> [upgrade]]
hdfs dfsadmin [-evictWriters <datanode_host:ipc_port>]
hdfs dfsadmin [-getDatanodeInfo <datanode_host:ipc_port>]
hdfs dfsadmin [-metasave filename]
hdfs dfsadmin [-triggerBlockReport [-incremental] <datanode_host:ipc_port>]
hdfs dfsadmin [-listOpenFiles [-blockingDecommission] [-path <path>]]
hdfs dfsadmin [-help [cmd]]
```

| 命令选项                                                     | 描述                                                         |
| :----------------------------------------------------------- | :----------------------------------------------------------- |
| `-report [-live] [-dead] [-decommissioning] [-enteringmaintenance] [-inmaintenance]` | 打印基本的集群健康信息，可选参数可用于对显示的DataNode列表进行过滤 |
| `-safemode enter\|leave\|get\|wait\|forceExit`                 | 进入\|离开\|获取\|等待\|强制离开   安全模式                  |
| `-saveNamespace [-beforeShutdown]`                             | 在安全模式条件下，保存元数据到fsiamge，即落盘。如果给出“beforeShutdown”选项，则当且仅当在时间窗口期间没有完成检查点（可配置数量的检查点周期）时，NameNode才会执行检查点。这通常在关闭NameNode之前使用，以防止潜在的fsimage / editlog损坏，可以进行手动保存 |
| `-rollEdits`                                                   | 在active 的 NameNode上滚动 editlog                           |
| `-restoreFailedStorage true \| false \| check`                 | 此选项将打开/关闭自动尝试以还原失败的存储副本。如果故障存储再次可用，系统将尝试在检查点期间恢复编辑和/或fsimage。'check'选项将返回当前设置。 |
| `-refreshNodes`                                                | 重新读取主机并读取排除文件（exclude file）以更新允许连接到Namenode的数据节点集以及应该退役或重新调试的数据节点集。 |
| `-setQuota <quota> <dirname> ... <dirname>`                    | 设置目录的quota信息，请参阅[HDFS配额指南](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HdfsQuotaAdminGuide.html#Administrative_Commands)。 |
| `-clrQuota <dirname> ... <dirname>`                            | 清空目录的quota信息，请参阅[HDFS配额指南](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HdfsQuotaAdminGuide.html#Administrative_Commands)。 |
| `-setSpaceQuota <quota> [-storageType <storagetype>] <dirname> ... <dirname>` | 有关详细信息，请参阅[HDFS配额指南](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HdfsQuotaAdminGuide.html#Administrative_Commands)。 |
| `-clrSpaceQuota [ -storageType<storagetype>] <dirname> ... <dirname>` | 有关详细信息，请参阅[HDFS配额指南](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HdfsQuotaAdminGuide.html#Administrative_Commands)。 |
| `-finalizeUpgrade`                                             | 完成HDFS的升级，Datanodes删除其先前版本的工作目录，然后Namenode执行相同操作，该命令执行后表示升级已经完成。 |
| `-rollingUpgrade [<query> \| <prepare> \| <finalize>]`         | 有关详细信息，请参阅[滚动升级文档](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HdfsRollingUpgrade.html#dfsadmin_-rollingUpgrade) |
| `-upgrade query \| finalize`                                   | 查询当前升级状态。 完成HDFS的升级（相当于-finalizeUpgrade）。 |
| `-refreshServiceAcl`                                           | 重新加载服务级别授权策略文件。                               |
| `-refreshUserToGroupsMappings`                                 | 刷新用户到组的映射。                                         |
| `-refreshSuperUserGroupsConfiguration`                         | 刷新超级用户代理组映射                                       |
| `-refreshCallQueue`                                            | 从config重新加载呼叫队列。                                   |
| `-refresh <host：ipc_port> <key> [arg1..argn]`                 | 触发`<host：ipc_port>`上`<key>`指定的资源的运行时刷新。之后的所有其他args被发送到主机。 |
| `-reconfig <datanode \| namenode> <host：ipc_port> <start \| status \| properties>` | 开始重新配置或获取正在进行的重新配置的状态，或获取可重新配置属性的列表。第二个参数指定节点类型。 |
| `-printTopology`                                               | 根据Namenode的报告打印机架及其节点的树                       |
| `-refreshNamenodes datanodehost：port`                         | 对于给定的datanode，重新加载配置文件，停止为已删除的块池提供服务并开始提供新的块池。 |
| `-getVolumeReport datanodehost：port`                          | 对于给定的datanode，获取卷报告。                             |
| `-deleteBlockPool datanode-host：port blockpoolId [force]`     | 如果强制传递，则删除给定datanode上给定blockpool id的块池目录及其内容，否则仅当目录为空时才删除该目录。如果datanode仍在为块池提供服务，则该命令将失败。请参阅refreshNamenodes以关闭datanode上的块池服务。 |
| `-setBalancerBandwidth <bandwidth in bytes per second>`        | 在HDFS块平衡期间更改每个数据节点使用的网络带宽。`<bandwidth>`是每个datanode将使用的每秒最大字节数。此值将覆盖dfs.datanode.balance.bandwidthPerSec参数。注意：新值在DataNode上不是持久的。 |
| `-getBalancerBandwidth <datanode_host：ipc_port>`              | 获取给定datanode的网络带宽（以每秒字节数为单位）。这是在HDFS块平衡期间datanode使用的最大网络带宽。 |
| `-fetchImage <local directory>`                                | 从NameNode下载最新的fsimage并将其保存在指定的本地目录中。    |
| `-allowSnapshot <snapshotDir>`                                 | 允许创建目录的快照。如果操作成功完成，则该目录将变为快照。有关更多信息，请参阅[HDFS快照文档](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HdfsSnapshots.html)。 |
| `-disallowSnapshot <snapshotDir>`                              | 不允许创建目录的快照。在禁止快照之前，必须删除目录的所有快照。有关更多信息，请参阅[HDFS快照文档](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HdfsSnapshots.html)。 |
| `-shutdownDatanode <datanode_host：ipc_port> [upgrade]`        | 提交给定datanode的关闭请求。有关详细信息，请参阅[滚动升级文档](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HdfsRollingUpgrade.html#dfsadmin_-shutdownDatanode) |
| `-evictWriters <datanode_host：ipc_port>`                      | 使datanode驱逐所有正在编写块的客户端。如果由于编写速度慢而停止停用，这将非常有用。 |
| `-getDatanodeInfo <datanode_host：ipc_port>`                   | 获取有关给定datanode的信息。有关详细信息，请参阅[滚动升级文档](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HdfsRollingUpgrade.html#dfsadmin_-getDatanodeInfo) |
| `-metasave filename`                                           | 保存的Namenode的主要数据结构，*文件名*由hadoop.log.dir属性指定的目录。如果存在，则覆盖*filename*。*filename*将包含以下每一行的一行 1.使用Namenode心跳的数据节点 2.等待复制的 块3.当前正在复制的 块4.等待删除的块 |
| `-triggerBlockReport [-incremental]<datanode_host：ipc_port>`  | 触发给定datanode的块报告。如果指定'incremental'，则不然，它将是一个完整的块报告。 |
| `-listOpenFiles [ -blockingDecommission ] [-path <path>]`      | 列出NameNode当前管理的所有打开文件以及访问它们的客户端名称和客户端计算机。打开的文件列表将按给定的类型和路径进行过滤。 |
| `-help [cmd]`                                                  | 显示给定命令或所有命令的帮助（如果未指定）。                 |

运行HDFS dfsadmin客户端。

```
$ hdfs dfsadmin -printTopology
Rack: /default-rack
   10.0.1.80:50010 (hadoopcluster80)
   10.0.1.82:50010 (hadoopcluster82)
   10.0.1.83:50010 (hadoopcluster83)
   10.0.1.84:50010 (hadoopcluster84)
```

### dfsrouter

用法：`hdfs dfsrouter`

运行DFS路由器。见[路由器](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs-rbf/HDFSRouterFederation.html#Router)的更多信息。

### dfsrouteradmin
用法：
```
    hdfs dfsrouteradmin
      [-add <source> <nameservice1, nameservice2, ...> <destination> [-readonly] [-order HASH|LOCAL|RANDOM|HASH_ALL] -owner <owner> -group <group> -mode <mode>]
      [-update <source> <nameservice1, nameservice2, ...> <destination> [-readonly] [-order HASH|LOCAL|RANDOM|HASH_ALL] -owner <owner> -group <group> -mode <mode>]
      [-rm <source>]
      [-ls <path>]
      [-setQuota <path> -nsQuota <nsQuota> -ssQuota <quota in bytes or quota size string>]
      [-clrQuota <path>]
      [-safemode enter | leave | get]
      [-nameservice disable | enable <nameservice>]
      [-getDisabledNameservices]
```

| 命令选项                                               | 描述                                                         |
| :----------------------------------------------------- | :----------------------------------------------------------- |
| -add **source** **nameservices** **destination**             | 添加装入表条目或更新（如果存在）。                           |
| -update **source** **nameservices** **destination**          | 更新装入表条目或创建一个条目（如果不存在）。                 |
| -rm **source**                                           | 删除指定路径的安装点。                                       |
| -ls **path**                                             | 列出指定路径下的挂载点。                                     |
| -setQuota **path** -nsQuota **nsQuota** -ssQuota **ssQuota** | 设置指定路径的配额。有关配额详细信息，请参阅[HDFS配额指南](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HdfsQuotaAdminGuide.html)。 |
| -clrQuota **path**                                       | 清除给定挂载点的配额。有关配额详细信息，请参阅[HDFS配额指南](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HdfsQuotaAdminGuide.html)。 |
| -safemode enter leave get                              | 手动设置路由器进入或离开安全模式。选项*get*将用于验证路由器是否处于安全模式状态。 |
| -nameservice disable enable **nameservice**              | 禁用/启用联盟中的名称服务。如果禁用，请求将不会转到该名称服务。 |
| -getDisabledNameservices                               | 获取联合中禁用的名称服务。                                   |

用于管理基于路由器的联合的命令。有关详细信息，请参阅[挂载表管理](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs-rbf/HDFSRouterFederation.html#Mount_table_management)。

### diskbalancer
用法：
```
   hdfs diskbalancer
     [-plan <datanode> -fs <namenodeURI>]
     [-execute <planfile>]
     [-query <datanode>]
     [-cancel <planfile>]
     [-cancel <planID> -node <datanode>]
     [-report -node <file://> | [<DataNodeID|IP|Hostname>,...]]
     [-report -node -top <topnum>]
```

| 命令选项 | 描述                                 |
| :------- | :----------------------------------- |
| -plan    | 创建一个失衡者计划                   |
| -execute | 在datanode上执行给定的计划           |
| -query   | 从datanode获取当前的diskbalancer状态 |
| -cancle  | 取消正在运行的计划                   |
| -report  | 报告来自datanode的卷信息             |

运行diskbalancer CLI。有关此命令的更多信息，请参阅[HDFS Diskbalancer](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSDiskbalancer.html)。

### ec
用法：
```
hdfs ec [generic options]
     [-setPolicy -policy <policyName> -path <path>]
     [-getPolicy -path <path>]
     [-unsetPolicy -path <path>]
     [-listPolicies]
     [-addPolicies -policyFile <file>]
     [-listCodecs]
     [-enablePolicy -policy <policyName>]
     [-disablePolicy -policy <policyName>]
     [-help [cmd ...]]
```

| 命令选项 | 描述                                 |
| :------- | :----------------------------------- |
| -setPolicy | 将指定的ErasureCoding策略设置为目录 |
| -getPolicy | 获取有关指定路径的ErasureCoding策略信息 |
| -unsetPolicy | 取消先前对目录上的“setPolicy”调用设置的ErasureCoding策略 |
| -listPolicies | 列出所有支持的ErasureCoding策略 |
| -addPolicies | 添加擦除编码策略列表 |
| -listCodecs | 获取系统中支持的擦除编码编解码器和编码器列表 |
| -enablePolicy | 在系统中启用ErasureCoding策略 |
| -disablePolicy | 在系统中禁用ErasureCoding策略 |

运行ErasureCoding CLI。有关此命令的更多信息，请参阅[HDFS ErasureCoding](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSErasureCoding.html#Administrative_commands)。


### haadmin
用法：
```
    hdfs haadmin -transitionToActive <serviceId> [--forceactive]
    hdfs haadmin -transitionToStandby <serviceId>
    hdfs haadmin -failover [--forcefence] [--forceactive] <serviceId> <serviceId>
    hdfs haadmin -getServiceState <serviceId>
    hdfs haadmin -getAllServiceState
    hdfs haadmin -checkHealth <serviceId>
    hdfs haadmin -help <command>
```

| 命令选项             | 描述                                                    |
| :------------------- | :------------------------------------------------------ |
| -checkHealth         | 检查给定NameNode的运行状况                              |
| -failover            | 在两个NameNode之间启动故障转移                          |
| -getServiceState     | 确定给定的NameNode是Active还是Standby                   |
| -getAllServiceState  | 返回所有NameNode的状态                                  |
| -transitionToActive  | 将给定NameNode的状态转换为Active（警告：不执行防护）    |
| -transitionToStandby | 将给定NameNode的状态转换为Standby（警告：没有完成防护） |
| -help [cmd]          | 显示给定命令或所有命令的帮助（如果未指定）。            |

有关此命令的更多信息，请参阅带有[NFS的HDFS HA](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSHighAvailabilityWithNFS.html#Administrative_commands)或[带有QJM的HDFS HA](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSHighAvailabilityWithQJM.html#Administrative_commands)。

### journalnode

用法：`hdfs journalnode`

此comamnd启动一个日志节点，用于与[QJM一起](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSHighAvailabilityWithQJM.html#Administrative_commands)使用[HDFS HA](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSHighAvailabilityWithQJM.html#Administrative_commands)。

### mover

用法: `hdfs mover [-p <files/dirs> | -f <local file name>]`

| 命令选项        | 描述                                          |
| :-------------- | :-------------------------------------------- |
| -f `<local file>` | 指定包含要迁移的HDFS文件/目录列表的本地文件。 |
| -p `<files/dirs>` | 指定要迁移的HDFS文件/目录的空格分隔列表。     |

运行数据迁移实用程序。有关详细信息，请参阅[Mover](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/ArchivalStorage.html#Mover_-_A_New_Data_Migration_Tool)。

请注意，当省略-p和-f选项时，默认路径是根目录。

此外，从2.7.0开始引入固定功能，以防止某些复制品被平衡器/移动器移动。默认情况下，此固定功能处于禁用状态，可通过配置属性“dfs.datanode.block-pinning.enabled”启用。启用时，此功能仅影响写入create（）调用中指定的favored节点的块。对于HBase regionserver等应用程序，我们希望维护数据局部性时，此功能非常有用。

### namenode
用法：
```
    hdfs namenode [-backup] |
          [-checkpoint] |
          [-format [-clusterid cid ] [-force] [-nonInteractive] ] |
          [-upgrade [-clusterid cid] [-renameReserved<k-v pairs>] ] |
          [-upgradeOnly [-clusterid cid] [-renameReserved<k-v pairs>] ] |
          [-rollback] |
          [-rollingUpgrade <rollback |started> ] |
          [-importCheckpoint] |
          [-initializeSharedEdits] |
          [-bootstrapStandby [-force] [-nonInteractive] [-skipSharedEditsCheck] ] |
          [-recover [-force] ] |
          [-metadataVersion ]
```

| 命令选项                                                     | 描述                                                         |
| :----------------------------------------------------------- | :----------------------------------------------------------- |
| -backup                                                      | 启动备份节点。                                               |
| -checkpoint                                                  | 启动检查点节点。                                             |
| -format [-clusterid cid]                                     | 格式化指定的NameNode。它启动NameNode，对其进行格式化然后将其关闭。如果name dir已存在且是否为集群禁用了重新格式化，则将抛出NameNodeFormatException。 |
| -upgrade [-clusterid cid] [ -renameReserved <kv pairs>]      | 在分发新的Hadoop版本后，应该使用升级选项启动Namenode。       |
| -upgradeOnly [-clusterid cid] [ -renameReserved <kv pairs>]  | 升级指定的NameNode然后关闭它。                               |
| -rollback                                                    | 将NameNode回滚到以前的版本。应在停止群集并分发旧Hadoop版本后使用此方法。 |
| -rollingUpgrade <rollback \| started>                        | 有关详细信息，请参阅[滚动升级文档](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HdfsRollingUpgrade.html#NameNode_Startup_Options) |
| -importCheckpoint                                            | 从检查点目录加载图像并将其保存到当前目录中。从属性dfs.namenode.checkpoint.dir读取检查点目录 |
| -initializeSharedEdits                                       | 格式化新的共享编辑目录并复制足够的编辑日志段，以便备用NameNode可以启动。 |
| -bootstrapStandby [-force] [-nonInteractive] [-skipSharedEditsCheck] | 允许通过从活动NameNode复制最新的命名空间快照来引导备用NameNode的存储目录。首次配置HA群集时使用此选项。-force或-nonInteractive选项与namenode -format命令中描述的含义相同。-skipSharedEditsCheck选项跳过编辑检查，确保我们在共享目录中已经有足够的编辑从活动的最后一个检查点启动。 |
| -recover [-force]                                            | 在损坏的文件系统上恢复丢失的元数据。有关详细信息，请参阅[HDFS用户指南](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HdfsUserGuide.html#Recovery_Mode)。 |
| -metadataVersion                                             | 验证配置的目录是否存在，然后打印软件和映像的元数据版本。     |

运行namenode。有关升级和回滚的更多信息，请参阅[升级回滚](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HdfsUserGuide.html#Upgrade_and_Rollback)。

### nfs3

用法：`hdfs nfs3`

此comamnd启动NFS3网关以与[HDFS NFS3服务一起使用](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HdfsNfsGateway.html#Start_and_stop_NFS_gateway_service)。

### 端口映射

用法：`hdfs portmap`

此comamnd启动RPC [端口映射](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HdfsNfsGateway.html#Start_and_stop_NFS_gateway_service)以与[HDFS NFS3服务一起使用](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HdfsNfsGateway.html#Start_and_stop_NFS_gateway_service)。

### secondarynamenode

用法：`hdfs secondarynamenode [-checkpoint [force]] | [-format] | [-geteditsize]`

| 命令选项  | 描述                                                         |
| :-------- | :----------------------------------------------------------- |
| -checkpoint [force] | 如果EditLog size> = fs.checkpoint.size，则检查SecondaryNameNode。如果使用force，则检查点与EditLog大小无关。 |
| -format | 启动期间格式化本地存储。 |
| -geteditsize | 打印NameNode上未取消选中的事务的数量。 |

运行HDFS辅助名称节点。有关详细信息，请参阅[Secondary Namenode](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HdfsUserGuide.html#Secondary_NameNode)。

### storagepolicies
用法：
```
  hdfs storagepolicies
      [-listPolicies]
      [-setStoragePolicy -path <path> -policy <policy>]
      [-getStoragePolicy -path <path>]
      [-unsetStoragePolicy -path <path>]
      [-satisfyStoragePolicy -path <path>]
      [-isSatisfierRunning]
      [-help <command-name>]
```
列出所有 all/Gets/sets/unsets 存储策略。有关更多信息，请参阅[HDFS存储策略文档](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/ArchivalStorage.html)。

### zkfc

用法：`hdfs zkfc [-formatZK [-force] [-nonInteractive]]`

| 命令选项  | 描述                                                         |
| :-------- | :----------------------------------------------------------- |
| -formatZK | 格式化Zookeeper实例。-force：如果znode存在，则格式化znode。-nonInteractive：如果znode存在，则格式化znode中止，除非指定了-force选项。 |
| -h        | 显示帮助                                                     |

此comamnd启动Zookeeper故障转移控制器进程，以便与[带有QJM的HDFS HA一起使用](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-hdfs/HDFSHighAvailabilityWithQJM.html#Administrative_commands)。

## 三、调试命令

帮助管理员调试HDFS问题的有用命令。这些命令仅适用于高级用户。

### verifyMeta

用法：`hdfs debug verifyMeta -meta <metadata-file> [-block <block-file>]`

| 命令选项              | 描述                                                         |
| :-------------------- | :----------------------------------------------------------- |
| -block *block-file*   | 可选参数，用于指定数据节点的本地文件系统上的块文件的绝对路径。 |
| -meta *metadata-file* | 数据节点的本地文件系统上的元数据文件的绝对路径。             |

验证HDFS元数据和块文件。如果指定了块文件，我们将验证元数据文件中的校验和是否与块文件匹配。

### computeMeta

用法：`hdfs debug computeMeta -block <block-file> -out <output-metadata-file>`

| 命令选项                    | 描述                                                       |
| :-------------------------- | :--------------------------------------------------------- |
| -block block-file         | 数据节点的本地文件系统上的块文件的绝对路径。               |
| -out output-metadata-file | 输出元数据文件的绝对路径，用于存储块文件的校验和计算结果。 |

从块文件计算HDFS元数据。如果指定了块文件，我们将从块文件计算校验和，并将其保存到指定的输出元数据文件中。

注意：使用风险自负！如果块文件损坏并且您覆盖了它的元文件，它将在HDFS中显示为“良好”，但您无法读取数据。仅用作最后一个度量，当您100％确定块文件是好的时。

### recoverLease

用法：`hdfs debug recoverLease -path <path> [-retries <num-retries>]`

| 命令选项                   | 描述                                                |
| :------------------------- | :-------------------------------------------------- |
| [ -path **path** ]           | 要恢复租约的HDFS路径。                              |
| [ -retries **num-retries** ] | 客户端重试调用recoverLease的次数。默认重试次数为1。 |

恢复指定路径上的租约。该路径必须驻留在HDFS文件系统上。默认重试次数为1。

参考：
- https://blog.51cto.com/u_9955199/3225646
- https://zhangboyi.blog.csdn.net/?type=blog
