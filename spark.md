
```
vim spark-env.sh
# 1、注释掉 export SPARK_MASTER_HOST=hdp--node--01
export SPARK_MASTER_HOST=hdp--node--01

# 2、在spark-env.sh添加SPARK_DAEMON_JAVA_OPTS，内容如下：
export SPARK_DAEMON_JAVA_OPTS="-Dspark.deploy.recoveryMode=ZOOKEEPER  - Dspark.deploy.zookeeper.url=hdp-node-01:2181,hdp-node-02:2181,hdp-node-03:2181  -Dspark.deploy.zookeeper.dir=/spark"
```
- 1.spark.deploy.recoveryMode： 恢复模式（Master 重新启动的模式）：有三种：（1）:zookeeper（2）:FileSystem（3）:none
- 2.spark.deploy.zookeeper.url： zookeeper的server地址
- 3.spark.deploy.zookeeper.dir： 保存集群元数据信息的文件，目录。包括Worker，Driver和Application。
