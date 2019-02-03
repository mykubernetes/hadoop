HBase的安装与部署  
================

1、Zookeeper集群的正常部署并启动  
``` $ /opt/modules/zookeeper-3.4.5-cdh5.3.6/bin/zkServer.sh start ```  
2、Hadoop集群的正常部署并启动  
``` $ /opt/modules/hadoop-2.5.0-cdh5.3.6/sbin/start-dfs.sh ```  
``` $ /opt/modules/hadoop-2.5.0-cdh5.3.6/sbin/start-yarn.sh ```  

3、解压HBase  
``` $ tar -zxf /opt/softwares/hbase-0.98.6-cdh5.3.6.tar.gz -C /opt/modules/ ```  
4、修改HBase配置文件  
  1)hbase-env.sh  
```
export JAVA_HOME=/opt/modules/jdk1.8.0_121
export HBASE_MANAGES_ZK=false
```  
  2)hbase-site.xml  
  注意：如果是name是高可用的配置集群名如下，如果name是单节点的配置hdfs://node01:8020/hbase  
```
    <!--  设置hbase的跟地址，为namenode所在位置 -->
    <property>
       <name>hbase.rootdir</name>
       <value>hdfs://mycluster/hbase</value>   
    </property>
    <!--  使hbase运行于完全分布式 -->
    <property>
        <name>hbase.cluster.distributed</name>
        <value>true</value>
    </property>
     <!--  HMaster的端口 -->
    <property>
        <name>hbase.master</name>
        <value>60000</value>
    </property>
     <!--  Zookeeper集群的地址列表，用逗号分隔 -->
    <property>
       <name>hbase.zookeeper.quorum</name>
       <value>node01:2181,node02:2181,node03:2181</value>
    </property>
     <!--  Zookeeper保存属性信息的文件，默认为/tmp 重启后丢失 -->
    <property>
       <name>hbase.zookeeper.property.dataDir</name>
       <value>/opt/modules/zookeeper-3.4.5/dataDir</value>
    </property>
```
  3)regionservers  
```
node01
node02
node03
```  
安装完毕  

可选操作  
  为避免Hbase里的jar包和Hadoop里的jar包文件不一样产生不必要的麻烦需要操作，一样则可以不操作  
  替换HBase根目录下的lib目录下的jar包，以解决兼容问题  
  * 删除原有Jar包  
```
$ rm -rf /opt/modules/cdh/hbase-0.98.6/lib/hadoop-*  
$ rm -rf lib/zookeeper-3.4.6.jar 
```  
(提示：如果lib目录下的zookeeper包不匹配也需要替换）* 拷贝新的Jar包  

这里涉及到的jar包大概是：  
```
 hadoop-annotations-2.5.0.jar
 hadoop-auth-2.5.0-cdh5.3.6.jar
 hadoop-client-2.5.0-cdh5.3.6.jar
 hadoop-common-2.5.0-cdh5.3.6.jar
 hadoop-hdfs-2.5.0-cdh5.3.6.jar
 hadoop-mapreduce-client-app-2.5.0-cdh5.3.6.jar
 hadoop-mapreduce-client-common-2.5.0-cdh5.3.6.jar
 hadoop-mapreduce-client-core-2.5.0-cdh5.3.6.jar
 hadoop-mapreduce-client-hs-2.5.0-cdh5.3.6.jar
 hadoop-mapreduce-client-hs-plugins-2.5.0-cdh5.3.6.jar
 hadoop-mapreduce-client-jobclient-2.5.0-cdh5.3.6.jar
 hadoop-mapreduce-client-jobclient-2.5.0-cdh5.3.6-tests.jar
 hadoop-mapreduce-client-shuffle-2.5.0-cdh5.3.6.jar
 hadoop-yarn-api-2.5.0-cdh5.3.6.jar
 hadoop-yarn-applications-distributedshell-2.5.0-cdh5.3.6.jar
 hadoop-yarn-applications-unmanaged-am-launcher-2.5.0-cdh5.3.6.jar
 hadoop-yarn-client-2.5.0-cdh5.3.6.jar
 hadoop-yarn-common-2.5.0-cdh5.3.6.jar
 hadoop-yarn-server-applicationhistoryservice-2.5.0-cdh5.3.6.jar
 hadoop-yarn-server-common-2.5.0-cdh5.3.6.jar
 hadoop-yarn-server-nodemanager-2.5.0-cdh5.3.6.jar
 hadoop-yarn-server-resourcemanager-2.5.0-cdh5.3.6.jar
 hadoop-yarn-server-tests-2.5.0-cdh5.3.6.jar
 hadoop-yarn-server-web-proxy-2.5.0-cdh5.3.6.jar
 zookeeper-3.4.5-cdh5.3.6.jar
```  
我们可以通过find命令快速进行定位，例如我们可以执行：  
``` $ find /opt/modules/ -name hadoop-hdfs-2.5.0.jar ```
 
然后将查找出来的Jar包根据指定位置复制到HBase的lib目录下，在这里我给大家整合好到一个文件夹中了，请依次执行：  
```     
$ tar -zxf /opt/softwares/HadoopJar.tar.gz -C /opt/softwares/
$ cp -a /opt/softwares/HadoopJar/* /opt/modules/cdh/hbase-0.98.6/lib/
```

将整理好的HBase安装目录scp到其他机器节点  
```
$ scp -r /opt/modules/hbase-0.98.6/ node02:/opt/modules/
$ scp -r /opt/modules/hbase-0.98.6/ node03:/opt/modules/
```
将Hadoop配置文件软连接到HBase的conf目录下  
      * core-site.xml  
``` $ ln -s /opt/modules/cdh/hadoop-2.5.0/etc/hadoop/core-site.xml /opt/modules/hbase-0.98.6-cdh5.3.6/conf/core-site.xml ```  
      * hdfs-site.xml  
``` $ ln -s /opt/modules/cdh/hadoop-2.5.0/etc/hadoop/hdfs-site.xml /opt/modules/hbase-0.98.6-cdh5.3.6/conf/hdfs-site.xml ```  
（提示：不要忘记其他几台机器也要做此操作）  

启动服务  
```
$ bin/hbase-daemon.sh start master 
$ bin/hbase-daemon.sh start regionserver
```  
或者：  
``` $ bin/start-hbase.sh ```  
对应的停止命令：  
``` $ bin/stop-hbase.sh ```  


HMaster的高可用  
1、确保HBase集群已正常停止  
``` $ bin/stop-hbase.sh ```  
2、在conf目录下创建backup-masters文件  
``` $ touch conf/backup-masters ```  
3、在backup-masters文件中配置高可用HMaster节点  
``` $ echo node02 > conf/backup-masters ```  
4、将整个conf目录scp到其他节点  
```
$ scp -r conf/ node02:/opt/modules/hbase-0.98.6-cdh5.3.6/
$ scp -r conf/ node03:/opt/modules/hbase-0.98.6-cdh5.3.6/
```
5、打开页面测试  
``` http://node01:60010 ```  

最后，可以尝试关闭第一台机器的HMaster：  
``` $ bin/hbase-daemon.sh stop master ```  
       然后查看第二台的HMaster是否会直接启用  



HBase常用操作  
1、进入HBase客户端命令操作界面  
``` $ bin/hbase shell ```  
2、查看帮助命令  
``` hbase(main):001:0> help ```  
3、查看当前数据库中有哪些表  
``` hbase(main):002:0> list ```  
4、创建一张表  
``` hbase(main):003:0>  create 'student','info' ```  
5、向表中存储一些数据  
```
hbase(main):004:0> put 'student','1001','info:name','Thomas'
hbase(main):005:0> put 'student','1001','info:sex','male'
hbase(main):006:0> put 'student','1001','info:age','18'
```

6、扫描查看存储的数据  
``` hbase(main):007:0> scan 'student' ```  
或：查看某个rowkey范围内的数据  

``` hbase(main):014:0> scan 'student',{STARTROW => '1001',STOPROW => '1007'} ```  
7、查看表结构  
``` hbase(main):009:0> describe 'student' ```  


8、更新指定字段的数据  
``` hbase(main):009:0> put 'student','1001','info:name','Nick' ```  

``` hbase(main):010:0> put 'student','1001','info:age','100' ```  
  
9、查看指定行的数据  
``` hbase(main):012:0> get 'student','1001' ```  

 或：查看指定行指定列或列族的数据  
``` hbase(main):013:0> get 'student','1001','info:name' ```  
10、删除数据  
1）删除某一个rowKey全部的数据  
       ``` hbase(main):015:0> deleteall 'student','1001' ```  
2）删除掉某个rowKey中某一列的数据  
       ``` hbase(main):016:0> delete 'student','1001','info:sex' ```  
11、清空表数据  
``` hbase(main):017:0> truncate 'student'  ```  

12、删除表  
    首先需要先让该表为disable状态，使用命令：  
``` hbase(main):018:0> disable 'student'  ```  
    然后才能drop这个表，使用命令：  
``` hbase(main):019:0> drop 'student'  ```  
 提示：如果直接drop表，会报错：Drop the named table. Table must first be disabled  

13、统计一张表有多少行数据  
```hbase(main):020:0> count 'student' ```
