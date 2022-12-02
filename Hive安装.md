Hive的部署与安装
===============
1、解压Hive到安装目录  
``` $ tar -zxf /opt/softwares/hive-0.13.1-cdh5.3.6.tar.gz -C ./ ```

2、重命名配置文件  
```
$ mv hive-default.xml.template hive-site.xml
$ mv hive-env.sh.template hive-env.sh
```  
3、hive-env.sh  
```
JAVA_HOME=/opt/modules/jdk1.8.0_121
HADOOP_HOME=/opt/modules/cdh/hadoop-2.5.0-cdh5.3.6/
export HIVE_CONF_DIR=/opt/modules/cdh/hive-0.13.1-cdh5.3.6/conf
```  
4、安装Mysql  
```
$ su - root
# yum -y install mysql mysql-server mysql-devel
# wget http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
# rpm -ivh mysql-community-release-el7-5.noarch.rpm
# yum -y install mysql-community-server
提示：如果使用离线绿色版本（免安装版本）需要手动初始化Mysql数据库
```  
5、配置Mysql  

开启Mysql服务
```
# systemctl start mysqld.service
```

设置root用户密码
```
# mysqladmin -uroot password '123456'
```  

为用户以及其他机器节点授权
```
mysql> grant all on *.* to root@'node01' identified by '123456';
flush privileges;
```  

** hive-site.xml   #修改的属性  
```
	<property>
	        <!-- jdbc连接的url -->
		<name>javax.jdo.option.ConnectionURL</name>
		<value>jdbc:mysql://node01:3306/metastore?createDatabaseIfNotExist=true</value>
		<description>JDBC connect string for a JDBC metastore</description>
	</property>

	<property>
	        <!-- jdbc连接的Driver -->
		<name>javax.jdo.option.ConnectionDriverName</name>
		<value>com.mysql.jdbc.Driver</value>
		<description>Driver class name for a JDBC metastore</description>
	</property>

	<property>
	        <!-- jdbc连接的username -->
		<name>javax.jdo.option.ConnectionUserName</name>
		<value>root</value>
		<description>username to use against metastore database</description>
	</property>

	<property>
	        <!-- jdbc连接的password -->
		<name>javax.jdo.option.ConnectionPassword</name>
		<value>123456</value>
		<description>password to use against metastore database</description>
	</property>
	
	<property>
	        <!-- Hive元数据存储的版本验证 -->
		<name>hive.metastore.schema.verification</name>
		<value>false</value>
	</property>
	
	<property>
	        <!-- 元数据存储授权 -->
		<name>hive.metastore.event.db.notification.api.auth</name>
		<value>false</value>
	</property>
	
	<property>
	        <!-- Hive默认在HDFS的工作目录 -->
		<name>hive.metastore.warehouse.dir</name>
		<value>/user/hive/warehouse</value>
	</property>
```  
** 创建日志目录  
``` mkdir /opt/modules/cdh/hive-0.13.1-cdh5.3.6/logs ```  
** hive-log4j.properties  
``` hive.log.dir=/opt/modules/cdh/hive-0.13.1-cdh5.3.6/logs ```  

** 拷贝数据库驱动包到Hive根目录下的lib文件夹  
https://github.com/mykubernetes/hadoop/blob/master/image/mysql-connector-java-5.1.37-bin.jar  
``` $ cp -a mysql-connector-java-5.1.27-bin.jar /opt/modules/cdh/hive-0.13.1-cdh5.3.6/lib/ ```  

** 启动Hive  
本地启动  
``` $ bin/hive ```  
启动远程模式   本地启动  
``` $hive --service metastore &   #启动远程模式，否则你只能在本地登录 ```  

远程系统配置客户端连接Hive（必须有Hadoop环境）  
```
$ tar zxvf apache-hive-1.2.0-bin.tar.gz
$ mv apache-hive-1.2.0-bin /opt
$ vi hive-site.xml
<configuration>
<!--通过thrift方式连接hive-->
	<property>
		<name>hive.metastore.uris</name>
		<value>thrift://192.168.18.215:9083</value>
	</property>
</configuration>
```  
配置好连接信息，连接命令行：  
``` $ /opt/apache-hive-1.2.0-bin/bin/hive ```

** 查看Hive是否启动  
```
$ jps
2615 DFSZKFailoverController
30027 ResourceManager
29656 NameNode
25451 Jps
10270 HMaster
14975 RunJar     #会启动一个RunJar进程
```  
** 修改HDFS系统中关于Hive的一些目录权限  
``` $ /opt/modules/cdh/hadoop-2.5.0-cdh5.3.6/bin/hadoop fs -chmod 777 /tmp/ ```  
``` $ /opt/modules/cdh/hadoop-2.5.0-cdh5.3.6/bin/hadoop fs -chmod 777 /user/hive/warehouse ```  

** 显示数据库名称以及字段名称  
```
	<!-- 是否在当前客户端中显示查询出来的数据的字段名称 -->
	<property>
		<name>hive.cli.print.header</name>
		<value>true</value>
		<description>Whether to print the names of the columns in query output.</description>
	</property>

	<!-- 是否在当前客户端中显示当前所在数据库名称 -->
	<property>
		<name>hive.cli.print.current.db</name>
		<value>true</value>
		<description>Whether to include the current database in the Hive prompt.</description>
	</property>
```  
** 创建数据库  
``` hive> create database staff; ```

** 创建表操作  
``` hive> create table t1(eid int, name string, sex string) row format delimited fields terminated by '\t'; ```  

** 编辑一个需要导入数据的的文件  
```
1	Nick	male
2	Thomas	male
3	Alice	female
```  	
** 导入数据  
*** 从本地导入  
``` load data local inpath '文件路径' into table; ```  
*** 从HDFS系统导入  #无local  
``` load data inpath '文件路径' into table; ```  
