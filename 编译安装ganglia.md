关闭selinux  
```
setenforce 0
```  

安装依赖包  
```
yum install wget gcc pcre pcre-devel glibc glibc-common expat expat-devel pcre pcre-devel zlib cairo-devel libxml2-devel pango-devel pango libpng-devel libpng freetype freetype-devel libart_lgpl-devel apr-devel rrdtool rrdtool-devel apr dejavu-lgc-sans-mono-fonts dejavu-sans-mono-fonts zlib-devel
```  

安装confuse  
```
http://ftp.twaren.net/Unix/NonGNU//confuse/confuse-2.7.tar.gz
tar -zxf confuse-2.7.tar.gz  
cd confuse-2.7 
mkdir -p /opt/confuse/2.7/ 
./configure   --prefix=/opt/confuse/2.7/  CFLAGS=-fPIC --disable-nls  
make && make install 

增加如下内容
vim /etc/ld.so.conf.d/ctyun.conf  
/opt/confuse/2.7/lib
启用配置 
ldconfig
检查是否生效
ldconfig -v | grep libpython
ldconfig -v | grep  confuse
```  

编译安装ganglia (全部节点都要安装)  
```
tar -zxf ganglia-3.7.2.tar.gz  
cd ganglia-3.7.2  
./configure --prefix=/opt/ganglia/3.7.2/  --with-gmetad --enable-gexec  CFLAGS="-I/opt/confuse/2.7/include  -L/opt/confuse/2.7/lib"   
# make && make install
```  

安装ganglia-web (主节点安装)  
```
yum install httpd php
mkdir -p /var/www/html/ganglia
tar xvf ganglia-web-3.7.2.tar.gz -C /var/www/html/ganglia
cd /var/www/html/ganglia
mv ganglia-web-3.7.2/* /var/www/html/ganglia/
rm -rf ganglia-web-3.7.2/
```  

配置php  
```
cp conf_default.php conf.php 
vi conf.php
$conf['gweb_confdir'] = "/var/www/html/ganglia";             #ganglia-web的跟目录
$conf['gmetad_root'] = "/var/lib/ganglia";                   #gmetad端收集的数据存放的路径
```  

```
vi header.php  
<?php  
session_start();  
ini_set('date.timezone','PRC');      #修改时区为本地时区,就添加这一行
if (isset($_GET['date_only'])) {  
   $d = date("r");  
   echo $d;  
   exit(0);  
} 
```  

配置临时目录  
```
cd /var/www/html/ganglia/dwoo
mkdir cache
chmod 777 cache
mkdir compiled
chmod 777 compiled
```  

配置http  
```
vi /etc/httpd/conf/httpd.conf
ServerName localhost:80
systemctl start httpd
systemctl enable httpd
```  

配置gmetad (主节点配置)  
```
cd /opt/ganglia-3.7.2
cp ./gmetad/gmetad.init /etc/init.d/gmetad  
cp ./gmetad/gmetad.conf /opt/ganglia/3.6.0/etc/

vi /etc/init.d/gmetad  --修改如下内容
GMETAD=/opt/ganglia/3.7.2/sbin/gmetad 

vim /opt/ganglia/3.7.2/etc/gmetad.conf     -- 修改如下内容
data_source "cluster" localhost                 #集群名，加集群地址
```  

修改rrds数据目录所有者  
```
mkdir -p /var/lib/ganglia/rrds
chown -R nobody:nobody /var/lib/ganglia/rrds
```  

启动gmetad服务,并设为开机自动运行  
```
mkdir -p /opt/ganglia/3.7.2/var/run
service gmetad restart    
chkconfig --add gmetad
```  


配置gmond (全部节点配置)  
```
cd /opt/ganglia-3.7.2
cp ./gmond/gmond.init /etc/init.d/gmond
./gmond/gmond -t > /opt/ganglia/3.7.2/etc/gmond.conf

vim /etc/init.d/gmond      --修改如下内容
GMOND=/opt/ganglia/3.7.2/sbin/gmond

vim /opt/ganglia/3.7.2/etc/gmond.conf
 cluster {  
   name = "cluster"         #集群名 
   owner = "nobody" 
   latlong = "unspecified" 
   url = "unspecified" 
 } 

udp_send_channel {  
#  mcast_join =  239.2.11.71  /*注释掉组播*/  
  host = 192.168.101.66  /*发送给安装gmetad的机器*/  
  port = 8649  
  ttl = 1  
}  
  
udp_recv_channel {  #接受UDP包配置  
# mcast_join = 239.2.11.71  
  port = 8649   
# bind = 239.2.11.71  
} 
```  

复制python module到ganglia部署目录  
```
mkdir -p /opt/ganglia/3.7.2/lib64/ganglia/python_modules
cp ./gmond/python_modules/*/*.py /opt/ganglia/3.7.2/lib64/ganglia/python_modules/

cp ./gmond/python_modules/conf.d/*.pyconf
cp ./gmond/python_modules/conf.d/*.pyconf /opt/ganglia/3.7.2/etc/conf.d/
```  

启动gmond服务,并设为开机自动运行  
```
service gmond  restart
chkconfig --add  gmond
```  
