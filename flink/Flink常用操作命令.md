# 1.基于Yarn模式提交任务

使用平台jar包测试：
```
./bin/flink run -m yarn-cluster -p 2 ./examples/batch/WordCount.jar      \
--input hdfs:///user/wupq/words.txt                        \
--output hdfs:///user/wupq/output2/2020122301
```

提交自己编写代码：
```
./bin/flink run -m yarn-cluster -yn 2 -c com.tencent.tbds.demo.KafkaSourceDemo /root/wupq/tbds-demo-1.0-SNAPSHOT.jar
```
注意：Flink1.12版本不支持-yn参数


# 2.flink run
```
    -c,–class Flink应用程序的入口
    -C,–classpath 指定所有节点都可以访问到的url,可用于多个应用程序都需要的工具类加载
    -d,–detached 是否使用分离模式，就是提交任务,cli是否退出,加了-d参数,cli会退出
    -n,–allowNonRestoredState 允许跳过无法还原的savepoint。比如删除了代码中的部分operator
    -p,–parallelism 执行并行度
    -s,–fromSavepoint 从savepoint恢复任务
    -sae,–shutdownOnAttachedExit 以attached模式提交，客户端退出的时候关闭集群
```

# 3.flink yarn-cluster 模式
```
    -d,–detached 是否使用分离模式
    -m,–jobmanager 指定提交的jobmanager
    -yat,–yarnapplicationType 设置yarn应用的类型
    -yD <property=value> 使用给定属性的值
    -yd,–yarndetached 使用yarn分离模式
    -yh,–yarnhelp yarn session的帮助
    -yid,–yarnapplicationId 挂到正在运行的yarnsession上
    -yj,–yarnjar Flink jar文件的路径
    -yjm,–yarnjobManagerMemory jobmanager的内存(单位M)
    -ynl,–yarnnodeLabel 指定 YARN 应用程序 YARN 节点标签
    -ynm,–yarnname 自定义yarn应用名称
    -yq,–yarnquery 显示yarn的可用资源
    -yqu,–yarnqueue 指定yarn队列
    -ys,–yarnslots 指定每个taskmanager的slots数
    -yt,–yarnship 在指定目录中传输文件
    -ytm,–yarntaskManagerMemory 每个taskmanager的内存
    -yz,–yarnzookeeperNamespace 用来创建ha的zk子路径的命名空间
    -z,–zookeeperNamespace 用来创建ha的zk子路径的命名空间
```
# 4.flink info
```
info [OPTIONS]
```

# 5.flink list(显示正在运行或调度的程序)
```
-a,–all 显示所有应用和对应的job id
    -r,–running 显示正在运行的应用和job id
    -s,–scheduled 显示调度的应用和job id
    #yarn-cluster模式
    -m,–jobmanager 指定连接的jobmanager
    -yid,–yarnapplicationId 挂到指定的yarn id对应的yarn session上
    -z,–zookeeperNamespace 用来创建ha的zk子路径的命名空间
```

# 6. flink stop(停止一个正在运行的应用)
```
-d,–drain 在获取savepoint，停止pipeline之前发送MAX_WATERMARK
-p,–savepointPath 指定savepoint的path，如果不指定会使用默认值(“state.savepoints.dir”)
```

# 7.savepoint(触发一个正在运行的应用生成savepoint)
```
语法：savepoint [OPTIONS] []
-d,–dispose savepoint的路径
-j,–jarfile Flink的jar包
```

## 使用Maven将自己的代码编译打包

## 打好的包一般放在工程目录的target子文件夹下
```
mvn clean package
```

# flink任务运行命令

session模式运行
```
flink run --class com.zclh.data.wordcount.WordCountKafkaInStdOut /data/cdh/test/flink-kafka-1.0-SNAPSHOT.jar

指定用户运行任务，job模式
sudo -u hdfs 
bin/flink run -m yarn-cluster -yjm 1024 -ytm 1024 --class com.zclh.data.wordcount.WordCountKafkaInStdOut /data/cdh/test/flink-kafka-1.0-SNAPSHOT.jar
 
job模式运行任务
bin/flink run -m yarn-cluster -yjm 1024 -ytm 1024 --class com.zclh.data.wordcount.WordCountKafkaInStdOut /data/cdh/test/flink-kafka-1.0.jar
 
 
bin/flink run -m yarn-cluster -yjm 1024 -ytm 1024 --class com.zclh.data.wordcount.WordCountKafkaInStdOut /data/cdh/test/flink-kafka-1.1.jar
 
bin/flink run -m yarn-cluster -yjm 1024 -ytm 1024 --class com.zclh.data.wordcount.WordCountKafkaInStdOut /data/cdh/test/flink-kafka-1.2.jar
 
 
bin/flink run -m yarn-cluster -yjm 1024 -ytm 1024 --class com.zclh.data.wordcount.WordCountKafkaInStdOut /data/cdh/test/flink-kafka-1.3.jar
 
 
bin/flink run -m yarn-cluster -yjm 1024 -ytm 1024 --class com.atguigu.hotitems_analysis.KafkaProducerUtil /data/cdh/test/HotItemsAnalysis-1.0.jar
 
 
bin/flink run -m yarn-cluster -yjm 1024 -ytm 1024 --class com.atguigu.hotitems_analysis.HotItems /data/cdh/test/HotItemsAnalysis-2.0.jar
 
bin/flink run -m yarn-cluster -yjm 1024 -ytm 1024 /data/cdh/test/HotItemsAnalysis-3.0.jar --class com.atguigu.hotitems_analysis.HotItems
 
bin/flink run --class com.atguigu.hotitems_analysis.HotItems /data/cdh/test/HotItemsAnalysis-3.0.jar
```

# 启动jar包中指定的类
```
java -cp /data/cdh/test/HotItemsAnalysis-4.0.jar com.atguigu.hotitems_analysis.KafkaProducerUtil
java -cp /data/cdh/test/HotItemsAnalysis-5.0.jar com.atguigu.hotitems_analysis.KafkaProducerUtil
 
 
bin/flink run --class com.atguigu.hotitems_analysis.HotItems /data/cdh/test/HotItemsAnalysis-4.0.jar
bin/flink run --class com.atguigu.hotitems_analysis.HotItems /data/cdh/test/HotItemsAnalysis-5.0.jar
bin/flink run -m yarn-cluster -yjm 1024 -ytm 1024 --class com.atguigu.hotitems_analysis.HotItems /data/cdh/test/HotItemsAnalysis-5.0.jar
```

- https://blog.csdn.net/BlackArmand/article/details/118521150
- https://www.it610.com/article/1295589346073714688.htm
- https://developer.aliyun.com/article/632124
- https://blog.csdn.net/weixin_46669856/article/details/122927506
- https://blog.csdn.net/u011487470/article/details/123043948
- https://blog.csdn.net/u010772882/article/details/125471427
