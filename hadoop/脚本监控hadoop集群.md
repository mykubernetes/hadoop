# 一、实现原理

> jps取角色的端口号，如果存在则跳过，否则启动角色，并把日志打印，记录角色重启记录。
 
clusterMonitor.sh（主节点）
```
#!/bin/bash
echo '.......................................'
QuorumPeerMain=$(jps | grep ' QuorumPeerMain')
ZKFC=$(jps | grep ' DFSZKFailoverController')
NameNode=$(jps | grep ' NameNode')
DataNode=$(jps | grep ' DataNode')
JournalNode=$(jps | grep ' JournalNode')
ResourceManager=$(jps | grep ' ResourceManager')
NodeManager=$(jps | grep ' NodeManager')
HMaster=$(jps | grep ' HMaster')
HRegionServer=$(jps | grep ' HRegionServer')
echo $QuorumPeerMain
echo $ZKFC
echo $NameNode
echo $DataNode
echo $JournalNode
echo $ResourceManager
echo $NodeManager
echo $HMaster
echo $HRegionServer
echo '.......................................'
if [[ -z $QuorumPeerMain ]]; then
	echo $(date) 'zookeeper is not running.' >> /home/logs/clusterMonitor.log
	echo $(date) $(zkServer.sh start) >> /home/logs/clusterStart.log
elif [[ -z $ZKFC ]]; then
	echo $(date) 'ZKFC is not running.' >> /home/logs/clusterMonitor.log
	echo $(date) | hdfs --daemon start zkfc >> /home/logs/clusterStart.log
fi	
if [[ -z $NameNode ]]; then
	echo $(date) 'NameNode is not running.' >> /home/logs/clusterMonitor.log
	echo $(date) $($HADOOP_HOME/sbin/start-all.sh) >> /home/logs/clusterStart.log
fi	
if [[ -z $DataNode ]]; then
	echo $(date) 'DataNode is not running.' >> /home/logs/clusterMonitor.log
	echo $(date) $($HADOOP_HOME/sbin/start-all.sh) >> /home/logs/clusterStart.log
fi	
if [[ -z $JournalNode ]]; then
	echo $(date) 'JournalNode is not running.' >> /home/logs/clusterMonitor.log
	echo $(date) $($HADOOP_HOME/sbin/start-all.sh) >> /home/logs/clusterStart.log
fi	
if [[ -z $ResourceManager ]]; then
	echo $(date) 'ResourceManager is not running.' >> /home/logs/clusterMonitor.log
	echo $(date) $($HADOOP_HOME/sbin/start-all.sh) >> /home/logs/clusterStart.log
fi	
if [[ -z $NodeManager ]]; then
	echo $(date) 'NodeManager is not running.' >> /home/logs/clusterMonitor.log
	echo $(date) $($HADOOP_HOME/sbin/start-all.sh) >> /home/logs/clusterStart.log
fi	
if [[ -z $HMaster ]]; then
	echo $(date) 'HMaster is not running.' >> /home/logs/clusterMonitor.log
	echo $(date) $($HBASE_HOME/bin/start-hbase.sh) >> /home/logs/clusterStart.log
fi	
if [[ -z $HRegionServer ]]; then
	echo $(date) 'HRegionServer is not running.' >> /home/logs/clusterMonitor.log
	echo $(date) $($HBASE_HOME/bin/start-hbase.sh) >> /home/logs/clusterStart.log
fi
echo '.......................................'
```

clusterMonitor.sh（从节点） 
```
#!/bin/bash
echo '.......................................'
QuorumPeerMain=$(jps | grep ' QuorumPeerMain')
DataNode=$(jps | grep ' DataNode')
NodeManager=$(jps | grep ' NodeManager')
HRegionServer=$(jps | grep ' HRegionServer')
echo $QuorumPeerMain
echo $DataNode
echo $NodeManager
echo $HRegionServer
echo '.......................................'
if [[ -z $QuorumPeerMain ]]; then
	echo $(date) 'zookeeper is not running.' >> /home/logs/clusterMonitor.log
	echo $(date) $(zkServer.sh start) >> /home/logs/clusterStart.log
fi
if [[ -z $DataNode ]]; then
	echo $(date) 'DataNode is not running.' >> /home/logs/clusterMonitor.log
	echo $(date) $($HADOOP_HOME/sbin/start-all.sh) >> /home/logs/clusterStart.log
fi
if [[ -z $NodeManager ]]; then
	echo $(date) 'NodeManager is not running.' >> /home/logs/clusterMonitor.log
	echo $(date) $($HADOOP_HOME/sbin/start-all.sh) >> /home/logs/clusterStart.log
fi
if [[ -z $HRegionServer ]]; then
	echo $(date) 'HRegionServer is not running.' >> /home/logs/clusterMonitor.log
	echo $(date) $($HBASE_HOME/bin/start-hbase.sh) >> /home/logs/clusterStart.log
fi
echo '.......................................'
```

# 二、定时执行 
```
vim /etc/crontab
# 一个小时监控一次
0  *  *  *  * root /home/shell/clusterMonitor.sh
```

# 三、脚本说明
- 脚本名称： clusterMonitor.sh
- 日志路径1：/home/logs/clusterMonitor.log
- 日志路径2：/home/logs/clusterStart.log
- clusterMonitor.log：打印当前节点角色没启动的信息
- clusterStart.log：打印角色启动时控制台输出的信息
