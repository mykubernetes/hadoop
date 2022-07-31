hdfs ha  
=======
一、Linux 其他准备操作  
配置NTP时间服务器  
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
``` # ntpdate pool.ntp.org ```  

3、 修改NTP配置文件  
```
# vi /etc/ntp.conf
去掉下面这行前面的# ,并把网段修改成自己的网段：
restrict 192.168.122.0 mask 255.255.255.0 nomodify notrap
注释掉以下几行：
#server 0.centos.pool.ntp.org
#server 1.centos.pool.ntp.org
#server 2.centos.pool.ntp.org
把下面两行前面的#号去掉,如果没有这两行内容,需要手动添加
server  127.127.1.0    # local clock
fudge  127.127.1.0 stratum 10
```  

4、重启ntp服务  
```
# systemctl start ntpd.service
# systemctl enable ntpd.service
```  

5、集群其他节点去同步这台时间服务器时间  
首先需要关闭这两台计算机的ntp服务  
```
# systemctl stop ntpd.service
# systemctl disable ntpd.service
# systemctl status ntpd，查看ntp服务状态
# pgrep ntpd，查看ntp服务进程id
同步第一台服务器z01的时间：
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
把生成之后的公钥拷贝给node01,node02,node03这三台机器，包含当前机器。  
$ ssh-copy-id node01  
$ ssh-copy-id node02  
$ ssh-copy-id node03  
```  


二、安装  
首先安装jdk  
``` $ tar -zxf /opt/softwares/jdk-8u121-linux-x64.gz -C /opt/modules/ ```  
2 JDK环境变量配置  
```
# vi /etc/profile
#JAVA_HOME
export JAVA_HOME=/opt/modules/jdk1.8.0_121
export PATH=$PATH:$JAVA_HOME/bin
```
zookeeper  
1、修改zoo.cfg配置文件  
修改conf目录下的zoo.cfg文件，如果没有该文件，请自行重命名sample.cfg文件，修改内容为：  
```
dataDir=/opt/modules/zookeeper/zkData
dataLogDir=/opt/modules/zookeeper/zkLog
server.1=node01:2888:3888
server.2=node02:2888:3888
server.3=node03:2888:3888
```
同时创建dataDir属性值所指定的目录  
2、在zkData目录下创建myid文件，修改值为1，如：  
```
$ cd /opt/modules/zookeeper/zkData
$ touch myid
$ echo 1 > myid
```
3、将zookeeper安装目录scp到其他机器节点  
```
$ scp -r /opt/modules/zookeeper/ node02:/opt/modules/
$ scp -r /opt/modules/zookeeper/ node03:/opt/modules/
```
4、修改其他机器节点的myid文件为2和3  
```
$ echo 2 > myid
$ echo 3 > myid
```
5、在每个节点上启动zookeeper以及查看状态  
```
$ bin/zkServer.sh start
$ bin/zkServer.sh status
```
三、hadoop  

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
```
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
	
        <property>
                <name>dfs.webhdfs.enabled</name>
                <value>true</value>
        </property>

</configuration>
```
- 访问namenode的hdfs使用50070端口，访问datanode的webhdfs使用50075端口。访问文件、文件夹信息使用namenode的IP和50070端口，访问文件内容或者进行打开、上传、修改、下载等操作使用datanode的IP和50075端口。要想不区分端口，直接使用namenode的IP和端口进行所有的webhdfs操作，就需要在所有的datanode上都设置hefs-site.xml中的dfs.webhdfs.enabled为true

4、编辑core-site.xml文件, 修改主机名，defaultFS名，dir存储路径等信息  
```
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

创建配置文件里的数据目录和journalnode目录
```
mkdir /opt/modules/cdh/hadoop/data
mkdir /opt/modules/cdh/hadoop/data/jn
```
完成后远程拷贝给其他服务器  

修改slaves文件,配置数据节点  
```
# vim slaves
node01
node02
node03
```
命令操作：  
启动服务  

初始化ha在zookeeper中的状态  
```$ bin/hdfs zkfc -formatZK ```  

在[nn1]上，对其进行格式化，并启动  
```
$ bin/hdfs namenode -format
$ sbin/hadoop-daemon.sh start namenode
```
在[nn2]上，同步nn1的元数据信息，并启动  
```
$ bin/hdfs namenode -bootstrapStandby
$ sbin/hadoop-daemon.sh start namenode
```  

启动各个进程  
``` sbin/start-dfs.sh ```  

查看各进程状态  
```
$ jps
13810 NameNode     
14096 JournalNode                  namenode  editlog备份
14350 Jps
3246 QuorumPeerMain                zookeeper进程
13908 DataNode                     数据节点
14264 DFSZKFailoverController      namedode故障自动转移
```

以下为手动启动方法按顺序启动  
——————————————————————————————————————————————————————  
初始化ha在zookeeper中的状态  
```$ bin/hdfs zkfc -formatZK ```  

在各个JournalNode节点上，输入以下命令启动journalnode服务：  
``` $ sbin/hadoop-daemon.sh start journalnode ```

在[nn1]上，对其进行格式化，并启动  
```
$ bin/hdfs namenode -format
$ sbin/hadoop-daemon.sh start namenode
```
在[nn2]上，同步nn1的元数据信息，并启动  
```
$ bin/hdfs namenode -bootstrapStandby
$ sbin/hadoop-daemon.sh start namenode
```
手动把nn1设置为active  
``` $ bin/hdfs haadmin -transitionToActive nn1 ```

查看服务状态  
``` $ bin/hdfs haadmin -getServiceState nn1 ```  

在各个节点启动数据节点  
``` $ sbin/hadoop-daemon.sh start datanode ```  
启动元数据故障转移  
``` $ sbin/hadoop-daemon.sh start zkfc ```

——————————————————————————————————————————————————————

重启各个服务  
访问web地址  
``` http://node01:50070 ```

四、2.2ResourceManager HA  

配置yarn的java环境变量
```
# vim yarn-env.sh  
export JAVA_HOME=/opt/modules/jdk1.8.0_121
export YARN_PID_DIR=${HADOOP_HOME}/pids
```

* yarn-site.xml  
```
<configuration>

<!-- Site specific YARN configuration properties -->
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>

    <property>
        <name>yarn.log-aggregation-enable</name>
        <value>true</value>
    </property>

    <!--任务历史服务-->
    <property> 
        <name>yarn.log.server.url</name> 
        <value>http://node01:19888/jobhistory/logs/</value> 
    </property> 

    <property>
        <name>yarn.log-aggregation.retain-seconds</name>
        <value>86400</value>
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

    <property>
        <name>yarn.resourcemanager.ha.rm-ids</name>
        <value>rm1,rm2</value>
    </property>

    <property>
        <name>yarn.resourcemanager.hostname.rm1</name>
        <value>node01</value>
    </property>

    <property>
        <name>yarn.resourcemanager.hostname.rm2</name>
        <value>node02</value>
    </property>
 
    <!--指定zookeeper集群的地址--> 
    <property>
        <name>yarn.resourcemanager.zk-address</name>
        <value>node01:2181,node02:2181,node03:2181</value>
    </property>

    <!--启用自动恢复--> 
    <property>
        <name>yarn.resourcemanager.recovery.enabled</name>
        <value>true</value>
    </property>
 
    <!--指定resourcemanager的状态信息存储在zookeeper集群--> 
    <property>
        <name>yarn.resourcemanager.store.class</name>    
        <value>org.apache.hadoop.yarn.server.resourcemanager.recovery.ZKRMStateStore</value>
    </property>
</configuration>
```

修改资源百分比，默认为0.1，设置0.5以上,表示集群上AM最多可使用的资源比例，目的为限制过多的app数量。
```
# vim capacity-scheduler.xml
<property>
    <name>yarn.scheduler.capacity.maximum-am-resource-percent</name>     
    <value>0.5</value>
    <description> 
    集群中用于运行应用程序ApplicationMaster的资源比例上限，该参数通常用于限制处于活动状态的应用程序数目。该参数类型为浮点型，默认是0.1，表示10%。所有队列的ApplicationMaster资源比例上限可通过参数 #### yarn.scheduler.capacity.maximum-am-resource-percent设置，而单个队列可通过参数yarn.scheduler.capacity.<queue-path>.maximum-am-resource-percent设置适合自己的值。
    </description>
</property>
```


* mapred-env.sh  
```
export JAVA_HOME=/opt/modules/jdk1.8.0_121
export HADOOP_MAPRED_PID_DIR=${HADOOP_HOME}/pids
```
	
* mapred-site.xml  
```
<configuration>
    <-- 指定mr运行在yarn上 -->
    <property>
        <name>mapreduce.framework.name</name>    
        <value>yarn</value>
    </property>
</configuration>
```

完成后远程拷贝给其他服务器  
``` $ scp etc/hadoop/yarn-site.xml node02:/opt/modules/hadoop-2.5.0/etc/hadoop/ ```  
通过jps查看每个服务器的zookeeper服务QuorumPeerMain已经运行，没有运行则开启，方式前文已经说过，不再赘述。  
在resourcemanager节点中启动（node02）中执行：  
``` $ sbin/start-yarn.sh ```  
在resourcemanager备份节点启动（node03）中执行：  
``` $ sbin/yarn-daemon.sh start resourcemanager ```  
查看服务状态  
``` $ bin/yarn rmadmin -getServiceState rm1 ```  

启动jobhistoryserver进程  
``` $ sbin/mr-jobhistory-daemon.sh start historyserver ```

两台机器分别查看jobhistoryserver  resourcemanager nodemanager进程  
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
- 1）NameNode 它是 hadoop 中的主服务器，管理文件系统名称空间和对集群中存储的文件的 访问，保存有 metadate。
- 2）SecondaryNameNode 提供周期检查点和清理任务。帮助 NN 合并 editslog，减少 NN 启动 时间。
- 3）DataNode 它负责管理连接到节点的存储（一个集群中可以有多个节点）。每个存储数据 的节点运行一个 datanode 守护进程。
- 4）ResourceManager（JobTracker）JobTracker 负责调度 DataNode 上的工作。每个 DataNode 有一个 TaskTracker，它们执行实际工作。
- 5）NodeManager（TaskTracker）执行任务
- 6）DFSZKFailoverController 高可用时它负责监控 NN 的状态，并及时的把状态信息写入 ZK。 它通过一个独立线程周期性的调用 NN 上的一个特定接口来获取 NN 的健康状态。FC 也有选 择谁作为 Active NN 的权利，因为最多只有两个节点，目前选择策略还比较简单（先到先得， 轮换）。
- 7）JournalNode 高可用情况下存放 namenode 的 editlog 文件.



访问web地址  
```
http://node:8088
```

测试  
```
$ bin/yarn jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.5.0.jar wordcount /input/ /output/
```
