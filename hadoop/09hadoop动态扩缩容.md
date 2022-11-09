# 大数据Hadoop集群的扩容及缩容（动态添加删除节点） 

# 一、添加白名单和黑名单#

- 白名单，表示在白名单的主机IP地址可以用来存储数据,企业中配置白名单，可以尽量防止黑客恶意访问攻击。

## 配置白名单步骤如下：

### 1）在NameNode节点的/opt/module/hadoop-3.1.3/etc/hadoop目录创建whitelist和blacklist

创建白名单
```
vim whitelist

# 输入如下内容
hadoop102
hadoop103
```

创建黑名单
```
touch blacklist
```

### 2）修改hdfs-site.xml
```
vim hdfs-site.xml
<property>
    <name>dfs.hosts</name>
    <value>/opt/module/hadoop-3.1.3/etc/hadoop/whitelist</value>
</property>
<property>
    <name>dfs.hosts.exclude</name>
    <value>/opt/module/hadoop-3.1.3/etc/hadoop/blacklist</value>
</property>
```

### 3）分发到所有节点
```
xsync whitelist blacklist hdfs-site.xml
```

### 4）第一次添加白名单必须重启集群，不是第一次，只需刷新NameNode节点即可
```
[hadoop@hadoop102 hadoop]$ myhadoop.sh stop
[hadoop@hadoop102 hadoop]$ myhadoop.sh start
```

### 5）在Web浏览器上查看DN，Namenode information



### 6）在hadoop104上执行上传数据失败，hadoop104上并没有副本
```
[hadoop@hadoop102 hadoop-3.1.3]$ hadoop fs -put NOTICE.txt /
```

### 7）二次修改白名单，增加Hadoop104， 并分发
```
[hadoop@hadoop102 hadoop]$ vim whitelist
# 新增hadoop104
hadoop102
hadoop103
hadoop104

# 分发
[hadoop@hadoop102 hadoop]$ xsync whitelist
```

### 8）刷新NameNode
```
[hadoop@hadoop102 hadoop]$ hdfs dfsadmin -refreshNodes
Refresh nodes successful
```

### 9）再次查看Namenode information



# 二、服役新数据节点#

## 1）需求:

随着公司业务增长，数据量越来越大，原有的数据节点的容量已经不能满足存储数据的需求，需要在原有集群基础上动态添加新的数据节点。

## 2）环境准备#

### （1）在hadoop102主机上再克隆一台hadoop105主机

### （2）修改IP地址和主机名称
```
sudo vim /etc/sysconfig/network-scripts/ifcfg-ens33
# 修改IPADDR
IPADDR=192.168.10.105

sudo vim /etc/hostname
hadoop105
# 重启
reboot
```

### （3）删除data和logs目录
```
cd /opt/module/hadoop-3.1.3
rm -rf data/ logs/
```

### （4）在所有节点的hosts增加节点名
```
sudo vim /etc/hosts
# 新增
192.168.10.105	hadoop105
```

### （5）启动HDFS和NodeManager
```
[hadoop@hadoop105 hadoop-3.1.3]$ hdfs --daemon start datanode
[hadoop@hadoop105 hadoop-3.1.3]$ yarn --daemon start nodemanager
[hadoop@hadoop105 hadoop-3.1.3]$ jps
1283 DataNode
1475 Jps
1389 NodeManager
```

### （6）添加白名单（如果设置了白名单，需要这一步，否则忽略）
```
[hadoop@hadoop102 hadoop]$ vim whitelist 
# 添加
hadoop105
# 分发，hadoop105单独设置一下
[hadoop@hadoop102 hadoop]$ xsync whitelist
# 刷新NameNode
[hadoop@hadoop102 hadoop]$ hdfs dfsadmin -refreshNodes
Refresh nodes successful
```

### （7）查看 Namenode information

## 节点间数据均衡#

### 开启数据均衡
```
[hadoop@hadoop105 hadoop-3.1.3]$ sbin/start-balancer.sh -threshold 10
```
参数10，代表的是集群中各个节点的磁盘空间利用率相差不超过10%，可根据实际情况进行调整。

### 停止负载均衡
```
[hadoop@hadoop105 hadoop-3.1.3]$ sbin/stop-balancer.sh
```
注意：由于HDFS需要启动单独的Rebalance Server来执行Rebalance操作，所以尽量不要再NameNode上执行start-balancer.sh，而是找一台比较空闲的机器。

# 三、黑名单退役旧节点#

### 1）编辑/opt/module/hadoop-3.1.3/etc/hadoop目录下的blacklist
```
vim blacklist
添加主机名（要退役的节点）

hadoop105
```

如果没有配置黑名单，需要在hdfs-site.xml中配置
```
<property>
    <name>dfs.hosts.exclude</name>
    <value>/opt/module/hadoop-3.1.3/etc/hadoop/blacklist</value>
</property>
```

### 2）分发配置文件balcklist hdfs-site.xml，所有节点都要修改
```
[hadoop@hadoop102 hadoop]$ xsync blacklist
```

### 3）刷新NameNode
```
[hadoop@hadoop102 hadoop]$ hdfs dfsadmin -refreshNodes
Refresh nodes successful
```

### 4）检查Web浏览器Namenode information，可以看到正在退役中。



表示正在退役，该阶段会复制副本到其他节点，之前上传到hadoop105的文件副本会被复制到其他节点

### 5）等待退役节点状态为Decommissioned（所有块已复制完成），停止该节点以及节点资源管理器。注意：如果副本数是3，服务的节点数量小于3，是不能退役成功的，需要修改副本数后才能退役。
```
[hadoop@hadoop105 hadoop-3.1.3]$ hdfs --daemon stop datanode
[hadoop@hadoop105 hadoop-3.1.3]$ yarn --daemon stop nodemanager
[hadoop@hadoop105 hadoop-3.1.3]$ jps
1941 Jps
```

### 6）如果数据不均衡，可以使用命令实现集群的平衡
```
[hadoop@hadoop102 hadoop-3.1.3]$ sbin/start-balancer.sh -threshold 10
```
