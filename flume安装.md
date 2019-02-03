flume安装  
========
1、安装flume  
``` tar -zxf flume-ng-1.5.0-cdh5.3.6.tar.gz -C /opt/modules/cdh/ ```  
2、进入解压后的路径  
    cd /opt/modules/cdh/apache-flume-1.5.0-cdh5.3.6-bin/ ```  
3、进入配置文件路径并更改模板文件  
```
    cd conf
    mv flume-env.sh.template flume-env.sh
```  
4、修改配置java的环境变量  
```
    vim flume-env.sh
    export JAVA_HOME=/opt/modules/jdk1.8.0_121
```  
