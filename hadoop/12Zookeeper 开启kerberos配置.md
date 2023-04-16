# 一. 前言

这两天需要搞一个开启kerberos的zookeeper环境用于测试. 顺手记录一下.

# 二. 安装步骤

## 2.1 前置环境准备
```
JDK : jdk1.8
服务器 : CentOS 7.5
软件版本: zookeeper : 2.4.8
前置环境: kerberos 安装 参考文档
```

## 2.2 安装zookeeper

zookeeper安装我就不细说了, 先贴一个配置文件示例 , 后续的参数配置都是基于这个zoo.cfg配置文件的基础上进行修改.
```
zoo.cfg 配置
# The number of milliseconds of each tick
tickTime=2000
# The number of ticks that the initial
# synchronization phase can take
initLimit=10
# The number of ticks that can pass between
# sending a request and getting an acknowledgement
syncLimit=5
# the directory where the snapshot is stored.
# do not use /tmp for storage, /tmp here is just
# example sakes.
dataDir=/opt/tools/zookeeper-3.4.8/data
# the port at which the clients will connect
clientPort=2181
# the maximum number of client connections.
# increase this if you need to handle more clients
#maxClientCnxns=60
#
# Be sure to read the maintenance section of the
# administrator guide before turning on autopurge.
#
# http://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_maintenance
#
# The number of snapshots to retain in dataDir
#autopurge.snapRetainCount=3
# Purge task interval in hours
# Set to "0" to disable auto purge feature
#autopurge.purgeInterval=1
```

- 启动服务进行验证
```
进入ZK 目录 : cd ${ZOOKEEPER_HOME}/bin
服务端启动 : sh zkServer.sh start
客户端启动 : sh zkServer.sh -server master01:2181
```
确认可以正常访问之后, 进行如下操作.

## 2.3 设置kerberos账号.

kerberos账号我统一用的`zookeeper`用户做的服务端启动,服务端必须是`zookeeper`,否则启动的时候报错 !!!

申请指令& 导出keytab文件如下:
```
# 创建凭证
kadmin.local -q "addprinc -randkey zookeeper/master01@EXAMPLE.COM "

# 导出凭证对应的keytab文件
kadmin.local -q "xst  -k /opt/keytab/zookeeper.keytab  zookeeper/master01@EXAMPLE.COM "
```

## 2.4 设置krb5配置文件

- 默认路径 /etc/krb5.conf , 主要是通过krb5.conf文件可以连接到kdc服务器.
```
# Configuration snippets may be placed in this directory as well
includedir /etc/krb5.conf.d/

[logging]
 default = FILE:/var/log/krb5libs.log
 kdc = FILE:/var/log/krb5kdc.log
 admin_server = FILE:/var/log/kadmind.log

[libdefaults]
 dns_lookup_realm = false
 ticket_lifetime = 24h
 renew_lifetime = 7d
 forwardable = true
 rdns = false
 pkinit_anchors = FILE:/etc/pki/tls/certs/ca-bundle.crt
 default_realm = EXAMPLE.COM
# default_ccache_name = KEYRING:persistent:%{uid}

[realms]
 EXAMPLE.COM = {
   kdc = master01:88
   admin_server = master01:789
 }

[domain_realm]
 .example.com = EXAMPLE.COM
 example.com = EXAMPLE.COM
```

## 2.5 创建java.env配置

- 在`${ZOOKEEPER_HOME}/conf`目录下创建`java.env`文件. 文件内容如下:
```
export JVMFLAGS=" -Dsun.security.krb5.debug=true -Djava.security.auth.login.config=/opt/tools/zookeeper-3.4.8/conf/jaas.conf"
```
- 这个文件是全局配置, 只能存在一份.
- -Dsun.security.krb5.debug=true 这个参数是为了指定开启kerberos的调试. 生产环境建议去掉.
- Djava.security.auth.login.config 是java的安全认证文件.

## 2.6 创建jaas.conf配置

- 在`${ZOOKEEPER_HOME}/conf`目录下创建`jaas.conf`文件. 文件内容如下:

注意`keyTab`和`principal`参数的配置.
```
[root@master01 conf]# more jaas.conf
Server {
    com.sun.security.auth.module.Krb5LoginModule required
    useKeyTab=true
    keyTab="/opt/keytab/zookeeper.keytab"
    storeKey=true
    useTicketCache=false
    principal="zookeeper/master01@EXAMPLE.COM";
};

Client {
    com.sun.security.auth.module.Krb5LoginModule required
    useKeyTab=true
    keyTab="/opt/keytab/zookeeper.keytab"
    storeKey=true
    useTicketCache=false
    principal="zookeeper/master01@EXAMPLE.COM";
};
```

注意:
- Server 代表服务端的配置. 安全起见, 正常部署客户端的时候不需要配置这个.
- Client 代表client的配置,安全起见 , 正常不应该与Server配置在一起.

## 2.7 修改zoo.cfg 配置

增加几个参数 :
```
authProvider.1=org.apache.zookeeper.server.auth.SASLAuthenticationProvider
jaasLoginRenew=3600000
```

## 2.8. 启动服务
```
进入ZK 目录 : cd ${ZOOKEEPER_HOME}/bin
服务端启动 : sh zkServer.sh start
客户端启动 : sh zkCli.sh -server master01:2181 [一定要带主机名,否则报错!!! ]
```

## 2.9 日志位置

主要用于问题定位&联调,
- kdc服务日志 : 默认 /var/log/krb5kdc.log
- server端日志: 默认 在${ZOOKEEPER_HOME}\bin\zookeeper.out文件中.
- client端日志: 直接是在控制台输出的. 如果想看kerberos相关的信息, 查看 [2.5章节] 设置JVM参数 -Dsun.security.krb5.debug=true

# 三. 趟过的坑

## 3.1. zookeeper 必须以zookeeper用户启动…

配置jass.conf配置文件的时候, 服务端的凭证信息必须是`zookeeper`. 否则会出问题,比如 客户端验证不通过. !!!
```
Server {
    com.sun.security.auth.module.Krb5LoginModule required
    useKeyTab=true
    keyTab="/opt/keytab/zookeeper.keytab"
    storeKey=true
    useTicketCache=false
    principal="zookeeper/master01@EXAMPLE.COM";
};
```

## 3.2.zookeeper配置了kerberos之后，zkCli.sh 连接认证不通过

连接命令： `zkCli.sh`

- 报错如下：
```
WatchedEvent state:SyncConnected type:None path:null
2017-08-21 10:11:42,054 [myid:] - ERROR [main-SendThread(localhost:2181):ZooKeeperSaslClient@308] - An error: (java.security.PrivilegedActionException: javax.security.sasl.SaslException: GSS initiate failed [Caused by GSSException: No valid credentials provided (Mechanism level: Server not found in Kerberos database (7) - LOOKING_UP_SERVER)]) occurred when evaluating Zookeeper Quorum Member's  received SASL token. Zookeeper Client will go to AUTH_FAILED state.
2017-08-21 10:11:42,054 [myid:] - ERROR [main-SendThread(localhost:2181):ClientCnxn$SendThread@1072] - SASL authentication with Zookeeper Quorum member failed: javax.security.sasl.SaslException: An error: (java.security.PrivilegedActionException: javax.security.sasl.SaslException: GSS initiate failed [Caused by GSSException: No valid credentials provided (Mechanism level: Server not found in Kerberos database (7) - LOOKING_UP_SERVER)]) occurred when evaluating Zookeeper Quorum Member's  received SASL token. Zookeeper Client will go to AUTH_FAILED state.
```

- 终于在kdc的日志中显示的信息，如下
```
Aug 21 10:11:42 master krb5kdc[21935](info): TGS_REQ (6 etypes {18 17 16 23 1 3}) 192.168.1.144: LOOKING_UP_SERVER: authtime 0,  zkcli@EXAMPLE.COM for zookeeper/localhost@EXAMPLE.COM, Server not found in Kerberos database
```

- 原因分析：
```
1、在zookeeper的认证请求中，zookeeper端的默认principall应该是zookeeper/<hostname>@<realm>
2、当采用zkCli.sh 的方式请求中，默认的host应该是localhost
   因此在kdc中才会发现客户端的请求和  zookeeper/localhost@EXAMPLE.COM 这个principal进行认证，但是在kerberos的database中却没有这个principal。
```

- 解决方法：
使用zkCli.sh -server host:port 访问。 同时zookeeper配置文件中sever部分的principal必须为zookeeper/@
注意: 服务端一定要以zookeeper用户的凭证进行启动. 否则client验证是不通过的!!!

参考:
- https://zhangboyi.blog.csdn.net/article/details/115246149
- https://developer.aliyun.com/article/25626
- https://blog.51cto.com/1992zhong/1958018
