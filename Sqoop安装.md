Sqoop  
=====  
一、安装：  
1、开启Zookeeper  
2、开启hdfs集群服务  
3、解压缩安装包  
``` tar -xvf sqoop-1.4.5-cdh5.3.6.tar.gz -C modules/ ```  
4、修改配置文件名  
``` cp sqoop-env-template.sh sqoop-env.sh ```  
5、配置文件：  
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




二、使用方法  
1、使用sqoop将mysql中的数据导入到HDFS  
```
Step1、确定Mysql服务的正常开启
Step2、在Mysql中创建一张表
mysql> create database company;
mysql> create table staff(
			id int(4) primary key not null auto_increment, 
			name varchar(255) not null, 
			sex varchar(255) not null);
mysql> insert into staff(name, sex) values('Thomas', 'Male');  
Step3、操作数据
```  

RDBMS --> HDFS  
使用Sqoop导入数据到HDFS  
** 全部导入  
```
$ bin/sqoop import \
--connect jdbc:mysql://hadoop-senior01.itguigu.com:3306/company \
--username root \
--password 123456 \
--table staff \
--target-dir /user/company \
--delete-target-dir \
--num-mappers 1 \
--fields-terminated-by "\t"
```  
** 查询导入  
```
$ bin/sqoop import 
--connect jdbc:mysql://hadoop-senior01.itguigu.com:3306/company 
--username root 
--password 123456 
--target-dir /user/company 
--delete-target-dir 
--num-mappers 1 
--fields-terminated-by "\t" 
--query 'select name,sex from staff where id >= 2 and $CONDITIONS;'
```  
** 导入指定列  
```
$ bin/sqoop import 
--connect jdbc:mysql://hadoop-senior01.itguigu.com:3306/company 
--username root 
--password 123456 
--target-dir /user/company 
--delete-target-dir 
--num-mappers 1 
--fields-terminated-by "\t"
--columns id, sex
 --table staff
 ```  

** 使用sqoop关键字筛选查询导入数据  
```
$ bin/sqoop import 
--connect jdbc:mysql://hadoop-senior01.itguigu.com:3306/company 
--username root 
--password 123456 
--target-dir /user/company 
--delete-target-dir 
--num-mappers 1 
--fields-terminated-by "\t"
--table staff
--where "id=3"
```  

RDBMS --> Hive  
1、在Hive中创建表（不需要提前创建表，会自动创建）  
``` hive (company)> create table staff_hive(id int, name string, sex string) row format delimited fields terminated by '\t'; ```  
2、向Hive中导入数据  
```
$ bin/sqoop import 
--connect jdbc:mysql://hadoop-senior01.itguigu.com:3306/company 
--username root 
--password 123456 
--table staff 
--num-mappers 1 
--hive-import 
--fields-terminated-by "\t" 
--hive-overwrite 
--hive-table company.staff_hive
```  

Hive/HDFS --> MYSQL  
1、在Mysql中创建一张表  
```
$ bin/sqoop export 
--connect jdbc:mysql://hadoop-senior01.itguigu.com:3306/company 
--username root 
--password 123456
--table staff_mysql
--num-mappers 1 
--export-dir /user/hive/warehouse/company.db/staff_hive
--input-fields-terminated-by "\t" 
```  
