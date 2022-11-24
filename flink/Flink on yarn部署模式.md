# 深入理解Flink-On-Yarn模式

# 1. 前言

- Flink提供了两种在yarn上运行的模式，分别为Session-Cluster和Per-Job-Cluster模式，本文分析两种模式及启动流程。

# Flink 作业提交
因Flink强大的灵活性及开箱即用的原则， 因此提交作业分为2种情况：

- yarn seesion
- Flink run

这2者对于现有大数据平台资源使用率有着很大的区别：
- 1.第一种yarn seesion(Start a long-running Flink cluster on YARN)这种方式需要先启动集群，然后在提交作业，接着会向yarn申请一块空间后，资源永远保持不变。如果资源满了，下一个作业就无法提交，只能等到yarn中的其中一个作业执行完成后，释放了资源，那下一个作业才会正常提交.
- 2.第二种Flink run直接在YARN上提交运行Flink作业(Run a Flink job on YARN)，这种方式的好处是一个任务会对应一个job,即没提交一个作业会根据自身的情况，向yarn申请资源，直到作业执行完成，并不会影响下一个作业的正常运行，除非是yarn上面没有任何资源的情况下。

# Flink yarn session部署

用yarn session在启动集群时，有2种方式可以进行集群启动分别是：
- 客户端模式
- 分离式模式

# 2. Session-Cluster模式

- Session-Cluster模式需要先启动集群，然后再提交作业，接着会向yarn申请一块空间后，资源永远保持不变。如果资源满了，下一个作业就无法提交，只能等到yarn中的其中一个作业执行完成后，释放了资源，下个作业才会正常提交。所有作业共享Dispatcher和ResourceManager；共享资源；适合规模小执行时间短的作业。

## 客户端模式

默认可以直接执行bin/yarn-session.sh 默认启动的配置是
```
{masterMemoryMB=1024, taskManagerMemoryMB=1024,numberTaskManagers=1, slotsPerTaskManager=1}
```

需要自己自定义配置的话，可以使用来查看参数：
```
bin/yarn-session.sh –help
Usage:
   Required
     -n,--container <arg>   Number of YARN container to allocate (=Number of Task Managers)
   Optional
     -D <property=value>             use value for given property
     -d,--detached                   If present, runs the job in detached mode
     -h,--help                       Help for the Yarn session CLI.
     -id,--applicationId <arg>       Attach to running YARN session
     -j,--jar <arg>                  Path to Flink jar file
     -jm,--jobManagerMemory <arg>    Memory for JobManager Container with optional unit (default: MB)
     -m,--jobmanager <arg>           Address of the JobManager (master) to which to connect. Use this flag to connect to a different JobManager than the one specified in the configuration.
     -n,--container <arg>            Number of YARN container to allocate (=Number of Task Managers)
     -nl,--nodeLabel <arg>           Specify YARN node label for the YARN application
     -nm,--name <arg>                Set a custom name for the application on YARN
     -q,--query                      Display available YARN resources (memory, cores)
     -qu,--queue <arg>               Specify YARN queue.
     -s,--slots <arg>                Number of slots per TaskManager
     -sae,--shutdownOnAttachedExit   If the job is submitted in attached mode, perform a best-effort cluster shutdown when the CLI is terminated abruptly, e.g., in response to a user interrupt, such as typing Ctrl + C.
     -st,--streaming                 Start Flink in streaming mode
     -t,--ship <arg>                 Ship files in the specified directory (t for transfer)
     -tm,--taskManagerMemory <arg>   Memory per TaskManager Container with optional unit (default: MB)
     -yd,--yarndetached              If present, runs the job in detached mode (deprecated; use non-YARN specific option instead)
     -z,--zookeeperNamespace <arg>   Namespace to create the Zookeeper sub-paths for high availability mode
```

yarn-session的参数介绍:
```
-n: 指定TaskManager的数量；
-d: 以分离模式运行；
-id:指定yarn的任务ID；
-j: Flink jar文件的路径;
-jm: JobManager容器的内存（默认值：MB）;
-nl: 为YARN应用程序指定YARN节点标签;
-nm: 在YARN上为应用程序设置自定义名称;
-q: 显示可用的YARN资源（内存，内核）;
-qu: 指定YARN队列;
-s: 指定TaskManager中slot的数量;
-st: 以流模式启动Flink;
-tm: 每个TaskManager容器的内存（默认值：MB）;
-z: 命名空间，用于为高可用性模式创建Zookeeper子路径;
```

我们启动一个yarn-session有2个Taskmanager，jobmanager内存2GB，taskManager2GB内存，那么脚本编写应该是这样的：
```
./bin/yarn-session.sh -n 2 -jm 1024 -tm 1024
```

启动的进程
```
[iknow@data-hadoop-50-63 ~]$ jps
186144 SecondaryNameNode
301825 ResourceManager
185845 DataNode
76966 Worker
457498 Jps
302171 NodeManager
457097 FlinkYarnSessionCli
185597 NameNode
```

```
[iknow@data-hadoop-50-64 ~]$ jps
269396 Jps
248059 NodeManager
39624 Worker
246509 DataNode
[iknow@data-hadoop-50-64 ~]$ jps
269697 Jps
248059 NodeManager
39624 Worker
269576 YarnSessionClusterEntrypoint
246509 DataNode
```

系统默认使用con/flink-conf.yaml里的配置。Flink on yarn将会覆盖掉几个参数：jobmanager.rpc.address因为jobmanager的在集群的运行位置并不是实现确定的，前面也说到了就是am的地址；taskmanager.tmp.dirs使用yarn给定的临时目录;parallelism.default也会被覆盖掉，如果在命令行里指定了slot数。

如果你想保证conf/flink-conf.yaml仅是全局末日配置，然后针对要启动的每一个yarn-session.sh都设置自己的配置，那么可以考虑使用-D修饰。

日志如下：
```
iknow@data-hadoop-50-63 flink-1.7.2]$ ./bin/yarn-session.sh -n 2 -jm 1024 -tm 1024
2019-02-22 11:26:54,048 INFO  org.apache.flink.configuration.GlobalConfiguration            - Loading configuration property: jobmanager.rpc.address, 192.168.50.63
2019-02-22 11:26:54,049 INFO  org.apache.flink.configuration.GlobalConfiguration            - Loading configuration property: jobmanager.rpc.port, 6123
2019-02-22 11:26:54,050 INFO  org.apache.flink.configuration.GlobalConfiguration            - Loading configuration property: jobmanager.heap.size, 1024m
2019-02-22 11:26:54,050 INFO  org.apache.flink.configuration.GlobalConfiguration            - Loading configuration property: taskmanager.heap.size, 1024m
2019-02-22 11:26:54,050 INFO  org.apache.flink.configuration.GlobalConfiguration            - Loading configuration property: taskmanager.numberOfTaskSlots, 1
2019-02-22 11:26:54,050 INFO  org.apache.flink.configuration.GlobalConfiguration            - Loading configuration property: parallelism.default, 1
2019-02-22 11:26:54,051 INFO  org.apache.flink.configuration.GlobalConfiguration            - Loading configuration property: rest.port, 18081
2019-02-22 11:26:54,392 WARN  org.apache.hadoop.util.NativeCodeLoader                       - Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
2019-02-22 11:26:54,450 INFO  org.apache.flink.runtime.security.modules.HadoopModule        - Hadoop user set to iknow (auth:SIMPLE)
2019-02-22 11:26:54,506 INFO  org.apache.hadoop.yarn.client.RMProxy                         - Connecting to ResourceManager at /0.0.0.0:8032
2019-02-22 11:26:54,606 INFO  org.apache.flink.yarn.cli.FlinkYarnSessionCli                 - The argument n is deprecated in will be ignored.
2019-02-22 11:26:54,713 INFO  org.apache.flink.yarn.AbstractYarnClusterDescriptor           - Cluster specification: ClusterSpecification{masterMemoryMB=1024, taskManagerMemoryMB=1024, numberTaskManagers=2, slotsPerTaskManager=1}
2019-02-22 11:26:55,023 WARN  org.apache.flink.yarn.AbstractYarnClusterDescriptor           - The configuration directory ('/home/iknow/xxx/flink-1.7.2/conf') contains both LOG4J and Logback configuration files. Please delete or rename one of them.
2019-02-22 11:26:56,027 INFO  org.apache.flink.yarn.AbstractYarnClusterDescriptor           - Submitting application master application_1550804667415_0004
2019-02-22 11:26:56,058 INFO  org.apache.hadoop.yarn.client.api.impl.YarnClientImpl         - Submitted application application_1550804667415_0004
2019-02-22 11:26:56,058 INFO  org.apache.flink.yarn.AbstractYarnClusterDescriptor           - Waiting for the cluster to be allocated
2019-02-22 11:26:56,060 INFO  org.apache.flink.yarn.AbstractYarnClusterDescriptor           - Deploying cluster, current state ACCEPTED
2019-02-22 11:26:59,340 INFO  org.apache.flink.yarn.AbstractYarnClusterDescriptor           - YARN application has been deployed successfully.
2019-02-22 11:26:59,652 INFO  org.apache.flink.runtime.rest.RestClient                      - Rest client endpoint started.
Flink JobManager is now running on data-hadoop-50-63.bjrs.xxx.com:37730 with leader id 00000000-0000-0000-0000-000000000000.
JobManager Web Interface: http://data-hadoop-50-63.bjrs.xxx.com:37730
JobManager Web Interface: http://data-hadoop-50-63.bjrs.xxx.com:37730
```

是jobManager的ui，查看yarn上的任务，发现0004一直是运行状态


点击ApplicationMaster，看到有一个任务运行完成了。


这个任务是通过下面的命令提交的，运行任务之前要把flink 下的LICENSE文件上传到hdfs
```
./bin/flink run ./examples/batch/WordCount.jar -input hdfs://192.168.50.63:9000/LICENSE -output hdfs://192.168.50.63:9000/wordcount-result_1.txt
```

运行日志如下：
```
[iknow@data-hadoop-50-63 flink-1.7.2]$ ./bin/flink run ./examples/batch/WordCount.jar -input hdfs://192.168.50.63:9000/LICENSE -output hdfs://192.168.50.63:9000/wordcount-result_1.txt
2019-02-22 11:36:58,256 INFO  org.apache.flink.yarn.cli.FlinkYarnSessionCli                 - Found Yarn properties file under /tmp/.yarn-properties-iknow.
2019-02-22 11:36:58,256 INFO  org.apache.flink.yarn.cli.FlinkYarnSessionCli                 - Found Yarn properties file under /tmp/.yarn-properties-iknow.
2019-02-22 11:36:58,504 INFO  org.apache.flink.yarn.cli.FlinkYarnSessionCli                 - YARN properties set default parallelism to 2
2019-02-22 11:36:58,504 INFO  org.apache.flink.yarn.cli.FlinkYarnSessionCli                 - YARN properties set default parallelism to 2
YARN properties set default parallelism to 2
2019-02-22 11:36:58,543 INFO  org.apache.hadoop.yarn.client.RMProxy                         - Connecting to ResourceManager at /0.0.0.0:8032
2019-02-22 11:36:58,633 INFO  org.apache.flink.yarn.cli.FlinkYarnSessionCli                 - No path for the flink jar passed. Using the location of class org.apache.flink.yarn.YarnClusterDescriptor to locate the jar
2019-02-22 11:36:58,633 INFO  org.apache.flink.yarn.cli.FlinkYarnSessionCli                 - No path for the flink jar passed. Using the location of class org.apache.flink.yarn.YarnClusterDescriptor to locate the jar
2019-02-22 11:36:58,699 INFO  org.apache.flink.yarn.AbstractYarnClusterDescriptor           - Found application JobManager host name 'data-hadoop-50-63.bjrs.xxx.com' and port '37730' from supplied application id 'application_1550804667415_0004'
Starting execution of program
Program execution finished
Job with JobID 6d1a05cfd324111904bb1749c50ef5d6 has finished.
Job Runtime: 9851 ms
```

Flink ui上点击进这个任务





对于客户端模式而言，你可以启动多个yarn session，一个yarn session模式对应一个JobManager,并按照需求提交作业，同一个Session中可以提交多个Flink作业。如果想要停止Flink Yarn Application，需要通过yarn application -kill命令来停止.
```
[iknow@data-hadoop-50-63 ~]$ yarn application -kill application_1550836652097_0002
```

杀掉任务之后再查看进程
```
[iknow@data-hadoop-50-63 ~]$ jps
1809 Jps
186144 SecondaryNameNode
301825 ResourceManager
185845 DataNode
76966 Worker
302171 NodeManager
185597 NameNode
```

```
[iknow@data-hadoop-50-64 ~]$ jps
269842 Jps
248059 NodeManager
39624 Worker
246509 DataNode
```

## 分离式模式

对于分离式模式，并不像客户端那样可以启动多个yarn session，如果启动多个，会出现下面的session一直处在等待状态。JobManager的个数只能是一个，同一个Session中可以提交多个Flink作业。如果想要停止Flink Yarn Application，需要通过yarn application -kill命令来停止。通过-d指定分离模式，即客户端在启动Flink Yarn Session后，就不再属于Yarn Cluster的一部分。

yarn-session启动的时候可以指定-nm的参数，这个就是给你的yarn-session起一个名字。比如
```
bin/yarn-session.sh -nm yarn-session_test
```

这个时候要停止该yarn-session.sh必须要用yarn的命令了`yarn application –kill <appid>`
```
[iknow@data-hadoop-50-63 ~]$ yarn application -kill application_1550836652097_0007
19/02/24 09:13:11 INFO client.RMProxy: Connecting to ResourceManager at /0.0.0.0:8032
Killing application application_1550836652097_0006
19/02/24 09:13:12 INFO impl.YarnClientImpl: Killed application application_1550836652097_0006
```

./bin/yarn-session.sh -nm test3 -d
```
[iknow@data-hadoop-50-63 flink-1.7.2]$ ./bin/yarn-session.sh -nm test3 -d
2019-02-24 17:31:40,471 INFO  org.apache.flink.configuration.GlobalConfiguration            - Loading configuration property: jobmanager.rpc.address, 192.168.50.63
2019-02-24 17:31:40,473 INFO  org.apache.flink.configuration.GlobalConfiguration            - Loading configuration property: jobmanager.rpc.port, 6123
2019-02-24 17:31:40,473 INFO  org.apache.flink.configuration.GlobalConfiguration            - Loading configuration property: jobmanager.heap.size, 1024m
2019-02-24 17:31:40,473 INFO  org.apache.flink.configuration.GlobalConfiguration            - Loading configuration property: taskmanager.heap.size, 1024m
2019-02-24 17:31:40,473 INFO  org.apache.flink.configuration.GlobalConfiguration            - Loading configuration property: taskmanager.numberOfTaskSlots, 1
2019-02-24 17:31:40,473 INFO  org.apache.flink.configuration.GlobalConfiguration            - Loading configuration property: parallelism.default, 1
2019-02-24 17:31:40,474 INFO  org.apache.flink.configuration.GlobalConfiguration            - Loading configuration property: rest.port, 18081
2019-02-24 17:31:40,482 INFO  org.apache.flink.yarn.cli.FlinkYarnSessionCli                 - Found Yarn properties file under /tmp/.yarn-properties-iknow.
2019-02-24 17:31:40,843 WARN  org.apache.hadoop.util.NativeCodeLoader                       - Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
2019-02-24 17:31:40,901 INFO  org.apache.flink.runtime.security.modules.HadoopModule        - Hadoop user set to iknow (auth:SIMPLE)
2019-02-24 17:31:40,954 INFO  org.apache.hadoop.yarn.client.RMProxy                         - Connecting to ResourceManager at /0.0.0.0:8032
2019-02-24 17:31:41,136 INFO  org.apache.flink.yarn.AbstractYarnClusterDescriptor           - Cluster specification: ClusterSpecification{masterMemoryMB=1024, taskManagerMemoryMB=1024, numberTaskManagers=1, slotsPerTaskManager=1}
2019-02-24 17:31:41,439 WARN  org.apache.flink.yarn.AbstractYarnClusterDescriptor           - The configuration directory ('/home/iknow/xxx/flink-1.7.2/conf') contains both LOG4J and Logback configuration files. Please delete or rename one of them.
2019-02-24 17:31:42,007 INFO  org.apache.flink.yarn.AbstractYarnClusterDescriptor           - Submitting application master application_1550836652097_0014
2019-02-24 17:31:42,038 INFO  org.apache.hadoop.yarn.client.api.impl.YarnClientImpl         - Submitted application application_1550836652097_0014
2019-02-24 17:31:42,038 INFO  org.apache.flink.yarn.AbstractYarnClusterDescriptor           - Waiting for the cluster to be allocated
2019-02-24 17:31:42,039 INFO  org.apache.flink.yarn.AbstractYarnClusterDescriptor           - Deploying cluster, current state ACCEPTED
2019-02-24 17:31:45,560 INFO  org.apache.flink.yarn.AbstractYarnClusterDescriptor           - YARN application has been deployed successfully.
2019-02-24 17:31:45,560 INFO  org.apache.flink.yarn.AbstractYarnClusterDescriptor           - The Flink YARN client has b
een started in detached mode. In order to stop Flink on YARN, use the following command or a YARN web interface to stop it:
yarn application -kill application_1550836652097_0014
Please also note that the temporary files of the YARN session in the home directory will not be removed.
2019-02-24 17:31:45,864 INFO  org.apache.flink.runtime.rest.RestClient                      - Rest client endpoint started.
Flink JobManager is now running on data-hadoop-50-63.bj.xxxcom:42513 with leader id 00000000-0000-0000-0000-000000000000.
JobManager Web Interface: http://data-hadoop-50-63.bj.xxx.com:42513
2019-02-24 17:31:45,879 INFO  org.apache.flink.yarn.cli.FlinkYarnSessionCli                 - The Flink YARN client has been started in detached mode. In order to stop Flink on YARN, use the following command or a YARN web interface to stop it:
yarn application -kill application_1550836652097_0014
```

# 3. Per-Job-Cluster模式

- 一个任务会对应一个Job，每提交一个作业会根据自身的情况，都会单独向yarn申请资源，直到作业执行完成，一个作业的失败与否并不会影响下一个作业的正常提交和运行。独享Dispatcher和ResourceManager，按需接受资源申请；适合规模大长时间运行的作业。

对于前面介绍的yarn session需要先启动一个集群，然后在提交作业。对于Flink run直接提交作业就相对比较简单，不需要额外的去启动一个集群，直接提交作业，即可完成Flink作业。

flink run参数介绍：
```
-c：如果没有在jar包中指定入口类，则需要在这里通过这个参数指定;
   -m：指定需要连接的jobmanager(主节点)地址，使用这个参数可以指定一个不同于配置文件中的jobmanager，可以说是yarn集群名称;
-p：指定程序的并行度。可以覆盖配置文件中的默认值;
-n:允许跳过保存点状态无法恢复。 你需要允许如果您从中删除了一个运算符你的程序是的一部分保存点时的程序触发;
-q:如果存在，则禁止将日志记录输出标准出来;
-s:保存点的路径以还原作业来自（例如hdfs:///flink/savepoint-1537);
还有参数如果在yarn-session当中没有指定，可以在yarn-session参数的基础上前面加“y”，即可控制所有的资源，这里就不獒述了。
```

```
./bin/flink run -m yarn-cluster -yn 1 -yjm 1024 -ytm 1024 ./examples/batch/WordCount.jar
```

日志如下：
```
[iknow@data-hadoop-50-63 flink-1.7.2]$ ./bin/flink run -m yarn-cluster -yn 1 -yjm 1024 -ytm 1024 ./examples/batch/WordCount.jar
2019-02-21 19:54:06,718 INFO  org.apache.hadoop.yarn.client.RMProxy                         - Connecting to ResourceManager at /0.0.0.0:8032
2019-02-21 19:54:06,815 INFO  org.apache.flink.yarn.cli.FlinkYarnSessionCli                 - No path for the flink jar passed. Using the location of class org.apache.flink.yarn.YarnClusterDescriptor to locate the jar
2019-02-21 19:54:06,815 INFO  org.apache.flink.yarn.cli.FlinkYarnSessionCli                 - No path for the flink jar passed. Using the location of class org.apache.flink.yarn.YarnClusterDescriptor to locate the jar
2019-02-21 19:54:06,822 INFO  org.apache.flink.yarn.cli.FlinkYarnSessionCli                 - The argument yn is deprecated in will be ignored.
2019-02-21 19:54:06,822 INFO  org.apache.flink.yarn.cli.FlinkYarnSessionCli                 - The argument yn is deprecated in will be ignored.
2019-02-21 19:54:06,931 INFO  org.apache.flink.yarn.AbstractYarnClusterDescriptor           - Cluster specification: ClusterSpecification{masterMemoryMB=1024, taskManagerMemoryMB=1024, numberTaskManagers=1, slotsPerTaskManager=1}
2019-02-21 19:54:07,231 WARN  org.apache.flink.yarn.AbstractYarnClusterDescriptor           - The configuration directory ('/home/iknow/xxx/flink-1.7.2/conf') contains both LOG4J and Logback configuration files. Please delete or rename one of them.
2019-02-21 19:54:10,039 INFO  org.apache.flink.yarn.AbstractYarnClusterDescriptor           - Submitting application master application_1550749966977_0002
2019-02-21 19:54:10,400 INFO  org.apache.hadoop.yarn.client.api.impl.YarnClientImpl         - Submitted application application_1550749966977_0002
2019-02-21 19:54:10,400 INFO  org.apache.flink.yarn.AbstractYarnClusterDescriptor           - Waiting for the cluster to be allocated
2019-02-21 19:54:10,403 INFO  org.apache.flink.yarn.AbstractYarnClusterDescriptor           - Deploying cluster, current state ACCEPTED
2019-02-21 19:54:14,451 INFO  org.apache.flink.yarn.AbstractYarnClusterDescriptor           - YARN application has been deployed successfully.
Starting execution of program
Executing WordCount example with default input data set.
Use --input to specify file input.
Printing result to stdout. Use --output to specify output path.
(a,5)
(action,1)
(after,1)
(against,1)
(all,2)
(and,12)
(arms,1)
(arrows,1)
(awry,1)
(ay,1)
(bare,1)
(be,4)
(bear,3)
(bodkin,1)
(bourn,1)
(but,1)
(by,2)
(calamity,1)
(cast,1)
(coil,1)
(come,1)
(conscience,1)
(consummation,1)
(contumely,1)
(country,1)
(cowards,1)
(currents,1)
(d,4)
(death,2)
(delay,1)
(despis,1)
(devoutly,1)
(die,2)
(does,1)
(dread,1)
(dream,1)
(dreams,1)
(end,2)
(enterprises,1)
(er,1)
(fair,1)
(fardels,1)
(flesh,1)
(fly,1)
(for,2)
(fortune,1)
(from,1)
(give,1)
(great,1)
(grunt,1)
(have,2)
(he,1)
(heartache,1)
(heir,1)
(himself,1)
(his,1)
(hue,1)
(ills,1)
(in,3)
(insolence,1)
(is,3)
(know,1)
(law,1)
(life,2)
(long,1)
(lose,1)
(love,1)
(make,2)
(makes,2)
(man,1)
(may,1)
(merit,1)
(might,1)
(mind,1)
(moment,1)
(more,1)
(mortal,1)
(must,1)
(my,1)
(name,1)
(native,1)
(natural,1)
(no,2)
(nobler,1)
(not,2)
(now,1)
(nymph,1)
(o,1)
(of,15)
(off,1)
(office,1)
(ophelia,1)
(opposing,1)
(oppressor,1)
(or,2)
(orisons,1)
(others,1)
(outrageous,1)
(pale,1)
(pangs,1)
(patient,1)
(pause,1)
(perchance,1)
(pith,1)
(proud,1)
(puzzles,1)
(question,1)
(quietus,1)
(rather,1)
(regard,1)
(remember,1)
(resolution,1)
(respect,1)
(returns,1)
(rub,1)
(s,5)
(say,1)
(scorns,1)
(sea,1)
(shocks,1)
(shuffled,1)
(sicklied,1)
(sins,1)
(sleep,5)
(slings,1)
(so,1)
(soft,1)
(something,1)
(spurns,1)
(suffer,1)
(sweat,1)
(take,1)
(takes,1)
(than,1)
(that,7)
(the,22)
(their,1)
(them,1)
(there,2)
(these,1)
(this,2)
(those,1)
(thought,1)
(thousand,1)
(thus,2)
(thy,1)
(time,1)
(tis,2)
(to,15)
(traveller,1)
(troubles,1)
(turn,1)
(under,1)
(undiscover,1)
(unworthy,1)
(us,3)
(we,4)
(weary,1)
(what,1)
(when,2)
(whether,1)
(whips,1)
(who,2)
(whose,1)
(will,1)
(wish,1)
(with,3)
(would,2)
(wrong,1)
(you,1)
Program execution finished
Job with JobID 8fb799387976bc6426b3ebdcf1e80dfd has finished.
Job Runtime: 8027 ms
Accumulator Results:
- 464ea1424ef5011784a0d0cbc837baba (java.util.ArrayList) [170 elements]
```

Yarn上也是有flink任务的



程序正在运行，过一段时间再看，状态是successed



192.168.50.63上测试从hdfs读入数据，写到hdfs
```
[iknow@data-hadoop-50-63 flink-1.7.2]$ hdfs dfs -put LICENSE /
[iknow@data-hadoop-50-63 flink-1.7.2]$ ./bin/flink run -m yarn-cluster -yn 1 -yjm 1024 -ytm 1024  ./examples/batch/WordCount.jar -input hdfs://192.168.50.63:9000/LICENSE -output hdfs://192.168.50.63:9000/wordcount-result.txt
```

运行日志如下：
```
[iknow@data-hadoop-50-63 flink-1.7.2]$ ./bin/flink run -m yarn-cluster -yn 1 -yjm 1024 -ytm 1024  ./examples/batch/WordCount.jar -input hdfs://192.168.50.63:9000/LICENSE -output hdfs://192.168.50.63:9000/wordcount-result.txt
2019-02-22 11:20:26,060 INFO  org.apache.hadoop.yarn.client.RMProxy                         - Connecting to ResourceManager at /0.0.0.0:8032
2019-02-22 11:20:26,154 INFO  org.apache.flink.yarn.cli.FlinkYarnSessionCli                 - No path for the flink jar passed. Using the location of class org.apache.flink.yarn.YarnClusterDescriptor to locate the jar
2019-02-22 11:20:26,154 INFO  org.apache.flink.yarn.cli.FlinkYarnSessionCli                 - No path for the flink jar passed. Using the location of class org.apache.flink.yarn.YarnClusterDescriptor to locate the jar
2019-02-22 11:20:26,161 INFO  org.apache.flink.yarn.cli.FlinkYarnSessionCli                 - The argument yn is deprecated in will be ignored.
2019-02-22 11:20:26,161 INFO  org.apache.flink.yarn.cli.FlinkYarnSessionCli                 - The argument yn is deprecated in will be ignored.
2019-02-22 11:20:26,273 INFO  org.apache.flink.yarn.AbstractYarnClusterDescriptor           - Cluster specification: ClusterSpecification{masterMemoryMB=1024, taskManagerMemoryMB=1024, numberTaskManagers=1, slotsPerTaskManager=1}
2019-02-22 11:20:26,581 WARN  org.apache.flink.yarn.AbstractYarnClusterDescriptor           - The configuration directory ('/home/iknow/xxx/flink-1.7.2/conf') contains both LOG4J and Logback configuration files. Please delete or rename one of them.
2019-02-22 11:20:28,005 INFO  org.apache.flink.yarn.AbstractYarnClusterDescriptor           - Submitting application master application_1550804667415_0003
2019-02-22 11:20:28,028 INFO  org.apache.hadoop.yarn.client.api.impl.YarnClientImpl         - Submitted application application_1550804667415_0003
2019-02-22 11:20:28,028 INFO  org.apache.flink.yarn.AbstractYarnClusterDescriptor           - Waiting for the cluster to be allocated
2019-02-22 11:20:28,030 INFO  org.apache.flink.yarn.AbstractYarnClusterDescriptor           - Deploying cluster, current state ACCEPTED
2019-02-22 11:20:31,563 INFO  org.apache.flink.yarn.AbstractYarnClusterDescriptor           - YARN application has been deployed successfully.
Starting execution of program
Program execution finished
Job with JobID 16e83cc5a60f9cd82ed39d72bcc62110 has finished.
Job Runtime: 8281 ms
```

查看文件wordcount-result.txt是有数据的
```
[iknow@data-hadoop-50-63 flink-1.7.2]$ hdfs dfs -cat /wordcount-result.txt
0 3
1 2
2 4
2004 1
```

## 运行到指定的yarn session

指定yarn applicationID 来运行到特定的yarn session

首先查看./bin/flink run 命令的说明
```
iknow@search-aa-4-59:~/xxx/flink-pangu $ ./bin/flink run --help
2019-02-26 20:32:50,218 INFO  org.apache.flink.yarn.cli.FlinkYarnSessionCli                 - Found Yarn properties file under /tmp/.yarn-properties-iknow.
2019-02-26 20:32:50,218 INFO  org.apache.flink.yarn.cli.FlinkYarnSessionCli                 - Found Yarn properties file under /tmp/.yarn-properties-iknow.
2019-02-26 20:32:50,540 WARN  org.apache.hadoop.conf.Configuration                          - /home/iknow/hadoop-client/etc/hadoop/core-site.xml:an attempt to override final parameter: fs.defaultFS;  Ignoring.
2019-02-26 20:32:50,542 WARN  org.apache.hadoop.conf.Configuration                          - /home/iknow/hadoop-client/etc/hadoop/hdfs-site.xml:an attempt to override final parameter: dfs.datanode.data.dir;  Ignoring.
2019-02-26 20:32:50,543 WARN  org.apache.hadoop.conf.Configuration                          - /home/iknow/hadoop-client/etc/hadoop/hdfs-site.xml:an attempt to override final parameter: dfs.namenode.name.dir;  Ignoring.

Action "run" compiles and runs a program.

  Syntax: run [OPTIONS] <jar-file> <arguments>
  "run" action options:
     -c,--class <classname>               Class with the program entry point
                                          ("main" method or "getPlan()" method.
                                          Only needed if the JAR file does not
                                          specify the class in its manifest.
     -C,--classpath <url>                 Adds a URL to each user code
                                          classloader  on all nodes in the
                                          cluster. The paths must specify a
                                          protocol (e.g. file://) and be
                                          accessible on all nodes (e.g. by means
                                          of a NFS share). You can use this
                                          option multiple times for specifying
                                          more than one URL. The protocol must
                                          be supported by the {@link
                                          java.net.URLClassLoader}.
     -d,--detached                        If present, runs the job in detached
                                          mode
     -n,--allowNonRestoredState           Allow to skip savepoint state that
                                          cannot be restored. You need to allow
                                          this if you removed an operator from
                                          your program that was part of the
                                          program when the savepoint was
                                          triggered.
     -p,--parallelism <parallelism>       The parallelism with which to run the
                                          program. Optional flag to override the
                                          default value specified in the
                                          configuration.
     -q,--sysoutLogging                   If present, suppress logging output to
                                          standard out.
     -s,--fromSavepoint <savepointPath>   Path to a savepoint to restore the job
                                          from (for example
                                          hdfs:///flink/savepoint-1537).
     -sae,--shutdownOnAttachedExit        If the job is submitted in attached
                                          mode, perform a best-effort cluster
                                          shutdown when the CLI is terminated
                                          abruptly, e.g., in response to a user
                                          interrupt, such as typing Ctrl + C.
  Options for yarn-cluster mode:
     -d,--detached                        If present, runs the job in detached
                                          mode
     -m,--jobmanager <arg>                Address of the JobManager (master) to
                                          which to connect. Use this flag to
                                          connect to a different JobManager than
                                          the one specified in the
                                          configuration.
     -sae,--shutdownOnAttachedExit        If the job is submitted in attached
                                          mode, perform a best-effort cluster
                                          shutdown when the CLI is terminated
                                          abruptly, e.g., in response to a user
                                          interrupt, such as typing Ctrl + C.
     -yD <property=value>                 use value for given property
     -yd,--yarndetached                   If present, runs the job in detached
                                          mode (deprecated; use non-YARN
                                          specific option instead)
     -yh,--yarnhelp                       Help for the Yarn session CLI.
     -yid,--yarnapplicationId <arg>       Attach to running YARN session
     -yj,--yarnjar <arg>                  Path to Flink jar file
     -yjm,--yarnjobManagerMemory <arg>    Memory for JobManager Container with
                                          optional unit (default: MB)
     -yn,--yarncontainer <arg>            Number of YARN container to allocate
                                          (=Number of Task Managers)
     -ynl,--yarnnodeLabel <arg>           Specify YARN node label for the YARN
                                          application
     -ynm,--yarnname <arg>                Set a custom name for the application
                                          on YARN
     -yq,--yarnquery                      Display available YARN resources
                                          (memory, cores)
     -yqu,--yarnqueue <arg>               Specify YARN queue.
     -ys,--yarnslots <arg>                Number of slots per TaskManager
     -yst,--yarnstreaming                 Start Flink in streaming mode
     -yt,--yarnship <arg>                 Ship files in the specified directory
                                          (t for transfer)
     -ytm,--yarntaskManagerMemory <arg>   Memory per TaskManager Container with
                                          optional unit (default: MB)
     -yz,--yarnzookeeperNamespace <arg>   Namespace to create the Zookeeper
                                          sub-paths for high availability mode
     -z,--zookeeperNamespace <arg>        Namespace to create the Zookeeper
                                          sub-paths for high availability mode

  Options for default mode:
     -m,--jobmanager <arg>           Address of the JobManager (master) to which
                                     to connect. Use this flag to connect to a
                                     different JobManager than the one specified
                                     in the configuration.
     -z,--zookeeperNamespace <arg>   Namespace to create the Zookeeper sub-paths
                                     for high availability mode
```

可以指定`yid -yid,--yarnapplicationId <arg> Attach to running YARN session`来运行到特定的`yarn session`

我们指定运行到ID为application_1550579025929_62420的yarn-session
```
./bin/flink run -yid application_1550579025929_62420 ./examples/batch/WordCount.jar -input hdfs://data-hadoop-112-16.bj.xxx.com:8020/flume/events-.1539684881482 -output hdfs://data-hadoop-112-16.bj.xxx.com:8020/flink/flink-test02.txt
```

运行日志如下：
```
iknow@search-aa-4-59:~/xxx/flink-pangu $ ./bin/flink run -yid application_1550579025929_62420 ./examples/batch/WordCount.jar -input hdfs://data-hadoop-xx-xx.bj.xxx.com:8020/flume/events-.1539684881482 -output hdfs://data-hadoop-112-16.bj.xxx.com:8020/flink/flink-test02.txt
2019-02-26 20:33:48,393 INFO  org.apache.flink.yarn.cli.FlinkYarnSessionCli                 - Found Yarn properties file under /tmp/.yarn-properties-iknow.
2019-02-26 20:33:48,393 INFO  org.apache.flink.yarn.cli.FlinkYarnSessionCli                 - Found Yarn properties file under /tmp/.yarn-properties-iknow.
2019-02-26 20:33:48,723 WARN  org.apache.hadoop.conf.Configuration                          - /home/iknow/hadoop-client/etc/hadoop/core-site.xml:an attempt to override final parameter: fs.defaultFS;  Ignoring.
2019-02-26 20:33:48,725 WARN  org.apache.hadoop.conf.Configuration                          - /home/iknow/hadoop-client/etc/hadoop/hdfs-site.xml:an attempt to override final parameter: dfs.datanode.data.dir;  Ignoring.
2019-02-26 20:33:48,726 WARN  org.apache.hadoop.conf.Configuration                          - /home/iknow/hadoop-client/etc/hadoop/hdfs-site.xml:an attempt to override final parameter: dfs.namenode.name.dir;  Ignoring.
2019-02-26 20:33:49,080 INFO  org.apache.hadoop.yarn.client.AHSProxy                        - Connecting to Application History server at data-hadoop-112-16.bjrs.xxx.com/192.168.112.16:10200
2019-02-26 20:33:49,094 INFO  org.apache.flink.yarn.cli.FlinkYarnSessionCli                 - No path for the flink jar passed. Using the location of class org.apache.flink.yarn.YarnClusterDescriptor to locate the jar
2019-02-26 20:33:49,094 INFO  org.apache.flink.yarn.cli.FlinkYarnSessionCli                 - No path for the flink jar passed. Using the location of class org.apache.flink.yarn.YarnClusterDescriptor to locate the jar
2019-02-26 20:33:49,105 INFO  org.apache.hadoop.yarn.client.RequestHedgingRMFailoverProxyProvider  - Looking for the active RM in [rm1, rm2]...
2019-02-26 20:33:49,265 INFO  org.apache.hadoop.yarn.client.RequestHedgingRMFailoverProxyProvider  - Found active RM [rm1]
2019-02-26 20:33:49,272 INFO  org.apache.flink.yarn.AbstractYarnClusterDescriptor           - Found application JobManager host name 'search-as-107-45.bj.xxx.com' and port '52901' from supplied application id 'application_1550579025929_62420'
Starting execution of program
2019-02-26 20:33:49,754 WARN  org.apache.hadoop.conf.Configuration                          - /home/iknow/hadoop-client/etc/hadoop/core-site.xml:an attempt to override final parameter: fs.defaultFS;  Ignoring.
2019-02-26 20:33:49,756 WARN  org.apache.hadoop.conf.Configuration                          - /home/iknow/hadoop-client/etc/hadoop/hdfs-site.xml:an attempt to override final parameter: dfs.datanode.data.dir;  Ignoring.
2019-02-26 20:33:49,757 WARN  org.apache.hadoop.conf.Configuration                          - /home/iknow/hadoop-client/etc/hadoop/hdfs-site.xml:an attempt to override final parameter: dfs.namenode.name.dir;  Ignoring.
2019-02-26 20:33:50,108 WARN  org.apache.hadoop.hdfs.shortcircuit.DomainSocketFactory       - The short-circuit local reads feature cannot be used because libhadoop cannot be loaded.
Program execution finished
Job with JobID 7331813a31914c4009493de57cc6e7e2 has finished.
Job Runtime: 26410 ms
```

JobManager的web ui上是有jobID为7331813a31914c4009493de57cc6e7e2的任务的。

hdfs上也有flink-test02.txt文件生成。



参考：
- https://www.jianshu.com/p/1b05202c4fb6
