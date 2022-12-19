# yarn命令概述
``` shell
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

| GENERIC_OPTIONS | Description |
|-----------------|-------------|
| -archives `<comma separated list of archives>` | 用逗号分隔计算中未归档的文件。 仅仅针对JOB。
| -conf `<configuration file>` | 制定应用程序的配置文件。
| -D `<property>=<value>` | 使用给定的属性值。
| -files `<comma separated list of files>` | 用逗号分隔的文件,拷贝到Map reduce机器，仅仅针对JOB
| -jt `<local>` or `<resourcemanager:port>` | 指定一个ResourceManager. 仅仅针对JOB。
| -libjars `<comma seperated list of jars>` | 将用逗号分隔的jar路径包含到classpath中去，仅仅针对JOB。

# 命令详解

1、application

- 使用语法：`yarn application [options]` #打印报告，申请和杀死任务
```
-list                       #列出RM中的应用程序。支持使用-appTypes来根据应用程序类型过滤应用程序，并支持使用-appStates来根据应用程序状态过滤应用程序。
-appStates <States>         #与-list一起使用，可根据输入的逗号分隔的应用程序状态列表来过滤应用程序。有效的应用程序状态可以是以下之一：ALL，NEW，NEW_SAVING，SUBMITTED，ACCEPTED，RUNNING，FINISHED，FAILED，KILLED。
-appTypes <Types>           #与-list一起使用，可以根据输入的逗号分隔的应用程序类型列表来过滤应用程序。

-kill <ApplicationId>       #杀死一个 application，需要指定一个 Application ID。
-status <ApplicationId>     #列出 某个application 的状态。

-movetoqueue <Application ID>   #移动 application 到其他的 queue，不能单独使用。
-queue <Queue Name>             #与 movetoqueue 命令一起使用，指定移动到哪个 queue。
```

示例1：
```
$ ./yarn application -list -appStates ACCEPTED
15/08/10 11:48:43 INFO client.RMProxy: Connecting to ResourceManager at hadoop1/10.0.1.41:8032
Total number of applications (application-types: [] and states: [ACCEPTED]):1
Application-Id	                Application-Name Application-Type User	 Queue	 State	  Final-State Progress Tracking-URL
application_1438998625140_1703	MAC_STATUS	 MAPREDUCE	  hduser default ACCEPTED UNDEFINED   0%       N/A
```

示例2:
```
$ ./yarn application -list
15/08/10 11:43:01 INFO client.RMProxy: Connecting to ResourceManager at hadoop1/10.0.1.41:8032
Total number of applications (application-types: [] and states: [SUBMITTED, ACCEPTED, RUNNING]):1
Application-Id	               Application-Name	Application-Type  User   Queue   State    Final-State   Progress Tracking-URL
application_1438998625140_1701 MAC_STATUS	MAPREDUCE	  hduser default ACCEPTED UNDEFINED	0%	 N/A
```

示例3：
```
$ ./yarn application -kill application_1438998625140_1705
15/08/10 11:57:41 INFO client.RMProxy: Connecting to ResourceManager at hadoop1/10.0.1.41:8032
Killing application application_1438998625140_1705
15/08/10 11:57:42 INFO impl.YarnClientImpl: Killed application application_1438998625140_1705
``` 

示例4：
```
# 移动application 到其他队列
$ ./yarn  application -movetoqueue application_1479736113445_2577 -queue other
```

示例5：
```
$ ./yarn application -status application_1670913878726_0009
Application Report : 
	Application-Id : application_1670913878726_0009
	Application-Name : ecs_3979920284451840_online
	Application-Type : Apache Flink
	User : eoi
	Queue : default
	Application Priority : 0
	Start-Time : 1670996233080
	Finish-Time : 0
	Progress : 100%
	State : RUNNING
	Final-State : UNDEFINED
	Tracking-URL : http://node03:40321
	RPC Port : 40321
	AM Host : node03
	Aggregate Resource Allocation : 1094361106 MB-seconds, 854989 vcore-seconds
	Aggregate Resource Preempted : 0 MB-seconds, 0 vcore-seconds
	Log Aggregation Status : NOT_START
	Diagnostics : Attempt recovered after RM restart
	Unmanaged Application : false
	Application Node Label Expression : <Not set>
	AM container Node Label Expression : <DEFAULT_PARTITION>
```

2、applicationattempt

- 使用语法：`yarn applicationattempt [options]` #打印应用程序尝试运行的任务
```
-help                    #帮助
-list <ApplicationId>    #获取到应用程序尝试的列表，其返回值ApplicationAttempt-Id 等于 <Application Attempt Id>
-status <Application Attempt Id>    #打印应用程序尝试的状态。
```

示例1：
```
$ yarn applicationattempt -list application_1437364567082_0106
15/08/10 20:58:28 INFO client.RMProxy: Connecting to ResourceManager at hadoopcluster79/10.0.1.79:8032
Total number of application attempts :1
ApplicationAttempt-Id	                 State    AM-Container-Id	                       Tracking-URL
appattempt_1437364567082_0106_000001   RUNNING	container_1437364567082_0106_01_000001 http://hadoopcluster79:8088/proxy/application_1437364567082_0106/
```

示例2：
```
$ yarn applicationattempt -status appattempt_1437364567082_0106_000001
15/08/10 21:01:41 INFO client.RMProxy: Connecting to ResourceManager at hadoopcluster79/10.0.1.79:8032
Application Attempt Report : 
	ApplicationAttempt-Id : appattempt_1437364567082_0106_000001
	State : FINISHED
	AMContainer : container_1437364567082_0106_01_000001
	Tracking-URL : http://hadoopcluster79:8088/proxy/application_1437364567082_0106/jobhistory/job/job_1437364567082_0106
	RPC Port : 51911
	AM Host : hadoopcluster80
	Diagnostics :
```

3、classpath

- 使用语法：`yarn classpath` #打印需要得到Hadoop的jar和所需要的lib包路径

示例
```
$ yarn classpath
/home/hadoop/apache/hadoop-2.4.1/etc/hadoop:/home/hadoop/apache/hadoop-2.4.1/etc/hadoop:/home/hadoop/apache/hadoop-2.4.1/etc/hadoop:/home/hadoop/apache/hadoop-2.4.1/share/hadoop/common/lib/*:/home/hadoop/apache/hadoop-2.4.1/share/hadoop/common/*:/home/hadoop/apache/hadoop-2.4.1/share/hadoop/hdfs:/home/hadoop/apache/hadoop-2.4.1/share/hadoop/hdfs/lib/*:/home/hadoop/apache/hadoop-2.4.1/share/hadoop/hdfs/*:/home/hadoop/apache/hadoop-2.4.1/share/hadoop/yarn/lib/*:/home/hadoop/apache/hadoop-2.4.1/share/hadoop/yarn/*:/home/hadoop/apache/hadoop-2.4.1/share/hadoop/mapreduce/lib/*:/home/hadoop/apache/hadoop-2.4.1/share/hadoop/mapreduce/*:/home/hadoop/apache/hadoop-2.4.1/contrib/capacity-scheduler/*.jar:/home/hadoop/apache/hadoop-2.4.1/share/hadoop/yarn/*:/home/hadoop/apache/hadoop-2.4.1/share/hadoop/yarn/lib/*
```

4、container

- 使用语法：`yarn container [options]` #打印container(s)的报告
```
-help                            #帮助
-list <Application Attempt Id>   #应用程序尝试的Containers列表
-status <ContainerId>            #打印Container的状态
```

示例1：
```
[hadoop@hadoopcluster78 bin]$ yarn container -list appattempt_1437364567082_0106_01 
15/08/10 20:45:45 INFO client.RMProxy: Connecting to ResourceManager at hadoopcluster79/10.0.1.79:8032
Total number of containers :25
Container-Id                                   Start Time                         Finish Time        State      Host                    LOG-URL
container_1437364567082_0106_01_000028	       1439210458659	                   0	             RUNNING	hadoopcluster83:37140	//hadoopcluster83:8042/node/containerlogs/container_1437364567082_0106_01_000028/hadoop
container_1437364567082_0106_01_000016	       1439210314436	                   0	             RUNNING	hadoopcluster84:43818	//hadoopcluster84:8042/node/containerlogs/container_1437364567082_0106_01_000016/hadoop
container_1437364567082_0106_01_000019	       1439210338598	                   0	             RUNNING	hadoopcluster83:37140	//hadoopcluster83:8042/node/containerlogs/container_1437364567082_0106_01_000019/hadoop
container_1437364567082_0106_01_000004	       1439210314130	                   0	             RUNNING	hadoopcluster82:48622	//hadoopcluster82:8042/node/containerlogs/container_1437364567082_0106_01_000004/hadoop
container_1437364567082_0106_01_000008	       1439210314130	                   0	             RUNNING	hadoopcluster82:48622	//hadoopcluster82:8042/node/containerlogs/container_1437364567082_0106_01_000008/hadoop
container_1437364567082_0106_01_000031	       1439210718604	                   0	             RUNNING	hadoopcluster83:37140	//hadoopcluster83:8042/node/containerlogs/container_1437364567082_0106_01_000031/hadoop
container_1437364567082_0106_01_000020	       1439210339601	                   0	             RUNNING	hadoopcluster83:37140	//hadoopcluster83:8042/node/containerlogs/container_1437364567082_0106_01_000020/hadoop
container_1437364567082_0106_01_000005	       1439210314130	                   0	             RUNNING	hadoopcluster82:48622	//hadoopcluster82:8042/node/containerlogs/container_1437364567082_0106_01_000005/hadoop
container_1437364567082_0106_01_000013	       1439210314435	                   0	             RUNNING	hadoopcluster84:43818	//hadoopcluster84:8042/node/containerlogs/container_1437364567082_0106_01_000013/hadoop
container_1437364567082_0106_01_000022	       1439210368679	                   0	             RUNNING	hadoopcluster84:43818	//hadoopcluster84:8042/node/containerlogs/container_1437364567082_0106_01_000022/hadoop
container_1437364567082_0106_01_000021	       1439210353626	                   0	             RUNNING	hadoopcluster83:37140	//hadoopcluster83:8042/node/containerlogs/container_1437364567082_0106_01_000021/hadoop
container_1437364567082_0106_01_000014	       1439210314435	                   0	             RUNNING	hadoopcluster84:43818	//hadoopcluster84:8042/node/containerlogs/container_1437364567082_0106_01_000014/hadoop
container_1437364567082_0106_01_000029	       1439210473726	                   0	             RUNNING	hadoopcluster80:42366	//hadoopcluster80:8042/node/containerlogs/container_1437364567082_0106_01_000029/hadoop
container_1437364567082_0106_01_000006	       1439210314130	                   0	             RUNNING	hadoopcluster82:48622	//hadoopcluster82:8042/node/containerlogs/container_1437364567082_0106_01_000006/hadoop
container_1437364567082_0106_01_000003	       1439210314129	                   0	             RUNNING	hadoopcluster82:48622	//hadoopcluster82:8042/node/containerlogs/container_1437364567082_0106_01_000003/hadoop
container_1437364567082_0106_01_000015	       1439210314436	                   0	             RUNNING	hadoopcluster84:43818	//hadoopcluster84:8042/node/containerlogs/container_1437364567082_0106_01_000015/hadoop
container_1437364567082_0106_01_000009	       1439210314130	                   0	             RUNNING	hadoopcluster82:48622	//hadoopcluster82:8042/node/containerlogs/container_1437364567082_0106_01_000009/hadoop
container_1437364567082_0106_01_000030	       1439210708467	                   0	             RUNNING	hadoopcluster83:37140	//hadoopcluster83:8042/node/containerlogs/container_1437364567082_0106_01_000030/hadoop
container_1437364567082_0106_01_000012	       1439210314435	                   0	             RUNNING	hadoopcluster84:43818	//hadoopcluster84:8042/node/containerlogs/container_1437364567082_0106_01_000012/hadoop
container_1437364567082_0106_01_000027	       1439210444354	                   0	             RUNNING	hadoopcluster84:43818	//hadoopcluster84:8042/node/containerlogs/container_1437364567082_0106_01_000027/hadoop
container_1437364567082_0106_01_000026	       1439210428514	                   0	             RUNNING	hadoopcluster83:37140	//hadoopcluster83:8042/node/containerlogs/container_1437364567082_0106_01_000026/hadoop
container_1437364567082_0106_01_000017	       1439210314436	                   0	             RUNNING	hadoopcluster84:43818	//hadoopcluster84:8042/node/containerlogs/container_1437364567082_0106_01_000017/hadoop
container_1437364567082_0106_01_000001	       1439210306902	                   0	             RUNNING	hadoopcluster80:42366	//hadoopcluster80:8042/node/containerlogs/container_1437364567082_0106_01_000001/hadoop
container_1437364567082_0106_01_000002	       1439210314129	                   0	             RUNNING	hadoopcluster82:48622	//hadoopcluster82:8042/node/containerlogs/container_1437364567082_0106_01_000002/hadoop
container_1437364567082_0106_01_000025	       1439210414171	                   0	             RUNNING	hadoopcluster83:37140	//hadoopcluster83:8042/node/containerlogs/container_1437364567082_0106_01_000025/hadoop
```

示例2：
```
[hadoop@hadoopcluster78 bin]$ yarn container -status container_1437364567082_0105_01_000020 
15/08/10 20:28:00 INFO client.RMProxy: Connecting to ResourceManager at hadoopcluster79/10.0.1.79:8032
Container Report : 
	Container-Id : container_1437364567082_0105_01_000020
	Start-Time : 1439208779842
	Finish-Time : 0
	State : RUNNING
	LOG-URL : //hadoopcluster83:8042/node/containerlogs/container_1437364567082_0105_01_000020/hadoop
	Host : hadoopcluster83:37140
	Diagnostics : null
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

示例1：
```
$ yarn logs -applicationId application_1437364567082_0104  -appOwner hadoop
15/08/10 17:59:19 INFO client.RMProxy: Connecting to ResourceManager at hadoopcluster79/10.0.1.79:8032


Container: container_1437364567082_0104_01_000003 on hadoopcluster82_48622
============================================================================
LogType: stderr
LogLength: 0
Log Contents:

LogType: stdout
LogLength: 0
Log Contents:

LogType: syslog
LogLength: 3673
Log Contents:
2015-08-10 17:24:01,565 WARN [main] org.apache.hadoop.conf.Configuration: job.xml:an attempt to override final parameter: mapreduce.job.end-notification.max.retry.interval;  Ignoring.
2015-08-10 17:24:01,580 WARN [main] org.apache.hadoop.conf.Configuration: job.xml:an attempt to override final parameter: mapreduce.job.end-notification.max.attempts;  Ignoring.
。。。。。。此处省略N万个字符


// 下面的命令，根据APP的全部者查看LOG日志，由于application_1437364567082_0104任务我是用hadoop用户启动的，因此打印的是以下信息：
$ yarn logs -applicationId application_1437364567082_0104  -appOwner root
15/08/10 17:59:25 INFO client.RMProxy: Connecting to ResourceManager at hadoopcluster79/10.0.1.79:8032
Logs not available at /tmp/logs/root/logs/application_1437364567082_0104
Log aggregation has not completed or is not enabled.
```

示例2：查看container日志
```
$ yarn logs -applicationId application_1437364567082_0104 -containerId container_1437364567082_0106_01_000030
```

7、node
- 使用语法：`yarn node [options]` #打印节点报告
```
-all             #所有的节点，不管是什么状态的。
-list             #列出所有RUNNING状态的节点。支持-states选项过滤指定的状态，节点的状态包含：NEW，RUNNING，UNHEALTHY，DECOMMISSIONED，LOST，REBOOTED。支持--all显示所有的节点。
-states <States> #和-list配合使用，用逗号分隔节点状态，只显示这些状态的节点信息。
-status <NodeId> #打印指定节点的状态。
```

示例1：
```
[hadoop@hadoopcluster78 bin]$ ./yarn node -list -all
15/08/10 17:34:17 INFO client.RMProxy: Connecting to ResourceManager at hadoopcluster79/10.0.1.79:8032
Total Nodes:4
         Node-Id	     Node-State	Node-Http-Address	Number-of-Running-Containers
hadoopcluster82:48622	        RUNNING	hadoopcluster82:8042	                           0
hadoopcluster84:43818	        RUNNING	hadoopcluster84:8042	                           0
hadoopcluster83:37140	        RUNNING	hadoopcluster83:8042	                           0
hadoopcluster80:42366	        RUNNING	hadoopcluster80:8042	                           0
```

示例2：
```
[hadoop@hadoopcluster78 bin]$ ./yarn node -list -states RUNNING
15/08/10 17:39:55 INFO client.RMProxy: Connecting to ResourceManager at hadoopcluster79/10.0.1.79:8032
Total Nodes:4
         Node-Id	     Node-State	Node-Http-Address	Number-of-Running-Containers
hadoopcluster82:48622	        RUNNING	hadoopcluster82:8042	                           0
hadoopcluster84:43818	        RUNNING	hadoopcluster84:8042	                           0
hadoopcluster83:37140	        RUNNING	hadoopcluster83:8042	                           0
hadoopcluster80:42366	        RUNNING	hadoopcluster80:8042	                           0
```

示例3：
```
[hadoop@hadoopcluster78 bin]$ ./yarn node -status hadoopcluster82:48622
15/08/10 17:52:52 INFO client.RMProxy: Connecting to ResourceManager at hadoopcluster79/10.0.1.79:8032
Node Report : 
	Node-Id : hadoopcluster82:48622
	Rack : /default-rack
	Node-State : RUNNING
	Node-Http-Address : hadoopcluster82:8042
	Last-Health-Update : 星期一 10/八月/15 05:52:09:601CST
	Health-Report : 
	Containers : 0
	Memory-Used : 0MB
	Memory-Capacity : 10240MB
	CPU-Used : 0 vcores
	CPU-Capacity : 8 vcores
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

示例1：
```
# hadoop daemonlog -getlevel hadoopcluster82:50075 org.apache.hadoop.hdfs.server.datanode.DataNode
Connecting to http://hadoopcluster82:50075/logLevel?log=org.apache.hadoop.hdfs.server.datanode.DataNode
Submitted Log Name: org.apache.hadoop.hdfs.server.datanode.DataNode
Log Class: org.apache.commons.logging.impl.Log4JLogger
Effective level: INFO

# yarn daemonlog -getlevel hadoopcluster79:8088 org.apache.hadoop.yarn.server.resourcemanager.rmapp.RMAppImpl
Connecting to http://hadoopcluster79:8088/logLevel?log=org.apache.hadoop.yarn.server.resourcemanager.rmapp.RMAppImpl
Submitted Log Name: org.apache.hadoop.yarn.server.resourcemanager.rmapp.RMAppImpl
Log Class: org.apache.commons.logging.impl.Log4JLogger
Effective level: INFO

# yarn daemonlog -getlevel hadoopcluster78:19888 org.apache.hadoop.mapreduce.v2.hs.JobHistory
Connecting to http://hadoopcluster78:19888/logLevel?log=org.apache.hadoop.mapreduce.v2.hs.JobHistory
Submitted Log Name: org.apache.hadoop.mapreduce.v2.hs.JobHistory
Log Class: org.apache.commons.logging.impl.Log4JLogger
Effective level: INFO
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

17、version

- 使用语法: `yarn version` # 打印hadoop的版本。

```
$ ./yarn version
Hadoop 2.8.5
Subversion https://git-wip-us.apache.org/repos/asf/hadoop.git -r 0b8464d75227fcee2c6e7f2410377b3d53d3d5f8
Compiled by jdu on 2018-09-10T03:32Z
Compiled with protoc 2.5.0
From source with checksum 9942ca5c745417c14e318835f420733
This command was run using /app/hadoop-2.8.5/share/hadoop/common/hadoop-common-2.8.5.jar
```

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
# yarn node -list

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

### Yarn常用shell命令

| 命令                              | 命令解释                                                     |
| --------------------------------- | ------------------------------------------------------------ |
| yarn node --list                  | 查看各个node上的任务数                                       |
| yarn application --list           | 列出所有的application信息                                    |
| yarn application -kill id         | 杀死一个application，需要指定一个application ID              |
| yarn node -status  NodeId        | 查看nodemanager节点的具体信息                                |
| yarn logs applicationId `<application id>`        | 查看任务日志信息                            |
| yarn logs -applicationId `<application id>` -containerId `<container id>`  | 查看某个容器的日志                        |
| yarn application -list -appStates | 状态过滤（all，new，new_saving，submitted，accepted，running，finished，failed，killed） |
| yarn container -list              | 查看容器                                                     |
| yarn rmadmin                      | 更新配置，加载队列配置（yarn rmadmin -refreshQueues）        |
| yarn queue -status [default]      | 查看队列，打印队列信息                                       |
| yarn rmadmin -refreshQueues       | 更新队列配置                                                 |

参考： 
- https://zhuanlan.zhihu.com/p/517237014
- https://hadoop.apache.org/docs/r3.3.4/hadoop-yarn/hadoop-yarn-site/YarnCommands.html
- http://www.javashuo.com/article/p-klvnbfyh-hb.html
