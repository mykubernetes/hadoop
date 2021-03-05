
```
vim spark-env.sh
export JAVA_HOME=/usr/local/jdk/jdk1.8.0_60
# 1、注释掉 export SPARK_MASTER_HOST=hdp--node--01
export SPARK_MASTER_HOST=hdp--node--01

# 2、在spark-env.sh添加SPARK_DAEMON_JAVA_OPTS，内容如下：
export SPARK_DAEMON_JAVA_OPTS="-Dspark.deploy.recoveryMode=ZOOKEEPER  - Dspark.deploy.zookeeper.url=hdp-node-01:2181,hdp-node-02:2181,hdp-node-03:2181  -Dspark.deploy.zookeeper.dir=/spark"
```
- 1.spark.deploy.recoveryMode： 恢复模式（Master 重新启动的模式）：有三种：（1）:zookeeper（2）:FileSystem（3）:none
- 2.spark.deploy.zookeeper.url： zookeeper的server地址
- 3.spark.deploy.zookeeper.dir： 保存集群元数据信息的文件，目录。包括Worker，Driver和Application。



spark的shell的基本使用：

(1)利用 Spark 自带的例子程序执行一个求 PI（蒙特卡洛算法）的程序:
```
$SPARK_HOME/bin/spark-submit \ 
--class org.apache.spark.examples.SparkPi \ 
--master spark://hadoop02:7077 \ 
--executor-memory 512m \ 
--total-executor-cores 3 \
$SPARK_HOME/examples/jars/spark-examples_2.11-2.3.0.jar \ 
100
```

(2)启动spark shell
启动local模式：
```
$ spark-shell
```

启动集群模式：
```
$SPARK_HOME/bin/spark-shell \ 
--master spark://hadoop02:7077,hadoop04:7077 \     #指定 Master 的地址
--executor-memory 512M \                           #指定每个 worker 可用内存为 512M
--total-executor-cores 2                           #指定整个集群使用的 cup 核数为 2 个
```
