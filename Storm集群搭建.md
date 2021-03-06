Storm集群搭建  
============
一、 集群规划  
```
node001			node002			node003
zk			zk			zk
storm			storm			storm
```  
二、 jar包下载  
官方网址：http://storm.apache.org/  

三、 安装jdk  
```
$ tar -zxf /opt/softwares/jdk-8u121-linux-x64.gz -C /opt/modules/
JDK环境变量配置
# vi /etc/profile
#JAVA_HOME
export JAVA_HOME=/opt/modules/jdk1.8.0_121
export PATH=$PATH:$JAVA_HOME/bin
```  
四、 安装Zookeeper  
1）解压安装  
（1）解压zookeeper安装包到/opt/module/目录下  
```  tar -zxvf zookeeper-3.4.10.tar.gz -C /opt/module/ ```  
（2）在/opt/module/zookeeper-3.4.10/这个目录下创建zkData  
``` mkdir -p zkData ```  
（3）重命名/opt/module/zookeeper-3.4.10/conf这个目录下的zoo_sample.cfg为zoo.cfg  
``` mv zoo_sample.cfg zoo.cfg ```  

2）配置zoo.cfg文件  
```
dataDir=/opt/module/zookeeper-3.4.10/zkData
增加如下配置
#######################cluster##########################
server.1=node001:2888:3888
server.2=node002:2888:3888
server.3=node003:2888:3888
集群模式下配置一个文件myid，这个文件在dataDir目录下
```  

3）集群操作  
（1）在/opt/module/zookeeper-3.4.10/zkData目录下创建一个myid的文件  
 ``` touch myid ```  
（2）编辑myid文件  
``` echo 1 > myid ```  
（3）拷贝配置好的zookeeper到其他机器上
```
scp -r zookeeper-3.4.10/ root@node002:/opt/app/
scp -r zookeeper-3.4.10/ root@node003:/opt/app/
并分别修改myid文件中内容为2、3
```  

（4）分别启动zookeeper  
``` bin/zkServer.sh start ```  
        
（5）查看状态  
``` 
bin/zkServer.sh status
JMX enabled by default
Using config: /opt/module/zookeeper-3.4.10/bin/../conf/zoo.cfg
Mode: follower
        
bin/zkServer.sh status
JMX enabled by default
Using config: /opt/module/zookeeper-3.4.10/bin/../conf/zoo.cfg
Mode: leader
       
bin/zkServer.sh status
JMX enabled by default
Using config: /opt/module/zookeeper-3.4.10/bin/../conf/zoo.cfg
 Mode: follower
```


五、Storm集群部署  

(1） 配置集群  
1）拷贝jar包到node001的/opt/software目录下  
2）解压jar包到/opt/module目录下  
``` tar -zxvf apache-storm-1.1.0.tar.gz -C /opt/module/ ```  
3）修改解压后的apache-storm-1.1.0.tar.gz文件名称为storm  
``` mv apache-storm-1.1.0/ storm ```  
4）在/opt/module/storm/目录下创建data文件夹  
``` mkdir data ```  
5）修改配置文件  
```
 pwd
 /opt/module/storm/conf
vi storm.yaml
# 设置Zookeeper的主机名称
storm.zookeeper.servers:
     - "node001"
     - "node002"
     - "node003"

# 设置主节点的主机名称
nimbus.seeds: ["node001"]

# 设置Storm的数据存储路径
 storm.local.dir: "/opt/module/storm/data"

# 设置Worker的端口号
supervisor.slots.ports:
    - 6700
    - 6701
    - 6702
    - 6703
```

(2）配置环境变量  
```
$ vi /etc/profile
    #STORM_HOME
    export STORM_HOME=/opt/module/storm
    export PATH=$PATH:$STORM_HOME/bin
$ source /etc/profile
```  

(3）分发配置好的Storm安装包  
```
scp -rp /opt/module/storm node002:/opt/module/storm
scp -rp /opt/module/storm node003:/opt/module/storm
```  

4）启动集群分别在每台机器  
（1）后台启动nimbus  
``` bin/storm nimbus & ```  
        
（2）后台启动supervisor  
``` bin/storm supervisor & ```  
         
（3）启动Storm ui   一台机器  
``` bin/storm ui ```  
    
5）通过浏览器查看集群状态  
``` http://node001:8080/index.html ```
 
    
    
    
六、Storm日志信息查看  

1、查看nimbus的日志信息  
 ```
在nimbus的服务器上
cd /opt/module/storm/logs
tail -100f /opt/module/storm/logs/nimbus.log
 ```  
 
2、查看ui运行日志信息  
 ```
在ui的服务器上，一般和nimbus一个服务器
cd /opt/module/storm/logs
tail -100f /opt/module/storm/logs/ui.log
```  

3、查看supervisor运行日志信息  
```
在supervisor服务上
cd /opt/module/storm/logs
tail -100f /opt/module/storm/logs/supervisor.log
```  

4、查看supervisor上worker运行日志信息  
```
在supervisor服务上
cd /opt/module/storm/logs
tail -100f /opt/module/storm/logs/worker-6702.log
```  

5、logviewer，可以在web页面点击相应的端口号即可查看日志  
```
分别在supervisor节点上执行：
bin/storm logviewer &
```  
 


七、Storm命令行操作  

 1、nimbus：启动nimbus守护进程  
 ``` storm nimbus ```  
 2、supervisor：启动supervisor守护进程  
 ``` storm supervisor ```  
 3、ui：启动UI守护进程。  
 ``` storm ui ```  
 4、list：列出正在运行的拓扑及其状态  
 ``` storm list ```  
 5、logviewer：Logviewer提供一个web接口查看Storm日志文件。  
 ``` storm logviewer ```  
 6、jar：  
 ``` storm jar 【jar路径】 【拓扑包名.拓扑类名】 【拓扑名称】 ```  
 7、kill：杀死名为Topology-name的拓扑  
 ``` storm kill topology-name [-w wait-time-secs] ```
 ``` -w：等待多久后杀死拓扑 ```  
 8、active：激活指定的拓扑spout。  
 ``` storm activate topology-name ```  
 9、deactivate：禁用指定的拓扑Spout。  
 ``` storm deactivate topology-name  ```  
 10、help：打印一条帮助消息或者可用命令的列表。  
 ``` storm help ```  
 ``` storm help <command> ```  
