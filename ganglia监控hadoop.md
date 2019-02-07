ganglia 安装及hadoop监控
======================


一、汉化版安装: 
```
# tar zxf ganglia-cn.tar.gz -C /usr/local/apache2/htdocs/
# cd /usr/local/apache2/htdocs
# mv ganglia-web-3.5.10 /ganglia	不用ganglia-web-3.5.10英文版本, 移动到/ganglia下备份
# mv ganglia-cn ganglia		
然后从上面的conf.php开始操作.  注意到ganglia-cn并没有以下配置项  
$conf['gweb_confdir'] = "/usr/local/apache2/htdocs/ganglia"; 
还要修改compiled, cache, views, conf, filter将gmetad_root更改为gweb_confdir  

#$conf['gmetad_root'] = "/var/lib/ganglia";
$conf['gmetad_root'] = "/usr/local/ganglia";
$conf['rrds'] = "${conf['gmetad_root']}/rrds";

# Where Dwoo (PHP templating engine) store compiled templates
$conf['dwoo_compiled_dir'] = "${conf['gweb_confdir']}/dwoo/compiled";
$conf['dwoo_cache_dir'] = "${conf['gweb_confdir']}/dwoo/cache";

# Where to store web-based configuration
$conf['views_dir'] = $conf['gweb_confdir'] . '/conf';
$conf['conf_dir'] = $conf['gweb_confdir'] . '/conf';

# Where to find filter configuration files, if not set filtering
# will be disabled
#$conf['filter_dir'] = "${conf['gweb_confdir']}/filters";

为了方便, 将已经配置好的ganglia打包, 部署到别的机器(比如生产机器)上时只需要用这个打包好的文件即可.  
# cd /usr/local/apache2/htdocs
# tar zcf ganglia.tar.gz ganglia 
不需要更改里面的内容. 但是要确保配置项正确  

1. ganglia的prefix=/usr/local/ganglia
2. rrds在/usr/local/ganglia下
2. 将ganglia.tar.gz解压到cd /usr/local/apache2/htdocs下

如果更改了ganglia-web在htdocs下的目录名, 下面的步骤中也要相应地修改: ganglia-web-3.5.10 → ganglia  
```  

二、主机安装前必装包检查  
```
# rpm -q gcc glibc glibc-common rrdtool rrdtool-devel expat expat-devel dejavu-lgc-sans-mono-fonts dejavu-sans-mono-fonts apr  apr-devel pcre pcre-devel libconfuse libconfuse-devel zlib zlib-devel 

gcc-4.4.7-4.el6.x86_64
glibc-2.12-1.132.el6.x86_64
glibc-common-2.12-1.132.el6.x86_64
package rrdtool is not installed
package rrdtool-devel is not installed
expat-2.0.1-11.el6_2.x86_64
package expat-devel is not installed
package dejavu-lgc-sans-mono-fonts is not installed
dejavu-sans-mono-fonts-2.30-2.el6.noarch
apr-1.3.9-5.el6_2.x86_64
package apr-devel is not installed
pcre-7.8-6.el6.x86_64
package pcre-devel is not installed
package libconfuse is not installed       libconfuse-2.7-4.el6.x86_64.rpm
package libconfuse-devel is not installed  libconfuse-devel-2.7-4.el6.x86_64.rpm
zlib-1.2.3-29.el6.x86_64
zlib-devel-1.2.3-29.el6.x86_64
```  
没有安装的在有条件访问互联网时可以通过 yum –y install  XXXX 来安装  
```
libconfuse，libconfuse-devel 无法通过yum 安装，需要下载rpm 包来进行安装
package libconfuse is not installed       libconfuse-2.7-4.el6.x86_64.rpm
package libconfuse-devel is not installed  libconfuse-devel-2.7-4.el6.x86_64.rpm
```


三、所有节点安装ganglia  
```
[root@master ganglia]# cp ganglia-3.6.0.tar.gz /tmp/ganglia/
# cd /ganglia
# tar zxf ganglia-3.6.0.tar.gz
# cd ganglia-3.6.0
#./configure --prefix=/usr/local/ganglia --with-gmetad --enable-gexec --with-python=/usr/bin/python2.6
#make && make install
```  

四、安装ganglia-web中文版（主节点）  
* conf.php  
```
# cp ganglia-asiainfo-linkage-cn.tar.gz /tmp/ganglia
# cd /ganglia
# tar -zxf ganglia-asiainfo-linkage-cn.tar.gz -C /usr/local/apache2/htdocs/ 
# cd /usr/local/apache2/htdocs/ganglia

# cp conf_default.php conf.php
# cd dwoo
# mkdir cache compiled    						配置临时目录
# chmow 777 cache compiled

# vi conf.php
$conf['gweb_root'] = dirname(__FILE__);
#$conf['gweb_confdir'] = "/var/lib/ganglia-web";
$conf['gweb_confdir'] = "/usr/local/apache2/htdocs/ganglia";
#$conf['gmetad_root'] = "/var/lib/ganglia";
$conf['gmetad_root'] = "/usr/local/ganglia";
$conf['rrds'] = "${conf['gmetad_root']}/rrds";			#mkdir /usr/local/ganglia/rrds
 
# vi header.php
session_start();
ini_set('date.timezone','PRC');
```  
```
# cd /usr/local/apache2/htdocs
# tar zcf ganglia.tar.gz ganglia

不需要更改里面的内容. 但是要确保配置项正确  
1. ganglia的prefix=/usr/local/ganglia
2. rrds在/usr/local/ganglia下
3. 将ganglia.tar.gz解压到cd /usr/local/apache2/htdocs下
```
如果更改了ganglia-web在htdocs下的目录名, 下面的步骤中也要相应地修改: ganglia  


5	Apache集成ganglia-web（主节点）		[httpd.conf]  
```
# vi /etc/httpd/httpd.conf		因为之前安装Apache时指定了--sysconfdir=/etc/httpd. 如果没有指定则在/usr/local/apach2/conf/httpd.conf
<IfModule dir_module>
    DirectoryIndex index.html index.php
    AddType application/x-httpd-php .php				可以不用指定, 因为在安装apache时已经添加过了
</IfModule>
Alias /ganglia "/usr/local/apache2/htdocs/ganglia"	配置使用别名访问
<Directory "/usr/local/apache2/htdocs/ganglia">
     AuthType Basic
     Options None
     AllowOverride None
     Order allow,deny
     Allow from all
</Directory>

启动apache2
/usr/local/apache2/bin/apachectl start
```  
6	配置gmetad（主节点）				[gmetad.conf]  
进入到ganglia-3.6.0解压的目录下  
```
# cd /ganglia/ganglia-3.6.0
# cp gmetad/gmetad.init /etc/init.d/gmetad
# vi /etc/init.d/gmetad
#GMETAD=/usr/sbin/gmetad
GMETAD=/usr/local/ganglia/sbin/gmetad

# cp gmetad/gmetad.conf /usr/local/ganglia/etc/
# vi /usr/local/ganglia/etc/gmetad.conf
data_source "hadoop" localhost
xml_port 8651
interactive_port 8652
rrd_rootdir "/usr/local/ganglia/rrds"

# chown -R nobody:nobody /usr/local/ganglia/rrds
# service gmetad restart		
# chkconfig --add gmetad
```  

7	所有节点配置gmond			[gmond.conf]  
```
# cd /ganglia/ganglia-3.6.0
# cp gmond/gmond.init /etc/init.d/gmond 
# vi /etc/init.d/gmond
#GMOND=/usr/sbin/gmond
GMOND=/usr/local/ganglia/sbin/gmond

# gmond/gmond -t > /usr/local/ganglia/etc/gmond.conf      	生成gmond配置文件, -t可以更改为--default_config
# vi /usr/local/ganglia/etc/gmond.conf
cluster {
  name = "hadoop"
  owner = "nobody"
  latlong = "unspecified"
  url = "unspecified"
}

# mkdir /usr/local/ganglia/lib64/ganglia/python_modules
# cp gmond/python_modules/*/*.py  /usr/local/ganglia/lib64/ganglia/python_modules
# mkdir /usr/local/ganglia/etc/conf.d
# cp gmond/python_modules/conf.d/*.pyconf  /usr/local/ganglia/etc/conf.d

# service gmond  restart		或者: /etc/init.d/gmond start
# chkconfig --add  gmond
```  




8	访问http://ip/ganglia  
如果提示404, 访问http://ip/ganglia、 不知道为什么别名没有起作用. 暂时先这么访问.  http://192.168.1.132/ganglia   







9	多节点安装ganglia  


执行  
主机安装前必装包检查  
所有节点安装ganglia  
所有节点配置gmond  

：在slave1, slaven上分别安装ganglia. 在./configure时确保能出现ganglia图案,然后make && make install  

192.168.1.132（master）作为主节点（数据收集节点，gmetad+gmond），192.168.1.133（slave1），192.168.1.n（slaven）作为数据监测节点（gmond）  
gmetad → meta -- 元数据		HDFS中的NameNode -- 名称节点 → 元数据节点 -- 管理数据节点的元数据， 因此gmetad可以看做管理gmond的元数据  
gmond → mon -- monitor -- 监测	监测自己主机的信息，发送给元数据节点gmetad。好比DataNode将自己主机上的数据块报告给NameNode  

详细配置样例（修改点用红色表示，被注视的用灰色表示）  
```
master: /usr/local/ganglia/etc/gmetad.conf
data_source "hadoop" 10 192.168.1.132
xml_port 8651
interactive_port 8652
rrd_rootdir "/usr/local/ganglia/rrds"

master: /usr/local/ganglia/etc/gmond.conf
globals {
  send_metadata_interval = 30 /*secs */
}
cluster {
  name = "hadoop"
  owner = "nobody"
  latlong = "unspecified"
  url = "unspecified"
}
udp_send_channel {
  #  mcast_join = 239.2.11.71
  host = 192.168.1.132
  port = 8649
  ttl = 1
}

udp_recv_channel {
  #  mcast_join = 239.2.11.71
  port = 8649
  #  bind = 239.2.11.71
  bind = 192.168.1.132
  retry_bind = true
}

slave1|slaven: /usr/local/ganglia/etc/gmond.conf
globals {
  send_metadata_interval = 30 /*secs */
}
cluster {
  name = "hadoop"
  owner = "nobody"
  latlong = "unspecified"
  url = "unspecified"
}
udp_send_channel {
  #  mcast_join = 239.2.11.71
  host = 192.168.1.132
  port = 8649
  ttl = 1
}

udp_recv_channel {
  # mcast_join = 239.2.11.71
  # port = 8649
  # bind = 239.2.11.71
  # retry_bind = true
}
tcp_accept_channel {
  #  port = 8649
  #  gzip_output = no
}
```  
master, slave1, slaven的globals, cluster, udp_send_channel的配置都是一样的.   
master的udp_recv_channel要指定bind和port, 而slave1, slaven的udp_recv_channel和tcp_accept_channel都要注释掉  

最后在master上重启service gmetad restart和service gmond restart  
在slave1, slaven上重启service gmond restart  

10	Ganglia监控Hadoop  
修改Hadoop集群所有节点的$HADOOP_HOME/etc/hadoop/hadoop-metrics2.properties文件: 
```
#*.sink.file.class=org.apache.hadoop.metrics2.sink.FileSink  
# default sampling period, in seconds  
#*.period=10

*.sink.ganglia.class=org.apache.hadoop.metrics2.sink.ganglia.GangliaSink31
*.sink.ganglia.period=10
  
*.sink.ganglia.slope=jvm.metrics.gcCount=zero,jvm.metrics.memHeapUsedM=both
*.sink.ganglia.dmax=jvm.metrics.threadsBlocked=70,jvm.metrics.memHeapUsedM=40
  
namenode.sink.ganglia.servers=master:8649
resourcemanager.sink.ganglia.servers= master:8649

datanode.sink.ganglia.servers= master:8649
nodemanager.sink.ganglia.servers= master:8649

maptask.sink.ganglia.servers= master:8649
reducetask.sink.ganglia.servers= master:8649
```  
在主节点上执行start-dfs.sh和start-yarn.sh. 然后访问http://ip/ganglia-web 查看metrics多了hadoop的相关度量信息.  
