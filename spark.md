1、从官网下载  
http://spark.apache.org/downloads.html

2、从微软的镜像站下载  
http://mirrors.hust.edu.cn/apache/

3、从清华的镜像站下载  
https://mirrors.tuna.tsinghua.edu.cn/apache/

# 安装基础

- 1、Java8安装成功
- 2、zookeeper安装成功
- 3、hadoop2.7.5 HA安装成功
- 4、Scala安装成功（不安装进程也可以启动）


# 一、Spark安装

 1、安装
```
$ tar -zxvf spark-2.3.0-bin-hadoop2.7.tgz -C apps/
$ cd apps/
$ ln -s spark-2.3.0-bin-hadoop2.7/ spark
```

2、进入spark/conf修改配置文件
```
$ cd apps/spark/conf/

#复制spark-env.sh.template并重命名为spark-env.sh，并在文件最后添加配置内容
$ cp spark-env.sh.template spark-env.sh
$ vim spark-env.sh

export JAVA_HOME=/usr/local/jdk1.8.0_73
#export SCALA_HOME=/usr/share/scala                #高可用不需要配置需要注释掉
#export SPARK_MASTER_IP=hadoop1                    #高可用不需要配置需要注释掉

export HADOOP_HOME=/home/hadoop/apps/hadoop-2.7.5
export HADOOP_CONF_DIR=/home/hadoop/apps/hadoop-2.7.5/etc/hadoop

export SPARK_WORKER_MEMORY=500m                    #启动需要的内存
export SPARK_WORKER_CORES=1                        #启动需要的cpu盒数

# MASTER监控页面默认访问端口8080，但是可能会和Zookeeper冲突，所以改成8089也可以自定义，访问UI监控页面时请注意
SPARK_MASTER_WEBUI_PORT=89889                      #spark web端口号
export SPARK_DAEMON_JAVA_OPTS="-Dspark.deploy.recoveryMode=ZOOKEEPER -Dspark.deploy.zookeeper.url=hadoop1:2181,hadoop2:2181,hadoop3:2181 -Dspark.deploy.zookeeper.dir=/spark"
```
- spark.deploy.recoveryMode 集群状态由zk来维护。通过zk实现spark的HA，Master(Active)挂掉的话，Master(standby)成为Master（Active），Master(Standby)需要读取zk集群状态信息，进行恢复所有Worker和Driver的状态信息，和所有的Application状态信息;
- spark.deploy.zookeeper.url： zookeeper的server地址
- Dspark.deploy.zookeeper.dir=/spark 保存集群元数据信息的文件，目录。包括Worker，Driver和Application。

3、配置从节点
```
# 1、复制slaves.template成slaves
$ cp slaves.template slaves

# 2、添加从节点信息
$ vim slaves
hadoop1
hadoop2
hadoop3
```

4、将安装包分发给其他节点
```
$ cd apps/
$ scp -r spark-2.3.0-bin-hadoop2.7/ hadoop2:$PWD
$ scp -r spark-2.3.0-bin-hadoop2.7/ hadoop3:$PWD

到对应节点创建软连接
$ cd apps/
$ ln -s spark-2.3.0-bin-hadoop2.7/ spark
```

4、配置环境变量
```
# 1、所有节点均要配置
$ vi ~/.bashrc 
#Spark
export SPARK_HOME=/home/hadoop/apps/spark
export PATH=$PATH:$SPARK_HOME/bin

# 2、保存并使其立即生效
$ source ~/.bashrc 
```

5、启动

1、先启动zookeeper集群
```
所有节点均要执行
$ zkServer.sh start
ZooKeeper JMX enabled by default
Using config: /home/hadoop/apps/zookeeper-3.4.10/bin/../conf/zoo.cfg
Starting zookeeper ... STARTED

$ zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /home/hadoop/apps/zookeeper-3.4.10/bin/../conf/zoo.cfg
Mode: follower
```


2、在启动HDFS集群
```
任意一个节点执行即可
$ ./start-dfs.sh
```

3、在启动Spark集群
```
在一个节点上执行
$ cd apps/spark/sbin/
$ s./tart-all.sh
```

4、在hadoop2上再启动一个master做主备切换
```
$ cd apps/spark/sbin/
$ ./start-master.sh
```

端口号：
- Spark 查看当前Spark-shell运行任务情况端口号： 4040（计算）
- Spark Master 内部通信服务端口号： 7077
- Standalone 模式下，Spark Master Web端口号： 8080（资源）
- Spark 历史服务器端口号： 18080
- Hadoop YARN 任务运行情况查看端口号： 8088


# 二、Spark程序on standalone

| 参数 | 解释 | 可选值举例 |
|------|------|------------|
| --class | Spark程序中包含主函数的累 | |
| --master | Spark程序运行的模式（环境） | `模式：local[*]、spark://ip:7077、yarn` |
| --executor-memory 1G | 指定每个excutor可用内存为1G | 符合集群内存配置即可，具体情况具体分析 |
| --total-executor-cores 2 | 指定所有executor使用的cpu核数为2个 | 符合集群内存配置即可，具体情况具体分析 |
| --executor-cores | 指定每个executor使用的cpu核数 | 符合集群内存配置即可，具体情况具体分析 |
| application-jar | 打包好的应用jar，包含依赖。这个RUL在机器中全局可见。比如hdfs:// 共享存储系统 如果是file://path,那么所有的节点path都包含同样的jar| |
| application-arguments | 传给main()方法的参数 | |

1、利用 Spark 自带的例子程序执行一个求 PI（蒙特卡洛算法）的程序:
```
$SPARK_HOME/bin/spark-submit \ 
--class org.apache.spark.examples.SparkPi \ 
--master spark://hadoop01:7077,hadoop02:7077 \ 
--executor-memory 512m \ 
--total-executor-cores 3 \
$SPARK_HOME/examples/jars/spark-examples_2.11-2.3.0.jar \ 
100
```

2、启动spark shell
```
# 1、启动local模式：
$ spark-shell

# 2、启动集群模式：
$SPARK_HOME/bin/spark-shell \ 
--master spark://hadoop01:7077,hadoop02:7077 \     #指定 Master 的地址
--executor-memory 512M \                           #指定每个 worker 可用内存为 512M
--total-executor-cores 2                           #指定整个集群使用的 cup 核数为 2 个
```

3、在spark shell中编写WordCount程序
```
1）编写一个hello.txt文件并上传到HDFS上的spark目录下
$ vim hello.txt
you,jump
i,jump
you,jump
i,jump
jump

$ hadoop fs -mkdir -p /spark
$ hadoop fs -put hello.txt /spark


2）在spark shell中用scala语言编写spark程序
scala> sc.textFile("/spark/hello.txt").flatMap(_.split(",")).map((_,1)).reduceByKey(_+_).saveAsTextFile("/spark/out")

3）使用hdfs命令查看结果
$ hadoop fs -cat /spark/out/p*
(jump,5)
(you,2)
(i,2)
```
- sc是SparkContext对象，该对象是提交spark程序的入口
- textFile("/spark/hello.txt")是hdfs中读取数据
- flatMap(_.split(" "))先map再压平
- map((_,1))将单词和1构成元组
- reduceByKey(_+_)按照key进行reduce，并将value累加
- saveAsTextFile("/spark/out")将结果写入到hdfs中

# 三、Spark程序on YARN

1、前提

成功启动zookeeper集群、HDFS集群、YARN集群

2、先停止YARN服务，然后修改yarn-site.xml，增加如下内容
```
<!--是否启动一个线程检查每个任务正使用的物理内存量，如果任务超出分配值，则直接将其杀掉，默认值是true-->
        <property>
                <name>yarn.nodemanager.pmem-check-enabled</name>
                <value>false</value>
        </property>
<!--是否启动一个线程检查每个任务正使用的虚拟内存量，如果任务超出分配值，则直接将其杀掉，默认值是true-->
        <property>
                <name>yarn.nodemanager.vmem-check-enabled</name>
                <value>false</value>
        </property>
        <property>
                <name>yarn.nodemanager.vmem-pmem-ratio</name>
                <value>4</value>
                <description>Ratio between virtual memory to physical memory when setting memory limits for containers</description>
        </property>  
```

```
# cat spark-env.sh
export JAVA_HOME=/usr/local/jdk1.8.0_73
YARN_CONF_DIR=/opt/module/hadoop/ect/hadoop
```

3、启动Spark on YARN
```
$ spark-shell --master yarn --deploy-mode client
```

4、Spark自带的示例程序PI
```
$ spark-submit --class org.apache.spark.examples.SparkPi \
> --master yarn \
> --deploy-mode cluster \
> --driver-memory 500m \
> --executor-memory 500m \
> --executor-cores 1 \
> /home/hadoop/apps/spark/examples/jars/spark-examples_2.11-2.3.0.jar \
> 10
```

https://www.cnblogs.com/aibabel/p/10828081.html


# 四、Spark on K8S 的几种模式

- Standalone：在 K8S 启动一个长期运行的集群，所有 Job 都通过 spark-submit 向这个集群提交
- Kubernetes Native：通过 spark-submit 直接向 K8S 的 API Server 提交，申请到资源后启动 Pod 做为 Driver 和 Executor 执行 Job，参考 http://spark.apache.org/docs/2.4.6/running-on-kubernetes.html
- Spark Operator：安装 Spark Operator，然后定义 spark-app.yaml，再执行 kubectl apply -f spark-app.yaml，这种申明式 API 和调用方式是 K8S 的典型应用方式，参考 https://github.com/GoogleCloudPlatform/spark-on-k8s-operator

官网spark on kubernetes: https://spark.apache.org/docs/latest/running-on-kubernetes.html


1|在宿主机提交 Job
```
bin/spark-submit \
    --master k8s://https://<k8s-apiserver-host>:<k8s-apiserver-port> \
    --deploy-mode cluster \
    --name spark-pi \
    --class org.apache.spark.examples.SparkPi \
    --conf spark.executor.instances=5 \
    --conf spark.kubernetes.container.image=<spark-image> \
    local:///path/to/examples.jar
```
- local:///path/to/examples.jar 指的是 容器的文件系统

2、在k8s上运行，需要证书
```
# --master 指定 k8s api server
# --conf spark.kubernetes.container.image 指定通过 docker-image-tool.sh 创建的镜像
# 第一个 wordcount.py 是要执行的命令
# 第二个 wordcount.py 是参数，即统计 wordcount.py 文件的单词量
bin/spark-submit \
    --master k8s://https://192.168.0.107:8443 \
    --deploy-mode cluster \
    --name spark-test \
    --conf spark.executor.instances=3 \
    --conf spark.kubernetes.container.image=spark-py:my_spark_2.4_hadoop_2.7 \
    /opt/spark/examples/src/main/python/wordcount.py \
    /opt/spark/examples/src/main/python/wordcount.py
```

3、通过kubectl proxy 运行不需要证书
```
kubectl proxy
```
然后 spark-submit 命令变成
```
# Api Server 的地址变成 http://127.0.0.1:8001
# 添加了 --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark
bin/spark-submit \
    --master k8s://http://127.0.0.1:8001 \
    --deploy-mode cluster \
    --name spark-test \
    --conf spark.executor.instances=3 \
    --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
    --conf spark.kubernetes.container.image=spark-py:my_spark_2.4_hadoop_2.7 \
    /opt/spark/examples/src/main/python/wordcount.py \
    /opt/spark/examples/src/main/python/wordcount.py
```

https://www.cnblogs.com/moonlight-lin/p/13296909.html
