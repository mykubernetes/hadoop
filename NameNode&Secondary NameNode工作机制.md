NameNode工作机制
1 NameNode&Secondary NameNode工作机制

![image](https://github.com/mykubernetes/hadoop/blob/master/image/nn%E5%92%8Csnn.png)

1）第一阶段：namenode启动  
（1）第一次启动namenode格式化后，创建fsimage和edits文件。如果不是第一次启动，直接加载编辑日志和镜像文件到内存。  
（2）客户端对元数据进行增删改的请求  
（3）namenode记录操作日志，更新滚动日志。  
（4）namenode在内存中对数据进行增删改查  

2）第二阶段：Secondary NameNode工作  
	（1）Secondary NameNode询问namenode是否需要checkpoint。直接带回namenode是否检查结果。  
	（2）Secondary NameNode请求执行checkpoint。  
	（3）namenode滚动正在写的edits日志  
	（4）将滚动前的编辑日志和镜像文件拷贝到Secondary NameNode  
	（5）Secondary NameNode加载编辑日志和镜像文件到内存，并合并。  
	（6）生成新的镜像文件fsimage.chkpoint  
	（7）拷贝fsimage.chkpoint到namenode  
	（8）namenode将fsimage.chkpoint重新命名成fsimage  

3）web端访问SecondaryNameNode  
	（1）启动集群  
	（2）浏览器中输入：http://node01:50090/status.html  
	（3）查看SecondaryNameNode信息  
 

4）chkpoint检查时间参数设置  
（1）通常情况下，SecondaryNameNode每隔一小时执行一次。  
    [hdfs-default.xml]  
  [<property>  
    <name>dfs.namenode.checkpoint.period</name>  
    <value>3600</value>  
  </property>
 （2）一分钟检查一次操作次数，当操作次数达到1百万时，SecondaryNameNode执行一次。  
  <property>  
    <name>dfs.namenode.checkpoint.txns</name>  
    <value>1000000</value>  
  <description>操作动作次数</description>  
  </property>
  <property>  
    <name>dfs.namenode.checkpoint.check.period</name>  
    <value>60</value>  
  <description> 1分钟检查一次操作次数</description>  
  </property>
  
