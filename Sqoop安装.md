Sqoop  
=====  
一、SQL-TO-HADOOP  
二、配置：  
1、开启Zookeeper  
2、开启集群服务  
3、配置文件：  
```
** sqoop-env.sh
#export HADOOP_COMMON_HOME=
export HADOOP_COMMON_HOME=/opt/modules/cdh/hadoop-2.5.0-cdh5.3.6/

#Set path to where hadoop-*-core.jar is available
#export HADOOP_MAPRED_HOME=
export HADOOP_MAPRED_HOME=/opt/modules/cdh/hadoop-2.5.0-cdh5.3.6/

#set the path to where bin/hbase is available
#export HBASE_HOME=

#Set the path to where bin/hive is available
#export HIVE_HOME=
export HIVE_HOME=/opt/modules/cdh/hive-0.13.1-cdh5.3.6/

#Set the path for where zookeper config dir is
#export ZOOCFGDIR=
export ZOOCFGDIR=/opt/modules/cdh/zookeeper-3.4.5-cdh5.3.6/
export ZOOKEEPER_HOME=/opt/modules/cdh/zookeeper-3.4.5-cdh5.3.6/
```  
4、拷贝jdbc驱动到sqoop的lib目录下  
``` cp -a mysql-connector-java-5.1.27-bin.jar /opt/modules/cdh/sqoop-1.4.5-cdh5.3.6/lib/ ```  
5、启动sqoop  
``` $ bin/sqoop help查看帮助 ```  
6、测试Sqoop是否能够连接成功  
```
$ bin/sqoop list-databases --connect jdbc:mysql://hadoop-senior01.itguigu.com:3306/metastore 
  --username root \
  --password 123456
```
