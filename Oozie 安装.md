Oozie的安装与部署  
================
任务计划

1、解压Oozie  
``` $ tar -zxf /opt/softwares/oozie-4.0.0-cdh5.3.6.tar.gz -C /opt/modules/cdh/ ```  
2、Hadoop配置文件修改，完成后scp到其他机器节点  		
* core-site.xml  
```   
	<!-- Oozie Server的Hostname -->
	<property>
		<name>hadoop.proxyuser.admin.hosts</name>
		<value>*</value>
	</property>

	<!-- 允许被Oozie代理的用户组 -->
	<property>
		<name>hadoop.proxyuser.admin.groups</name>
		<value>*</value>
	 	</property>
```  
配置JobHistoryServer服务(必须)  
* mapred-site.xml  
```
    	<!-- 配置 MapReduce JobHistory Server 地址 ，默认端口10020 -->
	<property>
	        <name>mapreduce.jobhistory.address</name>
	        <value>node001:10020</value>
	</property>
	
	<!-- 配置 MapReduce JobHistory Server web ui 地址， 默认端口19888 -->
	<property>
		<name>mapreduce.jobhistory.webapp.address</name>
		<value>node001:19888</value>
	</property>
```  

* yarn-site.xml  
```
	<!-- 任务历史服务 -->
	<property> 
		<name>yarn.log.server.url</name> 
		<value>http://node001:19888/jobhistory/logs/</value> 
	</property> 
```  

完成后：记得scp同步到其他机器节点
			
3、开启Hadoop集群  
``` $ sh ~/start-cluster.sh ```  
提示：需要配合开启JobHistoryServer  

最好执行一个MR任务进行测试。  

4、解压hadooplibs  
``` $ tar -zxf /opt/modules/cdh/oozie-4.0.0-cdh5.3.6/oozie-hadooplibs-4.0.0-cdh5.3.6.tar.gz -C /opt/modules/cdh/ ```  
完成后Oozie目录下会出现hadooplibs目录  
			
5、在Oozie目录下创建libext目录  
``` $ mkdir libext/ ```  
			
6、拷贝一些依赖的Jar包  
1)将hadooplibs里面的jar包，拷贝到libext目录下  
``` $ cp -ra /opt/modules/cdh/oozie-4.0.0-cdh5.3.6/hadooplibs/hadooplib-2.5.0-cdh5.3.6.oozie-4.0.0-cdh5.3.6/* libext/ ```  
2)拷贝Mysql驱动包到libext目录下  
``` $ cp -a /opt/softwares/mysql-connector-java-5.1.27/mysql-connector-java-5.1.27-bin.jar /opt/modules/cdh/oozie-4.0.0-cdh5.3.6/libext/ ```

 7、将ext-2.2.zip拷贝到libext/目录下  
``` $ cp /opt/softwares/ext-2.2.zip libext/  ```
			
8、修改Oozie配置文件  
* oozie-site.xml  
```
** JDBC驱动
	oozie.service.JPAService.jdbc.driver
	com.mysql.jdbc.Driver

** Mysql的oozie数据库的配置
	oozie.service.JPAService.jdbc.url
	jdbc:mysql://192.168.122.20:3306/oozie

** 数据库用户名
	oozie.service.JPAService.jdbc.username
	root

** 数据库密码
	oozie.service.JPAService.jdbc.password
	123456

** 让Oozie引用Hadoop的配置文件
	oozie.service.HadoopAccessorService.hadoop.configurations
	真的就是这样：--> *=/opt/modules/cdh/hadoop-2.5.0-cdh5.3.6/etc/hadoop
```  
9、在Mysql中创建Oozie的数据库  
1)进入数据库  
``` $ mysql -uroot -p123456 ```  
2)创建oozie数据库  
``` $ mysql> create database oozie;  ```  
10、初始化Oozie的配置  
1)上传Oozie目录下的yarn.tar.gz文件到HDFS（提示：yarn.tar.gz文件会自行解压）  
``` $ bin/oozie-setup.sh sharelib create -fs hdfs://node01:8020 -locallib oozie-sharelib-4.0.0-cdh5.3.6-yarn.tar.gz ``` 
					
执行成功之后，去50070检查对应目录有没有文件生成。  
2)创建oozie.sql文件  
``` $ bin/oozie-setup.sh db create -run -sqlfile oozie.sql ```  
3)打包项目，生成war包  
``` $ bin/oozie-setup.sh prepare-war ```  
11、启动Oozie服务  
``` $ bin/oozied.sh start ```  
（关闭Oozie服务：$ bin/oozied.sh stop）  
12、访问Oozie的Web页面  
``` http://node01:11000/oozie ```
