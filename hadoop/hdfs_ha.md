# hdfs ha  

## Hadoop安装包目录结构

| 目录 | 说明 |
|------|------|
| bin | Hadoop最基本的管理脚本和使用脚本的目录，这些脚本是sbin目录下管理脚本的基础实现，用户可以直接使用这些脚本管理和使用hadoop |
| etc | Hadoop配置文件所在的目录 |
| include | 对外提供的编程库头文件（具体同态库和静态库在lib目录中），这些头文件均是用C++定义的，通常用于C++程序访问HDFS或者编写MapReduce程序 |
| lib |  该目录包含了Hadoop对外提供的编程动态库和静态库，与include目录中的头文件结合使用 |
| libexec | 各个服务对用的shell配置文件所在的目录，可用于配置日志输出、启动参数（比如JVM参数）等基本信息 |
| sbin | Hadoop管理脚本所在的目录，主要包含HDFS和YARN中各类服务的启动/关闭脚本 |
| share | Hadoop各个模块编译后的jar包所在的目录，官方自带示例 |

配置文件概述：
- 第一类1个：hadoop-env.sh
- 第二类4个：xxxx-site.xml ,site表示的是用户定义的配置，会覆盖default中的默认配置。
  - core-site.xml 核心模块配置
  - hdfs-site.xml hdfs文件系统模块配置
  - mapred-site.xml MapReduce模块配置
  - yarn-site.xml yarn模块配置
- 第三类1个：workers
- 所有的配置文件目录：hadoop-3.3.1/etc/hadoop/

| 端口名称 | Hadoop2.x | Hadoop3.x |
|----------|-----------|-----------|
| NameNode内部通信端口 | 8020/9000 | 8020/9000/9820 |
| NameNode HTTP UI | 50070 | 9870 |
| MapReduce查看执行任务端口 | 8088 | 8088 |
| 历史服务器通信端口 | 19888 | 19888 |

## 一、Linux 其他准备操作  

1、 检查时区  
```
# date -R
Thu, 21 Mar 2019 18:07:27 -0400
```
如果显示的时区不是+0800，可以删除localtime文件夹后，再关联一个正确时区的链接过去，命令如下：  
```
# rm -rf /etc/localtime
# ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```  

2、同步时间  
```
# ntpdate pool.ntp.org
```

3、修改NTP配置文件  
```
# vim /etc/ntp.conf

# 去掉下面这行前面的# ,并把网段修改成自己的网段：
restrict 192.168.122.0 mask 255.255.255.0 nomodify notrap

# 注释掉以下几行：
#server 0.centos.pool.ntp.org
#server 1.centos.pool.ntp.org
#server 2.centos.pool.ntp.org

# 把下面两行前面的#号去掉,如果没有这两行内容,需要手动添加
server  127.127.1.0    # local clock
fudge  127.127.1.0 stratum 10
```  

4、重启ntp服务  
```
# systemctl start ntpd.service
# systemctl enable ntpd.service
```  

5、集群其他节点去同步这台时间服务器时间  
```
# 首先需要关闭这两台计算机的ntp服务  
# systemctl stop ntpd.service
# systemctl disable ntpd.service
# systemctl status ntpd
# pgrep ntpd，查看ntp服务进程id

# 同步第一台服务器z01的时间：
# ntpdate node01
```

6、 制定计划任务,周期性同步时间  
```
# crontab -e  
*/10 * * * * /usr/sbin/ntpdate node01  
```  

7、 重启定时任务  
```
# systemctl restart crond.service
```  

8、ssh无秘钥登录  
```
配置hadoop集群，首先需要配置集群中的各个主机的ssh无密钥访问  
$ ssh-keygen -t rsa

# 把生成之后的公钥拷贝给node01,node02,node03这三台机器，包含当前机器。  
$ ssh-copy-id node01  
$ ssh-copy-id node02  
$ ssh-copy-id node03  
```  


## 二、安装  

1、首先安装jdk  
```
$ tar -zxf /opt/softwares/jdk-8u121-linux-x64.gz -C /opt/modules/
```

2 JDK环境变量配置  
```
# vi /etc/profile
#JAVA_HOME
export JAVA_HOME=/opt/modules/jdk1.8.0_121
export PATH=$PATH:$JAVA_HOME/bin
```

3、zookeeper  

> 1）修改zoo.cfg配置文件  
修改conf目录下的zoo.cfg文件，如果没有该文件，请自行重命名sample.cfg文件，修改内容为：  
```
dataDir=/opt/modules/zookeeper/zkData
dataLogDir=/opt/modules/zookeeper/zkLog
server.1=node01:2888:3888
server.2=node02:2888:3888
server.3=node03:2888:3888
```
- 同时创建dataDir属性值所指定的目录  

> 2）在zkData目录下创建myid文件，修改值为1，如：  
```
$ cd /opt/modules/zookeeper/zkData
$ touch myid
$ echo 1 > myid
```

> 3）将zookeeper安装目录scp到其他机器节点  
```
$ scp -r /opt/modules/zookeeper/ node02:/opt/modules/
$ scp -r /opt/modules/zookeeper/ node03:/opt/modules/
```

> 4）修改其他机器节点的myid文件为2和3  
```
$ echo 2 > myid
$ echo 3 > myid
```

> 5、在每个节点上启动zookeeper以及查看状态  
```
$ bin/zkServer.sh start
$ bin/zkServer.sh status
```

## 三、hadoop  

1、JDK环境变量配置  
```
# vim /etc/profile
#JAVA_HOME
export HADOOP_HOME=/opt/modules/hadoop-2.7.2
export PATH=$PATH:$HADOOP_HOME/bin:$PATH:$HADOOP_HOME/sbin:$PATH

# source /etc/profile
```

2、设置hadoop里的JAVA_HOME  
```
# vim hadoop-env.sh
export JAVA_HOME=/opt/modules/jdk1.8.0_121
export HADOOP_PID_DIR=${HADOOP_HOME}/pids
```

3、编辑hdfs-site.xml文件, 修改主机名，defaultFS名，dir存储路径等信息
``` xml
# vim hdfs-site.xml  
<configuration>
	<!-- 指定数据冗余份数 -->
	<property>
		<name>dfs.replication</name>
		<value>3</value>
	</property>

	<!-- 完全分布式集群名称,执行hdfs的nameservice为ns,和core-site.xml保持一致 -->
	<property>
		<name>dfs.nameservices</name>
		<value>mycluster</value>
	</property>

	<!-- 集群中NameNode节点都有哪些ns下有两个namenode,分别是nn1,nn2 -->
	<property>
		<name>dfs.ha.namenodes.mycluster</name>
		<value>nn1,nn2</value>
	</property>

	<!-- nn1的RPC通信地址 -->
	<property>
		<name>dfs.namenode.rpc-address.mycluster.nn1</name>
		<value>node01:8020</value>
	</property>

	<!-- nn2的RPC通信地址 -->
	<property>
		<name>dfs.namenode.rpc-address.mycluster.nn2</name>
		<value>node02:8020</value>
	</property>

	<!-- nn1的http通信地址 -->
	<property>
		<name>dfs.namenode.http-address.mycluster.nn1</name>
		<value>node01:50070</value>
	</property>

	<!-- nn2的http通信地址 -->
	<property>
		<name>dfs.namenode.http-address.mycluster.nn2</name>
		<value>node02:50070</value>
	</property>
	
	<!-- nn1的servicerpc地址 -->
        <property>
                <name>dfs.namenode.servicerpc-address.mycluster.nn1</name>  
                <value> node01:53310</value>
        </property>

        <!-- nn2的servicerpc地址 -->
        <property>
                <name>dfs.namenode.servicerpc-address.mycluster.nn2</name>  
                <value> node02:53310</value>
        </property>

	<!-- 指定NameNode元数据在JournalNode上的存放位置，namenode2可以从JournalNode集群里获取最新的namenode的信息，达到热备的效果 -->
	<property>
		<name>dfs.namenode.shared.edits.dir</name>
		<value>qjournal://node01:8485;node02:8485;node03:8485/mycluster</value>
	</property>

	<!-- 声明journalnode存放数据的位置-->
	<property>
		<name>dfs.journalnode.edits.dir</name>
		<value>/opt/modules/cdh/hadoop/data/jn</value>
	</property>
	
        <!--namenode故障转移自动切换-->
	<property>
		<name>dfs.ha.automatic-failover.enabled</name>
		<value>true</value>
	</property>
	
        <!-- 访问代理类：client，mycluster，active配置失败自动切换实现方式-->
	<property>
  		<name>dfs.client.failover.proxy.provider.mycluster</name>
  		<value>org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider</value>
	</property>

	<!-- 配置隔离机制，即同一时刻只能有一台服务器对外响应 -->
	<property>
		<name>dfs.ha.fencing.methods</name>
		<value>sshfence</value>
	</property>

	<!-- 使用隔离机制时需要ssh登录秘钥所在的位置 -->
	<property>
		<name>dfs.ha.fencing.ssh.private-key-files</name>
		<value>/home/hadoop/.ssh/id_rsa</value>
	</property>

	<!-- 设置hdfs的操作权限，false表示任何用户都可以在hdfs上操作文件，生产环境不配置此项，默认为true -->
	<property>
		<name>dfs.permissions.enable</name>
		<value>false</value>
	</property>

        <!-- NN保存FsImage镜像的目录,作用是存放hadoop的名称节点namenode里的metadata,多路径以逗哈为分隔符file:///data/dfs/namenode1，file:///data/dfs/namenode2 -->
        <property>
                <name>dfs.namenode.name.dir</name>
                <value>file:///data/dfs/namenode</value>  
        </property>
	
	<!-- 存放HDFS文件系统数据文件的目录,作用是存放hadoop的数据节点datanode里的多个数据块 -->
        <property>
                <name>dfs.datanode.data.dir</name>
                <value>file:///data/dfs/datanode</value>    
        </property>
	
	<!-- CheckPoint时间设置,当操作次数达到1百万时，SecondaryNameNode执行一次 -->
	<property>
                <name>dfs.namenode.checkpoint.txns</name>  
                <value>1000000</value> 
                <description>操作动作次数</description> 
        </property> 
	
	<!-- CheckPoint时间设置,SecondaryNameNode每隔一小时执行一次 -->
        <property>  
                <name>dfs.namenode.checkpoint.period</name>  
                <value>3600s</value>
		<description> 1分钟检查一次操作次数</description>
        </property> 

	<property>
                <name>dfs.namenode.heartbeat.recheck-interval</name>
                <!--单位为毫秒-->
                <value>300000</value>
        </property>

        <property>
                <name>dfs.heartbeat.interval</name>
                <!--单位为秒-->
                <value>3</value>
        </property> 

	<property>
                <name>dfs.webhdfs.enabled</name>
                <value>true</value>
        </property>

</configuration>
```
- 访问namenode的hdfs使用50070端口，访问datanode的webhdfs使用50075端口。访问文件、文件夹信息使用namenode的IP和50070端口，访问文件内容或者进行打开、上传、修改、下载等操作使用datanode的IP和50075端口。要想不区分端口，直接使用namenode的IP和端口进行所有的webhdfs操作，就需要在所有的datanode上都设置hefs-site.xml中的dfs.webhdfs.enabled为true

4、编辑core-site.xml文件, 修改主机名，defaultFS名，dir存储路径等信息  
``` xml
# vim  core-site.xml  
<configuration>
	<!--指定HDFS中NameNode的地址或集群名,该值来自于hdfs-site.xml中的配置-->
	<property>
		<name>fs.defaultFS</name>
		<value>hdfs://mycluster</value>
	</property>

	<!--指定hadoop运行时产生文件的存储目录,,默认/tmp/hadoop-${user.name}-->
	<property>
		<name>hadoop.tmp.dir</name>
		<value>/opt/modules/cdh/hadoop/data</value>
	</property>
	
	<!--整合hive 用户代理设置 -->
        <property>
                <name>hadoop.proxyuser.root.hosts</name>
                <value>*</value>
        </property>
        <property>
                <name>hadoop.proxyuser.root.groups</name>
                <value>*</value>
        </property>
	
	<!--ZooKeeper集群的地址和端口,namenode故障转移自动切换和hdfs.xml里的文件同时用-->
	<property>
		<name>ha.zookeeper.quorum</name>
		<value>node01:2181,node02:2181,node03:2181</value>
	</property>
	
	<!-- 文件的缓冲区大小 -->
	<property>
                <name>io.file.buffer.size</name>
                <value>131702</value>      
                <description>用于顺序文件的缓冲区大小,默认4096byte，建议设定为 64KB 到 128KB，可减少I/O次数</description>         
        </property>
	
	<!--设置回收站的保存时间，这个时间以分钟为单位，例如4320=72h=3天-->
        <property>
	        <name>fs.trash.interval</name>
		<value>4320</value>
        </property>
</configuration>
```

5、创建配置文件里的数据目录和journalnode目录
```
mkdir /opt/modules/cdh/hadoop/data
mkdir /opt/modules/cdh/hadoop/data/jn
```
- 完成后远程拷贝给其他服务器  

6、修改slaves文件,配置数据节点  
```
# vim slaves
node01
node02
node03
```


## 四、Hadoop集群启动 

1、格式化zk，namenode的active节点执行
```
# bin/hdfs zkfc -formatZK
```

2、启动journalnode集群，只在journalnode角色的节点启动
```
# sbin/hadoop-daemon.sh start journalnode
```

该命令把slaves里的主机都启动（不推荐执行，用上面的单一启动即可）
```
# sbin/hadoop-daemons.sh start journalnode
```

3、在[nn1]上，格式化namenode并启动，在namenode节点执行 
```
# bin/hdfs namenode -format
# sbin/hadoop-daemon.sh start namenode
```

4、在[nn2]上，把nn2服务器的namenode节点变为standby namenode节点,同步nn1的元数据信息，并启动。  
```
# bin/hdfs namenode -bootstrapStandby
# sbin/hadoop-daemon.sh start namenode
```

手动把nn1设置为active  
```
# bin/hdfs haadmin -transitionToActive nn1
```

查看服务状态  
```
# bin/hdfs haadmin -getServiceState nn1
```

5、启动DataNode，每台datanode服务器上分别启动datanode节点。
```
# sbin/hadoop-daemon.sh start datanode                # #每台节点都要启动
```

6、启动zkfc，FalioverControllerActive是失败恢复线程。这个线程需要在NameNode节点所在的服务器上启动。
```
# sbin/hadoop-daemon.sh start zkfc 
```

7、启动各个进程  
```
# sbin/start-dfs.sh
```

8、查看各进程状态  
```
$ jps
13810 NameNode     
14096 JournalNode                  namenode  editlog备份
14350 Jps
3246 QuorumPeerMain                zookeeper进程
13908 DataNode                     数据节点
14264 DFSZKFailoverController      namedode故障自动转移
```

### 集群验证

使用浏览器访问http://node01:50070和http:// node02:50070，如果其中一个状态为Active另一个为Standby，则安装成功


## 五、ResourceManager HA  

### 配置日志的聚集
- 1、日志聚集概念：应用运行完成以后，将程序运行日志信息上传到HDFS系统上。
- 2、日志聚集功能好处：可以方便的查看到程序运行详情，方便开发调试。
- 3、注意：开启日志聚集功能，需要重新启动NodeManager 、ResourceManager和HistoryServer。

1、配置yarn的java环境变量
```
# vim yarn-env.sh  
export JAVA_HOME=/opt/modules/jdk1.8.0_121
export YARN_PID_DIR=${HADOOP_HOME}/pids
```

2、编辑yarn-site.xml文件, 高可用的yarn,两个rm的 yarn.resourcemanager.ha.id分别配置rm1和rm2
``` xml
# vim yarn-site.xml  

<configuration>

    <!-- NodeManager获取数据的方式 -->
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>

    <!--启用resourcemanager ha-->
    <property>
        <name>yarn.resourcemanager.ha.enabled</name>
        <value>true</value>
    </property>
 
    <!--声明两台resourcemanager的地址集群名称-->
    <property>
        <name>yarn.resourcemanager.cluster-id</name>
        <value>cluster-yarn1</value>
    </property>
    
    <!-- 指定两个resourcemanager的名称 --> 
    <property>
        <name>yarn.resourcemanager.ha.rm-ids</name>
        <value>rm1,rm2</value>
    </property>
    
    <property>
        <name>yarn.resourcemanager.ha.id</name>      
        <value>rm1</value>                                ####在第二台上要该成rm2                         
    </property>

    <!-- 配置rm1的主机 -->
    <property>
        <name>yarn.resourcemanager.hostname.rm1</name>
        <value>node01</value>
    </property>
    
    <!-- 配置rm2的主机 -->
    <property>
        <name>yarn.resourcemanager.hostname.rm2</name>
        <value>node02</value>
    </property>
    
    <!--指定yarn的老大 resoucemanager的地址-->
        <name>yarn.resourcemanager.hostname</name>
        <value>node01</value>               
    </property>

    <!--指定zookeeper集群的地址--> 
    <property>
        <name>yarn.resourcemanager.zk-address</name>
        <value>node01:2181,node02:2181,node03:2181</value>
	<description>For multiple zk services, separate them with comma</description>
    </property>

    <!--开启yarn恢复机制--> 
    <property>
        <name>yarn.resourcemanager.recovery.enabled</name>
        <value>true</value>
    </property>
 
    <!-- 执行rm恢复机制实现类，指定resourcemanager的状态信息存储在zookeeper集群--> 
    <property>
        <name>yarn.resourcemanager.store.class</name>    
        <value>org.apache.hadoop.yarn.server.resourcemanager.recovery.ZKRMStateStore</value>
    </property>
    
    <!-- 一台NodeManager的总可用内存资源，根据实际物理资源配置，假如机器内存是128G，配置100G-110G，预留部分 -->
    <property>
        <name>yarn.nodemanager.resource.memory-mb</name>
        <value>49152</value>           #49152为48G   #一般给系统预留12-16G
    </property>
    
    <!-- 单个任务可申请的最少物理内存量，默认是1024（MB） -->
    <property>
        <name>yarn.scheduler.minimum-allocation-mb</name>
        <value>128</value>
    </property>
    
    <!-- 单个任务可申请的最大物理内存量，默认是8192（MB） -->        
    <property>
        <name>yarn.scheduler.maximum-allocation-mb</name>
        <value>8192</value>
    </property>
    
    <!-- 一台NodeManager的总可用（逻辑）cpu核数，根据实际物理资源配置 -->
    <property>
        <name>yarn.nodemanager.resource.cpu-vcores</name>
        <value>8</value>                        #本机只有8C, 所以最大分8
    </property>
    
    <!-- 2.8.4 默认一个am最多申请4cores -->
    <property>
        <name>yarn.scheduler.maximum-allocation-vcores</name>
        <value>4</value>
    </property>
    
    <!-- 是否检查容器的虚拟内存使用超标情况 -->
    <property>
        <name>yarn.nodemanager.vmem-check-enabled</name>
        <value>false</value>
    </property>
    
    <!--  容器的虚拟内存使用上限：与物理内存的比率 -->
    <property>
        <name>yarn.nodemanager.vmem-pmem-ratio</name>
        <value>2.1</value>
    </property>

    <!--  是否启动一个线程检查每个任务正使用的物理内存量，如果任务超出分配值，则直接将其杀掉 -->
    <property>
        <name>yarn.nodemanager.pmem-check-enabled</name>
        <value>false</value>
    </property>
    
    <!-- 开启日志聚集功能 -->
    <property>
        <name>yarn.log-aggregation-enable</name>     
        <value>true</value>
    </property>
    
    <!-- 聚合后的日志在hdfs上保留的时间，单位为秒 -->
    <property>
        <name>yarn.log-aggregation.retain-seconds</name>                  
        <value>600000</value>
    </property>
    
    <!-- 聚合日志保存检查间隔时间 -->
    <property>
        <name>yarn.log-aggregation.retain-check-interval-seconds</name>
        <value>604800</value>
    </property>
    
    <!-- 设置日志聚集服务器地址 -->
    <property>
        <name>yarn.log.server.url</name>
	<value>http://node01:19888/jobhistory/logs</value>               #程序自动创建
    </property>
    
    <!-- 日志聚合的地址，默认为/tmp/logs -->
    <property>
        <name>yarn.nodemanager.remote-app-log-dir</name>
        <value>hdfs://mycluster/jobhistory/yarn-logs/</value>     
    </property>

    <!-- NodeManager开启重启作业保留机制 -->
    <property>
        <description>Enable the node manager to recover after starting</description>
        <name>yarn.nodemanager.recovery.enabled</name>
        <value>true</value>
    </property>
    
    <!-- NM保存container状态的本地目录,默认为$hadoop.tmp.dir/yarn-nm-recovery -->
    <property>
        <description>The local filesystem directory in which the node manager willstore state when recovery is enabled.</description>
        <name>yarn.nodemanager.recovery.dir</name>
        <value>${hadoop.tmp.dir}/yarn-nm-recovery</value>
    </property>
    
    <!-- 用来接收从ApplicationMaster过来的请求，默认0.0.0.0-->
    <property>
        <name>yarn.nodemanager.address</name>
        <value>0.0.0.0:8041</value>
    </property>
    
    <property>
        <name>yarn.nodemanager.recovery.supervised</name>
        <value>true</value>
    </property>

    <!-- am超时设置 -->
    <property>
        <name>yarn.am.liveness-monitor.expiry-interval-ms</name>
        <value>600000</value>
    </property>
    
     <!-- rm超时设置 -->
    <property>
        <name>yarn.resourcemanager.container.liveness-monitor.interval-ms</name>
        <value>600000</value>
    </property>
    
     <!-- nm超时设置 -->
    <property>
        <name>yarn.nm.liveness-monitor.expiry-interval-ms</name>
        <value>600000</value>
    </property>

</configuration>
```
- 配置完成后，将整个hadoop目录拷贝到其它主机节点相同的目录下


3、修改资源百分比，默认为0.1，设置0.5以上,表示集群上AM最多可使用的资源比例，目的为限制过多的app数量。
``` xml
# vim capacity-scheduler.xml
<property>
    <name>yarn.scheduler.capacity.maximum-am-resource-percent</name>     
    <value>0.5</value>
    <description> 
    集群中用于运行应用程序ApplicationMaster的资源比例上限，该参数通常用于限制处于活动状态的应用程序数目。该参数类型为浮点型，默认是0.1，表示10%。所有队列的ApplicationMaster资源比例上限可通过参数 #### yarn.scheduler.capacity.maximum-am-resource-percent设置，而单个队列可通过参数yarn.scheduler.capacity.<queue-path>.maximum-am-resource-percent设置适合自己的值。
    </description>
</property>
```

4、设置mapred里的JAVA_HOME
```
# vim mapred-env.sh  
export JAVA_HOME=/opt/modules/jdk1.8.0_121
export HADOOP_MAPRED_PID_DIR=${HADOOP_HOME}/pids
```

5、将mapred-site.xml.template改名为mapred-site.xml，编辑修改mapred-site.xml在`<configuration>`标签中添加修改如下内容
``` xml
# vim mapred-site.xml  
<configuration>
    <-- 指定mapreduce运行在yarn上 -->
    <property>
        <name>mapreduce.framework.name</name>    
        <value>yarn</value>
    </property>
</configuration>
```

6、完成后远程拷贝给其他服务器  
```
# scp etc/hadoop/yarn-site.xml node02:/opt/modules/hadoop-2.5.0/etc/hadoop/
```  

## 启动yarn集群

启动主Resourcemanager节点，启动成功后其他节点的nodemanager 也会跟随启动

1、在resourcemanager节点中启动执行
```
# sbin/start-yarn.sh          #全部拉起，不建议出问题不好排错，用下面的命令单独拉起
```  

```
# sbin/yarn-daemon.sh start resourcemanager      #单个起，推荐操作
```

2、启动nodemanager
```
# sbin/yarn-daemon.sh start nodemanager 
```

3、查看服务状态  
```
# bin/yarn rmadmin -getServiceState rm1
# bin/yarn rmadmin -getServiceState rm2
```  

4、启动jobhistoryserver进程,在namenode主节点启动
```
# sbin/mr-jobhistory-daemon.sh start historyserver
```

5、两台机器分别查看jobhistoryserver  resourcemanager nodemanager进程  
```
$ jps
15111 Jps
14663 NodeManager
13810 NameNode
14096 JournalNode
15024 JobHistoryServer    
3246 QuorumPeerMain
13908 DataNode
14264 DFSZKFailoverController

$ jps
14901 ResourceManager
15098 Jps
14305 NodeManager
13580 DataNode
12326 QuorumPeerMain
13772 DFSZKFailoverController
13516 NameNode
13668 JournalNode
```
- NameNode 它是 hadoop 中的主服务器，管理文件系统名称空间和对集群中存储的文件的 访问，保存有 metadate。
- SecondaryNameNode 提供周期检查点和清理任务。帮助 NN 合并 editslog，减少 NN 启动 时间。
- DataNode 它负责管理连接到节点的存储（一个集群中可以有多个节点）。每个存储数据 的节点运行一个 datanode 守护进程。
- ResourceManager（JobTracker）JobTracker 负责调度 DataNode 上的工作。每个 DataNode 有一个 TaskTracker，它们执行实际工作。
- NodeManager（TaskTracker）执行任务
- DFSZKFailoverController 高可用时它负责监控 NN 的状态，并及时的把状态信息写入 ZK。 它通过一个独立线程周期性的调用 NN 上的一个特定接口来获取 NN 的健康状态。FC 也有选 择谁作为 Active NN 的权利，因为最多只有两个节点，目前选择策略还比较简单（先到先得， 轮换）。
- JournalNode 高可用情况下存放 namenode 的 editlog 文件.

HDFS集群
```
start-dfs.sh 
stop-dfs.sh 
```

YARN集群
```
start-yarn.sh
stop-yarn.sh
```

Hadoop整体集群
```
start-all.sh
stop-all.sh
```

集群验证  
```
http://node01:8088
```

测试  
```
$ bin/yarn jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.5.0.jar wordcount /input/ /output/
```



# yarn命令概述
```
# yarn -help 
Usage: yarn [--config confdir] COMMAND
where COMMAND is one of:
  resourcemanager -format-state-store   deletes the RMStateStore
  resourcemanager                       run the ResourceManager
                                        Use -format-state-store for deleting the RMStateStore.
                                        Use -remove-application-from-state-store <appId> for 
                                            removing application from RMStateStore.
  nodemanager                           run a nodemanager on each slave
  timelineserver                        run the timeline server
  rmadmin                               admin tools
  version                               print the version
  jar <jar>                             run a jar file
  application                           prints application(s)
                                        report/kill application
  applicationattempt                    prints applicationattempt(s)
                                        report
  container                             prints container(s) report
  node                                  prints node report(s)
  queue                                 prints queue information
  logs                                  dump container logs
  classpath                             prints the class path needed to
                                        get the Hadoop jar and the
                                        required libraries
  daemonlog                             get/set the log level for each
                                        daemon
  top                                   run cluster usage tool
 or
  CLASSNAME                             run the class named CLASSNAME
```

使用语法：

- yarn [--config confdir] COMMAND [--loglevel loglevel] [GENERIC_OPTIONS] [COMMAND_OPTIONS]
```
--config confdir        #覆盖默认的配置目录，默认为${HADOOP_PREFIX}/conf.
--loglevel loglevel     #覆盖日志级别。有效的日志级别为FATAL，ERROR，WARN，INFO，DEBUG和TRACE。默认值为INFO。
GENERIC_OPTIONS         #多个命令支持的一组通用选项
COMMAND COMMAND_OPTIONS #以下各节介绍了各种命令及其选项
```

# 命令详解

1、application

- 使用语法：`yarn application [options]` #打印报告，申请和杀死任务
```
-appStates <States>         #与-list一起使用，可根据输入的逗号分隔的应用程序状态列表来过滤应用程序。有效的应用程序状态可以是以下之一：ALL，NEW，NEW_SAVING，SUBMITTED，ACCEPTED，RUNNING，FINISHED，FAILED，KILLED
-appTypes <Types>           #与-list一起使用，可以根据输入的逗号分隔的应用程序类型列表来过滤应用程序。
-list                       #列出RM中的应用程序。支持使用-appTypes来根据应用程序类型过滤应用程序，并支持使用-appStates来根据应用程序状态过滤应用程序。
-kill <ApplicationId>       #终止应用程序。
-status <ApplicationId>     #打印应用程序的状态。
```

2、applicationattempt

- 使用语法：`yarn applicationattempt [options]` #打印应用程序尝试的报告
```
-help                    #帮助
-list <ApplicationId>    #获取到应用程序尝试的列表，其返回值ApplicationAttempt-Id 等于 <Application Attempt Id>
-status <Application Attempt Id>    #打印应用程序尝试的状态。
```

3、classpath

- 使用语法：`yarn classpath` #打印需要得到Hadoop的jar和所需要的lib包路径

4、container

- 使用语法：`yarn container [options]` #打印container(s)的报告
```
-help                            #帮助
-list <Application Attempt Id>   #应用程序尝试的Containers列表
-status <ContainerId>            #打印Container的状态
```

5、jar

- 使用语法：`yarn jar <jar> [mainClass] args...` #运行jar文件，用户可以将写好的YARN代码打包成jar文件，用这个命令去运行它。

6、logs

- 使用语法：`yarn logs -applicationId <application ID> [options]` #转存container的日志。
```
-applicationId <application ID>    #指定应用程序ID，应用程序的ID可以在yarn.resourcemanager.webapp.address配置的路径查看（即：ID）
-appOwner <AppOwner>               #应用的所有者（如果没有指定就是当前用户）应用程序的ID可以在yarn.resourcemanager.webapp.address配置的路径查看（即：User）
-containerId <ContainerId>         #Container Id
-help                              #帮助
-nodeAddress <NodeAddress>         #节点地址的格式：nodename:port （端口是配置文件中:yarn.nodemanager.webapp.address参数指定）
```

7、node
- 使用语法：`yarn node [options]` #打印节点报告
```
-all             #所有的节点，不管是什么状态的。
-list             #列出所有RUNNING状态的节点。支持-states选项过滤指定的状态，节点的状态包含：NEW，RUNNING，UNHEALTHY，DECOMMISSIONED，LOST，REBOOTED。支持--all显示所有的节点。
-states <States> #和-list配合使用，用逗号分隔节点状态，只显示这些状态的节点信息。
-status <NodeId> #打印指定节点的状态。
```

8、queue

- 使用语法：`yarn queue [options]` #打印队列信息
```
-help     #帮助
-status  #<QueueName>    打印队列的状态
```

9、daemonlog

使用语法：
- `yarn daemonlog -getlevel <host:httpport> <classname>`
- `yarn daemonlog -setlevel <host:httpport> <classname> <level>`
```
-getlevel <host:httpport> <classname>            #打印运行在<host:port>的守护进程的日志级别。这个命令内部会连接http://<host:port>/logLevel?log=<name>
-setlevel <host:httpport> <classname> <level>    #设置运行在<host:port>的守护进程的日志级别。这个命令内部会连接http://<host:port>/logLevel?log=<name>
```

10、nodemanager

- 使用语法：`yarn nodemanager` #启动nodemanager

11、proxyserver

- 使用语法：`yarn proxyserver` #启动web proxy server

12、resourcemanager

- 使用语法：`yarn resourcemanager [-format-state-store]` #启动ResourceManager
```
-format-state-store     # RMStateStore的格式. 如果过去的应用程序不再需要，则清理RMStateStore， RMStateStore仅仅在ResourceManager没有运行的时候，才运行RMStateStore
```

13、rmadmin

- 使用语法： #运行Resourcemanager管理客户端
```
yarn rmadmin [-refreshQueues]
              [-refreshNodes]
              [-refreshUserToGroupsMapping] 
              [-refreshSuperUserGroupsConfiguration]
              [-refreshAdminAcls] 
              [-refreshServiceAcl]
              [-getGroups [username]]
              [-transitionToActive [--forceactive] [--forcemanual] <serviceId>]
              [-transitionToStandby [--forcemanual] <serviceId>]
              [-failover [--forcefence] [--forceactive] <serviceId1> <serviceId2>]
              [-getServiceState <serviceId>]
              [-checkHealth <serviceId>]
              [-help [cmd]]
```

```
-refreshQueues    #重载队列的ACL，状态和调度器特定的属性，ResourceManager将重载mapred-queues配置文件
-refreshNodes     #动态刷新dfs.hosts和dfs.hosts.exclude配置，无需重启NameNode。
                  #dfs.hosts：列出了允许连入NameNode的datanode清单（IP或者机器名）
                  #dfs.hosts.exclude：列出了禁止连入NameNode的datanode清单（IP或者机器名）
                  #重新读取hosts和exclude文件，更新允许连到Namenode的或那些需要退出或入编的Datanode的集合。
-refreshUserToGroupsMappings            #刷新用户到组的映射。
-refreshSuperUserGroupsConfiguration    #刷新用户组的配置
-refreshAdminAcls                       #刷新ResourceManager的ACL管理
-refreshServiceAcl                      #ResourceManager重载服务级别的授权文件。
-getGroups [username]                   #获取指定用户所属的组。
-transitionToActive [–forceactive] [–forcemanual] <serviceId>    #尝试将目标服务转为 Active 状态。如果使用了–forceactive选项，不需要核对非Active节点。如果采用了自动故障转移，这个命令不能使用。虽然你可以重写–forcemanual选项，你需要谨慎。
-transitionToStandby [–forcemanual] <serviceId>                  #将服务转为 Standby 状态. 如果采用了自动故障转移，这个命令不能使用。虽然你可以重写–forcemanual选项，你需要谨慎。
-failover [–forceactive] <serviceId1> <serviceId2>  #启动从serviceId1 到 serviceId2的故障转移。如果使用了-forceactive选项，即使服务没有准备，也会尝试故障转移到目标服务。如果采用了自动故障转移，这个命令不能使用。
-getServiceState <serviceId>                        #返回服务的状态。（注：ResourceManager不是HA的时候，时不能运行该命令的）
-checkHealth <serviceId>                            #请求服务器执行健康检查，如果检查失败，RMAdmin将用一个非零标示退出。（注：ResourceManager不是HA的时候，时不能运行该命令的）
-help [cmd]                                         #显示指定命令的帮助，如果没有指定，则显示命令的帮助。
```

14、scmadmin
使用语法：`yarn scmadmin [options]` #运行共享缓存管理客户端
```
-help              #查看帮助
-runCleanerTask    #运行清理任务
```

15、 sharedcachemanager

- 使用语法：`yarn sharedcachemanager` #启动共享缓存管理器


16、timelineserver

- 使用语法：`yarn timelineserver` #启动timelineserver

参考：
- https://hadoop.apache.org/docs/r2.7.7/hadoop-yarn/hadoop-yarn-site/YarnCommands.html

# Hadoop Yarn常用命令
1、查看任务

1.1、yarn application -list
```
# yarn application -list
2021-10-20 09:55:16,497 INFO client.RMProxy: Connecting to ResourceManager at hadoop102/192.168.10.102:8032
Total number of applications (application-types: [], states: [SUBMITTED, ACCEPTED, RUNNING] and tags: []):0
                Application-Id      Application-Name        Application-Type          User           Queue                   State             Final-State             Progress                        Tracking-URL
```

1.2、yarn application -list -appStates
- 根据 Application 状态过滤：yarn application -list -appStates （所有状态：ALL、NEW、NEW_SAVING、SUBMITTED、ACCEPTED、RUNNING、FINISHED、FAILED、KILLED）
```
# yarn application -list -appStates FINISHED
2021-10-20 09:57:30,688 INFO client.RMProxy: Connecting to ResourceManager at hadoop102/192.168.10.102:8032
Total number of applications (application-types: [], states: [FINISHED] and tags: []):0
                Application-Id      Application-Name        Application-Type          User           Queue                   State             Final-State             Progress                        Tracking-URL
```

1.3、kill 调Application
```
# yarn application -kill <applicationId>
# yarn application -kill application_1612577921195_0001
```

2、yarn logs 查看

2.1、查看application日志
```
# yarn logs -applicationId <ApplicationId>
# yarn logs -applicationId application_1612577921195_0001
```

2.2、查询 Container 日志
```
# yarn logs -applicationId <ApplicationId> -containerId <ContainerId>
# yarn logs -applicationId application_1612577921195_0001 -containerId container_1612577921195_0001_01_000001
```

3、查看尝试运行的任务

3.1 列出所有 Application 尝试的列表
```
# yarn applicationattempt -list <ApplicationId>
# yarn applicationattempt -list application_1612577921195_0001
```

3.2、打印 ApplicationAttemp 状态
```
# yarn applicationattempt -status <ApplicationAttemptId>
# yarn applicationattempt -status appattempt_1612577921195_0001_000001
2021-10-20 10:26:54,195 INFO client.RMProxy: Connecting to ResourceManager at hadoop103/192.168.10.103:8032
Total number of application attempts :1
 ApplicationAttempt-Id State AM- Container-Id Tracking-URL
appattempt_1612577921195_0001_000001 FINISHED container_1612577921195_0001_01_000001 http://hadoop103:8088/proxy/application_1612577921195_0001/
```

4、yarn container 查看容器
- 注意：只有在任务跑的途中才能看到 container 的状态

4.1、列出所有 Container
```
# yarn container -list <ApplicationAttemptId>
yarn container -list appattempt_1612577921195_0001_000001
```

4.2、打印 Container 状态
```
# yarn container -status <ContainerId>
yarn container -status container_1612577921195_0001_01_000001
```

5、其他指令

5.1、yarn node 查看节点状态
```
# yarn node -list -all
# yarn node -list -all
2021-10-20 10:15:02,236 INFO client.RMProxy: Connecting to ResourceManager at hadoop102/192.168.10.102:8032
Total Nodes:3
         Node-Id             Node-State Node-Http-Address       Number-of-Running-Containers
 hadoop102:46859                RUNNING    hadoop102:8042                                  0
 hadoop101:35827                RUNNING    hadoop101:8042                                  0
 hadoop103:39244                RUNNING    hadoop103:8042                                  0
```

5.2、yarn rmadmin 更新配置
- 加载队列配置：yarn rmadmin -refreshQueues
```
# yarn rmadmin -refreshQueues
[develop@hadoop102 ~]$  yarn rmadmin -refreshQueues
2021-10-20 10:16:00,157 INFO client.RMProxy: Connecting to ResourceManager at hadoop102/192.168.10.102:8033
```

5.3、yarn queue 查看队列
- 打印队列信息：yarn queue -status
```
# yarn queue -status <QueueName>
# yarn queue -status default
2021-10-20 10:17:10,487 INFO client.RMProxy: Connecting to ResourceManager at hadoop102/192.168.10.102:8032
Queue Information : 
Queue Name : default
        State : RUNNING
        Capacity : 100.0%
        Current Capacity : .0%
        Maximum Capacity : 100.0%
        Default Node Label expression : <DEFAULT_PARTITION>
        Accessible Node Labels : *
        Preemption : disabled
        Intra-queue Preemption : disabled
```
