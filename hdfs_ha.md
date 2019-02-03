hdfs ha  

一、Linux 其他准备操作  
配置NTP时间服务器  
	1、 检查时区  
	对于我们当前这种案例，主要目标是把z01这台服务器设置为时间服务器，剩下的z02，z03这两台机器同步z01的时间，我们需要这样做的原因是因为，整个集群架构中的时间，要保持一致。
	检查当前系统时区，使用命令：# date -R  
 	注意这里，如果显示的时区不是+0800，你可以删除localtime文件夹后，再关联一个正确时区的链接过去，命令如下：  
	# rm -rf /etc/localtime  
	# ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime  
	2、 同步时间  
	# ntpdate pool.ntp.org  
	3、 修改NTP配置文件  
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
	4、 重启ntp服务  
	# systemctl start ntpd.service，注意，如果是centOS7以下的版本，使用命令：service ntpd start  
	# systemctl enable ntpd.service，注意，如果是centOS7以下的版本，使用命令：chkconfig ntpd on  
	5、 集群其他节点去同步这台时间服务器时间  
	首先需要关闭这两台计算机的ntp服务  
	# systemctl stop ntpd.service，centOS7以下，则：service ntpd stop  
	# systemctl disable ntpd.service，centOS7以下，则：chkconfig ntpd off  
	# systemctl status ntpd，查看ntp服务状态  
	# pgrep ntpd，查看ntp服务进程id  
	同步第一台服务器z01的时间：  
	# ntpdate node01  
	6、 制定计划任务,周期性同步时间  
	# crontab -e  
	*/10 * * * * /usr/sbin/ntpdate node01  
	7、 重启定时任务  
	# systemctl restart crond.service，centOS7以下使用：service crond restart，其他台机器的配置同理  
	
ssh无秘钥登录  
	配置hadoop集群，首先需要配置集群中的各个主机的ssh无密钥访问  
	在z04上，通过如下命令，生成一对公私钥对  
	$ ssh-keygen -t rsa，，会在/home/z/.ssh/目录下生成两个文件：id_rsa 和 id_rsa.pub，如图所示：  
	生成之后呢，把z01生成的公钥拷贝给node01,node02,node03这三台机器，包含当前机器。  
	$ ssh-copy-id node01  
	$ ssh-copy-id node02  
	$ ssh-copy-id node03  
	完成后，其他机器同理。   

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
JDK环境变量配置  
```
# vi /etc/profile
#JAVA_HOME
export HADOOP_HOME=/opt/modules/hadoop-2.7.2
export PATH=$PATH:$HADOOP_HOME/bin
export PATH=$PATH:$HADOOP_HOME/sbin
source /etc/profile
```

1、NameNode HA  
设置hadoop里的JAVA_HOME  
* hadoop-env.sh  
``` export JAVA_HOME=/opt/modules/jdk1.8.0_121 ```

* hdfs-site.xml  
```
<configuration>
	<!-- 指定数据冗余份数 -->
	<property>
		<name>dfs.replication</name>
		<value>3</value>
	</property>

	<!-- 完全分布式集群名称 -->
	<property>
		<name>dfs.nameservices</name>
		<value>mycluster</value>
	</property>

	<!-- 集群中NameNode节点都有哪些 -->
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

	<!-- 指定NameNode元数据在JournalNode上的存放位置 -->
	<property>
		<name>dfs.namenode.shared.edits.dir</name>
		<value>qjournal://node01:8485;node02:8485;node03:8485/mycluster</value>
	</property>

	<!-- 配置隔离机制，即同一时刻只能有一台服务器对外响应 -->
	<property>
		<name>dfs.ha.fencing.methods</name>
		<value>sshfence</value>
	</property>

	<!-- 使用隔离机制时需要ssh无秘钥登录-->
	<property>
		<name>dfs.ha.fencing.ssh.private-key-files</name>
		<value>/home/hadoop/.ssh/id_rsa</value>
	</property>

	<!-- 声明journalnode服务器存储目录-->
	<property>
		<name>dfs.journalnode.edits.dir</name>
		<value>/opt/modules/cdh/hadoop/data/jn</value>
	</property>

	<!-- 关闭权限检查-->
	<property>
		<name>dfs.permissions.enable</name>
		<value>false</value>
	</property>

	<!-- 访问代理类：client，mycluster，active配置失败自动切换实现方式-->
	<property>
  		<name>dfs.client.failover.proxy.provider.mycluster</name>
  		<value>org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider</value>
	</property>
	
	<!--namenode故障转移自动切换-->
	<property>
		<name>dfs.ha.automatic-failover.enabled</name>
		<value>true</value>
	</property>
	
</configuration>
```

* core-site.xml  
```
<configuration>
	<!--指定HDFS中NameNode的地址或集群名-->
	<property>
		<name>fs.defaultFS</name>
		<value>hdfs://mycluster</value>
	</property>

	<!--指定hadoop运行时产生文件的存储目录-->
	<property>
		<name>hadoop.tmp.dir</name>
		<value>/opt/modules/cdh/hadoop/data</value>
	</property>
	
	<!--namenode故障转移自动切换和hdfs.xml里的文件同时用-->
	<property>
		<name>ha.zookeeper.quorum</name>
		<value>node01:2181,node02:2181,node03:2181</value>
	</property>
</configuration>
```
完成后远程拷贝给其他服务器  

配置数据节点  
```
   slave
	node01
	node02
	node03
```
命令操作：  
启动服务  
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
	
初始化ha在zookeeper中的状态  
```$ bin/hdfs zkfc -formatZK ```

重启各个服务  
访问web地址  
``` http://node01:50070 ```

四、2.2ResourceManager HA  
* yarn-env.sh  
``` export JAVA_HOME=/opt/modules/jdk1.8.0_121 ```

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

*mapred-env.sh  
``` export JAVA_HOME=/opt/modules/jdk1.8.0_121 ```
	
*mapred-site.xml  
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
访问web地址  
``` http://node:8088 ```  

测试  
```$ bin/yarn jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.5.0.jar wordcount /input/ /output/ ```
