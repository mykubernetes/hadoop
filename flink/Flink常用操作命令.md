# 一、启动
```
./start-cluster.sh
```

# 二、run
```
./bin/flink run [OPTIONS]
 
./bin/flink run -m yarn-cluster -c com.wang.flink.WordCount /opt/app/WordCount.jar
```

| OPTIONS | 功能说明 |
|---------|----------|
| -d | detached 是否使用分离模式 |
| -m | jobmanager 指定提交的jobmanager |
| -yat | –yarnapplicationType 设置yarn应用的类型 |
| -yD | 使用给定属性的值 |
| -yd | –yarndetached 使用yarn分离模式 |
| -yh | –yarnhelp yarn session的帮助 |
| -yid | –yarnapplicationId 挂到正在运行的yarnsession上 |
| -yj | –yarnjar Flink jar文件的路径 |
| -yjm | –yarnjobManagerMemory jobmanager的内存(单位M) |
| -ynl | –yarnnodeLabel 指定 YARN 应用程序 YARN 节点标签 |
| -ynm | –yarnname 自定义yarn应用名称 |
| -yq | –yarnquery 显示yarn的可用资源 |
| -yqu | –yarnqueue 指定yarn队列 |
| -ys | –yarnslots 指定每个taskmanager的slots数 |
| -yt | yarnship 在指定目录中传输文件 |
| -ytm | –yarntaskManagerMemory 每个taskmanager的内存 |
| -yz | –yarnzookeeperNamespace 用来创建ha的zk子路径的命名空间 |
| -z | –zookeeperNamespace 用来创建ha的zk子路径的命名空间 |
| -p | 并行度 |
| -yn | 需要分配的YARN容器个数(=任务管理器的数量) |

# 三、info
```
./bin/flink info [OPTIONS]
```

| OPTIONS | 功能说明 |
|---------|----------|
| -c | 程序进入点，主类 |
| -p | 并行度 |

# 四、list
```
./bin/flink list [OPTIONS]
```

| OPTIONS | 功能说明 |
|---------|----------|
| -a | –all 显示所有应用和对应的job id |
| -r | –running 显示正在运行的应用和job id |
| -s | –scheduled 显示调度的应用和job id |
| -m | –jobmanager 指定连接的jobmanager |
| -yid | –yarnapplicationId 挂到指定的yarn id对应的yarn session上 |
| -z | –zookeeperNamespace 用来创建ha的zk子路径的命名空间 |

# 五、stop
```
./bin/flink stop  [OPTIONS] <Job ID>
```

| OPTIONS | 功能说明 |
|---------|----------|
| -d | 在采取保存点和停止管道之前，发送MAX_WATERMARK |
| -p | savepointPath 保存点的路径 'xxxxx' |
| -m | –jobmanager 指定连接的jobmanager |
| -yid | –yarnapplicationId 挂到指定的yarn id对应的yarn session上 |
| -z | –zookeeperNamespace 用来创建ha的zk子路径的命名空间 |

# 六、cancel（弱化）
```
./bin/flink cancel  [OPTIONS] <Job ID>
```

| OPTIONS | 功能说明 |
|---------|----------|
| -s | 使用 "stop "代替 |
| -D | 允许指定多个通用配置选项 |
| -m | 要连接的JobManager的地址 |
| -yid | –yarnapplicationId 挂到指定的yarn id对应的yarn session上 |
| -z | –zookeeperNamespace 用来创建ha的zk子路径的命名空间 |

# 七、savepoint
```
./bin/flink savepoint  [OPTIONS] <Job ID>
```

| OPTIONS | 功能说明 |
|---------|----------|
| -d | 要处理的保存点的路径 |
| -j | Flink程序的JAR文件 |
| -m | 要连接的JobManager的地址 |
| -yid | –yarnapplicationId 挂到指定的yarn id对应的yarn session上 |
| -z | –zookeeperNamespace 用来创建ha的zk子路径的命名空间 |


- https://blog.csdn.net/BlackArmand/article/details/118521150
- https://www.it610.com/article/1295589346073714688.htm
- https://developer.aliyun.com/article/632124
- https://blog.csdn.net/weixin_46669856/article/details/122927506
- https://blog.csdn.net/u011487470/article/details/123043948
- https://blog.csdn.net/u010772882/article/details/125471427
- https://flink-learning.org.cn/article/detail/758a865c6c808d6b89d494c0827a1d61?name=article
