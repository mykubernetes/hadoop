分布式安装部署  
=============
0）首先安装jdk    
``` $ tar -zxf /opt/softwares/jdk-8u121-linux-x64.gz -C /opt/modules/ ```  
JDK环境变量配置  
```
# vi /etc/profile
#JAVA_HOME
export JAVA_HOME=/opt/modules/jdk1.8.0_121
export PATH=$PATH:$JAVA_HOME/bin
```  
1）解压安装  
（1）解压zookeeper安装包到/opt/module/目录下  
```
tar -zxvf zookeeper-3.4.10.tar.gz -C /opt/module/
```  

（2）创建data目录和log目录
```
mkdir /opt/module/zookeeper-3.4.10/{data,logs}

```  

（3）重命名/opt/module/zookeeper-3.4.10/conf这个目录下的zoo_sample.cfg为zoo.cfg  
```
mv zoo_sample.cfg zoo.cfg
```  

2）配置zoo.cfg文件  
（1）具体配置  
```
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/opt/module/zookeeper-3.4.10/data
dataLogDir=/opt/module/zookeeper-3.4.10/logs
clientPort=2181
maxClientCnxns=60
autopurge.snapRetainCount=3
autopurge.purgeInterval=1
集群配置
#######################cluster##########################
server.1=node001:2888:3888
server.2=node002:2888:3888
server.3=node003:2888:3888
```

ZooKeeper配置详解
```
tickTime=2000
#ZooKeeper服务器之间或客户单与服务器之间维持心跳的时间间隔，单位是毫秒，默认为2000。

initLimit=10
#zookeeper接受客户端（这里所说的客户端不是用户连接zookeeper服务器的客户端,而是zookeeper服务器集群中连接到leader的follower 服务器）初始化连接时最长能忍受多少个心跳时间间隔数。
#当已经超过10个心跳的时间（也就是tickTime）长度后 zookeeper 服务器还没有收到客户端的返回信息,那么表明这个客户端连接失败。总的时间长度就是 10*2000=20秒。

syncLimit=5
#标识ZooKeeper的leader和follower之间同步消息，请求和应答时间长度，最长不超过多少个tickTime的时间长度，总的时间长度就是5*2000=10秒。

dataDir=/opt/module/zookeeper-3.4.10/data
#存储内存数据库快照的位置；ZooKeeper保存Client的数据都是在内存中的，如果ZooKeeper节点故障或者服务停止，那么ZooKeeper就会将数据快照到该目录当中。

clientPort=2181
#ZooKeeper客户端连接ZooKeeper服务器的端口，监听端口

maxClientCnxns=60
#ZooKeeper可接受客户端连接的最大数量，默认为60

dataLogDir=/opt/module/zookeeper-3.4.10/logs
#如果没提供的话使用的则是dataDir。zookeeper的持久化都存储在这两个目录里。dataLogDir里是放到的顺序日志(WAL)。而dataDir里放的是内存数据结构的snapshot，便于快速恢复。为了达到性能最大化，一般建议把dataDir和dataLogDir分到不同的磁盘上，这样就可以充分利用磁盘顺序写的特性

autopurge.snapRetainCount=3
#ZooKeeper要保留dataDir中快照的数量

autopurge.purgeInterval=1
#ZooKeeper清楚任务间隔(以小时为单位)，设置为0表示禁用自动清除功能

server.1=localhost:2888:3888
#指定ZooKeeper集群主机地址及通信端口
#1 为集群主机的数字标识，一般从1开始，三台ZooKeeper集群一般都为123
#localhost 为集群主机的IP地址或者可解析主机名
#2888 端口用来集群成员的信息交换端口，用于ZooKeeper集群节点与leader进行信息同步
#3888 端口是在leader挂掉时或者刚启动ZK集群时专门用来进行选举leader所用的端口
```

添加zookeeper环境变量
```
cat << EOF >> /etc/profile

export ZOOKEEPER_HOME=/opt/module/zookeeper-3.4.10/
export PATH=\$PATH:\$ZOOKEEPER_HOME/bin
EOF

source /etc/profile
```


3）集群操作  
（1）在/opt/module/zookeeper-3.4.10/data/目录下创建一个myid的文件  
```
touch myid
```  
 添加myid文件，注意一定要在linux里面创建，在notepad++里面很可能乱码  
（2）编辑myid文件  
```
vi myid
```  
在文件中添加与server对应的编号：如1  
（3）拷贝配置好的zookeeper到其他机器上  
```
scp -r zookeeper-3.4.10/ root@node002:/opt/module/
scp -r zookeeper-3.4.10/ root@node003:/opt/module/
并分别修改myid文件中内容为2、3
```  

ZooKeeper执行程序简介
```
/opt/module/zookeeper-3.4.10/bin/ -l
total 44
-rwxr-xr-x 1 2002 2002  232 Mar  7 00:50 README.txt
-rwxr-xr-x 1 2002 2002 1937 Mar  7 00:50 zkCleanup.sh  
-rwxr-xr-x 1 2002 2002 1056 Mar  7 00:50 zkCli.cmd
-rwxr-xr-x 1 2002 2002 1534 Mar  7 00:50 zkCli.sh           #ZK客户端连接ZK的脚本程序
-rwxr-xr-x 1 2002 2002 1759 Mar  7 00:50 zkEnv.cmd
-rwxr-xr-x 1 2002 2002 2919 Mar  7 00:50 zkEnv.sh           #ZK变量脚本程序
-rwxr-xr-x 1 2002 2002 1089 Mar  7 00:50 zkServer.cmd
-rwxr-xr-x 1 2002 2002 6773 Mar  7 00:50 zkServer.sh        #ZK启动脚本程序
-rwxr-xr-x 1 2002 2002  996 Mar  7 00:50 zkTxnLogToolkit.cmd
-rwxr-xr-x 1 2002 2002 1385 Mar  7 00:50 zkTxnLogToolkit.sh
```

zkServer.sh启动文件
```
/opt/module/zookeeper-3.4.10/bin/zkServer.sh 
ZooKeeper JMX enabled by default
Using config: /opt/module/zookeeper-3.4.10/bin/../conf/zoo.cfg
Usage: /opt/module/zookeeper-3.4.10/bin/zkServer.sh {start|start-foreground|stop|restart|status|upgrade|print-cmd}

#关闭ZK服务
/opt/module/zookeeper-3.4.10/bin/zkServer.sh stop

#启动ZK服务
/opt/module/zookeeper-3.4.10/bin/zkServer.sh start

#启动ZK服务并打印启动信息到标准输出，方便于排错
/opt/module/zookeeper-3.4.10/bin/zkServer.sh start-foreground

#重启ZK服务
/opt/module/zookeeper-3.4.10/bin/zkServer.sh restart

#查看ZK服务状态
/opt/module/zookeeper-3.4.10/bin/zkServer.sh status
```

4）分别启动zookeeper  
 ``` # bin/zkServer.sh start ```  

5）查看状态  
```
# bin/zkServer.sh status
JMX enabled by default
Using config: /opt/module/zookeeper-3.4.10/bin/../conf/zoo.cfg
Mode: follower
	
# bin/zkServer.sh status
JMX enabled by default
Using config: /opt/module/zookeeper-3.4.10/bin/../conf/zoo.cfg
Mode: leader
	
# bin/zkServer.sh status
JMX enabled by default
Using config: /opt/module/zookeeper-3.4.10/bin/../conf/zoo.cfg
Mode: follower
```  

zkCli.sh客户端连接
```
/opt/module/zookeeper-3.4.10/bin/zkCli.sh -server localhost:2181
#连接ZK服务
#-server：指定ZK服务
#localhost：指定要连接的主机
#2181：指定连接端口，默认不加参数会连接到本机的2181端口

#使用?号或者help可以获取帮助命令
[zk: localhost:2181(CONNECTED) 0] ?
ZooKeeper -server host:port cmd args
        stat path [watch]                       #获取节点数据内容和属性信息
        set path data [version]                 #更新节点数据内容
        ls path [watch]                         #列出节点
        delquota [-n|-b] path
        ls2 path [watch]                        #列出节点数据内容和属性信息
        setAcl path acl                         #设置ACL访问控制权限
        setquota -n|-b val path
        history                                 #获取历史命令记录
        redo cmdno
        printwatches on|off
        delete path [version]                   #删除节点，version表示数据版本
        sync path                               #同步节点
        listquota path
        rmr path                                #删除节点，忽略节点下的子节点
        get path [watch]                        #读取数据内容和属性信息
        create [-s] [-e] path data acl          #创建节点命令
        addauth scheme auth
        quit                                    #退出当前ZK连接
        getAcl path                             #获取节点ACL策略信息
        close                                   #断开当前ZK连接，但不退出窗口
        connect host:port                       #断开当前ZK连接后，可使用connect加参数来连接指定ZK节点
```
create [-s] [-e] path data acl 选项介绍： -s用来指定节点特性为顺序节点；顺序节点：是创建时唯一且被独占的递增性整数作为其节点号码，此号码会被叠加在路径之后。 -e用来指定特性节点为临时节点,临时节点不允许有子目录；关于持久节点和临时节点请看上篇文章 若不指定，则表示持久节点 acl用来做权限控制


1）启动客户端  
``` $ bin/zkCli.sh ```  

2）显示所有操作命令  
``` [zk: localhost:2181(CONNECTED) 1] help ```

3）查看当前znode中所包含的内容
```
[zk: localhost:2181(CONNECTED) 0] ls / 
[zookeeper]
```    
4）查看当前节点数据并能看到更新次数等数据
```
[zk: localhost:2181(CONNECTED) 1] ls2 /
[zookeeper]
cZxid = 0x0
ctime = Thu Jan 01 08:00:00 CST 1970
mZxid = 0x0
mtime = Thu Jan 01 08:00:00 CST 1970
pZxid = 0x0
cversion = -1
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 0
numChildren = 1
```  
5）创建普通节点  
```
[zk: localhost:2181(CONNECTED) 2] create /app1 "hello app1"
Created /app1
[zk: localhost:2181(CONNECTED) 4] create /app1/server101 "192.168.1.101"
Created /app1/server101
```  
6）获得节点的值
```
[zk: localhost:2181(CONNECTED) 6] get /app1
hello app1
cZxid = 0x20000000a
ctime = Mon Jul 17 16:08:35 CST 2017
mZxid = 0x20000000a
mtime = Mon Jul 17 16:08:35 CST 2017
pZxid = 0x20000000b
cversion = 1
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 10
numChildren = 1

[zk: localhost:2181(CONNECTED) 8] get /app1/server101
192.168.1.101
cZxid = 0x20000000b
ctime = Mon Jul 17 16:11:04 CST 2017
mZxid = 0x20000000b
mtime = Mon Jul 17 16:11:04 CST 2017
pZxid = 0x20000000b
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 13
numChildren = 0
```  
7）创建短暂节点  
``` [zk: localhost:2181(CONNECTED) 9] create -e /app-emphemeral 8888 ```  
（1）在当前客户端是能查看到的  
```
[zk: localhost:2181(CONNECTED) 10] ls /
[app1, app-emphemeral, zookeeper]
```  
（2）退出当前客户端然后再重启启动客户端  
```
[zk: localhost:2181(CONNECTED) 12] quit
$ bin/zkCli.sh
```  
（3）再次查看根目录下短暂节点已经删除  
```
[zk: localhost:2181(CONNECTED) 0] ls /
[app1, zookeeper]
```  
8）创建带序号的节点  
```
（1）先创建一个普通的根节点app2
[zk: localhost:2181(CONNECTED) 11] create /app2 "app2"
（2）创建带序号的节点
[zk: localhost:2181(CONNECTED) 13] create -s /app2/aa 888
Created /app2/aa0000000000
[zk: localhost:2181(CONNECTED) 14] create -s /app2/bb 888
Created /app2/bb0000000001
[zk: localhost:2181(CONNECTED) 15] create -s /app2/cc 888
Created /app2/cc0000000002
如果原节点下有1个节点，则再排序时从1开始，以此类推。
[zk: localhost:2181(CONNECTED) 16] create -s /app1/aa 888
Created /app1/aa0000000001
```  
9）修改节点数据值  
``` [zk: localhost:2181(CONNECTED) 2] set /app1 999 ```  

10）节点的值变化监听  
```
（1）在node003主机上注册监听/app1节点数据变化
[zk: localhost:2181(CONNECTED) 26] get /app1 watch
（2）在node002主机上修改/app1节点的数据
[zk: localhost:2181(CONNECTED) 5] set /app1  777
（3）观察node003主机收到数据变化的监听
WATCHER::
WatchedEvent state:SyncConnected type:NodeDataChanged path:/app1
```  
11）节点的子节点变化监听（路径变化）  
```
（1）在node003主机上注册监听/app1节点的子节点变化
[zk: localhost:2181(CONNECTED) 1] ls /app1 watch
[aa0000000001, server101]
（2）在node002主机/app1节点上创建子节点
[zk: localhost:2181(CONNECTED) 6] create /app1/bb 666
Created /app1/bb
（3）观察node003主机收到子节点变化的监听
WATCHER::
WatchedEvent state:SyncConnected type:NodeChildrenChanged path:/app1
```  
12）删除节点  
``` [zk: localhost:2181(CONNECTED) 4] delete /app1/bb ```  

13）递归删除节点  
``` [zk: localhost:2181(CONNECTED) 7] rmr /app2 ```  

14）查看节点状态  
```
[zk: localhost:2181(CONNECTED) 12] stat /app1
cZxid = 0x20000000a
ctime = Mon Jul 17 16:08:35 CST 2017
mZxid = 0x200000018
mtime = Mon Jul 17 16:54:38 CST 2017
pZxid = 0x20000001c
cversion = 4
dataVersion = 2
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 3
numChildren = 2
```
