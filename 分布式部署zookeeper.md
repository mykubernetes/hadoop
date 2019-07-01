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
``` $ tar -zxvf zookeeper-3.4.10.tar.gz -C /opt/module/ ```  
（2）在/opt/module/zookeeper-3.4.10/这个目录下创建data/zkData  
``` mkdir -p data/zkData ```  
（3）重命名/opt/module/zookeeper-3.4.10/conf这个目录下的zoo_sample.cfg为zoo.cfg  
``` mv zoo_sample.cfg zoo.cfg ```  

2）配置zoo.cfg文件  
（1）具体配置  
```
dataDir=/opt/module/zookeeper-3.4.10/data/zkData
dataLogDir=/opt//module/zookeeper-3.4.10/log
增加如下配置
#######################cluster##########################
server.1=node001:2888:3888
server.2=node002:2888:3888
server.3=node003:2888:3888
```
（2）配置参数解读  
Server.A=B:C:D。  
A是一个数字，表示这个是第几号服务器；  
B是这个服务器的ip地址；  
C是这个服务器与集群中的Leader服务器交换信息的端口；  
D是万一集群中的Leader服务器挂了，需要一个端口来重新进行选举，选出一个新的Leader，而这个端口就是用来执行选举时服务器相互通信的端口。  
集群模式下配置一个文件myid，这个文件在dataDir目录下，这个文件里面有一个数据就是A的值，Zookeeper启动时读取此文件，拿到里面的数据与zoo.cfg里面的配置信息比较从而判断到底是哪个server。  

3）集群操作  
（1）在/opt/module/zookeeper-3.4.10/data/zkData目录下创建一个myid的文件  
``` touch myid ```  
 添加myid文件，注意一定要在linux里面创建，在notepad++里面很可能乱码  
（2）编辑myid文件  
``` vi myid ```  
在文件中添加与server对应的编号：如1
（3）拷贝配置好的zookeeper到其他机器上
```
scp -r zookeeper-3.4.10/ root@node002:/opt/module/
scp -r zookeeper-3.4.10/ root@node003:/opt/module/
并分别修改myid文件中内容为2、3
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


客户端命令行操作  
命令基本语法	功能描述
```
  help	              显示所有操作命令
  ls path [watch]   	使用 ls 命令来查看当前znode中所包含的内容
  ls2 path [watch]   	查看当前节点数据并能看到更新次数等数据
  create            	普通创建
  -s                  含有序列
  -e                  临时（重启或者超时消失）
  get path [watch]   	获得节点的值
  set	                设置节点的具体值
  stat	              查看节点状态
  delete            	删除节点
  rmr	                递归删除节点
``` 
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
