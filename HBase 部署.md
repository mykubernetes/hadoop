HBase的安装与部署  
================

1、Zookeeper集群的正常部署并启动  
``` $ /opt/modules/zookeeper-3.4.5/bin/zkServer.sh start ```  
2、Hadoop集群的正常部署并启动  
``` $ /opt/modules/hadoop-2.5.0/sbin/start-dfs.sh ```  
``` $ /opt/modules/hadoop-2.5.0/sbin/start-yarn.sh ```  

3、解压HBase  
``` $ tar -zxf /opt/softwares/hbase-0.98.6.tar.gz -C /opt/modules/ ```  
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

| 命名 | 描述 | 语法 |
|-----|------|-------|
| help ‘命令名’ | 查看命令的使用描述 | help ‘命令名’ |
| whoami | 我是谁 | whoami |
| version | 返回hbase集群的状态信息 | version |
| status | 返回hbase集群的状态信息 | status |
| table_help | 查看如何操作表 | status
| create | 创建表 | create ‘表名’, ‘列族名1’, ‘列族名2’, ‘列族名N’ |
| alter | 修改列族 | 添加一个列族：alter ‘表名’, ‘列族名’ / 删除列族：alter ‘表名’, {NAME=> ‘列族名’, METHOD=> ‘delete’} |
| describe | 显示表相关的详细信息 | describe ‘表名’ |
| list | 列出hbase中存在的所有表 | list |
| exists | 测试表是否存在 | exists ‘表名’ |
| put | 添加或修改的表的值 | put ‘表名’, ‘行键’, ‘列族名’, ‘列值’ / put ‘表名’, ‘行键’, ‘列族名:列名’, ‘列值’ |
| scan | 通过对表的扫描来获取对用的值 | scan ‘表名’ / 扫描某个列族： scan ‘表名’, {COLUMN=>‘列族名’} / 扫描某个列族的某个列： scan ‘表名’,  {COLUMN=>‘列族名:列名’} / 查询同一个列族的多个列： scan ‘表名’, {COLUMNS => [ ‘列族名1:列名1’, ‘列族名1:列名2’, …]} |
| get | 获取行或单元（cell）的值 | get ‘表名’, ‘行键’ / get ‘表名’, ‘行键’, ‘列族名’ |
| count | 统计表中行的数量 | count ‘表名’ |
| incr | 增加指定表行或列的值 | incr ‘表名’, ‘行键’, ‘列族:列名’, 步长值 |
| get_counter | 获取计数器 | get_counter ‘表名’, ‘行键’, ‘列族:列名’ |
| delete | 删除指定对象的值（可以为表，行，列对应的值，另外也可以指定时间戳的值）） | 删除列族的某个列： delete ‘表名’, ‘行键’, ‘列族名:列名’ |
| deleteall | 删除指定行的所有元素值 | deleteall ‘表名’, ‘行键’ |
| truncate | 重新创建指定表 | truncate ‘表名’ |
| enable | 使表有效 | enable ‘表名’ |
| is_enabled | 是否启用 | is_enabled ‘表名’ |
| disable | 使表无效 | disable ‘表名’ |
| is_enabled | 是否启用 | is_enabled ‘表名’ |
| is_disabled | 是否无效 | is_disabled ‘表名’ |
| drop | 删除表 | drop的表必须是disable的 / disable ‘表名’ / drop ‘表名’ |
| shutdown | 关闭hbase集群（与exit不同）	 |
| tools | 列出hbase所支持的工具	 |  |
| exit | 退出 |  |

HBase常用操作  
1、进入HBase客户端命令操作界面  
```
$ bin/hbase shell
```

2、查看帮助命令  
```
hbase(main):001:0> help
```

3、查看当前数据库中有哪些表  
```
hbase(main):002:0> list
```

4、创建一张表
```
# create创建student表，包含info、data两个列族
hbase(main):003:0>  create 'student','info', 'data'
```

5、向表中存储一些数据  
```
# 向student表中插入信息，row key为1001，列族info中添加name列标示符，值为Thomas
hbase(main):004:0> put 'student','1001','info:name','Thomas'

# 向student表中插入信息，row key为1001，列族info中添加sex列标示符，值为male
hbase(main):005:0> put 'student','1001','info:sex','male'

# 向student表中插入信息，row key为1001，列族info中添加age列标示符，值为18
hbase(main):006:0> put 'student','1001','info:age','18'
```

6、扫描查看存储的数据
```
# scan 查询student表中的所有信息
hbase(main):007:0> scan 'student'

# 查询student表中列族为info的信息
hbase(main):014:0> scan 'student', {COLUMNS => 'info'}

# 查询student表中列族为info和data的信息
hbase(main):014:0> scan 'student', {COLUMNS => ['info', 'data']}

# 查询student表中列族为info列为name和列族为data列为pic的信息
hbase(main):014:0> scan 'student', {COLUMNS => ['info:name', 'data:pic']}

# 查看某个rowkey范围内的数据  
hbase(main):014:0> scan 'student',{STARTROW => '1001',STOPROW => '1007'}
hbase(main):014:0> scan 'student',{STARTROW => '1001',ENDROW => '1007'}

查询student表中列族为info、列标示符为name的信息,并且版本最新的5个
hbase(main):014:0> scan 'student', {COLUMNS => 'info:name', VERSIONS => 5}

查询students表中列族为info和data且列标示符中含有a字符的信息
hbase(main):014:0> scan 'student', {COLUMNS => ['info', 'data'], FILTER => "(QualifierFilter(=,'substring:a'))"}

查询students表中row key以rk字符开头的
hbase(main):014:0> scan 'student',{FILTER=>"PrefixFilter('rk')"}

查询student表中指定范围的数据
hbase(main):014:0> scan 'student', {TIMERANGE => [1392368783980, 1392380169184]}
```

7、查看表结构  
```
hbase(main):009:0> describe 'student'
```

8、更新指定字段的数据
```
向student表中插入信息，row key为1001，列族info中添加name列标示符，值为Nick
hbase(main):009:0> put 'student','1001','info:name','Nick'

向student表中插入信息，row key为1001，列族info中添加age列标示符，值为100
hbase(main):010:0> put 'student','1001','info:age','100'
```  
  
9、查看指定行的数据
```
# get 获取student表中row key为1001的所有信息
hbase(main):012:0> get 'student','1001'

# 获取ustudent表中row key为1001，info列族的所有信息
hbase(main):012:0> get 'student','1001', 'info'

# 获取student表中row key为1001，info列族的name、age列标示符的信息
hbase(main):012:0> get 'student','1001', 'info:name', 'info:age'

# 获取student表中row key为1001，info、data列族的信息
hbase(main):012:0> get 'student','1001', 'info', 'data'
hbase(main):012:0> get 'student', '1001', {COLUMN => ['info', 'data']}

# 获取student表中row key为1001，列族info列name和列族data列pic的信息
hbase(main):012:0> get 'student', '1001', {COLUMN => ['info:name', 'data:pic']}

# 获取student表中row key为1001，列族为info，版本号最新5个的信息
hbase(main):012:0> get 'student', '1001', {COLUMN => 'info', VERSIONS => 5}

# 获取student表中row key为1001，列族为info列为name，版本号最新5个的信息
hbase(main):012:0> get 'student', '1001', {COLUMN => 'info:name', VERSIONS => 5}

# 获取student表中row key为1001，列族为info，指定时间范围，版本号最新5个的信息
hbase(main):012:0> get 'student', '1001', {COLUMN => 'info:name', VERSIONS => 5, TIMERANGE => [1488892553804, 1488892688096]}

# 获取student表中row key为rk0001，cell的值为zhangsan的信息
get 'people', '1001', {FILTER => "ValueFilter(=, 'binary:zhangsan')"}

# 获取user表中row key为rk0001，列标示符中含有a的信息
get 'student', '1001', {FILTER => "(QualifierFilter(=,'substring:a'))"}
```

10、删除数据  
```
1）删除某一个rowKey全部的数据  
hbase(main):015:0> deleteall 'student','1001'

2）删除掉某个rowKey中某一列的数据  
hbase(main):016:0> delete 'student','1001','info:sex'

3）删除一行数据,删除student表row key为1001，列标示符为info:name，timestamp为1392383705316的数据
hbase(main):016:0> delete 'student','1001','info:name',1392383705316
```

11、清空student表数据  
```
hbase(main):017:0> truncate 'student'
```

12、删除表  
```
1、首先需要先让该表为disable状态
hbase(main):018:0> disable 'student'

2、然后才能drop这个表
hbase(main):019:0> drop 'student'
```  
提示：如果直接drop表，会报错：Drop the named table. Table must first be disabled  

13、统计一张表有多少行数据  
```
方式一
base(main):020:0> count 'student'

方式二
# hbase org.apache.hadoop.hbase.mapreduce.RowCounter 'namespaceName:tableName'
```
 
