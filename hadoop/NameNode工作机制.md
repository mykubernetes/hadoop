
# 一. NN和2NN工作机制

**问题引出**： NameNode如何管理和存储元数据?

计算机中存储数据的两种方式：磁盘、内存
- 元数据存储磁盘：存储磁盘⽆法⾯对客户端对元数据信息的随机访问，还有响应客户请求，必然是效率过低。但是安全性⾼
- 元数据存储内存：元数据存放内存，可以高效的查询以及快速响应客户端的查询请求，数据保存在内存，如果断点，内存中的数据全部丢失。安全性低

**解决办法**： 内存+磁盘;NameNode内存+FsImage的⽂件(磁盘)

**新问题**： 磁盘和内存中元数据如何划分?

两个数据一模⼀样，还是两个数据合并到一起才是⼀份完整的数据呢?
- 如果两份数据一模一样的话，客户端 Client 如果对元数据进行增删改操作，则需要时刻保证两份数据的一致性，导致效率变低
- 如果两份数据合并后 ==> 完整数据的情况。NameNode 引入了 edits 文件（日志文件，只能追加写入），记录了client 的增删改操作，而不再让 NameNode 把数据 dump 出来形成 fsimage文件（让 NameNode 专注于处理客户端的请求）
- edits文件：文件生成快，恢复慢；fsimage文件：文件生成慢，恢复快

**新问题**： 谁来负责文件合并？

如果长时间添加数据到Edits中，会导致该文件数据过大，效率降低，而且一旦断电，恢复元数据需要的时间过长。因此，需要定期进行FsImage和Edits的合并，但是谁来合并？

- NameNode：NameNode本身任务重，再负责合并，势必效率过低，甚至会影响本身的任务
- 因此，引入一个新的节点SecondaryNamenode，专门用于FsImage和Edits的合并。


# 二、流程分析

## 1）第一阶段：namenode启动  

- 1、第一次启动NameNode格式化后，创建Fsimage和Edits文件。如果不是第一次启动，直接加载编辑日志和镜像文件到内存。
- 2、客户端对元数据进行增删改的请求。
- 3、NameNode记录操作日志，更新滚动日志（所谓滚动日志，即 把前一阶段的日志保存成一个日志文件，再新生成一个文件，新生成文件后缀带有 inprogress 字样）。
- 4、NameNode在内存中对数据进行增删改。


## 2）第二阶段：Secondary NameNode工作

- 1、Secondary NameNode询问NameNode是否需要CheckPoint。直接带回NameNode是否检查结果。
- 2、Secondary NameNode请求执行CheckPoint。
- 3、NameNode滚动正在写的Edits日志。
- 4、将滚动前的编辑日志和镜像文件拷贝到Secondary NameNode。
- 5、Secondary NameNode加载编辑日志和镜像文件到内存，并合并。
- 6、生成新的镜像文件fsimage.chkpoint。
- 7、拷贝fsimage.chkpoint到NameNode。
- 8、NameNode将fsimage.chkpoint重新命名成fsimage。

## 3）web端访问SecondaryNameNode

- 1、启动集群
- 2、浏览器中输入：http://node01:50090/status.html
- 3、查看SecondaryNameNode信息
 

## 4）chkpoint检查时间参数设置

- 1、通常情况下，SecondaryNameNode每隔一小时执行一次。  

**hdfs-default.xml**
```
  <property>  
    <name>dfs.namenode.checkpoint.period</name>  
    <value>3600</value>  
  </property>
```

- 2、一分钟检查一次操作次数，当操作次数达到1百万时，SecondaryNameNode执行一次。  
```
  <property>  
    <name>dfs.namenode.checkpoint.txns</name>  
    <value>1000000</value>  
  <description>操作动作次数</description>  
  </property>
  
  <property>  
    <name>dfs.namenode.checkpoint.check.period</name>  
    <value>60</value>  
  <description> 1分钟检查一次操作次数</description>  
  </property> 
```

# 三、NN和2NN工作机制详解

- Fsimage：NameNode内存中元数据序列化后形成的文件。

- Edits：记录客户端更新元数据信息的每一步操作（可通过Edits运算出元数据）。

- NameNode启动时，先滚动Edits并生成一个空的edits.inprogress，然后加载Edits和Fsimage到内存中，此时NameNode内存就持有最新的元数据信息。Client开始对NameNode发送元数据的增删改的请求，这些请求的操作首先会被记录到edits.inprogress中（查询元数据的操作不会被记录在Edits中，因为查询操作不会更改元数据信息），如果此时NameNode挂掉，重启后会从Edits中读取元数据的信息。然后，NameNode会在内存中执行元数据的增删改的操作。

- 由于Edits中记录的操作会越来越多，Edits文件会越来越大，导致NameNode在启动加载Edits时会很慢，所以需要对Edits和Fsimage进行合并（所谓合并，就是将Edits和Fsimage加载到内存中，照着Edits中的操作一步步执行，最终形成新的Fsimage）。SecondaryNameNode的作用就是帮助NameNode进行Edits和Fsimage的合并工作。

- SecondaryNameNode首先会询问NameNode是否需要CheckPoint（触发CheckPoint需要满足两个条件中的任意一个，定时时间到和Edits中数据写满了）。直接带回NameNode是否检查结果。SecondaryNameNode执行CheckPoint操作，首先会让NameNode滚动Edits并生成一个空的edits.inprogress，滚动Edits的目的是给Edits打个标记，以后所有新的操作都写入edits.inprogress，其他未合并的Edits和Fsimage会拷贝到SecondaryNameNode的本地，然后将拷贝的Edits和Fsimage加载到内存中进行合并，生成fsimage.chkpoint，然后将fsimage.chkpoint拷贝给NameNode，重命名为Fsimage后替换掉原来的Fsimage。NameNode在启动时就只需要加载之前未合并的Edits和Fsimage即可，因为合并过的Edits中的元数据信息已经被记录在Fsimage中。


# 四、镜像文件和编辑日志文件  

1）概念: namenode被格式化之后，将在/opt/module/hadoop-2.7.2/data/tmp/dfs/name/current目录中产生如下文件
```
edits_0000000000000000000
fsimage_0000000000000000000.md5
seen_txid
VERSION
```
（1）Fsimage文件：HDFS文件系统元数据的一个永久性的检查点，其中包含HDFS文件系统的所有目录和文件idnode的序列化信息。  
（2）Edits文件：存放HDFS文件系统的所有更新操作的路径，文件系统客户端执行的所有写操作首先会被记录到edits文件中。  
（3）seen_txid文件保存的是一个数字，就是最后一个edits_的数字  
（4）每次Namenode启动的时候都会将fsimage文件读入内存，并从00001开始到seen_txid中记录的数字依次执行每个edits里面的更新操作，保证内存中的元数据信息是最新的、同步的，可以看成Namenode启动的时候就将fsimage和edits文件进行了合并。  

2）oiv查看fsimage文件  
（1）查看oiv和oev命令  
```
hdfs --help  
oiv                  apply the offline fsimage viewer to an fsimage
oev                  apply the offline edits viewer to an edits file
```

（2）基本语法
```
hdfs oiv -p 文件类型 -i镜像文件 -o 转换后文件输出路径  
```

（3）案例实操  
```
/opt/module/hadoop-2.7.2/data/tmp/dfs/name/current
hdfs oiv -p XML -i fsimage_0000000000000000025 -o /opt/module/hadoop-2.7.2/fsimage.xml
cat /opt/module/hadoop-2.7.2/fsimage.xml
```
将显示的xml文件内容拷贝到eclipse中创建的xml文件中，并格式化。  

3）oev查看edits文件  

（1）基本语法  
```
hdfs oev -p 文件类型 -i编辑日志 -o 转换后文件输出路径  
```

（2）案例实操  
```
hdfs oev -p XML -i edits_0000000000000000012-0000000000000000013 -o /opt/module/hadoop-2.7.2/edits.xml
cat /opt/module/hadoop-2.7.2/edits.xml
```
将显示的xml文件内容拷贝到eclipse中创建的xml文件中，并格式化。  

# 五、滚动编辑日志  
正常情况HDFS文件系统有更新操作时，就会滚动编辑日志。也可以用命令强制滚动编辑日志。

1）滚动编辑日志（前提必须启动集群）  
```
hdfs dfsadmin -rollEdits  
```

2）镜像文件什么时候产生  
Namenode启动时加载镜像文件和编辑日志  


# 六、 namenode版本号  

1）查看namenode版本号  
在/opt/module/hadoop-2.7.2/data/tmp/dfs/name/current这个目录下查看VERSION
```
namespaceID=1933630176
clusterID=CID-1f2bf8d1-5ad2-4202-af1c-6713ab381175
cTime=0
storageType=NAME_NODE
blockpoolID=BP-97847618-192.168.10.102-1493726072779
layoutVersion=-63
```
2）namenode版本号具体解释  
（1）namespaceID在HDFS上，会有多个Namenode，所以不同Namenode的namespaceID是不同的，分别管理一组blockpoolID。  
（2）clusterID集群id，全局唯一  
（3）cTime属性标记了namenode存储系统的创建时间，对于刚刚格式化的存储系统，这个属性为0；但是在文件系统升级之后，该值会更新到新的时间戳。  
（4）storageType属性说明该存储目录包含的是namenode的数据结构。  
（5）blockpoolID：一个block pool id标识一个block pool，并且是跨集群的全局唯一。当一个新的Namespace被创建的时候(format过程的一部分)会创建并持久化一个唯一ID。在创建过程构建全局唯一的BlockPoolID比人为的配置更可靠一些。NN将BlockPoolID持久化到磁盘中，在后续的启动过程中，会再次load并使用。  
（6）layoutVersion是一个负整数。通常只有HDFS增加新特性时才会更新这个版本号。  



# 七、SecondaryNameNode目录结构  

Secondary NameNode用来监控HDFS状态的辅助后台程序，每隔一段时间获取HDFS元数据的快照。  
在/opt/module/hadoop-2.7.2/data/tmp/dfs/namesecondary/current这个目录中查看SecondaryNameNode目录结构。  
```
edits_0000000000000000001-0000000000000000002
fsimage_0000000000000000002
fsimage_0000000000000000002.md5
VERSION
```
SecondaryNameNode的namesecondary/current目录和主namenode的current目录的布局相同。  
好处：在主namenode发生故障时（假设没有及时备份数据），可以从SecondaryNameNode恢复数据。  
方法一：将SecondaryNameNode中数据拷贝到namenode存储数据的目录；  
方法二：使用-importCheckpoint选项启动namenode守护进程，从而将SecondaryNameNode用作新的主namenode。  
1）案例实操（一）：  
模拟namenode故障，并采用方法一，恢复namenode数据  
（1）kill -9 namenode进程

（2）删除namenode存储的数据（/opt/module/hadoop-2.7.2/data/tmp/dfs/name）
```
rm -rf /opt/module/hadoop-2.7.2/data/tmp/dfs/name/*  
```

（3）拷贝SecondaryNameNode中数据到原namenode存储数据目录  
```
cp -R /opt/module/hadoop-2.7.2/data/tmp/dfs/namesecondary/* /opt/module/hadoop-2.7.2/data/tmp/dfs/name/  
```

（4）重新启动namenode  
```
sbin/hadoop-daemon.sh start namenode  
```

2）案例实操（二）：  
模拟namenode故障，并采用方法二，恢复namenode数据  
（0）修改hdfs-site.xml中的  
```
<property>
  <name>dfs.namenode.checkpoint.period</name>
  <value>120</value>
</property>

<property>
  <name>dfs.namenode.name.dir</name>
  <value>/opt/module/hadoop-2.7.2/data/tmp/dfs/name</value>
</property>
```

（1）kill -9 namenode进程  

（2）删除namenode存储的数据（/opt/module/hadoop-2.7.2/data/tmp/dfs/name）  
```
rm -rf /opt/module/hadoop-2.7.2/data/tmp/dfs/name/*  
```

（3）如果SecondaryNameNode不和Namenode在一个主机节点上，需要将SecondaryNameNode存储数据的目录拷贝到Namenode存储数据的平级目录。  
```
 pwd
/opt/module/hadoop-2.7.2/data/tmp/dfs
ls
data  name  namesecondary
```

（4）导入检查点数据（等待一会ctrl+c结束掉）
```
bin/hdfs namenode -importCheckpoint  
```

（5）启动namenode
```
sbin/hadoop-daemon.sh start namenode
```

（6）如果提示文件锁了，可以删除in_use.lock 
```
rm -rf /opt/module/hadoop-2.7.2/data/tmp/dfs/namesecondary/in_use.lock
```


# 八、 集群安全模式操作  

1）概述  
  Namenode启动时，首先将映像文件（fsimage）载入内存，并执行编辑日志（edits）中的各项操作。一旦在内存中成功建立文件系统元数据的映像，则创建一个新的    fsimage文件和一个空的编辑日志。此时，namenode开始监听datanode请求。但是此刻，namenode运行在安全模式，即namenode的文件系统对于客户端来说是只读的。  
  系统中的数据块的位置并不是由namenode维护的，而是以块列表的形式存储在datanode中。在系统的正常操作期间，namenode会在内存中保留所有块位置的映射信息。在安全模式下，各个datanode会向namenode发送最新的块列表信息，namenode了解到足够多的块位置信息之后，即可高效运行文件系统。  
  如果满足“最小副本条件”，namenode会在30秒钟之后就退出安全模式。所谓的最小副本条件指的是在整个文件系统中99.9%的块满足最小副本级别（默认    值：dfs.replication.min=1）。在启动一个刚刚格式化的HDFS集群时，因为系统中还没有任何块，所以namenode不会进入安全模式。  

2）基本语法  
集群处于安全模式，不能执行重要操作（写操作）。集群启动完成后，自动退出安全模式。
```
bin/hdfs dfsadmin -safemode get	        （功能描述：查看安全模式状态）
bin/hdfs dfsadmin -safemode enter       （功能描述：进入安全模式状态）
bin/hdfs dfsadmin -safemode leave       （功能描述：离开安全模式状态）
bin/hdfs dfsadmin -safemode wait        （功能描述：等待安全模式状
```

3）案例    

模拟等待安全模式  

1、先进入安全模式  
```
bin/hdfs dfsadmin -safemode enter
```

2、执行下面的脚本  
编辑一个脚本  
```
#!/bin/bash
bin/hdfs dfsadmin -safemode wait
bin/hdfs dfs -put ~/hello.txt /root/hello.txt
```

3、再打开一个窗口，执行  
```
bin/hdfs dfsadmin -safemode leave  
```

# 九、 Namenode多目录配置  

1）namenode的本地目录可以配置成多个，且每个目录存放内容相同，增加了可靠性。  

2）具体配置如下：  

**hdfs-site.xml**
```
<property>
    	<name>dfs.namenode.name.dir</name>
	<value>file:///${hadoop.tmp.dir}/dfs/name1,file:///${hadoop.tmp.dir}/dfs/name2</value>
</property>
```
