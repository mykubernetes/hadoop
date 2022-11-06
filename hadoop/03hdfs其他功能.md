HDFS其他功能
---
一、 集群间数据拷贝
---
采用discp命令实现两个hadoop集群之间的递归数据复制
```
bin/hadoop distcp hdfs://node002:9000/user/hadoop/hello.txt hdfs://node003:9000/user/hadoop/hello.txt
```

二、 Hadoop存档
---
1）理论概述
每个文件均按块存储，每个块的元数据存储在namenode的内存中，因此hadoop存储小文件会非常低效。因为大量的小文件会耗尽namenode中的大部分内存。但注意，存储小文件所需要的磁盘容量和存储这些文件原始内容所需要的磁盘空间相比也不会增多。例如，一个1MB的文件以大小为128MB的块存储，使用的是1MB的磁盘空间，而不是128MB。

Hadoop存档文件或HAR文件，是一个更高效的文件存档工具，它将文件存入HDFS块，在减少namenode内存使用的同时，允许对文件进行透明的访问。具体说来，Hadoop存档文件可以用作MapReduce的输入。

2）案例实操
```
1、需要启动yarn进程
start-yarn.sh

2、归档文件
归档成一个叫做xxx.har的文件夹，该文件夹下有相应的数据文件。Xx.har目录是一个整体，该目录看成是一个归档文件即可。
bin/hadoop archive -archiveName myhar.har -p /user/src   /user/dst

3、查看归档
hadoop fs -lsr /user/dst/myhar.har
hadoop fs -lsr har:///user/dst/myhar.har

4、解归档文件
hadoop fs -cp har:/// user/dst/myhar.har /* /user/src
```

三、快照管理
---
```
1、开启/禁用指定目录的快照功能
hdfs dfsadmin -allowSnapshot /user/hadoop/data		
hdfs dfsadmin -disallowSnapshot /user/hadoop/data	

2、对目录创建快照 hdfs dfs -createSnapshot <snapshotDir> [<snapshotName>]
hdfs dfs -createSnapshot /user/hadoop/data		# 对目录创建快照

通过web访问hdfs://hadoop102:9000/user/hadoop/data/.snapshot/s…..    # 快照和源文件使用相同数据块
hdfs dfs -lsr /user/hadoop/data/.snapshot/

3、指定名称创建快照 
hdfs dfs -createSnapshot /user/hadoop/data miao170508		

4、重命名快照
hdfs dfs -renameSnapshot /user/hadoop/data/ miao170508 atguigu170508		

5、列出当前用户所有可快照目录
hdfs lsSnapshottableDir	

6、比较两个快照目录的不同之处
hdfs snapshotDiff /user/hadoop/data/  .  .snapshot/hadoop170508	

7、恢复快照
hdfs dfs -cp /user/hadoop/input/.snapshot/s20170708-134303.027 /user
```

四、 回收站
---
```
1、默认回收站
默认值fs.trash.interval=0，0表示禁用回收站，可以设置删除文件的存活时间。
默认值fs.trash.checkpoint.interval=0，检查回收站的间隔时间。
要求fs.trash.checkpoint.interval<=fs.trash.interval。

2、启用回收站
修改core-site.xml，配置垃圾回收时间为1分钟。
    <property>
	<name>fs.trash.interval</name>
	<value>1</value>
    </property>

3、查看回收站
 回收站在集群中的；路径：/user/hadoop/.Trash/….

4、修改访问垃圾回收站用户名称
进入垃圾回收站用户名称，默认是dr.who，修改为atguigu用户
[core-site.xml]
    <property>
        <name>hadoop.http.staticuser.user</name>
        <value>hadoop</value>
     </property>

5、通过程序删除的文件不会经过回收站，需要调用moveToTrash()才进入回收站
Trash trash = New Trash(conf);
trash.moveToTrash(path);

6、恢复回收站数据
hadoop fs -mv /user/hadoop/.Trash/Current/user/hadoop/input    /user/hadoop/input

7、清空回收站
hdfs dfs -expunge
```
